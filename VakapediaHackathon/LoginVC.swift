//
//  MainVC.swift
//  VakapediaHackathon
//
//  Created by Mustafa ALP on 25/03/2017.
//  Copyright © 2017 Mustafa ALP. All rights reserved.
//

import UIKit
import Alamofire

class LoginVC: UIViewController  , UIPickerViewDelegate , UIPickerViewDataSource{

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    
    var isWorked : Int = 0
    let isWorking = ["Hayır" , "Evet"]
    let baseURL = "http://localhost:1337"
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return isWorking.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return isWorking[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if isWorking[row] == "Evet" {
            locationField.isEnabled = true
            isWorked = 1
        }else{
            locationField.isEnabled = false
            isWorked = 0
        }
    }
    @IBAction func saveTapped(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainVC") as! TabBarVC
        self.present(vc, animated: true, completion: nil)
        return
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
        }else if isWorked == 1{
            if(locationField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!{
                warn("Lokasyon belirlemeniz gerekmektedir.")
                return
            }
        }
        postAccountToServer(nameField.text! , lastNameField.text! , emailField.text!)
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
                print(value)
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainVC")
                self.present(vc!, animated: true, completion: nil)
            case .failure(let err) :
                print(err)
            }
        }
        
    }
    
    func warn(_ msg : String){
        let alert = UIAlertController(title: "Uyarı!", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
