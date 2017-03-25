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

class ChatVC: UIViewController , UITableViewDataSource , UITableViewDelegate{

    @IBOutlet weak var textField: UITextField!
    var messages = [NSDictionary]()
    var messageArray = [String]()
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handleSend(_ sender: Any) {
        let ref = FIRDatabase.database().reference(fromURL: "https://hackathon-vakapedia.firebaseio.com/").child("messages")
        let childRef = ref.childByAutoId()
        
        let values = ["text" :textField.text]
        childRef.updateChildValues(values)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatTableView.delegate = self
        chatTableView.dataSource = self
        
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
            
            self.chatTableView.reloadData()
            //print(snapshot)
            // can also use
            // snapshot.childSnapshotForPath("full_name").value as! String
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messageArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell") as! ChatCell
        cell.message.text = self.messageArray[indexPath.row]
        return cell
    }
}
