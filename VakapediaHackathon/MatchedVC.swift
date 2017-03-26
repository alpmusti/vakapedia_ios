//
//  MatchedVC.swift
//  VakapediaHackathon
//
//  Created by Mustafa ALP on 26/03/2017.
//  Copyright © 2017 Mustafa ALP. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainAccess

struct Match{
    var name : String!
    var surname : String!
    var location_name : String!
    var id : String!
    var commonHours : String!
}

class MatchedVC: UITableViewController {
    
    let keyChain : Keychain = Keychain(service : "Vakapedia")
    var currentUserId :String!
    var arrayOfMatches = [Match]()

    @IBAction func matchedBackButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let id =  keyChain["userId"]{
            currentUserId = id
        }
        print(currentUserId)
        
        Alamofire.request("http://localhost:1337/findJoinedTrips?joined_user=\(currentUserId!)" , method : .get ).responseJSON{
            response in
            switch response.result{
            case .success(let value) :
                let json = JSON(value)
                for i in 0..<json.count{
                    self.arrayOfMatches.append(
                        Match(name: json[i]["name"].stringValue,
                                  surname: json[i]["surname"].stringValue,
                                  location_name: json[i]["location_name"].stringValue,
                                  id: json[i]["user_id"].stringValue,
                                  commonHours : json[i]["common_hours"].stringValue
                        )
                    )
                }
                self.tableView.reloadData()
            case . failure(let err) :
                print(err)
            }
        }

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return arrayOfMatches.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "matchedCell") as! MatchedCell
        
        cell.matchedName.text = "\(arrayOfMatches[indexPath.row].name!) \(arrayOfMatches[indexPath.row].surname!)"
        cell.matchedLocation.text = "\(arrayOfMatches[indexPath.row].location_name!)"
        cell.matchedHours.text = "\(arrayOfMatches[indexPath.row].commonHours!)"
        return cell
    }

}
