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


class GameViewController: UIViewController, DataEnteredDelegate, ScoreboardDelegate {

    var data = GameData()
    
    lazy var ref: FIRDatabaseReference = FIRDatabase.database().reference()
    var usersRef: FIRDatabaseReference!
    
    var claimListenerHandle: UInt!
    var userCountListenerHandle: UInt!
    var userListenerHandle: UInt!
    
    var myGroup = dispatch_group_create()
    var addClaimsGroup = dispatch_group_create()
    
    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let sarilipSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("sarilip", ofType: "m4a")!)
        try! audioPlayer = AVAudioPlayer(contentsOfURL: sarilipSound, fileTypeHint: "m4a")
        audioPlayer.prepareToPlay()
        anilButton.enabled = false
        
        usersRef = ref.child("sessions/\(data.gameID)/users")
        
        gameNameLabel.text = " " + data.gameID
        
        if data.isAdmin() {
            userNameLabel.text = data.userName + " (Admin)"
        } else {
            userNameLabel.text = data.userName
            showClaimButton.hidden = true
            anilButton.hidden = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        claimListenerHandle = ref.child("sessions/\(data.gameID)/metadata/claim count").observeEventType(.Value, withBlock: {
            (snapshot: FIRDataSnapshot) in
            if let count = snapshot.value as? Int {
                self.remainingClaimValue = count
            }
        })
        
        userCountListenerHandle = ref.child("sessions/\(data.gameID)/metadata/user count").observeEventType(.Value, withBlock: {
            (snapshot: FIRDataSnapshot) in
            if let count = snapshot.value as? Int {
                self.sessionInfo.text = "\(count) Users in game"
            }
        })
        
        userListenerHandle = ref.child("sessions/\(data.gameID)/users").observeEventType(.ChildAdded, withBlock: {
            (snapshot: FIRDataSnapshot) in
            
            self.data.addPlayer(snapshot.key)
            
            // Maybe call a .Value first, then .ChildAdded inside this block?
            // Could make .ChildAdded trigger only once!
            // Test on multiple devices.
    
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        ref.removeObserverWithHandle(claimListenerHandle)
    }

    var claimOwnerString: String?
    
    var claimTruthBool: Bool?
    
    @IBOutlet weak var remainingClaims: UILabel!
    
    private var remainingClaimValue: Int {
        
        get{
            let remainingClaimValueString = remainingClaims.text!.componentsSeparatedByString(" ")
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
    
    @IBAction func newGame(sender: UIBarButtonItem) {
        
        let newGameAlert = UIAlertController(title: "Quit", message: "Are you sure you want to quit game?", preferredStyle: UIAlertControllerStyle.Alert)
        
        newGameAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: {(action: UIAlertAction!) in
            self.data.clear()
            self.clearDisplays()
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            self.performSegueWithIdentifier("quitGame", sender: self)
        }))
        
        newGameAlert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: {(action: UIAlertAction!) in
        }))
        
        presentViewController(newGameAlert, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "makeYourClaims" {
            let secondViewController = segue.destinationViewController as! AddClaimsViewController
            secondViewController.userName = self.data.userName
            secondViewController.delegate = self
        } else if segue.identifier == "showScoreboard" {
            let second = segue.destinationViewController as! ScoreboardViewController
            second.delegate = self
            second.scoreData = data.scores
        }
    }

    @IBAction func showLeaderboardButton(sender: UIBarButtonItem) {
        //Currently does nothing.
    }
    
    //Used for DataEnteredDelegate
    func userDidEnterInformation(claim: Claim) {
        
        //data.addClaim(claim.name, sentence: claim.sentence, truthfulness: claim.truthfulness)
        // Single player artifact.
        //data.addPlayer(claim.name)
        
        var index : Int = 0
        
        let claimToBePushed = [
            "user name"     : data.userName,
            "sentence"      : claim.sentence,
            "truthfulness"  : claim.truthfulness
        ]
        
        let claimUpdate = [
            "sessions/\(self.data.gameID)/claims/\(index)" : claimToBePushed
        ]
        self.ref.updateChildValues(claimUpdate)
        
        let claimsRef = ref.child("sessions/\(self.data.gameID)/claims")
        let claimCountRef = ref.child("sessions/\(self.data.gameID)/metadata/claim count")
        
        claimsRef.observeSingleEventOfType(.Value, withBlock: {
            (snapshot) in
            index = snapshot.value! as! Int
            
            let claimUpdate = [
                "sessions/\(self.data.gameID)/claims/\(index)" : claimToBePushed
            ]
            self.ref.updateChildValues(claimUpdate)
            
            claimCountRef.runTransactionBlock { (currentData: FIRMutableData) -> FIRTransactionResult in
                if let count = currentData.value as? Int {
                    currentData.value = count + 1
                    return FIRTransactionResult.successWithValue(currentData)
                } else {
                    return FIRTransactionResult.successWithValue(currentData)
                }
            }
        })
        
        //Removed this.
        //remainingClaimValue = data.claimCount
    }
    
    func increaseUserScore(user: String, byScore score: Int){
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
    
    @IBAction func showClaim(sender: UIButton) {
        
        if (data.claimCount != 0 ) {
            claimOwner.text = nil
            claimTruth.text = nil
        
            let claimToBeShowed = data.randomClaim()
        
            claimLabel.text = "\"\(claimToBeShowed.sentence)\""
        
            claimOwnerString = claimToBeShowed.name
            claimTruthBool = claimToBeShowed.truthfulness
        
            remainingClaimValue = data.claimCount
            
            audioPlayer.play()
        
            anilButton.enabled = true
            showClaimButton.enabled = false
        }
    }
    
    @IBAction func reveal(sender: AnyObject) {
        if let temp = claimOwnerString{
            claimOwner.text = " - \(temp)"
        }
        if let tempBool = claimTruthBool {
            
            if (tempBool){
                claimTruth.textColor = UIColor.greenColor()
                claimTruth.text = "True"
            } else {
                claimTruth.textColor = UIColor.redColor()
                claimTruth.text = "False"
            }
        }
        showClaimButton.enabled = true
        anilButton.enabled = false
    }
    
    func clearDisplays() {
        remainingClaimValue = 0
        claimTruth.text = ""
        claimLabel.text = "Welcome to Sarılıp Yılana"
        claimOwner.text = ""
        claimOwnerString = nil
        claimTruthBool = nil
        
        anilButton.enabled = false
        showClaimButton.enabled = true
    }
}
