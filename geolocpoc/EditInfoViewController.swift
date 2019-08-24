//
//  EditInfoViewController.swift
//  geolocpoc
//
//  Created by Areeb Waseem on 7/7/19.
//  Copyright © 2019 Areeb Waseem. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import Reachability
import SDWebImage




class EditInfoViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var profile_view_upper_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var outer_view: UIView!
    
    @IBOutlet weak var save_button: UIBarButtonItem!
    
    @IBOutlet weak var uppper_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var stack_view: UIView!
    
    var firestore:Firestore!
    
    var reachability:Reachability!
    
    
    var imagePickerController:UIImagePickerController!
    
    var secondImagePickerController:UIImagePickerController!
    
    @IBOutlet weak var profile_view_image: UIImageView!
    
    var storage:Storage!
    
    @IBOutlet weak var progressBar: UIActivityIndicatorView!
    
    @IBOutlet weak var name_text_field: UITextField!
    
    
    @IBOutlet weak var id_text_field: UITextField!
    
    
    @IBOutlet weak var designation_text_field: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(out_tapped))
        outer_view.addGestureRecognizer(tapGesture)
        stack_view.addGestureRecognizer(tapGesture)
        
        add_observer_keyboard()
        
        
        reachability = Reachability.init()
        
        firestore = Firestore.firestore()
        
        storage = Storage.storage()
        
    
        imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        secondImagePickerController = UIImagePickerController()
        secondImagePickerController.delegate = self
        secondImagePickerController.allowsEditing = true
        
        
        get_user_info()
        get_user_profile_pic()

        // Do any additional setup after loading the view.
    }
    
    
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
        
    }
    
    func start_bar(){
        save_button.isEnabled = false
        progressBar.startAnimating()
    }
    
    
    func error_bar(){
        save_button.isEnabled = true
        progressBar.stopAnimating()
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        var image : UIImage!
        
        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        {
            image = img
            self.profile_view_image.image = image
            
        }
        else if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            image = img
            self.profile_view_image.image = image
        }
        
        picker.dismiss(animated: true,completion: nil)
        
        if (image != nil)
        {
            self.show_image_alert(image: image)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if(!get_activity_state())
        {
            pop_current_view_controller()
        }
        
    }
    

    
    @objc func out_tapped() {
        
        if (name_text_field.isEditing)
        {
            name_text_field.endEditing(true)
        }
        if (id_text_field.isEditing)
        {
            id_text_field.endEditing(true)
        }
        if (designation_text_field.isEditing)
        {
            designation_text_field.endEditing(true)
        }
        
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
            uppper_constraint.constant =  -(keyboardHeight/3)
            profile_view_upper_constraint.constant = profile_view_upper_constraint.constant - (keyboardHeight/4)
        }
    }
    
    
    func get_activity_state() -> Bool {
        
        if ( Auth.auth().currentUser != nil  && Auth.auth().currentUser?.uid != nil ){
            return true;
        } else {
            return false;
        }
        
    }
    
    
    @objc func keyboardDidHide(_ notification: Notification) {
        uppper_constraint.constant =  0
        profile_view_upper_constraint.constant = 24
    }
    
    
    @IBAction func gallery_clicked(_ sender: UIButton) {
        display_gallery()
    }
    
    
    @IBAction func camera_clicked(_ sender: UIButton) {
        display_camera()
    }
    
    
    
    func display_camera(){
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            out_tapped()
            self.imagePickerController.sourceType = .camera
            self.imagePickerController.mediaTypes = ["public.image"]
            self.present(self.imagePickerController, animated: true, completion: nil)
        }else{
            show_alert(heading: "Alert", body: "Camera not available")
        }
        
    }
    
    func display_gallery(){
        
        out_tapped()
        
        self.secondImagePickerController.sourceType = .photoLibrary
        self.secondImagePickerController.mediaTypes = ["public.image"]
        self.secondImagePickerController.navigationBar.topItem?.rightBarButtonItem?.tintColor = .black
        
        self.present(self.secondImagePickerController, animated: true, completion: {
            
        })
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
    
    
    func show_image_alert(image:UIImage)
    {
        let alert = UIAlertController(title: "Alert", message: "Do you want to make this your profile picture?", preferredStyle: .alert)
        let dismiss_action = UIAlertAction(title: "No", style: .default) { (dismiss_action) in
            
        }
        let accept_action = UIAlertAction(title: "Yes", style: .default) { (accept_action) in
            self.save_image_to_db(image: image)
        }
        alert.addAction(dismiss_action)
        alert.addAction(accept_action)
        present(alert, animated : true, completion : nil)
    }
    
    
    func save_image_to_db(image: UIImage){
        
        if (!check_connection())
        {
            self.show_alert(heading: "Alert", body: "No internet connection")
            return
        }
        
        if (get_activity_state())
        {
            self.start_bar()
            let store_ref = storage.reference().child((Auth.auth().currentUser?.uid)!).child("profile_picture")
            if let data = image.pngData()
            {
                store_ref.putData(data, metadata: nil) { (metadata, error) in
                    if (error != nil)
                    {
                        self.error_bar()
                        self.show_alert(heading: "Error", body: "Error saving Image, try again")
                    }else{
                        self.error_bar()
                        self.show_alert(heading: "Success", body: "Image Saved")
                    }
                }
            }
            else{
                self.show_alert(heading: "Alert", body: "Representaion Error")
                self.error_bar()
            }
            
        }
        else{
            self.show_alert(heading: "Alert", body: "Null User")
            self.error_bar()
            pop_current_view_controller()
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
    
    @IBAction func save_button_clicked(_ sender: UIBarButtonItem) {
        save_info()
    }
    
    
    private func save_info(){
        
        let name = name_text_field.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let id = id_text_field.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let designation = designation_text_field.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if(get_activity_state())
        {
            
            if(check_connection())
            {
                if(!name.isEmpty && !id.isEmpty && !designation.isEmpty){
                    
                    start_bar()
                    
                    let taskMap = ["name":name, "id":id,"designation":designation]
                    
                    firestore.collection("Users").document(Auth.auth().currentUser!.uid).setData(taskMap, merge: true) { (error) in
                        self.error_bar()
                        if(error != nil)
                        {
                            self.show_alert(heading: "Error", body: error?.localizedDescription ?? "database error")
                        }else{
                            self.pop_current_view_controller()
                        }
                    }
                    
                    
                }else{
                    show_alert(heading: "Alert", body: "Fields can't be empty")
                }
            }else{
                show_alert(heading: "Alert", body: "No internet connection")
            }
            
        }else{
            pop_current_view_controller()
        }
        
    }
    
    
    func pop_current_view_controller(){
        self.navigationController?.popViewController(animated: true)
         self.dismiss(animated: true, completion: nil)
        /*
        for controller in self.navigationController!.viewControllers as Array{
            if(controller.isKind(of: ViewController.self)){
                self.navigationController!.popToViewController(controller, animated: true)
                self.dismiss(animated: true, completion: nil)
                break
            }
        }
 */
    }
    
    func get_user_info(){
        
        if(get_activity_state() && check_connection())
        {
            firestore.collection("Users").document(Auth.auth().currentUser!.uid).getDocument { (snapshot, error) in
                if(error == nil)
                {
                    if(snapshot?.get("name") != nil)
                    {
                        self.name_text_field.text = snapshot?.get("name") as? String ?? ""
                    }
                    if(snapshot?.get("id") != nil)
                    {
                        self.id_text_field.text = snapshot?.get("id") as? String ?? ""
                    }
                    if(snapshot?.get("designation") != nil)
                    {
                        self.designation_text_field.text = snapshot?.get("designation") as? String ?? ""
                    }
            }
            }
        }
    }
    
    func get_user_profile_pic(){
        
        
        if(get_activity_state() && check_connection())
        {
            
        let ref = storage.reference()
        
        
        ref.child((Auth.auth().currentUser?.uid)!).child("profile_picture").downloadURL { (url, error) in
            if (error != nil)
            {
            }else{
                if (url != nil)
                {
                   self.profile_view_image.sd_setImage(with: url, placeholderImage: UIImage(named: "asset_four"), options: SDWebImageOptions.refreshCached) { (image, error, cache_type, url) in
                        print("got image")
                        if (image != nil)
                        {
                            //self.save_image_to_db(image: image!)
                        }
                    }
                }
            }
        }
        
        }
        
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
