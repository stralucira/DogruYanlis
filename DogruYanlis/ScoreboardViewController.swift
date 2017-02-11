//
//  ScoreboardViewController.swift
//  DogruYanlis
//
//  Created by Başar Oğuz on 06/08/16.
//  Copyright © 2016 basaroguz. All rights reserved.
//

import UIKit
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


protocol ScoreboardDelegate: class {
    
    func increaseUserScore(_ name: String, byScore: Int)
    
}

class MyButton: UIButton {
    
    var tagString: String?
    
}

class ScoreboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        leaderboardTable.dataSource = self
        leaderboardTable.delegate = self
        
    }
    
    let greenColor = UIColor( red: 18/255, green: 136/255, blue: 2/255, alpha: 1.0 )
    
    weak var delegate: ScoreboardDelegate? = nil
    
    var scoreData: [String: Int]? = nil
    
    @IBOutlet weak var leaderboardTable: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scoreData!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        let nameLabel = UILabel(frame: CGRect(x:25, y:0, width:100, height:50))
        let scoreLabel = UILabel(frame: CGRect(x:300, y:0, width: 50, height: 50))
        
        let names = Array(scoreData!.keys)
        
        let addSinglePointButton = MyButton(frame: CGRect(x: 320, y: 0, width: 50, height: 50))
        let subtractSinglePointButton = MyButton(frame: CGRect(x: 240, y: 0, width: 50, height: 50))
        
        subtractSinglePointButton.setTitle("-", for: UIControlState())
        subtractSinglePointButton.setTitleColor(greenColor, for: UIControlState())
        subtractSinglePointButton.tagString = names[indexPath.row]
        subtractSinglePointButton.addTarget(self, action: #selector(ScoreboardViewController.minusPressed(_:)), for: .touchUpInside)
        
        addSinglePointButton.setTitle("+", for: UIControlState())
        addSinglePointButton.setTitleColor(greenColor, for: UIControlState())
        addSinglePointButton.tagString = names[indexPath.row]
        addSinglePointButton.addTarget(self, action: #selector(ScoreboardViewController.pressed(_:)), for: .touchUpInside)

        nameLabel.text = names[indexPath.row]
        scoreLabel.text = "\(scoreData![names[indexPath.row]]!)"
        
        cell.addSubview(scoreLabel)
        cell.addSubview(nameLabel)
        cell.addSubview(subtractSinglePointButton)
        cell.addSubview(addSinglePointButton)
       
        return cell
    }
    
    //Table height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func pressed(_ sender: MyButton!){
        let playerName = sender.tagString!
        scoreData![playerName]! += 1
        delegate?.increaseUserScore(playerName, byScore: 1)
        self.leaderboardTable.reloadData()
    }
    
    func minusPressed(_ sender: MyButton!){
        let playerName = sender.tagString!
        if(scoreData![playerName] > 0 ){
            scoreData![playerName]! -= 1
        }
        delegate?.increaseUserScore(playerName, byScore: -1)
        self.leaderboardTable.reloadData()
    }
    
}
