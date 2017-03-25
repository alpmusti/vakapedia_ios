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

    @IBOutlet weak var mailText: UILabel!
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var genderText: UILabel!
    let keyChain  = Keychain(service: "Vakapedia")
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let userId = keyChain["userId"]!
        let params : HTTPHeaders = ["id" : userId]
        Alamofire.request("http://localhost:1337/getUser" , parameters : params).responseJSON{
            response in
            switch response.result{
            case .success(let value) :
                print(value)
                let json = JSON(value)
                self.processFetchedUser(json)
            case . failure(let err) :
                print(err)
            }
        }
    }
    
    func processFetchedUser(_ userInfo : JSON){
        mailText.text = userInfo["email"].stringValue
        nameText.text = "\(userInfo["name"].stringValue) \(userInfo["surname"])"
        genderText.text = userInfo["gender"].stringValue
        
        if(userInfo["gender"].stringValue == "Erkek"){
            imageView.image = UIImage(named: "male")
        }else{
            imageView.image = UIImage(named: "female")
        }
    }
    @IBAction func editButtonTapped(_ sender: Any) {
        keyChain["isEditing"] = "1"
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")
        self.present(vc! , animated : true , completion : nil)
    }
}

