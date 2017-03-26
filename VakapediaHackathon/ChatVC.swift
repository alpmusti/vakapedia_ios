//
//  ChatVC.swift
//  VakapediaHackathon
//
//  Created by Mustafa ALP on 25/03/2017.
//  Copyright © 2017 Mustafa ALP. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON
import KeychainAccess

class ChatVC: UITableViewController, UITextFieldDelegate{

    var messages = [NSDictionary]()
    var messageArray = [String]()
    let keyChain : Keychain = Keychain(service : "Vakapedia")
    
    @IBOutlet weak var messageField: UITextField!
    @IBAction func sendMessageHandle(_ sender: Any) {
        print("ok")
        handleSend()
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageField.delegate = self
        fetchMessages()
    }
    
    func fetchMessages(){
        let ref = FIRDatabase.database().reference().child("messages")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if !snapshot.exists() { return }
            for item in snapshot.children{
              
                    let child = item as! FIRDataSnapshot
                    let dict = child.value as! NSDictionary
                    self.messages.append(dict)
            }
            for item in self.messages{
                self.messageArray.append(item.value(forKey: "text")! as! String)
            }
            
            self.tableView.reloadData()
            //print(snapshot)
            // can also use
            // snapshot.childSnapshotForPath("full_name").value as! String
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messageArray.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell") as! ChatCell
        cell.messageTxt.text = self.messageArray[indexPath.row]
        return cell
    }
    
    func handleSend(){
        let toId = keyChain["toId"]!
        let fromId  = keyChain["userId"]!
        let ref = FIRDatabase.database().reference(fromURL: "https://hackathon-vakapedia.firebaseio.com/").child("messages")
        let childRef = ref.childByAutoId()
        
        let values = ["text" : messageField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), "toId": toId , "fromId": fromId] as [String : Any]
        childRef.updateChildValues(values)
        fetchMessages()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}
