//
//  singleChatViewController.swift
//  geolocpoc
//
//  Created by Areeb Waseem on 27/07/2019.
//  Copyright © 2019 Areeb Waseem. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import Toast_Swift
import GoogleMaps
import Reachability

class singleChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var reachability:Reachability!
    
    var firestore:Firestore!
    
    var storage:Storage!
    
    var is_activity_running = false
    
    var chat_with_user_uid:String?
    
    var current_uid:String?
    
    var job_uid:String?
    
    @IBOutlet weak var ind_chat_table_view: UITableView!
    
    var messages_array:[message_object] = []
    
    var messages_listener:ListenerRegistration?
    
    var message_ids:[String] = []
    
    @IBOutlet weak var message_text_field: UITextField!
    
    @IBOutlet weak var send_view_bottom_constraint: NSLayoutConstraint!
    
    var is_first = true
    
    var other_user_object:user_object?
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        is_activity_running = true
        
        reachability = Reachability.init()
        
        firestore = Firestore.firestore()
        
        storage = Storage.storage()
        
        current_uid = Auth.auth().currentUser?.uid
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(out_tapped))
            
        ind_chat_table_view.addGestureRecognizer(tapGesture)
        
         ind_chat_table_view.register(UINib(nibName: "rightindMessageTableViewCell", bundle:nil), forCellReuseIdentifier: "right_ind_chat_table_view_cell")
        
         ind_chat_table_view.register(UINib(nibName: "indChatTableViewCell", bundle:nil), forCellReuseIdentifier: "ind_chat_table_view_cell")
        
        ind_chat_table_view.rowHeight = UITableView.automaticDimension
        ind_chat_table_view.estimatedRowHeight = 120.0
        
        ind_chat_table_view.delegate = self
        ind_chat_table_view.dataSource = self
        
        add_observer_keyboard()
        
        get_message_room_data()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        is_activity_running = true
        
        if(!self.get_activity_state())
        {
           self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        is_activity_running = false
        messages_listener?.remove()
        
    }
    
    
    func show_alert(heading:String, body:String)
    {
        
        let alert = UIAlertController(title: heading, message: body, preferredStyle: .alert)
        
        let dismiss_action = UIAlertAction(title: "Dismiss", style: .default) { (dismiss_action) in
            print("dismissed")
        }
        
        alert.addAction(dismiss_action)
        
        present(alert, animated : true, completion : nil)
        
    }
    
    func showToast(controller: UIViewController, message : String, seconds: Double) {
        
        var style = ToastStyle()
        
        // this is just one of many style options
        style.backgroundColor = .blue
        style.messageColor = .white
        style.messageAlignment = .center
        style.verticalPadding = 24
        
        // present the toast with the new style
        
        let w = UIScreen.main.bounds.width
        let h = UIScreen.main.bounds.height
        
        let point = CGPoint(x: w/2, y: h/1.2)
        
        
        self.view.makeToast(message, point: point, title: nil, image: nil, completion: nil)
        //self.view.makeToast(message, duration: 3.0, point: point, style: style)
    }
    
    func check_connection() -> Bool
    {
        
        if (reachability != nil)
        {
            
            if (reachability.connection == .wifi || reachability.connection == .cellular)
            {
                return true
            }
            else{
                return false
            }
            
        }
        else{
            return true
        }
        
    }
    
    func get_activity_state() -> Bool {
        
        if ( Auth.auth().currentUser != nil  && Auth.auth().currentUser?.uid != nil && is_activity_running && chat_with_user_uid != nil && current_uid != nil && job_uid != nil){
            return true;
        } else {
            return false;
        }
        
    }
    
    func get_message_room_uid()-> String{
        
        var comp_uid = ""
        
        if(get_activity_state())
        {
            comp_uid = current_uid! < chat_with_user_uid! ? current_uid! + "_" + chat_with_user_uid! : chat_with_user_uid! + "_" + current_uid!
        }
        return comp_uid
        
    }
    
    
    func get_message_room_data(){
        
        if(self.get_activity_state())
        {
          
            if (self.check_connection())
            {
               
            self.messages_listener?.remove()
            self.message_ids.removeAll()
            self.messages_array.removeAll()
            self.ind_chat_table_view.reloadData()
            is_first = true
                
            
        firestore.collection("Users").document(self.chat_with_user_uid!).getDocument { (snapshot, error) in
            
                    if(error == nil && snapshot != nil)
                    {
                        
            self.other_user_object = user_object(doc_snapshot: snapshot!)
                
             self.messages_listener = self.firestore.collection("Jobs").document(self.job_uid!).collection("message_rooms").document(self.get_message_room_uid()).collection("individual_messages").order(by: "message_time").addSnapshotListener { (querySnapshot, error) in
                
                if(self.get_activity_state())
                {
                
                guard let snapshot = querySnapshot else{
                    print("error")
                    return
                }
                    
            DispatchQueue.main.async {
                
               // var section_reload:[Int] = []
                
                snapshot.documentChanges.forEach({ (doc_change) in
                    
                        
                        if doc_change.type == .added{
                            
                            if(!self.message_ids.contains(doc_change.document.documentID))
                            {
                                self.message_ids.append(doc_change.document.documentID)
                                self.messages_array.append(message_object(snapshot: doc_change.document))
                                if(!self.is_first){
                                  self.ind_chat_table_view.beginUpdates()
                                self.ind_chat_table_view.insertRows(at: [IndexPath(row: self.messages_array.count-1, section: 0)], with: .automatic)
                                    self.ind_chat_table_view.endUpdates()
                                }
                              //  section_reload.append(self.messages_array.count - 1)
                            }
                            
                        }else if doc_change.type == .modified{
                            
                            if let index = self.message_ids.firstIndex(of: doc_change.document.documentID)
                            {
                                self.messages_array[index] = message_object(snapshot: doc_change.document)
                               self.ind_chat_table_view.reloadData()
                              //  section_reload.append(index)
                            }
                            
                        }else if doc_change.type == .removed{
                            
                            if let index = self.message_ids.firstIndex(of: doc_change.document.documentID)
                            {
                                self.messages_array.remove(at: index)
                                self.message_ids.remove(at: index)
                                self.ind_chat_table_view.reloadData()
                              //  section_reload.append(index)
                            }
                            
                    }
                    
                })
                
                // consider reloading specific rows
                if(self.is_first)
                {
                    self.is_first = false
                    self.ind_chat_table_view.reloadData()
                }
                
                if(self.messages_array.count > 0)
                {
                    self.ind_chat_table_view.scrollToRow(at: IndexPath(item: self.messages_array.count - 1, section: 0), at: .bottom, animated: true)
                }
                
           }
                    
            }
                
            }
                    }else{
                        self.showToast(controller: self, message: "Error loading data, reload!", seconds: 2.0)
            }
                
            }
                
            }else{
                self.showToast(controller: self, message: "No internet connection", seconds: 2.0)
            }
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.messages_array.count
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var msg_type = ""
        
        var message_obj:message_object?
        
        if(self.get_activity_state())
        {
            
        if (indexPath.row < self.messages_array.count)
        {
            
            message_obj = self.messages_array[indexPath.row]
            
            if let msg_uid = message_obj?.message_from_uid{
                if(msg_uid == current_uid!)
                {
                    msg_type = "self"
                }
            }else{
                msg_type = "other"
            }
            
        }
            
        }
        
        if(msg_type == "self")
        {
            
               let cell = tableView.dequeueReusableCell(withIdentifier: "right_ind_chat_table_view_cell", for: indexPath) as! rightindMessageTableViewCell
            
            
              cell.right_ind_message_label.text = message_obj?.message_text ?? ""
            
            
            if let time_stamp = message_obj?.message_time{
                
                let date = time_stamp.dateValue()
                let cal = Calendar.current
                let comp = cal.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
                if cal.isDateInToday(date){
                    if let hr = comp.hour, let mn = comp.minute, let sc = comp.second{
                        
                        let tr_str = (hr < 10 ? ("0" + String(hr)) : String(hr)) + ":" + (mn < 10 ? ("0" + String(mn)) : String(mn)) + ":" + (sc < 10 ? ("0" + String(sc)) : String(sc))
                        cell.time_label.text = tr_str
                    }
                }else{
                    if let dy = comp.day, let mn = comp.month, let yr = comp.year {
                        let tr_str = (dy < 10 ? ("0" + String(dy)) : String(dy)) + ":" + (mn < 10 ? ("0" + String(mn)) : String(mn)) + ":" + (yr < 10 ? ("0" + String(yr)) : String(yr))
                        cell.time_label.text = tr_str
                    }
                }
            }
            
               return cell
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ind_chat_table_view_cell", for: indexPath) as! indChatTableViewCell
            
            cell.ind_message_label.text = message_obj?.message_text ?? ""
            
            cell.get_picture(ms_uid: message_obj?.message_from_uid ?? "")
            
            if let name = other_user_object?.name{
                cell.user_name_label.text = name
            }
            
            if let time_stamp = message_obj?.message_time{
                
                let date = time_stamp.dateValue()
                let cal = Calendar.current
                let comp = cal.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
                if cal.isDateInToday(date){
                    if let hr = comp.hour, let mn = comp.minute, let sc = comp.second{
                        
                        let tr_str = (hr < 10 ? ("0" + String(hr)) : String(hr)) + ":" + (mn < 10 ? ("0" + String(mn)) : String(mn)) + ":" + (sc < 10 ? ("0" + String(sc)) : String(sc))
                        cell.message_time_label.text = tr_str
                    }
                }else{
                    if let dy = comp.day, let mn = comp.month, let yr = comp.year {
                        let tr_str = (dy < 10 ? ("0" + String(dy)) : String(dy)) + ":" + (mn < 10 ? ("0" + String(mn)) : String(mn)) + ":" + (yr < 10 ? ("0" + String(yr)) : String(yr))
                        cell.message_time_label.text = tr_str
                    }
                }
            }
            
            return cell
            
        }
        
    }
    
    
    @IBAction func send_clicked(_ sender: UIButton) {
        
        if (self.get_activity_state())
        {
            
            
            let msg_to_send = self.message_text_field.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if(!msg_to_send.isEmpty){
                
                if(self.check_connection())
                {
                
                let taskMap:[String:Any] = ["message_time": FieldValue.serverTimestamp(), "message_text": msg_to_send, "message_from_uid": self.current_uid!]
                firestore.collection("Jobs").document(self.job_uid!).collection("message_rooms").document(get_message_room_uid()).collection("individual_messages").addDocument(data: taskMap) { (error) in
                    
                    if(error == nil)
                    {
                        self.message_text_field.text = ""
                    }else{
                        self.showToast(controller: self, message: "Error sending message", seconds: 2.0)
                    }
                    
                }
                    
                }else{
                    self.showToast(controller: self, message: "No internet connection", seconds: 2.0)
                }
                
            }else{
                self.showToast(controller: self, message: "Fields can't be empty", seconds: 2.0)
            }
            
        }else{
            
            self.showToast(controller: self, message: "Error, try again", seconds: 2.0)
            
        }
        
    }
    
    
    
    @IBAction func refresh_clicked(_ sender: UIBarButtonItem) {
        
        
        
        self.get_message_room_data()
        
        
    }
    
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
        
    }
    
    func add_observer_keyboard(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidShow),
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )
        
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        if(self.messages_array.count > 0)
        {
            print("called")
            self.ind_chat_table_view.scrollToRow(at: IndexPath(item: self.messages_array.count - 1, section: 0), at: .bottom, animated: true)
        }
    }
    
    
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            send_view_bottom_constraint.constant =  keyboardHeight/1.25
           // send_view_bottom_constraint.constant =  keyboardHeight - (self.navigationController?.toolbar.frame.height ?? 0)
        }
        
    }
    
    
    @objc func out_tapped() {
        
      if message_text_field.isEditing{
           message_text_field.endEditing(true)
        }
        
    }
    
    
    @objc func keyboardDidHide(_ notification: Notification) {
        
       send_view_bottom_constraint.constant =  0
        
        if(self.messages_array.count > 0)
        {
            
            self.ind_chat_table_view.scrollToRow(at: IndexPath(item: self.messages_array.count - 1, section: 0), at: .bottom, animated: true)
            
        }
        
    }
    
}


// improve scrolling
// implement other user chat
