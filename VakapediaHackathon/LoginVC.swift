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
import Firebase

class LoginVC: UIViewController , UIPickerViewDelegate , UIPickerViewDataSource{

    @IBOutlet weak var genderPicker: UIPickerView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    var selectedGender : String!
    
    let baseURL = "http://localhost:1337"
    let keyChain : Keychain = Keychain(service: "Vakapedia").synchronizable(true)
    let genders = ["Kadın" , "Erkek"]
    var editingProfile : Bool = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if keyChain["isEditing"] == "1"{
            editingProfile = true
            self.keyChain["isFirst"] = "1"
        }else if keyChain["isFirst"] == "0"{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainVC") as! TabBarVC
            self.present(vc, animated: true, completion: nil)
        }
        genderPicker.delegate = self
        genderPicker.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func saveTapped(_ sender: Any) {
        self.view.endEditing(true)
        if !editingProfile{
            self.showTextOverlay("Hesap oluşturuluyor...")
        }else{
            self.showTextOverlay("Hesabınız güncelleniyor...")
        }
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
        }else if editingProfile{
            updateAccountToServer(nameField.text! , lastNameField.text! , emailField.text! , selectedGender)
        }else{
            postAccountToServer(nameField.text! , lastNameField.text! , emailField.text! , selectedGender)
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func postAccountToServer(_ name : String , _ lastName : String , _ email : String , _ gender : String){
        self.view.endEditing(true)
        let params : Parameters = [
            "name": name,
            "surname": lastName,
            "email": email,
            "gender": gender
        ]
        
        FIRAuth.auth()?.createUser(withEmail: email, password: "1234567", completion: {(user : FIRUser? , err) in
            if err != nil{
                print(err ?? "hata mesajı alınamadı")
                return
            }
            
            guard let uid = user?.uid else{
                return
            }
            
            let ref = FIRDatabase.database().reference(fromURL: "https://hackathon-vakapedia.firebaseio.com/")
            let usersRef = ref.child("users").child(uid)
            let values = ["name": name , "email": email]
            usersRef.updateChildValues(values , withCompletionBlock : {
                (error ,ref ) in
                if error != nil{
                    print(error)
                    return
                }
                print("Saved user successfully")
            })
        })
        
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
    
    func updateAccountToServer(_ name : String , _ lastName : String , _ email : String , _ gender : String){
        self.view.endEditing(true)
        let params : Parameters = [
            "name": name,
            "surname": lastName,
            "email": email,
            "gender": gender
        ]
        
        Alamofire.request("\(baseURL)/createUser", method: .put, parameters: params, encoding: JSONEncoding.default).responseJSON {
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
        keyChain["isEditing"] = "0"
    }
    
    func warn(_ msg : String){
        let alert = UIAlertController(title: "Uyarı!", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedGender = genders[row]
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}
