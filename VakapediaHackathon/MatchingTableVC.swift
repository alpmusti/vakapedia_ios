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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showTextOverlay("Yakındakiler listeleniyor...")
        findSimilarPoints()
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
        
        cell.nameLabel.text = "İsim : \(arrayOfListPoints[indexPath.row].name!) \(arrayOfListPoints[indexPath.row].surname!)"
        cell.dateLabel.text = "Tarih : \(arrayOfListPoints[indexPath.row].date_start!) - \(arrayOfListPoints[indexPath.row].date_end!)"
        cell.locationLabel.text = arrayOfListPoints[indexPath.row].location_name
        
        return cell
    }
    
    func findSimilarPoints(){
        let locationY = keyChain["location_x"]
        let locationX = keyChain["location_y"]
        
        Alamofire.request("http://localhost:1337/findSimilarLocation?location_x=\(locationX!)&location_y=\(locationY!)" , method: .get).responseJSON{
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
                                  id: json[i]["id"].stringValue,
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

}
