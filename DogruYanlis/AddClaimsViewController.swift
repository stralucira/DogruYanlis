//
//  AddClaimsViewController.swift
//  DogruYanlis
//
//  Created by Başar Oğuz on 24/07/16.
//  Copyright © 2016 basaroguz. All rights reserved.
//

import UIKit
import Eureka

//protocol DataEnteredDelegate: class {
//    
//    func userDidEnterInformation(_ claim: Claim)
//
//}

@IBDesignable
class AddClaimsViewController: FormViewController {

    //var addClaimsGroup = dispatch_group_create()
    
    let _greenColor = UIColor( red: 18/255, green: 136/255, blue: 2/255, alpha: 1.0 )
    let greenColor = UIColor( red: 18/255, green: 136/255, blue: 2/255, alpha: 1.0 ).cgColor
    
    let _redColor = UIColor( red: 156/255, green: 0/255, blue: 0/255, alpha: 1.0 )
    let redColor = UIColor( red: 156/255, green: 0/255, blue: 0/255, alpha: 1.0 ).cgColor
    
    var userName: String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //navigationController?.navigationBar.alpha = 0.5
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.navigationBar.tintColor = _greenColor
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        CheckRow.defaultCellSetup = { cell, row in cell.tintColor = self._greenColor }
        
        form
            //Header section
            +++ Section(){ section in
                let header = HeaderFooterView<AddClaimsLogoView>(.class)
                section.header = header
                section.header!.height = { 130 }
            }
            
            //Claim count slider section.
            +++ Section()
                <<< SliderRowInt("sliderRowTag") {
                    $0.title = "How many claims do you want to make?"
                    $0.minimumValue = 1
                    $0.maximumValue = 5
                    $0.steps = 4
                    $0.value = 1
                }
            
            //Claim input section
            +++ Section("Claims")
                <<< TextAreaRow("First Claim") {
                    $0.placeholder = "First Claim"
                    $0.textAreaHeight = .dynamic(initialTextViewHeight: 40)
                }
                <<< CheckRow() {
                    $0.title = "True"
                    $0.value = true
                }
                
                <<< TextAreaRow() {
                    $0.placeholder = "Second Claim"
                    $0.textAreaHeight = .dynamic(initialTextViewHeight: 40)
                    $0.hidden = Condition.function(["sliderRowTag"], { form in
                        let sliderRowValue = (form.rowBy(tag: "sliderRowTag") as? SliderRowInt)?.value
                        if (sliderRowValue! < 2) {
                            return true
                        } else {
                            return false
                        }
                    })
                }
                <<< CheckRow() {
                    $0.hidden = Condition.function(["sliderRowTag"], { form in
                        let sliderRowValue = (form.rowBy(tag: "sliderRowTag") as? SliderRowInt)?.value
                        if (sliderRowValue! < 2) {
                            return true
                        } else {
                            return false
                        }
                    })
                    $0.title = "True"
                    $0.value = true
                }
            
                <<< TextAreaRow() {
                    $0.placeholder = "Third Claim"
                    $0.textAreaHeight = .dynamic(initialTextViewHeight: 40)
                    $0.hidden = Condition.function(["sliderRowTag"], { form in
                        let sliderRowValue = (form.rowBy(tag: "sliderRowTag") as? SliderRowInt)?.value
                        if (sliderRowValue! < 3) {
                            return true
                        } else {
                            return false
                        }
                    })
                }
                <<< CheckRow() {
                    $0.hidden = Condition.function(["sliderRowTag"], { form in
                        let sliderRowValue = (form.rowBy(tag: "sliderRowTag") as? SliderRowInt)?.value
                        if (sliderRowValue! < 3) {
                            return true
                        } else {
                            return false
                        }
                    })
                    $0.title = "True"
                    $0.value = true
                }
        
                <<< TextAreaRow() {
                    $0.placeholder = "Fourth Claim"
                    $0.textAreaHeight = .dynamic(initialTextViewHeight: 40)
                    $0.hidden = Condition.function(["sliderRowTag"], { form in
                        let sliderRowValue = (form.rowBy(tag: "sliderRowTag") as? SliderRowInt)?.value
                        if (sliderRowValue! < 4) {
                            return true
                        } else {
                            return false
                        }
                    })
                }
                <<< CheckRow() {
                    $0.hidden = Condition.function(["sliderRowTag"], { form in
                        let sliderRowValue = (form.rowBy(tag: "sliderRowTag") as? SliderRowInt)?.value
                        if (sliderRowValue! < 4) {
                            return true
                        } else {
                            return false
                        }
                    })
                    $0.title = "True"
                    $0.value = true
                }
        
                <<< TextAreaRow() {
                    $0.placeholder = "Fifth Claim"
                    $0.textAreaHeight = .dynamic(initialTextViewHeight: 40)
                    $0.hidden = Condition.function(["sliderRowTag"], { form in
                        let sliderRowValue = (form.rowBy(tag: "sliderRowTag") as? SliderRowInt)?.value
                        if (sliderRowValue! < 5) {
                            return true
                        } else {
                            return false
                        }
                    })
                }
                <<< CheckRow() {
                    $0.hidden = Condition.function(["sliderRowTag"], { form in
                        let sliderRowValue = (form.rowBy(tag: "sliderRowTag") as? SliderRowInt)?.value
                        if (sliderRowValue! < 5) {
                            return true
                        } else {
                            return false
                        }
                    })
                    $0.title = "True"
                    $0.value = true
                }
            +++ Section()
                <<< ButtonRow() {
                    $0.title = "Submit"
                }
    }
    
    var successfulClaims: Int = 0
    var successMessage = ""
    var titleMessage = ""
    
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    //weak var delegate: DataEnteredDelegate? = nil
    
    func textFieldsValid() -> Bool {
        return true
    }
    
    //Clear function
    func clear() {
        
    }
    
}

class AddClaimsLogoView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let imageView = UIImageView(image: UIImage(named: "addYourClaims"))
        imageView.frame = CGRect(x: 0, y: -20, width: 500, height: 130)
        imageView.autoresizingMask = .flexibleWidth
        self.frame = CGRect(x: 0, y: -20, width: 500, height: 100)
        imageView.contentMode = .scaleAspectFill
        let label = UILabel(frame: CGRect(x:0, y:50, width:500, height: 20))
        label.text = "Make Your Claims"
        label.font = UIFont(name: "Helvetica-Bold", size: 25)
        label.textColor = UIColor.white
        label.center = CGPoint(x: 330, y: 65)
        imageView.addSubview(label)
        self.addSubview(imageView)
    }
    //Reperable init
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

