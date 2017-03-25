//
//  FirstViewController.swift
//  VakapediaHackathon
//
//  Created by Mustafa ALP on 24/03/2017.
//  Copyright © 2017 Mustafa ALP. All rights reserved.
//

import UIKit
import Alamofire
import KeychainAccess
import SwiftyJSON

class ProfileVC: UIViewController {

    let keyChain  = Keychain(service: "Vakapedia")
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let userId = keyChain["userId"]!
        let params : Parameters = ["id" : userId]
        Alamofire.request("http://localhost:1337/getUser" , method : .post ,parameters : params  , encoding: JSONEncoding.default ).responseJSON{
            response in
            switch response.result{
            case .success(let value) :
                print(value)
            case . failure(let err) :
                print(err)
            }
        }
    }
    
}

