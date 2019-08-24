//
//  sign_up_view_controller.swift
//  geolocpoc
//
//  Created by Areeb Waseem on 7/2/19.
//  Copyright © 2019 Areeb Waseem. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import Reachability

class sign_up_view_controller: UIViewController {
    
    @IBOutlet weak var progress_bar: UIActivityIndicatorView!
    
    @IBOutlet weak var outer_view: UIView!
    
    @IBOutlet weak var email_text_field: UITextField!
    
    @IBOutlet weak var password_text_field: UITextField!
    
    @IBOutlet weak var signup_button: UIButton!
    
    var reachability:Reachability!
    
    
    @IBOutlet weak var view_top_constraint: NSLayoutConstraint!
    
    var firestore:Firestore!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        reachability = Reachability.init()
        
        firestore = Firestore.firestore()
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(out_tapped))
        
        outer_view.addGestureRecognizer(tapGesture)
        
        
        add_observer_keyboard()
        
        //   performSegue(withIdentifier: "sign_up_to_add_info_segue", sender: self)
        

        // Do any additional setup after loading the view.
    }
    
    
    
    
    @IBAction func signup_button_clicked(_ sender: UIButton) {
        
        
            out_tapped()
        
            if(check_connection())
            {
                if(Auth.auth().currentUser != nil)
                {
                    do{
                        try Auth.auth().signOut()
                        show_alert(heading: "Error", body: "Try Again")
                    }catch{
                        show_alert(heading: "Error", body: "Try Again")
                    }
                }else{
                    
                    let email = email_text_field.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                    let password = password_text_field.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if(!email.isEmpty && !password.isEmpty)
                    {
                        
                        start_bar()
                        firestore.collection("Users").whereField("email", isEqualTo: email).getDocuments{ (snapshot, error) in
                            if(error != nil){
                                self.error_bar()
                                self.show_alert(heading: "Error", body: "Try again")
                            }else{
                                if(snapshot?.documents != nil)
                                {
                                if(snapshot?.documents.count ?? 0 == 0)
                                {
                                    Auth.auth().createUser(withEmail: email, password: password, completion: { (result, error) in
                                        if(error != nil)
                                        {
                                            self.error_bar()
                                            self.show_alert(heading: "Error", body: error?.localizedDescription ?? "Error signing up")
                                        }else{
                                            if(Auth.auth().currentUser != nil)
                                            {
                                             let taskMap = ["email":email, "type":"email"]
                                                self.firestore.collection("Users").document(Auth.auth().currentUser!.uid).setData(taskMap, merge: true, completion: { (error) in
                                                    if(error == nil)
                                                    {
                                                        self.error_bar()
                                                        self.email_text_field.text = ""
                                                        self.password_text_field.text = ""
                                                        self.performSegue(withIdentifier: "sign_up_to_add_info_segue", sender: self)
                                                    }else{
                                                        self.error_bar()
                                                        do{
                                                            try Auth.auth().signOut()
                                                            self.show_alert(heading: "Error", body: "Try Again")
                                                        }catch{
                                                            self.show_alert(heading: "Error", body: "Try Again")
                                                        }
                                                    }
                                                })
                                            }else{
                                                self.error_bar()
                                                 self.show_alert(heading: "Error", body: "Null user try again")
                                            }
                                        }
                                    })
                                }else{
                                    self.error_bar()
                                    self.show_alert(heading: "Alert", body: "Your account is already signed up, Login!")
                                    }
                                    
                                }else{
                                    self.error_bar()
                                    self.show_alert(heading: "Error", body: "Try again")
                                }
                            }
                        }
                    }else{
                        show_alert(heading: "Alert", body: "Fields can't be empty")
                    }
                }
                
            }else{
                show_alert(heading: "Alert", body: "No internet connection")
            }
 
        
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
    
    
    @IBAction func back_clicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @objc func out_tapped() {
        
        if (email_text_field.isEditing)
        {
            email_text_field.endEditing(true)
        }
        if (password_text_field.isEditing)
        {
            password_text_field.endEditing(true)
        }
        
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
        
        if ( Auth.auth().currentUser != nil  && Auth.auth().currentUser?.uid != nil ){
            return true;
        } else {
            return false;
        }
        
    }
    
    deinit {
        print("de init called")
        NotificationCenter.default.removeObserver(self)
        
    }
    
    func start_bar(){
        signup_button.isEnabled = false
        progress_bar.startAnimating()
    }
    
    
    func error_bar(){
        signup_button.isEnabled = true
        progress_bar.stopAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("called")
         self.navigationItem.hidesBackButton = false
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
            selector: #selector(keyboardDidHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            view_top_constraint.constant =  -(keyboardHeight/4)
        }
    }
    
    
    @objc func keyboardDidHide(_ notification: Notification) {
        view_top_constraint.constant =  0
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
