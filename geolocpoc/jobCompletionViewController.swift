//
//  jobCompletionViewController.swift
//  geolocpoc
//
//  Created by Areeb Waseem on 04/08/2019.
//  Copyright © 2019 Areeb Waseem. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import Toast_Swift
import GoogleMaps
import Reachability
import DropDown
import M13Checkbox
import AVKit
import AVFoundation
import DLRadioButton

class jobCompletionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UINavigationControllerDelegate, UIImagePickerControllerDelegate  {
    
    
    var job_uid:String?
    
    var is_activity_running = false
    
    var storage:Storage!
    
    var reachability:Reachability!
    
    var firestore:Firestore!
    
    var images_array:[job_completion_image_object] = []
    
    var videos:[job_completion_video_object] = []
    
    @IBOutlet weak var bottom_complete_job: UIBarButtonItem!
    
    @IBOutlet weak var bottom_image_button: UIBarButtonItem!
    
    
    @IBOutlet weak var bottom_video_button: UIBarButtonItem!
    
    
    @IBOutlet weak var main_progress_bar: UIActivityIndicatorView!
    
    
    @IBOutlet weak var cur_im_up_stack_bottom_constraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var images_table_view: UITableView!
    
    
    @IBOutlet weak var videos_table_view: UITableView!
    
    @IBOutlet weak var long_description_view: UITextView!
    
    
    @IBOutlet weak var short_description_view: UITextView!
    
    
    @IBOutlet weak var images_table_view_height_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var videos_table_view_height_constraint: NSLayoutConstraint!
    
    var imagePickerController:UIImagePickerController!
    
    var secondImagePickerController:UIImagePickerController!
    
    @IBOutlet weak var save_image_progress_bar: UIActivityIndicatorView!
    
    
    @IBOutlet weak var current_selected_image_view: UIImageView!
    
    
    @IBOutlet weak var current_image_desc_layout: UIView!
    
    
    @IBOutlet weak var image_add_button: UIButton!
    
    var img_current:UIImage?
    
    
    @IBOutlet weak var stack_view: UIStackView!
    
    
    @IBOutlet weak var img_desc_text_field: UITextField!
    
    var is_saved = false
    
    var job_form_obj:job_form_object?
    
    var is_video_selected = false
    
    
    
    @IBOutlet weak var cur_selec_video_outer_layout: UIView!
    
    
    @IBOutlet weak var video_thumbnail_image: UIImageView!
    
    
    @IBOutlet weak var vide_save_progress_bar: UIActivityIndicatorView!
    
    @IBOutlet weak var video_desc_text_field: UITextField!
    
    @IBOutlet weak var add_video_button: UIButton!
    
    
    @IBOutlet weak var cur_vid_bot_constraint: NSLayoutConstraint!
    
    var cur_selected_video_url:URL?
    
    var cur_sele_video_thumb_image:UIImage?
    
    
    
    @IBOutlet weak var vid_play_button: UIButton!
    
    var drop_downs_list:[DropDown] = []
    
    var radio_buttons:[String:[DLRadioButton]] = [:]
    
    var completed_form:[String:[String]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        is_activity_running = true
        
        reachability = Reachability.init()
        
        firestore = Firestore.firestore()
        
        storage = Storage.storage()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(out_tapped))
        
        self.current_image_desc_layout.addGestureRecognizer(tapGesture)
        self.cur_selec_video_outer_layout.addGestureRecognizer(tapGesture)
        self.stack_view.addGestureRecognizer(tapGesture)
        
        
        images_table_view.register(UINib(nibName: "jobCompletionImagesTableViewCell", bundle:nil), forCellReuseIdentifier: "job_completion_image_table_view_cell")
        
        images_table_view.rowHeight = UITableView.automaticDimension
        images_table_view.estimatedRowHeight = 120.0
        
        images_table_view.delegate = self
        images_table_view.dataSource = self
        
        
        videos_table_view.register(UINib(nibName: "jobCompletionVideoTableViewCell", bundle:nil), forCellReuseIdentifier: "job_completion_videos_table_view_cell")
        
        videos_table_view.rowHeight = UITableView.automaticDimension
        videos_table_view.estimatedRowHeight = 120.0
        
        videos_table_view.delegate = self
        videos_table_view.dataSource = self
        
        
        imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        secondImagePickerController = UIImagePickerController()
        secondImagePickerController.delegate = self
        secondImagePickerController.allowsEditing = true
        
        add_observer_keyboard()
        
        // check this
        /*
        if(self.get_activity_state() && self.check_connection())
        {
            firestore.collection("Jobs").document(self.job_uid!).collection("job_completion_forms").document(Auth.auth().currentUser!.uid).delete()
        }
 */
        
        /*
        let view = UIView()
        
        let dropDown = DropDown()
        
        /*
        var new_frame = view.frame
        new_frame.size.width = self.view.frame.width
        new_frame.size.height = 40
        
        view.frame = new_frame
        */
       // stack_view.addSubview(view)
        
        // The view to which the drop down will appear on
        dropDown.anchorView = cr_view // UIView or UIBarButtonItem
        
        // The list of items to display. Can be changed dynamically
       // dropDown.direction = .top
        
        dropDown.dataSource = ["Car", "Motorcycle", "Truck"]
        
