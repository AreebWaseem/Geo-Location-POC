//
//  job_details_view_controller.swift
//  geolocpoc
//
//  Created by Areeb Waseem on 21/07/2019.
//  Copyright © 2019 Areeb Waseem. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import Toast_Swift
import GoogleMaps
import Reachability
import AVKit
import AVFoundation

class job_details_view_controller: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // get from previous view controller
    
    var reachability:Reachability!
    
    var firestore:Firestore!
    
    
    @IBOutlet weak var currently_working_label_height_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var images_table_view: UITableView!
    
    @IBOutlet weak var progress_bar: UIActivityIndicatorView!
    
    var storage:Storage!
    
    var is_activity_running = false
    
    @IBOutlet weak var title_label: UILabel!
    
    @IBOutlet weak var description_label: UILabel!
    
    @IBOutlet weak var currently_working_table_view: UITableView!
    
    
    @IBOutlet weak var images_table_view_height_constraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var bottom_button: UIBarButtonItem!
    
    
    @IBOutlet weak var currently_working_table_view_height_constraint: NSLayoutConstraint!
    
    var job_uid:String?
    
    var job_obj:job_object?
    
    var images_array:[String] = []
    
    @IBOutlet weak var videos_table_view: UITableView!
    
    @IBOutlet weak var videos_table_view_height_constraint: NSLayoutConstraint!
    
    var videos:[String] = []
    
    var current_working_users:[String] = []
    
    var ind_selected_user_uid:String?
    
    var is_working = false
    
    var should_post = false
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        is_activity_running = true
        
        reachability = Reachability.init()
        
        firestore = Firestore.firestore()
        
        storage = Storage.storage()
    
        images_table_view.register(UINib(nibName: "jobsImagesTableViewCell", bundle:nil), forCellReuseIdentifier: "job_individual_image_cell")
        
        images_table_view.rowHeight = UITableView.automaticDimension
        images_table_view.estimatedRowHeight = 120.0
        
        images_table_view.delegate = self
        images_table_view.dataSource = self
        
        
        videos_table_view.register(UINib(nibName: "jobsVideosTableViewCell", bundle:nil), forCellReuseIdentifier: "video_table_view_cell")
        
        videos_table_view.rowHeight = UITableView.automaticDimension
        videos_table_view.estimatedRowHeight = 120.0
        
        videos_table_view.delegate = self
        videos_table_view.dataSource = self
        
        
       currently_working_table_view.register(UINib(nibName: "currentlyWorkingTableViewCell", bundle:nil), forCellReuseIdentifier: "currently_working_cell_iden")
        
       currently_working_table_view.rowHeight = UITableView.automaticDimension
       currently_working_table_view.estimatedRowHeight = 120.0
        
       currently_working_table_view.delegate = self
       currently_working_table_view.dataSource = self
        
        if(self.job_uid == nil)
        {
            self.navigationController?.popViewController(animated: true)
        }else{
            load_job()
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(job_completed),
            name: Notification.Name(rawValue: "job_completed"),
            object: nil
        )
        
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
    
    @IBAction func start_job_clicked(_ sender: UIBarButtonItem) {
        if (self.get_activity_state())
        {
        
        if (self.check_connection() && Auth.auth().currentUser != nil && job_uid != nil)
        {
            if(self.bottom_button.title?.trimmingCharacters(in: .whitespacesAndNewlines) == "Fill Form")
            {
                
                self.performSegue(withIdentifier: "job_details_to_complete_form", sender: self)
                
                
            }else{
                
            let taskMap = ["currently_working":FieldValue.arrayUnion([Auth.auth().currentUser!.uid])]
                
                let batch = firestore.batch()
                
                batch.setData(taskMap, forDocument: firestore.collection("Jobs").document(self.job_uid!), merge: true)
                
                let taskMap1 =  ["currently_working_on": FieldValue.arrayUnion([self.job_uid!])]
                
                batch.setData(taskMap1, forDocument:firestore.collection("Users").document(Auth.auth().currentUser!.uid), merge: true)
                
                
                batch.commit { (error) in
                    if(error == nil)
                    {
                       
                        self.showToast(controller: self, message: "Job Started", seconds: 2.0)
                        self.bottom_button.title = "Fill Form"
                        self.is_working = true
                    }else{
                         self.showToast(controller: self, message: "Couldn't Start Job", seconds: 2.0)
                    }
                }
                
            }
            
        }else{
            if(!self.check_connection())
            {
            showToast(controller: self, message: "No internet Connection", seconds: 2.0)
            }
        }
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
        is_activity_running = false
        if(should_post)
        {
              NotificationCenter.default.post(name: Notification.Name(rawValue: "show_ne_jobs"), object: nil)
        }
    }
    
    @objc func job_completed(){
        
        self.should_post = true
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    
    @IBAction func refresh_clicked(_ sender: UIBarButtonItem) {
        load_job()
    }
    
    @IBAction func group_chat_clicked(_ sender: UIBarButtonItem) {
        if(self.is_working)
        {
        check_group_chat_room()
        }else{
             self.showToast(controller: self, message: "Start Job First", seconds: 2.0)
        }
    }
    
    func check_group_chat_room(){
        
        
        if (self.get_activity_state())
        {
        
            if(self.check_connection())
            {
                 let taskMap = ["group_members": FieldValue.arrayUnion([Auth.auth().currentUser!.uid])]
                
                firestore.collection("Jobs").document(self.job_uid!).collection("message_rooms").document("group_chat").setData(taskMap, merge: true) { (error) in
                    if(error == nil)
                    {
                       self.performSegue(withIdentifier: "job_details_to_group_chat_segue", sender: self)
                    }else{
                        self.showToast(controller: self, message: "Error try again", seconds: 2.0)
                    }
                }
            }else{
                self.showToast(controller: self, message: "No internet connection", seconds: 2.0)
            }
            
        }
        
    }
    
    
    func load_job(){
        if(self.get_activity_state())
        {
        if(self.check_connection())
        {
            
        self.progress_bar.startAnimating()
        self.images_array.removeAll()
        self.videos.removeAll()
        self.images_table_view.reloadData()
        self.videos_table_view.reloadData()
        self.current_working_users.removeAll()
        self.currently_working_table_view.reloadData()
        is_working = false
            
            
        firestore.collection("Jobs").document(job_uid!).getDocument { (snapshot, error) in
            
            self.progress_bar.stopAnimating()
            
            if(error == nil && snapshot != nil)
            {
                
                print("got job")
                self.job_obj = job_object(snapshot: snapshot!)
                self.title_label.text = self.job_obj?.title ?? ""
                self.description_label.text = self.job_obj?.description ?? ""
                
                if(!(self.job_obj?.image_paths.isEmpty ?? true))
                {
                    self.images_array = self.job_obj!.image_paths
                    self.images_table_view.reloadData()
                    print(self.images_array.count)
                }
                
                if(!(self.job_obj?.videos.isEmpty ?? true))
                {
                    self.videos = self.job_obj!.videos
                    self.videos_table_view.reloadData()
                    print(self.videos.count)
                }
                if(!(self.job_obj?.currently_working_users.isEmpty ?? true)){
                    
                    self.current_working_users = self.job_obj!.currently_working_users
                    
                    if let index = self.current_working_users.firstIndex(of: Auth.auth().currentUser?.uid ?? ""){

                        self.current_working_users.remove(at: index)
                        self.is_working = true
                        self.bottom_button.title = "Fill Form"
                        
                    }
                    
                    if(self.current_working_users.count > 0)
                    {
                    self.currently_working_label_height_constraint.constant = 28
                    }
                    
                    self.currently_working_table_view.reloadData()
                    print(self.current_working_users.count)
                    
                }else{
                    self.currently_working_label_height_constraint.constant = 0
                }
                
            }else{
                self.showToast(controller: self, message: error?.localizedDescription ?? "Error getting data", seconds: 2.0)
            }
            
        }
        }else{
            self.showToast(controller: self, message: "No internet connection", seconds: 2.0)
        }
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
    
    func start_job(){
        
        if(Auth.auth().currentUser != nil)
        {
            
        }else{
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    
    //////////////////// Table View Methods //////////////////
    
    
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
        }else if(tableView.tag == 2)
        {
            if(current_working_users.count == 0)
            {
            self.currently_working_table_view_height_constraint.constant = 1
            self.viewWillLayoutSubviews()
            }
            return current_working_users.count
        }
        else{
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(tableView.tag == 1)
        {
             let cell = tableView.dequeueReusableCell(withIdentifier: "video_table_view_cell", for: indexPath) as! jobsVideosTableViewCell
            
            if(indexPath.row < videos.count)
            {
                cell.video_path = videos[indexPath.row]
               // cell.thumbnail(url_string: cell.video_path!)
            }
            
            return cell
            
        }else if (tableView.tag == 0){
        
         let cell = tableView.dequeueReusableCell(withIdentifier: "job_individual_image_cell", for: indexPath) as! jobsImagesTableViewCell
        
        if(indexPath.row < self.images_array.count)
        {
            let image_path = self.images_array[indexPath.row]
            cell.image_path = image_path
        }
        
        return cell
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "currently_working_cell_iden", for: indexPath) as! currentlyWorkingTableViewCell
            
            if(indexPath.row < self.current_working_users.count)
            {
                let uid = self.current_working_users[indexPath.row]
                cell.load_name(user_uid: uid)
                cell.load_image(user_uid: uid)
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
        }else if (tableView.tag == 2)
        {
              self.currently_working_table_view_height_constraint.constant = tableView.contentSize.height
        }
        //tableView.sizeToFit()
        self.viewWillLayoutSubviews()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        if(tableView.tag == 1)
        {
            if(indexPath.row < self.videos.count){
        let video = videos[indexPath.row]
        play_video(url: video)
            }
            
        }
        else if(tableView.tag == 2)
        {
            
        if(self.is_working)
        {
            
        if(indexPath.row < self.current_working_users.count){
            
        self.ind_selected_user_uid = self.current_working_users[indexPath.row]
        self.check_room()
            
        }
            
        }else{
            self.showToast(controller: self, message: "Start Job First", seconds: 2.0)
            }
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "job_details_to_single_chat_segue", let set_vc = segue.destination as? singleChatViewController, let with_user_uid = self.ind_selected_user_uid, let j_uid = self.job_uid {
            set_vc.chat_with_user_uid = with_user_uid
            set_vc.job_uid = j_uid
        }
        else if segue.identifier == "job_details_to_group_chat_segue", let set_vc = segue.destination as? groupChatViewController, let j_uid = self.job_uid {
            set_vc.job_uid = j_uid
        }else if segue.identifier == "job_details_to_complete_form", let set_vc = segue.destination as? jobCompletionViewController, let j_uid = self.job_uid{
            set_vc.job_uid = j_uid
        }
        
    }
    
    ////////////////////////////// video code //////////////////////////////////////////////
    
    
    func play_video(url:String){
        
        let videoURL = URL(string: url)
        
        let player = AVPlayer(url: videoURL!)
        
        let playerViewController = AVPlayerViewController()
        
        playerViewController.player = player
        
        self.present(playerViewController, animated: true) {
            playerViewController.player?.play()
        }
        
    }
    
    
    /////////////////////////// Room Creation //////////////////////////////////////////
    
    func check_room(){
        // find right place
        if self.get_activity_state(), let current_uid = Auth.auth().currentUser?.uid, let job_uid = self.job_uid, let ind_selected_user_uid = self.ind_selected_user_uid
        {
            
            if(self.check_connection())
            {
                
                if(!self.get_message_room_uid().isEmpty){
                    firestore.collection("Jobs").document(job_uid).collection("message_rooms").document(get_message_room_uid()).getDocument { (snapshot, error) in
                
                if(error == nil)
                {
                    
                    if(snapshot != nil && (snapshot!.data()?.count ?? 0 > 0 ))
                    {
                         self.performSegue(withIdentifier: "job_details_to_single_chat_segue", sender: self)
                    }else{
                        
                        let array:[String] = [current_uid , ind_selected_user_uid]
                        
                        let taskMap:[String:Any] = ["between": array]
                        self.firestore.collection("Jobs").document(job_uid).collection("message_rooms").document(self.get_message_room_uid()).setData(taskMap, merge: true, completion: { (error) in
                            if(error == nil)
                            {
                                
                                self.performSegue(withIdentifier: "job_details_to_single_chat_segue", sender: self)
                                
                            }else{
                                
                                self.showToast(controller: self, message: "Error creating chat room", seconds: 2.0)
                                
                            }
                        })
                        
                    }
                    
                }else{
                    self.showToast(controller: self, message: "Error try again" , seconds: 2.0)
                }
                
            }
                
            }else{
                self.showToast(controller: self, message: "Error try again", seconds: 2.0)
            }
                
            }else{
                self.showToast(controller: self, message: "No internet connection", seconds: 2.0)
            }
            
        }else{
           self.showToast(controller: self, message: "Error try again", seconds: 2.0)
        }
        
    }
    
    
    
    func get_activity_state() -> Bool {
        
        if ( Auth.auth().currentUser != nil  && Auth.auth().currentUser?.uid != nil && is_activity_running && job_uid != nil){
            return true;
        } else {
            return false;
        }
        
    }
    
    
    func get_message_room_uid() -> String{
        
        var comp_uid = ""
        
        if(get_activity_state() && ind_selected_user_uid != nil)
        {
        comp_uid = Auth.auth().currentUser!.uid < ind_selected_user_uid! ? Auth.auth().currentUser!.uid + "_" + ind_selected_user_uid! : ind_selected_user_uid! + "_" + Auth.auth().currentUser!.uid
        }
        return comp_uid
        
    }
    
    

}
