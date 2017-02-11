//
//  AddClaimsViewController.swift
//  DogruYanlis
//
//  Created by Başar Oğuz on 24/07/16.
//  Copyright © 2016 basaroguz. All rights reserved.
//

import UIKit

protocol DataEnteredDelegate: class {
    
    func userDidEnterInformation(claim: Claim)

}

@IBDesignable
class AddClaimsViewController: UIViewController {

    let _greenColor = UIColor( red: 18/255, green: 136/255, blue: 2/255, alpha: 1.0 )
    let greenColor = UIColor( red: 18/255, green: 136/255, blue: 2/255, alpha: 1.0 ).CGColor
    
    let _redColor = UIColor( red: 156/255, green: 0/255, blue: 0/255, alpha: 1.0 )
    let redColor = UIColor( red: 156/255, green: 0/255, blue: 0/255, alpha: 1.0 ).CGColor
    
    let mySwitch = SevenSwitch(frame: CGRectZero)
    let mySwitch2 = SevenSwitch(frame: CGRectZero)
    let mySwitch3 = SevenSwitch(frame: CGRectZero)
    
    var userName: String = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    
        mySwitch.frame = CGRectMake(290, 150, 80, 33)
        mySwitch2.frame = CGRectMake(290, 201, 80, 33)
        mySwitch3.frame = CGRectMake(290, 252, 80, 33)
        switchHandler(mySwitch)
        switchHandler(mySwitch2)
        switchHandler(mySwitch3)
        mySwitch.addTarget(self, action: #selector(AddClaimsViewController.switchOne(_:)), forControlEvents: UIControlEvents.ValueChanged)
        mySwitch2.addTarget(self, action: #selector(AddClaimsViewController.switchTwo(_:)), forControlEvents: UIControlEvents.ValueChanged)
        mySwitch3.addTarget(self, action: #selector(AddClaimsViewController.switchThree(_:)), forControlEvents: UIControlEvents.ValueChanged)

        self.view.addSubview(mySwitch)
        self.view.addSubview(mySwitch2)
        self.view.addSubview(mySwitch3)
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddClaimsViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        sentenceOne.layer.cornerRadius = 10.0
        sentenceOne.layer.masksToBounds = true
        sentenceOne.layer.borderColor = greenColor
        sentenceOne.layer.borderWidth = 2
        
        sentenceTwo.layer.cornerRadius = 10.0
        sentenceTwo.layer.masksToBounds = true
        sentenceTwo.layer.borderColor = greenColor
        sentenceTwo.layer.borderWidth = 2
        
        sentenceThree.layer.cornerRadius = 10.0
        sentenceThree.layer.masksToBounds = true
        sentenceThree.layer.borderColor = greenColor
        sentenceThree.layer.borderWidth = 2
        
    }
    
    var successfulClaims: Int = 0
    var successMessage = ""
    var titleMessage = ""
    
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    weak var delegate: DataEnteredDelegate? = nil
    
    @IBOutlet weak var sentenceOne: UITextField!
    
    func switchOne(sender: SevenSwitch) {
        if ( sender.isOn() == false ) {
            sentenceOne.layer.borderColor = redColor
        } else {
            sentenceOne.layer.borderColor = greenColor
        }
    }
    
    @IBOutlet weak var sentenceTwo: UITextField!
    
    @IBAction func switchTwo(sender: SevenSwitch) {
        
        if ( sender.isOn() == false ) {
            sentenceTwo.layer.borderColor = redColor
        } else {
            sentenceTwo.layer.borderColor = greenColor
        }
    }
    @IBOutlet weak var sentenceThree: UITextField!
    
    @IBAction func switchThree(sender: SevenSwitch) {
        
        if ( sender.isOn() == false ) {
            sentenceThree.layer.borderColor = redColor
        } else {
            sentenceThree.layer.borderColor = greenColor
        }
        
    }
    
    @IBAction func save(sender: UIButton) {
        if textFieldsValid() {
            if ((sentenceOne.text !=  "") || (sentenceTwo.text !=  "") || (sentenceThree.text !=  "")){
            
                if (sentenceOne.text != "") {
                    delegate?.userDidEnterInformation(Claim(name: userName, sentence: sentenceOne.text!, truthfulness: mySwitch.isOn()))
                    successfulClaims += 1
                }
        
                if (sentenceTwo.text != "") {
                    delegate?.userDidEnterInformation(Claim(name: userName, sentence: sentenceTwo.text!, truthfulness: mySwitch2.isOn()))
                    successfulClaims += 1
                }
        
                if (sentenceThree.text != "") {
                    delegate?.userDidEnterInformation(Claim(name: userName, sentence: sentenceThree.text!, truthfulness: mySwitch3.isOn()))
                    successfulClaims += 1
                }
            
                if (successfulClaims == 1) {
                    successMessage = "Your 1 claim has been submitted."
                    titleMessage = "Gratz \(userName)!"
                
                } else {
                    successMessage = "Your \(successfulClaims) claims has been submitted."
                    titleMessage = "Gratz \(userName)!"
                }
                
                let successAlertController = UIAlertController(
                    title: titleMessage,
                    message: successMessage,
                    preferredStyle: UIAlertControllerStyle.Alert
                )
                successAlertController.addAction(
                    UIAlertAction(
                        title: "Okay",
                        style: UIAlertActionStyle.Default,
                        handler: { (successAlertController) in
                            _ = self.navigationController?.popViewControllerAnimated(true)
                        }
                    )
                )
                self.presentViewController(successAlertController, animated: true, completion: nil)
                clear()
            }
        }
    }
    
    func textFieldsValid() -> Bool {
        if (((sentenceOne.text == "") && (sentenceTwo.text == "")) && (sentenceThree.text == "")) {
            
            let claimNotEnteredAlertController = UIAlertController(title: "", message:
                "You have not entered any claims!", preferredStyle: UIAlertControllerStyle.Alert)
            claimNotEnteredAlertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(claimNotEnteredAlertController, animated: true, completion: nil)
            return false
        } else {
            return true
        }
    }

    
    func switchHandler(mySwitch: SevenSwitch) -> Void {
        mySwitch.offLabel.text = "FALSE"
        mySwitch.offLabel.textColor = UIColor.whiteColor()
        mySwitch.onLabel.textColor = UIColor.whiteColor()
        mySwitch.inactiveColor =  _redColor
        mySwitch.activeColor = _greenColor
        mySwitch.tintColor = UIColor.clearColor()
        mySwitch.thumbImage = UIImage(named: "iconsnake")
        mySwitch.on = true
        mySwitch.onLabel.text = "TRUE"
    }
    
    //Clear function
    func clear() {
        
        sentenceOne.text = nil
        sentenceTwo.text = nil
        sentenceThree.text = nil
        
        mySwitch.on = true
        mySwitch2.on = true
        mySwitch3.on = true
        
        sentenceOne.layer.borderColor = greenColor
        sentenceTwo.layer.borderColor = greenColor
        sentenceThree.layer.borderColor = greenColor
        
        successfulClaims = 0
        
    }
    
}
