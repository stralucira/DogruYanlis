//
//  SignInViewController.swift
//  DogruYanlis
//
//  Created by Başar Oğuz on 25/01/17.
//  Copyright © 2017 basaroguz. All rights reserved.
//

import UIKit
import Firebase
import Dispatch
import CoreFoundation
import Foundation

class SignInViewController: UIViewController, UITextFieldDelegate {

    var ref: FIRDatabaseReference!
    
    var sessionExistsGroup = DispatchGroup()
    var userExistsGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        self.gameNameField.delegate = self
        self.userNameField.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignInViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        gameNameField.text = nil
        userNameField.text = nil
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignInViewController.keyboardWillShowNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignInViewController.keyboardWillHideNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        // Remove memory overflow pointers.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBOutlet weak var gameNameField: UITextField!
    
    fileprivate var gameName: String {
        get {
            if (gameNameField.text != nil) {
                return (gameNameField.text?.lowercased())!
            }
            else {
                return ""
            }
        }
    }
    
    @IBOutlet weak var userNameField: UITextField!
    
    fileprivate var userName: String {
        get {
            if (userNameField.text != nil) {
                return userNameField.text!
            }
            else {
                return ""
            }

        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //textField.placeholder = ""
    }
    
    @IBAction func newGame(_ sender: UIButton) {
        if textFieldsValid() {
            gameExists(gameName) { (exists) in
                if exists {
                    self.joinGameInstead()
                } else {
                    self.dismiss(animated: true, completion: nil)
                    self.performSegue(withIdentifier: "startNewGame", sender: self)
                }
            }
        }
    }

    @IBAction func joinGame(_ sender: UIButton) {
        if textFieldsValid() {
            gameExists(gameName, completionHandler: { (gameExists) in
                if gameExists {
                    self.userExistsInGame(self.userName, completionHandler: { (userExists) in
                        if userExists {
                            self.presentUserExistsAlert()
                        } else {
                            self.dismiss(animated: true, completion: nil)
                            self.performSegue(withIdentifier: "joinGame", sender: self)
                        }
                    })
                } else {
                    self.presentGameNotFoundAlert()
                }
            })
        }
    }
    
    
    func gameExists(_ gameName: String, completionHandler: @escaping (Bool) -> ()) {
        var gameExists: Bool = false
        sessionExistsGroup.enter()
        ref.child("sessions").observeSingleEvent(of: .value,
            with: {(snapshot) in
                let sessions = snapshot.value as? NSDictionary
                if let sessions = sessions {
                    gameExists = sessions[gameName] != nil
                    self.sessionExistsGroup.leave()
                } else {
                    print("No sessions exist in database")
                    completionHandler(false)
                }
            }
        )
        sessionExistsGroup.notify(queue: DispatchQueue.main, execute: {
            completionHandler(gameExists)
        })
    }
    
    func userExistsInGame(_ userName: String , completionHandler: @escaping (Bool) -> ()) {
        var userExists: Bool = false
        userExistsGroup.enter()
        ref.child("sessions/\(gameName)/users").observeSingleEvent(of: .value,
            with: {(snapshot) in
                let users = snapshot.value as? NSDictionary
                if let users = users {
                    userExists = users[userName] != nil
                    self.userExistsGroup.leave()
                } else {
                    print("User does not exists in game")
                    completionHandler(false)
                }
            }
        )
        userExistsGroup.notify(queue: DispatchQueue.main, execute: {
            completionHandler(userExists)
        })
    }
    
    func presentUserExistsAlert() {
        let userExistsAlert = UIAlertController(title:"User Already Exists", message: "Please enter a different user name to join.", preferredStyle: UIAlertControllerStyle.alert)
        userExistsAlert.addAction(
            UIAlertAction(
                title: "Ok",
                style: UIAlertActionStyle.cancel,
                handler: nil
            )
        )
        self.present(userExistsAlert, animated: true, completion: nil)
    }

    func presentGameNotFoundAlert() {
        let gameDoesNotExistAlert = UIAlertController(title:"Game Not Found", message: "Please enter an active game name to join.", preferredStyle: UIAlertControllerStyle.alert)
        gameDoesNotExistAlert.addAction(
            UIAlertAction(
                title: "Ok",
                style: UIAlertActionStyle.cancel,
                handler: nil
            )
        )
        self.present(gameDoesNotExistAlert, animated: true, completion: nil)
    }
    
    func textFieldsValid() -> Bool {
        if self.gameName.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty {
            let gameNameEmptyAlert = UIAlertController(title: "Warning", message: "Game name cannot be empty", preferredStyle: UIAlertControllerStyle.alert)
            gameNameEmptyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(gameNameEmptyAlert, animated: true, completion: nil)
            return false
        } else if self.userName.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty {
            let userNameEmptyAlert = UIAlertController(title: "Warning", message: "Your name cannot be empty", preferredStyle: UIAlertControllerStyle.alert)
            userNameEmptyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(userNameEmptyAlert, animated: true, completion: nil)
            return false
        } else {
            return true
        }
    }
    
    func joinGameInstead() {
        let gameExistsAlert = UIAlertController(title:"Game Exists", message: "Do you want to join the game instead?", preferredStyle: UIAlertControllerStyle.alert)
        gameExistsAlert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: UIAlertActionStyle.cancel,
                handler: nil
            )
        )
        gameExistsAlert.addAction(
            UIAlertAction(
                title: "Join",
                style: UIAlertActionStyle.default,
                handler: {
                    (gameExistsAlert) in
                    self.dismiss(animated: true, completion: nil)
                    self.performSegue(withIdentifier: "joinGame", sender: self)
                }
            )
        )
        self.present(gameExistsAlert, animated: true, completion: nil)
    }
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let user = [
            "claimCount"    : 0,
            "score"         : 0,
        ]
        let userUpdate = [
            "sessions/\(self.gameName)/users/\(self.userName)" : user
        ]
        let metadata = [
            "admin"         : self.userName,
            "user count"    : 1,
            "locked"        : false,
            "claim count"   : 0
        ] as [String : Any]
        let metadataUpdate = [
            "sessions/\(self.gameName)/metadata" : metadata,
        ]
        if (segue.identifier == "startNewGame") {
            self.ref.updateChildValues(metadataUpdate)
            self.ref.updateChildValues(userUpdate)
        
            let navigationViewController = segue.destination as! UINavigationController
            let destinationViewController = navigationViewController.viewControllers[0] as! GameViewController
            
            destinationViewController.data.gameID = gameName
            destinationViewController.data.userName = userName
            destinationViewController.data.admin = userName
            destinationViewController.data.addPlayer(userName)
            
        } else if (segue.identifier == "joinGame") {
            self.ref.updateChildValues(userUpdate)
            
            let userCountReference = ref.child("sessions/\(self.gameName)/metadata/user count")
            
            userCountReference.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
                if let count = currentData.value as? Int {
                    currentData.value = count + 1
                }
                return FIRTransactionResult.success(withValue: currentData)
            }) { (error, committed, snapshot) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
            
            let navigationViewController = segue.destination as! UINavigationController
            let destinationViewController = navigationViewController.viewControllers[0] as! GameViewController
            
            destinationViewController.data.gameID = gameName
            destinationViewController.data.userName = userName
            destinationViewController.data.addPlayer(userName)
        }
    }
    
    func keyboardWillShowNotification(_ notification: Notification) {
        
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            
            self.bottomConstraint.constant = -keyboardFrame.size.height
            self.view.layoutIfNeeded()

        })
    }
    
    func keyboardWillHideNotification(_ notification: Notification) {
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            
            self.bottomConstraint.constant = 0
            self.view.layoutIfNeeded()
            
        })
        
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
}
