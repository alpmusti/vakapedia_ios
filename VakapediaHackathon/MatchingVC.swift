//
//  MatchingVC.swift
//  VakapediaHackathon
//
//  Created by Mustafa ALP on 25/03/2017.
//  Copyright © 2017 Mustafa ALP. All rights reserved.
//

import UIKit

struct match{
    var name : String!
    var location : String?
    var date : String?
}

class MatchingVC: UIViewController , UITableViewDelegate , UITableViewDataSource{

    @IBOutlet weak var matchingTableView: UITableView!
    var matches = [match]()
        override func viewDidLoad() {
        super.viewDidLoad()
        matchingTableView.delegate = self
        matchingTableView.dataSource = self
    
        matches = [
                match(name: "Mustafa ALP", location: "Koaceli", date: "11.12.2017"),
                match(name: "Mustafa ALP3", location: "2Koaceli", date: "13.12.2017"),
                match(name: "Mustafa ALP2", location: "3Koaceli", date: "12.12.2017")
        ]
    
        matchingTableView.reloadData()
            
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "matchingCell") as! MatchingCell
        
        cell.nameLabel.text = matches[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlert("\(matches[indexPath.row].name!) kişisi ile gezmek istediğinize emin misiniz? Onaylayıp gitmediğiniz buluşmalar için güvenilirlik puanı kaybedebilirsiniz.")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func showAlert(_ msg : String){
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: UIAlertActionStyle.default, handler: {action in self.setMatch()}))
        alert.addAction(UIAlertAction(title : "Vazgeç", style : UIAlertActionStyle.destructive , handler:nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setMatch(){
        print("ok")
    }
}
