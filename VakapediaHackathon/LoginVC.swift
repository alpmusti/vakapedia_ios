//
//  MainVC.swift
//  VakapediaHackathon
//
//  Created by Mustafa ALP on 25/03/2017.
//  Copyright © 2017 Mustafa ALP. All rights reserved.
//

import UIKit
import Alamofire
import KeychainAccess
import SwiftOverlays
import SwiftyJSON

class LoginVC: UIViewController{

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    
    let baseURL = "http://localhost:1337"
    let keyChain : Keychain = Keychain(service: "Vakapedia")
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)        
        if keyChain["isFirst"] == "0"{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainVC") as! TabBarVC
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

       @IBAction func saveTapped(_ sender: Any) {
        
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainVC") as! TabBarVC
//        self.present(vc, animated: true, completion: nil)
//        return
        if (nameField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            warn("İsim alanı boş olamaz!")
            return
        }else if (lastNameField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!{
            warn("Soyisim alanı boş olamaz!")
            return
        }else if (emailField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!{
            warn("Email alanı boş olamaz!")
            return
        }else if !isValidEmail(testStr: emailField.text!) {
            warn("Geçersiz mail adresi girdiniz!")
            return
        }else{
            self.showTextOverlay("Hesap oluşturuluyor.")
            postAccountToServer(nameField.text! , lastNameField.text! , emailField.text!)
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func postAccountToServer(_ name : String , _ lastName : String , _ email : String){
        self.view.endEditing(true)
        let params : Parameters = [
            "name": name,
            "surname": lastName,
            "email": email
        ]
        
        Alamofire.request("\(baseURL)/createUser", method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON {
            response in
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                self.keyChain["userId"] = json["userId"].stringValue
                self.keyChain["isFirst"] = "0"
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainVC") as! TabBarVC
                self.present(vc , animated : true , completion : nil)
            case .failure(let err) :
                print(err)
            }
        }
        self.removeAllOverlays()
    }
    
    func warn(_ msg : String){
        let alert = UIAlertController(title: "Uyarı!", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
