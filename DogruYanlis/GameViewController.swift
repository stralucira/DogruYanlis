//
//  GameViewController.swift
//  DogruYanlis
//
//  Created by Başar Oğuz on 25/07/16.
//  Copyright © 2016 basaroguz. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



class GameViewController: UIViewController, DataEnteredDelegate, ScoreboardDelegate {

    var data = GameData()
    
    lazy var ref: FIRDatabaseReference = FIRDatabase.database().reference()
    var usersRef: FIRDatabaseReference!
    
    var claimListenerHandle: UInt!
    var userCountListenerHandle: UInt!
    var userListenerHandle: UInt!
    
    var myGroup = DispatchGroup()
    var addClaimsGroup = DispatchGroup()
    
    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let sarilipSound = URL(fileURLWithPath: Bundle.main.path(forResource: "sarilip", ofType: "m4a")!)
        try! audioPlayer = AVAudioPlayer(contentsOf: sarilipSound, fileTypeHint: "m4a")
        audioPlayer.prepareToPlay()
        anilButton.isEnabled = false
        
        usersRef = ref.child("sessions/\(data.gameID)/users")
        
        gameNameLabel.text = " " + data.gameID
        
        if data.isAdmin() {
            userNameLabel.text = data.userName + " (Admin)"
        } else {
            userNameLabel.text = data.userName
            showClaimButton.isHidden = true
            anilButton.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        claimListenerHandle = ref.child("sessions/\(data.gameID)/metadata/claim count").observe(.value, with: {
            (snapshot: FIRDataSnapshot) in
            if let count = snapshot.value as? Int {
                self.remainingClaimValue = count
            }
        })
        
        userCountListenerHandle = ref.child("sessions/\(data.gameID)/metadata/user count").observe(.value, with: {
            (snapshot: FIRDataSnapshot) in
            if let count = snapshot.value as? Int {
                self.sessionInfo.text = "\(count) Users in game"
            }
        })
        
        userListenerHandle = ref.child("sessions/\(data.gameID)/users").observe(.childAdded, with: {
            (snapshot: FIRDataSnapshot) in
            
            self.data.addPlayer(snapshot.key)
            
            // Maybe call a .Value first, then .ChildAdded inside this block?
            // Could make .ChildAdded trigger only once!
            // Test on multiple devices.
    
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        ref.removeObserver(withHandle: claimListenerHandle)
    }

    var claimOwnerString: String?
    
    var claimTruthBool: Bool?
    
    @IBOutlet weak var remainingClaims: UILabel!
    
    fileprivate var remainingClaimValue: Int {
        
        get{
            let remainingClaimValueString = remainingClaims.text!.components(separatedBy: " ")
            return Int(remainingClaimValueString[0])!
        }
        set{
            remainingClaims.text = String(newValue) + " Claims Left"
        }
    }

    @IBOutlet weak var anilButton: UIButton!
    @IBOutlet weak var claimTruth: UILabel!
    @IBOutlet weak var claimOwner: UILabel!
    @IBOutlet weak var claimLabel: UILabel!
    @IBOutlet weak var showClaimButton: UIButton!
    
    @IBOutlet weak var sessionInfo: UILabel!
    
    @IBOutlet weak var gameNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBAction func newGame(_ sender: UIBarButtonItem) {
        
        let newGameAlert = UIAlertController(title: "Quit", message: "Are you sure you want to quit game?", preferredStyle: UIAlertControllerStyle.alert)
        
        newGameAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(action: UIAlertAction!) in
            self.data.clear()
            self.clearDisplays()
            self.navigationController?.dismiss(animated: true, completion: nil)
            self.performSegue(withIdentifier: "quitGame", sender: self)
        }))
        
        newGameAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(action: UIAlertAction!) in
        }))
        
        present(newGameAlert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "makeYourClaims" {
            let secondViewController = segue.destination as! AddClaimsViewController
            secondViewController.userName = self.data.userName
            secondViewController.delegate = self
        } else if segue.identifier == "showScoreboard" {
            let second = segue.destination as! ScoreboardViewController
            second.delegate = self
            second.scoreData = data.scores
        }
    }

    @IBAction func showLeaderboardButton(_ sender: UIBarButtonItem) {
        //Currently does nothing.
    }
    
    //Used for DataEnteredDelegate
    func userDidEnterInformation(_ claim: Claim) {
        
        //data.addClaim(claim.name, sentence: claim.sentence, truthfulness: claim.truthfulness)
        // Single player artifact.
        //data.addPlayer(claim.name)
        
        var index : Int = 0
        
        let claimToBePushed = [
            "user name"     : data.userName,
            "sentence"      : claim.sentence,
            "truthfulness"  : claim.truthfulness
        ] as [String : Any]
        
        let claimUpdate = [
            "sessions/\(self.data.gameID)/claims/\(index)" : claimToBePushed
        ]
        self.ref.updateChildValues(claimUpdate)
        
        let claimsRef = ref.child("sessions/\(self.data.gameID)/claims")
        let claimCountRef = ref.child("sessions/\(self.data.gameID)/metadata/claim count")
        
        claimsRef.observeSingleEvent(of: .value, with: {
            (snapshot) in
            index = snapshot.value! as! Int
            
            let claimUpdate = [
                "sessions/\(self.data.gameID)/claims/\(index)" : claimToBePushed
            ]
            self.ref.updateChildValues(claimUpdate)
            
            claimCountRef.runTransactionBlock { (currentData: FIRMutableData) -> FIRTransactionResult in
                if let count = currentData.value as? Int {
                    currentData.value = count + 1
                    return FIRTransactionResult.success(withValue: currentData)
                } else {
                    return FIRTransactionResult.success(withValue: currentData)
                }
            }
        })
        
        //Removed this.
        //remainingClaimValue = data.claimCount
    }
    
    func increaseUserScore(_ user: String, byScore score: Int){
        if (score == 1) {
            data.addPoint(user)
        } else if (score == 2) {
            data.addYilanPoint(user)
        } else if (score == -1) {
            if (data.scores[user] > 0 ){
                data.subtractPoint(user)
            }
        }
    }
    
    @IBAction func showClaim(_ sender: UIButton) {
        
        if (data.claimCount != 0 ) {
            claimOwner.text = nil
            claimTruth.text = nil
        
            let claimToBeShowed = data.randomClaim()
        
            claimLabel.text = "\"\(claimToBeShowed.sentence)\""
        
            claimOwnerString = claimToBeShowed.name
            claimTruthBool = claimToBeShowed.truthfulness
        
            remainingClaimValue = data.claimCount
            
            audioPlayer.play()
        
            anilButton.isEnabled = true
            showClaimButton.isEnabled = false
        }
    }
    
    @IBAction func reveal(_ sender: AnyObject) {
        if let temp = claimOwnerString{
            claimOwner.text = " - \(temp)"
        }
        if let tempBool = claimTruthBool {
            
            if (tempBool){
                claimTruth.textColor = UIColor.green
                claimTruth.text = "True"
            } else {
                claimTruth.textColor = UIColor.red
                claimTruth.text = "False"
            }
        }
        showClaimButton.isEnabled = true
        anilButton.isEnabled = false
    }
    
    func clearDisplays() {
        remainingClaimValue = 0
        claimTruth.text = ""
        claimLabel.text = "Welcome to Sarılıp Yılana"
        claimOwner.text = ""
        claimOwnerString = nil
        claimTruthBool = nil
        
        anilButton.isEnabled = false
        showClaimButton.isEnabled = true
    }
}
