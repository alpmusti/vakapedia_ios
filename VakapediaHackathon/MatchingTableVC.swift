//
//  MatchingTableVC.swift
//  VakapediaHackathon
//
//  Created by Mustafa ALP on 25/03/2017.
//  Copyright © 2017 Mustafa ALP. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainAccess

struct ListPoint{
    var name : String!
    var surname : String!
    var location_x : Float!
    var location_y : Float!
    var location_name : String!
    var id : String!
    var date_start : String!
    var date_end : String!
}

class MatchingTableVC: UITableViewController {
    
    let keyChain : Keychain = Keychain(service: "Vakapedia")
    var arrayOfListPoints = [ListPoint]()
    var openerUserId : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if keyChain["location_x"] != nil && keyChain["location_y"] != nil{
            self.showWaitOverlayWithText("Yakındakiler listeleniyor...")
            findSimilarPoints()
        }else{
            showAlert(msg: "Haritadan bulunduğunuz yeri seçmelisiniz.")
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return arrayOfListPoints.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MatchingCell
        
        if(keyChain["userId"] != arrayOfListPoints[indexPath.row].id!){
            
            cell.nameLabel.text = "İsim : \(arrayOfListPoints[indexPath.row].name!) \(arrayOfListPoints[indexPath.row].surname!)"
            cell.dateLabel.text = "Tarih : \(arrayOfListPoints[indexPath.row].date_start!) - \(arrayOfListPoints[indexPath.row].date_end!)"
            cell.locationLabel.text = arrayOfListPoints[indexPath.row].location_name
        }else{
            arrayOfListPoints.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showMatched("\(arrayOfListPoints[indexPath.row].name!) kişisi ile gezmek istediğinize emin misiniz? Onaylayıp gitmediğiniz buluşmalar için güvenilirlik puanı kaybedebilirsiniz." ,arrayOfListPoints[indexPath.row])
        //print("opener user : \(openerUserId) joined user : \(keyChain["userId"])")
    }
    
    func findSimilarPoints(){
        //let locationY = keyChain["location_x"]
        //let locationX = keyChain["location_y"]
        
        //MARK : Test purposes
        Alamofire.request("http://localhost:1337/findSimilarLocation?location_x=41.07&location_y=29.03" , method: .get).responseJSON{
            response in
            switch response.result{
            case .success(let value) :
                let json = JSON(value)
                for i in 0..<json.count{
                    self.arrayOfListPoints.append(
                        ListPoint(name: json[i]["name"].stringValue,
                                  surname: json[i]["surname"].stringValue,
                                  location_x: json[i]["location_x"].floatValue,
                                  location_y: json[i]["location_y"].floatValue,
                                  location_name: json[i]["location_name"].stringValue,
                                  id: json[i]["user_id"].stringValue,
                                  date_start: json[i]["date_start"].stringValue,
                                  date_end: json[i]["date_end"].stringValue)
                    )
                }                
                self.tableView.reloadData()
                if(self.arrayOfListPoints.count == 0){
                    self.showAlert(msg: "Yakınlarınızda müsait olan herhangi bir kişi bulunamadı!")
                }
            case .failure(let err) :
                print(err)
            }
        }
        self.removeAllOverlays()
    }
    func showAlert(msg : String){
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func showMatched(_ msg : String , _ opener : ListPoint){
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: UIAlertActionStyle.default, handler: {action in self.setMatch(opener)}))
        alert.addAction(UIAlertAction(title : "Vazgeç", style : UIAlertActionStyle.destructive , handler:nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setMatch(_ opener : ListPoint){
        print("Opener : \(opener.date_start!)-\(opener.date_end!) \nJoiner : \(keyChain["date_start"]!) - \(keyChain["date_end"]!)")
        let joinerDateStart = keyChain["date_start"]
        let joinerDateEnd = keyChain["date_end"]
        
        let openerStart = timeFormat(opener.date_start) // A
        let openerEnd = timeFormat(opener.date_end) // B
        let joinerStart = timeFormat(joinerDateStart!) //C
        let joinerEnd = timeFormat(joinerDateEnd!) // D
        
        var commonStart : String?; var commonEnd : String?;
        
        if joinerStart > openerEnd || joinerEnd < openerStart{
            showAlert(msg : "Seçtiğiniz kişi ile saat aralıklarınız uyuşmamaktadır")
            return
        }else if (openerStart <= joinerStart && joinerEnd <= openerEnd) {
            commonStart = joinerDateStart
            commonEnd = joinerDateEnd
        }else if (openerStart <= joinerStart && openerEnd <= joinerEnd) {
            commonStart = joinerDateStart
            commonEnd = opener.date_end
        }else if (joinerStart <= openerStart && joinerEnd <= openerEnd) {
            commonStart = opener.date_start
            commonEnd = joinerDateEnd
        }else if (joinerStart <= openerStart && openerEnd <= joinerEnd) {
            commonStart = opener.date_start
            commonEnd = opener.date_end
        }
        print("\(commonStart!)-\(commonEnd!)")
        //parametreler : opener_user , joined_user , location_name , common_hours
        let paramsForTrip : Parameters = [
        "opener_user": opener.id,
        "joined_user" : keyChain["userId"]!,
        "location_name" : opener.location_name,
        "common_hours" : "\(commonStart!)-\(commonEnd!)"
        ]
        
        print(paramsForTrip)
        Alamofire.request("http://localhost:1337/joinTrip" , method : .post , parameters : paramsForTrip , encoding : JSONEncoding.default ).responseJSON{
            
            response in
            
            switch response.result{
            case .success(let value):
                print(value)
                let json = JSON(value)
                if json["result"] == 1 {
                    self.keyChain["toId"] = opener.id
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! UINavigationController
                    self.present(vc, animated: true, completion: nil)
                }
            case .failure(let err):
                print("Error while posting join Trip " , err)
                return
            }
        }
       
    }
    
    func timeFormat(_ fullDate : String) -> Int{
        var wholeDate = fullDate
        let splittedDate = wholeDate.characters.split{$0 == " "}.map(String.init)
        let startTime = splittedDate[1].characters.split{$0 == ":"}.map(String.init)
        
        // or simply:
        // let fullNameArr = fullName.characters.split{" "}.map(String.init)
        let start : Int = Int(
            startTime[0]
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        )!
        
        return start
    }
}