        dropDown.direction = .bottom
        
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        
        dropDown.show()
        
        let checkbox = M13Checkbox(frame: CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0))
        
        stack_view.addArrangedSubview(checkbox)
        stack_view.layoutSubviews()
        */
        
        /*
        let checkbox = M13Checkbox()
        checkbox.heightAnchor.constraint(equalToConstant: 100).isActive = true
        checkbox.widthAnchor.constraint(equalToConstant: 100).isActive = true
        stack_view.addArrangedSubview(checkbox)
        
      //  let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 200))
     //   view.backgroundColor = UIColor.black
      
        let view1 = UIView()
        view1.heightAnchor.constraint(equalToConstant: 100).isActive = true
        view1.widthAnchor.constraint(equalToConstant: 100).isActive = true
        view1.backgroundColor = UIColor.black
        stack_view.addArrangedSubview(view1)
        */
        
        /*
        let stackView1 = UIStackView()
        stackView1.axis = .vertical
        stackView1.spacing = 6
        stackView1.distribution = .equalSpacing
        
        let label1 = UILabel()
        label1.text = "Hello from label"
        label1.heightAnchor.constraint(equalToConstant: 20).isActive = true
        label1.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        stackView1.addArrangedSubview(label1)
        
        let checkbox = M13Checkbox()
        checkbox.heightAnchor.constraint(equalToConstant: 40).isActive = true
        checkbox.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        let checkbox1 = M13Checkbox()
        checkbox1.heightAnchor.constraint(equalToConstant: 40).isActive = true
        checkbox1.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        stackView1.addArrangedSubview(checkbox)
        stackView1.addArrangedSubview(checkbox1)
        
      //  stackView1.addArrangedSubview(checkbox)
      //  stackView1.addArrangedSubview(checkbox)
       // stackView1.addArrangedSubview(checkbox)
        
        stack_view.addArrangedSubview(stackView1)
        */
        
    
        load_form()
        
        
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
            selector: #selector(keyboardDidHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.cur_im_up_stack_bottom_constraint.constant =  keyboardHeight + 8
            self.cur_vid_bot_constraint.constant = keyboardHeight + 8
        }
    }
    
    @objc func keyboardDidHide(_ notification: Notification) {
        self.cur_im_up_stack_bottom_constraint.constant = 40
        self.cur_vid_bot_constraint.constant = 40
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        picker.dismiss(animated: true,completion: nil)
        
        if(self.is_video_selected)
        {
            
            self.video_thumbnail_image.image = UIImage(named: "video-camera")
            
            if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL{
                 print("got video")
                
                self.cur_selected_video_url = videoURL
                
                if let img_found = self.generate_thumbnail(url: videoURL){
                    self.video_thumbnail_image.image = img_found
                    self.cur_sele_video_thumb_image = img_found
                }
                
                self.show_add_video_desc_layout()
                
            }else{
                self.cur_selected_video_url = nil
                self.showToast(controller: self, message: "No video", seconds: 2.0)
            }
            
        }else{
        
        var image : UIImage!
        
        
        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        {
            image = img
            self.current_selected_image_view.image = image
            
        }
        else if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            image = img
            self.current_selected_image_view.image = image
        }
       // else if let video = inf[UIImagePickerController.InfoKey.mediaType]
        
        
        
        if (image != nil)
        {
            self.img_current = image
            self.show_add_img_desc_layout()
        }
            
        }
        
    }
    
    func show_add_video_desc_layout(){
        self.navigationController?.navigationBar.layer.zPosition = -1
        self.navigationController?.toolbar.layer.zPosition = -1
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.toolbar.isHidden = true
        self.video_desc_text_field.text = ""
        self.cur_selec_video_outer_layout.isHidden = false
    }
    
    func hide_add_video_desc_layout(){
        self.navigationController?.navigationBar.layer.zPosition = 0
        self.navigationController?.toolbar.layer.zPosition = 0
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.toolbar.isHidden = false
        self.video_desc_text_field.text = ""
        self.cur_selec_video_outer_layout.isHidden = true
        out_tapped()
        
    }
    
    func show_add_img_desc_layout(){
        self.navigationController?.navigationBar.layer.zPosition = -1
        self.navigationController?.toolbar.layer.zPosition = -1
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.toolbar.isHidden = true
        self.img_desc_text_field.text = ""
        self.current_image_desc_layout.isHidden = false        
    }
    
    
    func hide_add_img_desc_layout(){
        self.navigationController?.navigationBar.layer.zPosition = 0
        self.navigationController?.toolbar.layer.zPosition = 0
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.toolbar.isHidden = false
        self.current_image_desc_layout.isHidden = true
        out_tapped()
        
    }

    // lay out this image view, or if it already exists, set its image property to uiImage
    
    
    @IBAction func refresh_clicked(_ sender: UIBarButtonItem) {
        
        self.hide_add_img_desc_layout()
        
    }
    
    
    @IBAction func photo_clicked(_ sender: UIBarButtonItem) {
        
        self.current_selected_image_view.image = UIImage(named: "repairing")
        show_camera_gallery_alert()
        
    }
    
    @IBAction func video_clicked(_ sender: UIBarButtonItem) {
        self.display_video_alert()
    }
    
    
    
    // check this
    
    @IBAction func add_clicked(_ sender: UIButton) {
        
       
        out_tapped()
        
        if (!self.check_connection())
        {
            self.show_alert(heading: "Alert", body: "No internet connection")
            return
        }
        
        if (self.get_activity_state())
        {
            
            if(self.img_current !=  nil)
            {
                
            self.start_save_image_bar()
            
            let tmp_stamp = Date().timeIntervalSince1970.description
            
            let store_ref = storage.reference().child(self.job_uid!).child("completion_forms").child(Auth.auth().currentUser!.uid).child(tmp_stamp)
            
            if let data = self.img_current!.pngData()
            {
                
                store_ref.putData(data, metadata: nil) { (metadata, error) in
                    
                    if (error != nil)
                    {
                        
                      // self.errror_save_image_bar()
                        self.show_alert(heading: "Error", body: "Error saving Image, try again")
                        
                    }else{
                        
                       // self.errror_save_image_bar()
                      //  self.show_alert(heading: "Success", body: "Image Saved")
                        store_ref.downloadURL(completion: { (url, error) in
                            
                            if(error == nil && url != nil)
                            {
                                
                                let taskMap = [ "images" : FieldValue.arrayUnion([["desc": self.img_desc_text_field.text!,"url":url!.absoluteString, "path":store_ref.fullPath]])]
                               
                                let newTaskMap = [ "images" : FieldValue.arrayRemove([["desc": self.img_desc_text_field.text!,"url":url!.absoluteString, "path":store_ref.fullPath]])]
                                
                                
                                
                                self.firestore.collection("Jobs").document(self.job_uid!).collection("job_completion_forms").document(Auth.auth().currentUser!.uid).setData(taskMap, merge: true, completion: { (error) in
                                    
                                    if(error == nil)
                                    {
                                        
                                        self.errror_save_image_bar()
                                        
                                        self.hide_add_img_desc_layout()
                                        
                                        self.images_array.append(job_completion_image_object(img: self.img_current!, desc: self.img_desc_text_field.text!, path : store_ref.fullPath, taskMap:newTaskMap))
                                        
                                        self.images_table_view.beginUpdates()
                                        
                                        self.images_table_view.insertRows(at: [IndexPath(row: self.images_array.count-1, section: 0)], with: .automatic)
                                        
                                        self.images_table_view.endUpdates()
                                        
                                        self.showToast(controller: self , message: "Image Saved", seconds: 2.0)
                                        
                                    }else{
                                        
                                        store_ref.delete(completion: { (error) in
                                            
                                        })
                                        self.errror_save_image_bar()
                                        self.show_alert(heading: "Error", body: "Error saving Image, try again")
                                        
                                    }
                                    
                                })
                                
                            }else{
                                
                            store_ref.delete(completion: { (error) in
                                    
                                })
                                
                            self.errror_save_image_bar()
                            self.show_alert(heading: "Error", body: "Error saving Image, try again")
                                
                            }
                            
                        })
                        
                    }
                    
                }
                
            }
            else{
                self.show_alert(heading: "Alert", body: "Representaion Error")
                 self.errror_save_image_bar()
            }
            }else{
                self.showToast(controller: self, message: "No selected image", seconds: 2.0)
            }
            
        }
        
    }
    
    @IBAction func add_video_clicked(_ sender: UIButton) {
        
        out_tapped()
        
        if (!self.check_connection())
        {
            self.show_alert(heading: "Alert", body: "No internet connection")
            return
        }
        
        if (self.get_activity_state())
        {
            
            if let vid_url = self.cur_selected_video_url
            {
                
                self.start_save_video_bar()
                
                let tmp_stamp = Date().timeIntervalSince1970.description
                
                let store_ref = storage.reference().child(self.job_uid!).child("completion_forms").child(Auth.auth().currentUser!.uid).child(tmp_stamp)
              
                    
                store_ref.putFile(from: vid_url, metadata:  nil) { (metadata, error) in
                        
                        if (error != nil)
                        {
                            
                            // self.errror_save_image_bar()
                            self.show_alert(heading: "Error", body: "Error saving video, try again")
                            
                        }else{
                            
                            // self.errror_save_image_bar()
                            //  self.show_alert(heading: "Success", body: "Image Saved")
                            store_ref.downloadURL(completion: { (url, error) in
                                
                                if(error == nil && url != nil)
                                {
                                    
                                    let taskMap = [ "videos" : FieldValue.arrayUnion([["desc": self.video_desc_text_field.text!,"url":url!.absoluteString, "path":store_ref.fullPath]])]
                                    
                                    let newTaskMap =  [ "videos" : FieldValue.arrayRemove([["desc": self.video_desc_text_field.text!,"url":url!.absoluteString, "path":store_ref.fullPath]])]
                                    self.firestore.collection("Jobs").document(self.job_uid!).collection("job_completion_forms").document(Auth.auth().currentUser!.uid).setData(taskMap, merge: true, completion: { (error) in
                                        
                                        if(error == nil)
                                        {
                                            
                                            self.errror_save_video_bar()
                                            
                                            self.hide_add_video_desc_layout()
                                            
                                            self.videos.append(job_completion_video_object(loc: vid_url, desc: self.video_desc_text_field.text!, thumb: self.cur_sele_video_thumb_image, path:store_ref.fullPath, taskMap:newTaskMap))
                                            
                                            self.videos_table_view.beginUpdates()
                                            
                                            self.videos_table_view.insertRows(at: [IndexPath(row: self.videos.count-1, section: 0)], with: .automatic)
                                            
                                            self.videos_table_view.endUpdates()
                                            
                                            self.showToast(controller: self , message: "Video Saved", seconds: 2.0)
                                            
                                        }else{
                                            
                                            store_ref.delete(completion: { (error) in
                                                
                                            })
                                            
                                            self.errror_save_video_bar()
                                            self.show_alert(heading: "Error", body: "Error saving Image, try again")
                                            
                                        }
                                        
                                    })
                                    
                                }else{
                                    
                                    store_ref.delete(completion: { (error) in
                                        
                                    })
                                    
                                    self.errror_save_video_bar()
                                    self.show_alert(heading: "Error", body: "Error saving Video, try again")
                                    
                                }
                                
                            })
                            
                        }
                        
                    }
                    
            
            }else{
                self.showToast(controller: self, message: "No selected video", seconds: 2.0)
            }
            
        }
        
    }
    
    
    func start_save_image_bar(){
        
        
        self.image_add_button.isEnabled = false
        self.current_selected_image_view.isHidden = true
        self.save_image_progress_bar.startAnimating()
        
    }
    func errror_save_image_bar(){
        
        self.image_add_button.isEnabled = true
        self.current_selected_image_view.isHidden = false
         self.save_image_progress_bar.stopAnimating()
        
    }
    
    
    func start_save_video_bar(){
        
        
        self.add_video_button.isEnabled = false
        self.vid_play_button.isHidden = true
        self.video_thumbnail_image.isHidden = true
        self.vide_save_progress_bar.startAnimating()
        
    }
    func errror_save_video_bar(){
        
        self.add_video_button.isEnabled = true
        self.vid_play_button.isHidden = false
        self.video_thumbnail_image.isHidden = false
        self.vide_save_progress_bar.stopAnimating()
        
    }
    
    
    func display_camera(){
        
        self.is_video_selected = false
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.imagePickerController.sourceType = .camera
            self.imagePickerController.mediaTypes = ["public.image"]
            self.present(self.imagePickerController, animated: true, completion: nil)
        }else{
            show_alert(heading: "Alert", body: "Camera not available")
        }
        
    }
    
    func display_video_alert(){
        
        
        self.is_video_selected = true
        
        out_tapped()
        
        self.secondImagePickerController.sourceType = .photoLibrary
        self.secondImagePickerController.navigationBar.topItem?.rightBarButtonItem?.tintColor = .black
        self.secondImagePickerController.mediaTypes = ["public.movie"]
        self.present(self.secondImagePickerController, animated: true, completion: {
            
        })
        
    }
    
    func display_gallery(){
        
        self.current_selected_image_view.image = UIImage(named: "repairing")
        self.is_video_selected = false
        
        out_tapped()
        
        self.secondImagePickerController.sourceType = .photoLibrary
        self.secondImagePickerController.navigationBar.topItem?.rightBarButtonItem?.tintColor = .black
        self.secondImagePickerController.mediaTypes = ["public.image"]
        self.present(self.secondImagePickerController, animated: true, completion: {
            
        })
        
    }
    
    func start_main_bar(){
        self.main_progress_bar.startAnimating()
        self.bottom_complete_job.isEnabled = false
        self.bottom_image_button.isEnabled = false
        self.bottom_video_button.isEnabled = false
    }
    
    func error_main_bar(){
        self.main_progress_bar.stopAnimating()
        self.bottom_complete_job.isEnabled = true
        self.bottom_image_button.isEnabled = true
        self.bottom_video_button.isEnabled = true
    }
    
    @IBAction func complete_job_clicked(_ sender: UIBarButtonItem) {
        
        if(self.get_activity_state())
        {
            if(self.check_connection()){
                if(!self.short_description_view.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !self.long_description_view.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty){
                    
                    self.start_main_bar()
                    if(self.completed_form.count > 0)
                    {
                        
                    var should_submit = true;
                        
                    for element in self.completed_form{
                        if(element.value.count == 0)
                        {
                            should_submit = false;
                            break;
                        }
                    }
                        
                    if(should_submit){
                        
                        let taskMap3:[String:Any] = ["short_description":self.short_description_view.text.trimmingCharacters(in: .whitespacesAndNewlines),"description":self.long_description_view.text.trimmingCharacters(in: .whitespacesAndNewlines), "filled_fields": self.completed_form]
                        
                       
                        let taskMap:[String : Any] = ["currently_working": FieldValue.arrayRemove([Auth.auth().currentUser!.uid]), "is_complete" : "true"]
                        
                        let batch = firestore.batch()
                        
                        batch.setData(taskMap, forDocument: firestore.collection("Jobs").document(self.job_uid!), merge: true)
                        
                        let taskMap1 =  ["currently_working_on": FieldValue.arrayRemove([self.job_uid!])]
                        
                        batch.setData(taskMap1, forDocument:firestore.collection("Users").document(Auth.auth().currentUser!.uid), merge: true)
                        
                        batch.setData(taskMap3, forDocument: firestore.collection("Jobs").document(self.job_uid!).collection("job_completion_forms").document(Auth.auth().currentUser!.uid), merge: true)
                        
                        batch.commit { (error) in
                            self.error_main_bar()
                            if (error == nil)
                            {
                            self.is_saved = true
                            self.showToast(controller: self, message: "Job Complete", seconds: 2.0)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                                     self.navigationController?.popViewController(animated: true)
                                })
                            }else{
                                self.showToast(controller: self, message: "Error Completing Job", seconds: 2.0)
                            }
                        }
                        
                        
                    }else{
                         self.error_main_bar()
                        self.showToast(controller: self, message: "Fill all fields", seconds: 2.0)
                    }
                    }else{
                        self.error_main_bar()
                        self.showToast(controller: self, message: "Fill all fields", seconds: 2.0)
                    }
                    
                }else{
                    self.showToast(controller: self, message: "Fill all fields", seconds: 2.0)
                }
            }else{
                self.showToast(controller: self, message: "No Internet Connection", seconds: 2.0)
            }
        }else{
            self.showToast(controller: self, message: "Activity State Error", seconds: 2.0)
        }
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        is_activity_running = true
        
        if(!self.get_activity_state())
        {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if(!is_saved && self.get_activity_state() && self.check_connection())
        {
            /*
            firestore.collection("Jobs").document(self.job_uid!).collection("job_completion_forms").document(Auth.auth().currentUser!.uid).delete()
 */
        }else if (is_saved){
            NotificationCenter.default.post(name: Notification.Name(rawValue: "job_completed"), object: nil)
        }
        is_activity_running = false
    }
    
    
    func get_activity_state() -> Bool {
        
        if ( Auth.auth().currentUser != nil  && Auth.auth().currentUser?.uid != nil && is_activity_running && job_uid != nil){
            return true;
        } else {
            return false;
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (tableView.tag == 0)
        {
            
            if (images_array.count == 0)
            {
                self.images_table_view_height_constraint.constant = 1
                //tableView.sizeToFit()
                self.viewWillLayoutSubviews()
                
            }
            return self.images_array.count
        }
        else if(tableView.tag == 1)
        {
            
            if (videos.count == 0)
            {
                self.videos_table_view_height_constraint.constant = 1
                //tableView.sizeToFit()
                self.viewWillLayoutSubviews()
            }
            return self.videos.count
        }
        else{
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if(tableView.tag == 1)
        {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "job_completion_videos_table_view_cell", for: indexPath) as! jobCompletionVideoTableViewCell
            
            if (indexPath.row < self.videos.count)
            {
                let video_obj = self.videos[indexPath.row]
                
                if let thumb = video_obj.thumb {
                    cell.video_image_view.image = thumb
                }
                cell.video_description.text = video_obj.video_desc ?? ""
                
            }
            
            
            
            
            return cell
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "job_completion_image_table_view_cell", for: indexPath) as! jobCompletionImagesTableViewCell
            
            if (indexPath.row < self.images_array.count)
            {
                let img_obj = self.images_array[indexPath.row]
                if let img = img_obj.image {
                    cell.ind_image.image = img
                }
                cell.description_label.text = img_obj.image_desc ?? ""
            }
            
            return cell
            
        }
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if(tableView.tag  == 0)
        {
            print("height was \(tableView.contentSize.height)")
            self.images_table_view_height_constraint.constant = tableView.contentSize.height
        }else if(tableView.tag == 1)
        {
            print("height was \(tableView.contentSize.height)")
            self.videos_table_view_height_constraint.constant = tableView.contentSize.height
        }
        //tableView.sizeToFit()
        self.viewWillLayoutSubviews()
        
    }
    
    func show_camera_gallery_alert(){
        
        let alert = UIAlertController(title: "Alert", message: "Choose the required option", preferredStyle: .alert)
        
        let gallery_action = UIAlertAction(title: "Gallery", style: .default) { (dismiss_action) in
            
            self.display_gallery()
            
        }
        let camera_action = UIAlertAction(title: "Camera", style: .default) { (dismiss_action) in
            
            self.display_camera()
            
        }
        
        alert.addAction(gallery_action)
        alert.addAction(camera_action)
        present(alert, animated : true, completion : nil)
        
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
    
    @objc func out_tapped() {
        
        if(img_desc_text_field.isEditing){
            self.img_desc_text_field.endEditing(true)
            print("out_tapped here")
        }
        if(video_desc_text_field.isEditing){
            self.video_desc_text_field.endEditing(true)
        }
        long_description_view.endEditing(true)
        short_description_view.endEditing(true)
        print("was here")
        
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
    
    func load_form(){
        
        if(self.get_activity_state())
        {
            
            if(self.check_connection()){
                
                self.drop_downs_list.removeAll()
                self.radio_buttons.removeAll()
                
                self.job_form_obj = job_form_object()
                
                firestore.collection("Jobs").document(self.job_uid!).collection("original_form").order(by: "field_number").getDocuments(completion: { (querySnapshot, error) in
                    
                    if(error != nil)
                    {
                        
                        self.showToast(controller: self, message: "Error loading Form, try again", seconds: 2.0)
                        
                    }else{
                        
                        guard let query_snapshot = querySnapshot else{
                            self.showToast(controller: self, message: "Error loading Form, try again", seconds: 2.0)
                            return
                        }
                        
                        DispatchQueue.main.async {
                            
                            for snapshot in query_snapshot.documents {
                                
                                if let type = snapshot.get("type") as? String{
                                    
                                    if (type == "dropdown"){
                                        
                                        if let cur_obj = self.job_form_obj?.add_dropdown(snapshot: snapshot){
                                            
                        
                                          //  let view = UIView()
                                            
                                            //view.heightAnchor.constraint(equalToConstant: 40).isActive = true
                                           // view.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
                                            
                                            let button = UIButton()
                                            button.heightAnchor.constraint(equalToConstant: 20).isActive = true
                                            button.titleLabel?.textAlignment = .center
                                            button.titleLabel!.font = UIFont.systemFont(ofSize: 18);
                                            
                                            button.setTitleColor(UIColor.black, for: .normal)
                                            button.setTitle(cur_obj.dropdown_title ?? "Select from drop down", for: .normal)
                        
                                            
                                            let cur_stack_view = UIStackView()
                                            
                                            cur_stack_view.axis = .horizontal
                                            
                                            cur_stack_view.spacing = 8
                                            
                                            cur_stack_view.distribution = .equalSpacing
                                            
                                            cur_stack_view.addArrangedSubview(button)
                                            
                                            if let image = UIImage(named: "drop-down-arrow-2")
                                            {
                                            
                                            let imageView = UIImageView(image: image)
                                            imageView.heightAnchor.constraint(equalToConstant: 14).isActive = true
                                            imageView.widthAnchor.constraint(equalToConstant: 14).isActive = true
                                            cur_stack_view.addArrangedSubview(imageView)
                                                
                                            }
                                            
                                            
                                           // view.addSubview(button)
                                            
                                            // button.center = view.center
                                            
                                            let dropDown = DropDown()
                                            
                                            // The view to which the drop down will appear on
                                            dropDown.anchorView = cur_stack_view // UIView or UIBarButtonItem
                                            
                                            // The list of items to display. Can be changed dynamically
                                            dropDown.dataSource = cur_obj.dropdown_elements
                                            
                                            dropDown.direction = .bottom
                                            
                                            dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
                                            
                                            dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
                                                
                                                self.dropdown_selected(doc_id: cur_obj.id,index_sel:index)
                                                button.titleLabel?.text = item
                                                
                                            }
                                        
                                            
                                            self.drop_downs_list.append(dropDown)
                                            
                                            let cur_index = self.drop_downs_list.count - 1
                                            
                                            button.tag = cur_index
                                            
                                            button.addTarget(self, action: #selector(self.drop_clicked),for: .touchUpInside)
                                            
                                            
                                            
                                            self.stack_view.addArrangedSubview(cur_stack_view)
                                            
                                            print("added")
                                            
                                            self.completed_form[cur_obj.id] = []
                                            
                                            
                                        }
                                    }
                                        
                                    else if (type == "radio_button"){
                                        
                                        if let cur_obj = self.job_form_obj?.add_radio_button(snapshot: snapshot){
                                            
                                            let cur_stack_view = UIStackView()
                                            
                                            cur_stack_view.axis = .vertical
                                            
                                            cur_stack_view.spacing = 12
                                            
                                            cur_stack_view.distribution = .equalSpacing
                                            
                                            cur_stack_view.alignment = .center
                                            
                                            let label = UILabel()
                                            
                                            label.textAlignment = .center
                                            
                                            label.text = cur_obj.radio_button_title ?? "Select the revelant option"
                                            
                                            cur_stack_view.addArrangedSubview(label)
                                            
                                            let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20);
                                            
                                            let firstRadioButton = self.createRadioButton(frame: frame, title: cur_obj.individual_radio_buttons[0], color: UIColor.blue);
                                            
                                            firstRadioButton.tag = 0
                                            
                                            firstRadioButton.accessibilityIdentifier = cur_obj.id
                                            
                                            var otherButtons : [DLRadioButton] = [];
                                            
                                            
                                            for (i,element) in cur_obj.individual_radio_buttons.enumerated() {
                                                
                                               if(i>0)
                                               {
                                                
                                                let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20);
                                                
                                                let radioButton = self.createRadioButton(frame: frame, title: element, color: UIColor.blue);
                                                
                                                radioButton.tag = i
                                                
                                                radioButton.accessibilityIdentifier = cur_obj.id
                                                
                                                otherButtons.append(radioButton);
                                                
                                                
                                                }
                                                
                                            }
                                            
                                            firstRadioButton.otherButtons = otherButtons;
                                            
                                            var cur_buttons_array:[DLRadioButton] = []
                                            cur_buttons_array.append(firstRadioButton)
                                            cur_buttons_array.append(contentsOf: otherButtons)
                                            
                                            self.radio_buttons[cur_obj.id] = cur_buttons_array
                                            
                                            for elem in cur_buttons_array{
                                                cur_stack_view.addArrangedSubview(elem)
                                            }
                                            
                                            
                                            self.stack_view.addArrangedSubview(cur_stack_view)
                                            
                                            self.completed_form[cur_obj.id] = []
                                            
                                        }
                                        
                                    }
                                        
                                    else if (type == "check_box"){
                                    
                                        
                                        
                                        if let cur_obj = self.job_form_obj?.add_check_box(snapshot: snapshot){
                                        
                                        let cur_stack_view = UIStackView()
                                            
                                        cur_stack_view.axis = .vertical
                                            
                                        cur_stack_view.spacing = 12
                                            
                                        cur_stack_view.distribution = .equalSpacing
                                            
                                        cur_stack_view.alignment = .center
                                            
                                        let label = UILabel()
                                            
                                        label.textAlignment = .center
                                            
                                        label.text = cur_obj.check_box_title ?? "Check the revelant options"
                                            
                                        cur_stack_view.addArrangedSubview(label)

                                        for (index,element) in cur_obj.individual_check_boxes.enumerated(){
                                                
                                        let checkbox = M13Checkbox()
                                            
                                        checkbox.heightAnchor.constraint(equalToConstant: 20).isActive = true
                                            
                                        checkbox.widthAnchor.constraint(equalToConstant: 20).isActive = true
                                            
                                        checkbox.accessibilityIdentifier = cur_obj.id
                                            
                                        checkbox.tag = index
                                            
                                        checkbox.addTarget(self, action: #selector(self.check_box_clicked),for: .valueChanged)
                                            
                                        let cur_hor_stack_view = UIStackView()
                                            
                                        cur_hor_stack_view.axis = .horizontal
                                            
                                        cur_hor_stack_view.spacing = 8
                                            
                                        cur_hor_stack_view.distribution = .fillProportionally
                                            
                                        let label = UILabel()
                                            
                                        label.text = element
                                            
                                        label.font = UIFont.systemFont(ofSize: 14);
                                            
                                        cur_hor_stack_view.addArrangedSubview(checkbox)
                                            
                                        cur_hor_stack_view.addArrangedSubview(label)
                                            
                                        cur_stack_view.addArrangedSubview(cur_hor_stack_view)
                                                
                                        }
                                            
                                        self.stack_view.addArrangedSubview(cur_stack_view)
                                            
                                        self.completed_form[cur_obj.id] = []
                                            
                                        }
                                        
                                        
                                    }
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                })
                
                
        }else{
            
            self.showToast(controller: self, message: "No interent connection", seconds: 2.0)
            
            }
            
        }
        
    }
    
    @objc func drop_clicked(sender:UIButton){
        
        if(sender.tag < self.drop_downs_list.count)
        {
        let dr_down = self.drop_downs_list[sender.tag]
        dr_down.show()
        }
        
    }
    
    @objc func check_box_clicked(sender:M13Checkbox){
        
       print(sender.tag)
       print(sender.accessibilityIdentifier ?? "None")
       print(sender.checkState)
        
        DispatchQueue.main.async {
            
            if let doc_id = sender.accessibilityIdentifier{
                
                let ind = String(sender.tag)
                
                if var val = self.completed_form[doc_id]{
                    
                    if let index_found = val.firstIndex(of: ind){
                        
                        if(sender.checkState != .checked){
                            val.remove(at: index_found)
                        }
                        
                    }else if(sender.checkState == .checked){
                        val.append(ind)
                    }
                    
                    self.completed_form[doc_id] = val
                }
                
            }
            
        }
        
    }
    
    
    func generate_thumbnail(url:URL) -> UIImage?{
        
        let asset = AVURLAsset(url: url, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        
        do{
            
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let uiImage = UIImage(cgImage: cgImage)
            return uiImage
            
        }catch{
            
            return UIImage(named: "repairing")
            
        }
        
    }
    
    
    
    
    
    @IBAction func play_button_clicked(_ sender: Any) {
        
        if(self.cur_selected_video_url != nil)
        {
            self.play_video(url: self.cur_selected_video_url!)
        }else{
            self.hide_add_img_desc_layout()
        }
        
    }
    
    func play_video(url:URL){
        
        let videoURL = url
        
        let player = AVPlayer(url: videoURL)
        
        let playerViewController = AVPlayerViewController()
        
        playerViewController.player = player
        
        self.present(playerViewController, animated: true) {
            playerViewController.player?.play()
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if(tableView.tag == 1)
        {
            if(indexPath.row < videos.count){
            
            let video = videos[indexPath.row]
                
                if let vid_url = video.url{
                    
           self.play_video(url: vid_url)
                    
                }
            }
            
        }
        
    }
    
    func dropdown_selected(doc_id:String,index_sel:Int){
        
        print(doc_id,index_sel)
        
        self.completed_form[doc_id] = [String(index_sel)]
        
    }
    
    
    private func createRadioButton(frame : CGRect, title : String, color : UIColor) -> DLRadioButton {
        
        let radioButton = DLRadioButton();
        
        radioButton.heightAnchor.constraint(equalToConstant: frame.height).isActive = true
        radioButton.widthAnchor.constraint(equalToConstant: frame.width).isActive = true
        radioButton.titleLabel!.font = UIFont.systemFont(ofSize: 14);
        radioButton.setTitle(title, for: []);
        radioButton.setTitleColor(color, for: []);
        radioButton.iconColor = color;
        radioButton.indicatorColor = color;
        radioButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        radioButton.addTarget(self, action: #selector(self.logSelectedButton), for: UIControl.Event.touchUpInside);
        self.view.addSubview(radioButton);
        
        return radioButton;
        
    }
    
    @objc @IBAction private func logSelectedButton(radioButton : DLRadioButton) {
        
        
        
        if let doc_id = radioButton.accessibilityIdentifier{
            self.completed_form[doc_id] = [String(radioButton.tag)]
        }
        /*
        print(radioButton.accessibilityIdentifier ?? "None")
        print(radioButton.tag)
        
        self.completed_form[]
        
        if (radioButton.isMultipleSelectionEnabled) {
            
            for button in radioButton.selectedButtons() {
                print(String(format: "%@ is selected.\n", button.titleLabel!.text!));
            }
            
        } else {
            print(String(format: "%@ is selected.\n", radioButton.selected()!.titleLabel!.text!));
        }
 */
        
        
        
    }
    
    
    @IBAction func hide_vi_desc_clicked(_ sender: UIButton) {
        self.hide_add_video_desc_layout()
    }
    
    @IBAction func hide_img_desc_clicked(_ sender: UIButton) {
        self.hide_add_img_desc_layout()
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if(editingStyle == .delete){
            if(tableView.tag == 0){
            if(indexPath.row < self.images_array.count){
            if(self.check_connection())
            {
            let obj_found = self.images_array[indexPath.row]
            self.images_array.remove(at: indexPath.row)
            self.images_table_view.reloadData()
            self.delete_image_at_index_path(obj: obj_found, index: indexPath.row)
            }else{
                self.showToast(controller: self, message: "No internet Connectiom", seconds: 2.0)
                }
            }
            }else if (tableView.tag == 1){
                if(indexPath.row < self.videos.count){
                    if(self.check_connection())
                    {
                        let obj_found = self.videos[indexPath.row]
                        self.videos.remove(at: indexPath.row)
                        self.videos_table_view.reloadData()
                        self.delete_video_at_index_path(obj: obj_found, index: indexPath.row)
                    }else{
                        self.showToast(controller: self, message: "No internet Connectiom", seconds: 2.0)
                    }
                }
            }
        }
        
    }
    
    func delete_image_at_index_path(obj:job_completion_image_object, index:Int){
        if(self.get_activity_state())
        {
        if let path = obj.path{
        let store_ref = storage.reference(withPath: path)
            store_ref.delete { (error) in
                if(error == nil){
                    if let taskMap = obj.taskMap{ self.firestore.collection("Jobs").document(self.job_uid!).collection("job_completion_forms").document(Auth.auth().currentUser!.uid).setData(taskMap, merge: true, completion: { (error) in
                        if(error != nil)
                        {
                            self.images_array.insert(obj, at: index)
                            self.images_table_view.reloadData()
                            self.showToast(controller: self, message: "Error deleting Image", seconds: 2.0)
                        }
                    })
                    }
                }else{
                    self.images_array.insert(obj, at: index)
                    self.images_table_view.reloadData()
                    self.showToast(controller: self, message: "Error deleting Image", seconds: 2.0)
                }
            }
        }
        }
    }
    
    func delete_video_at_index_path(obj:job_completion_video_object, index:Int){
        if(self.get_activity_state())
        {
        if let path = obj.path{
            let store_ref = storage.reference(withPath: path)
            store_ref.delete { (error) in
                if(error == nil){
                    if let taskMap = obj.taskMap{ self.firestore.collection("Jobs").document(self.job_uid!).collection("job_completion_forms").document(Auth.auth().currentUser!.uid).setData(taskMap, merge: true, completion: { (error) in
                        if(error != nil){
                            self.videos.insert(obj, at: index)
                            self.videos_table_view.reloadData()
                            self.showToast(controller: self, message: "Error deleting Video", seconds: 2.0)
                        }
                    })
                    }
                }else{
                    self.videos.insert(obj, at: index)
                    self.videos_table_view.reloadData()
                    self.showToast(controller: self, message: "Error deleting Video", seconds: 2.0)
                }
            }
        }
        }
    }
    
    
    
    
}


// check save image logic

// when document deleted delete all files from storage

// implement load job logic

/*
 let taskMap:[String : Any] = ["currently_working": FieldValue.arrayRemove([Auth.auth().currentUser!.uid]), "is_complete" : "true"]
 
 let batch = firestore.batch()
 
 batch.setData(taskMap, forDocument: firestore.collection("Jobs").document(self.job_uid!), merge: true)
 
 let taskMap1 =  ["currently_working_on": FieldValue.arrayRemove([self.job_uid!])]
 
 batch.setData(taskMap1, forDocument:firestore.collection("Users").document(Auth.auth().currentUser!.uid), merge: true)
 
 batch.commit { (error) in
 
 if(error == nil)
 {
 
 self.showToast(controller: self, message: "Job Complete", seconds: 2.0)
 self.navigationController?.popViewController(animated: true)
 self.should_post = true
 
 }else{
 
 self.showToast(controller: self, message: "Error try again", seconds: 2.0)
 
 }
 
 }
 */


