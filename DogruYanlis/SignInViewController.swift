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
    
    var myGroup = dispatch_group_create()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        self.gameNameField.delegate = self
        self.userNameField.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignInViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        gameNameField.text = nil
        userNameField.text = nil
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignInViewController.keyboardWillShowNotification(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignInViewController.keyboardWillHideNotification(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
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
    
    private var gameName: String {
        get {
            if (gameNameField.text != nil) {
                return (gameNameField.text?.lowercaseString)!
            }
            else {
                return ""
            }
        }
    }
    
    @IBOutlet weak var userNameField: UITextField!
    
    private var userName: String {
        get {
            if (userNameField.text != nil) {
                return userNameField.text!
            }
            else {
                return ""
            }

        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        //textField.placeholder = ""
    }
    
    @IBAction func newGame(sender: UIButton) {
        if textFieldsValid() {
            gameExists(gameName) { (exists) in
                if exists {
                    self.joinGameInstead()
                } else {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    self.performSegueWithIdentifier("startNewGame", sender: self)
                }
            }
        }
    }

    @IBAction func joinGame(sender: UIButton) {
        if textFieldsValid() {
            gameExists(gameName, completionHandler: { (exists) in
                if exists {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    self.performSegueWithIdentifier("joinGame", sender: self)
                } else {
                    let gameDoesNotExistAlert = UIAlertController(title:"Game Not Found", message: "Please enter an active game name to join.", preferredStyle: UIAlertControllerStyle.Alert)
                    gameDoesNotExistAlert.addAction(
                        UIAlertAction(
                            title: "Ok",
                            style: UIAlertActionStyle.Cancel,
                            handler: nil
                        )
                    )
                    self.presentViewController(gameDoesNotExistAlert, animated: true, completion: nil)
                }
            })
        }
    }
    
    func gameExists(gameName: String, completionHandler: (Bool) -> ()) {
        var gameExists: Bool = false
        dispatch_group_enter(myGroup)
        ref.child("sessions").observeSingleEventOfType(.Value,
            withBlock: {(snapshot) in
                let sessions = snapshot.value as? NSDictionary
                if let sessions = sessions {
                    gameExists = sessions[gameName] != nil
                    dispatch_group_leave(self.myGroup)
                } else {
                    print("No sessions exist in database")
                    completionHandler(false)
                }
            }
        )
        dispatch_group_notify(myGroup, dispatch_get_main_queue(), {
            completionHandler(gameExists)
        })
    }
    
    func textFieldsValid() -> Bool {
        if self.gameName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).isEmpty {
            let gameNameEmptyAlert = UIAlertController(title: "Warning", message: "Game name cannot be empty", preferredStyle: UIAlertControllerStyle.Alert)
            gameNameEmptyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(gameNameEmptyAlert, animated: true, completion: nil)
            return false
        } else if self.userName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).isEmpty {
            let userNameEmptyAlert = UIAlertController(title: "Warning", message: "Your name cannot be empty", preferredStyle: UIAlertControllerStyle.Alert)
            userNameEmptyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(userNameEmptyAlert, animated: true, completion: nil)
            return false
        } else {
            return true
        }
    }
    
    func joinGameInstead() {
        let gameExistsAlert = UIAlertController(title:"Game Exists", message: "Do you want to join the game instead?", preferredStyle: UIAlertControllerStyle.Alert)
        gameExistsAlert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: UIAlertActionStyle.Cancel,
                handler: nil
            )
        )
        gameExistsAlert.addAction(
            UIAlertAction(
                title: "Join",
                style: UIAlertActionStyle.Default,
                handler: {
                    (gameExistsAlert) in
                    self.dismissViewControllerAnimated(true, completion: nil)
                    self.performSegueWithIdentifier("joinGame", sender: self)
                }
            )
        )
        self.presentViewController(gameExistsAlert, animated: true, completion: nil)
    }
    
//    func joinGameWithName(gameName: String) {
//
//
//    }
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
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
        ]
        let metadataUpdate = [
            "sessions/\(self.gameName)/metadata" : metadata,
        ]
        if (segue.identifier == "startNewGame") {
            self.ref.updateChildValues(metadataUpdate)
            self.ref.updateChildValues(userUpdate)
        
            let navigationViewController = segue.destinationViewController as! UINavigationController
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
                return FIRTransactionResult.successWithValue(currentData)
            }) { (error, committed, snapshot) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
            
            let navigationViewController = segue.destinationViewController as! UINavigationController
            let destinationViewController = navigationViewController.viewControllers[0] as! GameViewController
            
            destinationViewController.data.gameID = gameName
            destinationViewController.data.userName = userName
            destinationViewController.data.addPlayer(userName)
        }
    }
    
    func keyboardWillShowNotification(notification: NSNotification) {
        
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            
            self.bottomConstraint.constant = -keyboardFrame.size.height
            self.view.layoutIfNeeded()

        })
    }
    
    func keyboardWillHideNotification(notification: NSNotification) {
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            
            self.bottomConstraint.constant = 0
            self.view.layoutIfNeeded()
            
        })
        
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
}
