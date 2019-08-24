//
//  MainViewController.swift
//  geolocpoc
//
//  Created by Areeb Waseem on 7/6/19.
//  Copyright © 2019 Areeb Waseem. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import CoreLocation
import Toast_Swift
import GoogleMaps
import Reachability


class MainViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var locationManager:CLLocationManager?
    
    @IBOutlet weak var latitude_label: UILabel!
    
    @IBOutlet weak var map_view: GMSMapView!
    
    @IBOutlet weak var heading_label: UILabel!
    
    @IBOutlet weak var compass_icon: UIImageView!
    
    
    @IBOutlet weak var longitude_label: UILabel!
    
    
    @IBOutlet weak var location_details_label: UILabel!
    
    
    var is_location_set = false
    
    var reachability:Reachability!
    
    var firestore:Firestore!
    
    var storage:Storage!
    
    @IBOutlet weak var compass_stack_view: UIStackView!
    
    
    @IBOutlet weak var compass_distance_label: UILabel!
    
    var array:[String] = []
    
    var markers_array:[GMSMarker] = []
     var users_markers_array:[GMSMarker] = []
    
    var is_getting_jobs = false
    
    var users:[user_object] = []
    var user_ids:[String] = []
    var is_map_set = false
    var is_activity_running = false
    
    var users_listener:ListenerRegistration?
    
    var timer:Timer?
    
    var updated_user_location:GeoPoint?
    
    var jobs_array:[job_object] = []
    
    var selected_job_id:String?
    
    var is_job_marker_set = false
    
    var job_listener:ListenerRegistration?
    
    var updated_job_location:GeoPoint?
    
    var should_track = false
    
    
    @IBOutlet weak var jobs_outer_view: UIView!
    
    
    
    @IBOutlet weak var jobs_table_view: UITableView!
    
    
    
    @IBOutlet weak var jobs_button: UIBarButtonItem!
    
    var selected_job_marker:GMSMarker?
    
    var first_three_jobs:[job_object] = []
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        is_activity_running = true
        
        reachability = Reachability.init()
        
        firestore = Firestore.firestore()
        
        storage = Storage.storage()
        
        locationManager = CLLocationManager()
        
        locationManager?.delegate = self
        
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        
        map_view.delegate = self
        
        jobs_table_view.delegate = self
        
        jobs_table_view.dataSource = self
        
        jobs_table_view.register(UINib(nibName: "job_table_view_cell", bundle:nil), forCellReuseIdentifier: "jobs_table_view_cell")
        
        if(check_location_permission()){
            
            set_map_view()
            
        }
        
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if(user == nil)
            {
                
                if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse)
                {
                    self.users_listener?.remove()
                    self.locationManager?.stopUpdatingLocation()
                    self.locationManager?.stopUpdatingHeading()
                }
                
                self.navigationController?.popToRootViewController(animated: true)
                // self.dismiss(animated: <#T##Bool#>, completion: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
              //  self.navigationController?.popViewController(animated: true)
               // self.dismiss(animated: true, completion: nil)
                
            }
        }
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(show_ne_jobs),
            name: Notification.Name(rawValue: "show_ne_jobs"),
            object: nil
        )
        
        
     
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func show_ne_jobs(){
        
        let alert = UIAlertController(title: "Alert", message: "Job completed, consider navigating to other nearby jobs", preferredStyle: .alert)
        
        
        let dismiss_action = UIAlertAction(title: "Dismiss", style: .default) { (dismiss_action) in
            print("dismissed")
        }
        
        let show_nearby = UIAlertAction(title: "Show Nearby Jobs", style: .default) { (near_action) in
            self.get_nearest_jobs()
        }
        
        alert.addAction(dismiss_action)
        alert.addAction(show_nearby)
        present(alert, animated : true, completion : nil)
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        is_activity_running = true
        self.navigationItem.hidesBackButton = true
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(update_firestore_location), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        is_activity_running = false
        users_listener?.remove()
        timer?.invalidate()
        timer = nil
    }
    
    
    ////////////////////// Alert Events ////////////////////////
    
    
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
    
    
    
    ///////////////////////// Map events //////////////////////
    
    
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        let job_data = marker.userData as? Dictionary<String, String>
        if(job_data != nil)
        {
        print(job_data!["job_uid"] ?? "Null uid")
        }else{
        print("Null uid")
        }
        var snip_string = ""
        if let job_data = marker.userData as? Dictionary<String,String>
        {
            
            if let desc = job_data["description"]
            {
              snip_string = "Description: " + desc + "\n"
            }
            
        }
        if(self.updated_user_location != nil)
        {
            // change this
            
            if let loc_dist = self.get_distance(first_loc: self.updated_user_location, second_loc: GeoPoint(latitude: marker.position.latitude, longitude: marker.position.longitude))
            {
                self.show_job_details()
                if (loc_dist < 10)
                {
                    self.stop_tracking()
                   // self.show_job_details()
                }else{
                snip_string = snip_string  + "Distance: " + String(format: "%.0f", loc_dist) + "m"
                }
            }
            
        }
        if(!snip_string.isEmpty)
        {
          marker.snippet = snip_string
        }
        
        return false
    }

    
    
    ///////////////////////// Permission events //////////////////////
    
    
    
    func check_location_permission()->Bool{
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse)
        {
            return true
        }else{
            return false
        }
    }
    
    func request_loc_auth()
    {
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse)
        {
            start_update()
        }else{
            if(locationManager == nil)
            {
                print("nil manager")
            }
            locationManager?.requestAlwaysAuthorization()
        }
    }
    
    /////////////////////// Location Events //////////////////////
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if (status == .authorizedAlways || status == .authorizedWhenInUse)
        {
            set_map_view()
            start_update()
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        show_alert(heading: "Location Error", body: error.localizedDescription)
        // showToast(controller: self, message: NSLocalizedString("no_internet_connection", comment: ""), seconds: 2.0)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if (locations.last?.horizontalAccuracy != nil && self.get_activity_state())
        {
            let accuracy:Double = (locations.last?.horizontalAccuracy)!
            
            if (accuracy < 0)
            {
                return
            }
            
            if(accuracy >= 0 && accuracy < 100)
            {
                
                if (locations.last?.coordinate.latitude != nil && locations.last?.coordinate.longitude != nil)
                {
                    let lat:Double = (locations.last?.coordinate.latitude)!
                    let lon:Double  = (locations.last?.coordinate.longitude)!
                    
                    let ge_po = GeoPoint(latitude: lat, longitude: lon)
                    self.updated_user_location = ge_po
                    
                    print(accuracy)
                    
                   // if(!is_location_set || should_track)
                    if(!is_location_set)
                    {
                        is_location_set = true
                        /*
                        if(!is_location_set)
                        {
                        is_location_set = true
                        }
 */
                        set_camera_position(lat: lat, lon: lon)
                        
                    }
                    
                    //  getAddressFromLatLon(pdblLatitude: (String(lat)), withLongitude: String(lon))
                }
                
            }
            
        }
        
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        if(newHeading.headingAccuracy < 0)
        {
            return
        }
        
        if(self.get_activity_state())
        {
        //print("Heading Accuracy: ",newHeading.headingAccuracy)
        // print("Magnetic Heading: ", newHeading.magneticHeading)
        // print("True Heading: ", newHeading.trueHeading)
        
        let heading:Double = newHeading.trueHeading
            
        //print(heading)
        
        //heading_label.text = "Heading: " + String(format: "%.0f",heading)
        
            if let user_loc = updated_user_location,let job_loc = updated_job_location , should_track {
                
                
                let bearing = self.getBearingBetweenTwoPoints1(point1: CLLocation(latitude: user_loc.latitude, longitude: user_loc.longitude), point2: CLLocation(latitude: job_loc.latitude, longitude: job_loc.longitude))
                
                
               // + (360 - heading) + bearing
                let heading_updated:Double = (360-heading) + bearing
                
                /*
                if(heading_updated > 360)
                {
                    heading_updated = 360 - heading_updated
                }
 */
                
                
                
                UIView.animate(withDuration: 0.5) {
                    
                    let angle = heading_updated * .pi / 180  // convert from degrees to radians
                    self.compass_stack_view.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
                    if let loc_dist = self.get_distance(first_loc: self.updated_user_location, second_loc: self.updated_job_location)
                    {
                        self.compass_distance_label.text = String(format: "%.0f", loc_dist) + "m"
                    }
                    
                }
                
            }
            
        }
        
    }
    
    
    func degreesToRadians(degrees: Double) -> Double { return degrees * .pi / 180.0 }
    func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / .pi }
    
    func getBearingBetweenTwoPoints1(point1 : CLLocation, point2 : CLLocation) -> Double {
        
        let lat1 = degreesToRadians(degrees: point1.coordinate.latitude)
        let lon1 = degreesToRadians(degrees: point1.coordinate.longitude)
        
        let lat2 = degreesToRadians(degrees: point2.coordinate.latitude)
        let lon2 = degreesToRadians(degrees: point2.coordinate.longitude)
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        return radiansToDegrees(radians: radiansBearing)
    }
    

    
    /////////////////////// Button Events  ///////////////////////


    @IBAction func logout_button_clicked(_ sender: UIBarButtonItem) {
        
        if(Auth.auth().currentUser == nil)
        {
           self.navigationController?.popToRootViewController(animated: true)
        }else
        {
        do{
            try Auth.auth().signOut()
        }catch{
            show_alert(heading: "Error", body: "Try Again")
        }
        }
        
    }
    
    
    
    @IBAction func proflie_clicked(_ sender: UIBarButtonItem) {
        
        self.hide_table_view()
        performSegue(withIdentifier: "main_to_edit_info_segue", sender: self)
        
    }
    
    
    @IBAction func location_clicked(_ sender: UIBarButtonItem) {
        
        self.hide_table_view()
        
        if (!((CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways) || (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse)))
        {
            //self.show_alert(heading: "Alert", body: "Grant location permission from settings")
            self.showToast(controller: self, message: "Allow location permission", seconds: 2.0)
            request_loc_auth()
        }else{
            start_update()
        }
        
    }
    
    // not in use
    @IBAction func users_clicked(_ sender: UIBarButtonItem) {
        get_all_users()
    }
    
    
    @IBAction func jobs_clicked(_ sender: UIBarButtonItem) {
        
        if(self.updated_user_location != nil)
        {
            
        if(!should_track)
        {
            
        self.get_all_jobs()
            
        }else{
            
        self.stop_tracking()
            
        }
            
        }else{
            
            self.showToast(controller: self, message: "User location not available", seconds: 2.0)
            
        }
        
    }
    
    /////////////////////////   Functions ////////////////////////////////////////
    
    
    
    func start_update()
    {
    //  locationManager?.stopUpdatingHeading()
    //  locationManager?.stopUpdatingLocation()
        locationManager?.startUpdatingHeading()
        locationManager?.startUpdatingLocation()
    }

    
    
    
    func set_map_view()
    {
        
        let camera = GMSCameraPosition.camera(withLatitude: 31.536236, longitude: 74.412750, zoom: 16)
        self.map_view.camera = camera
        self.map_view.isMyLocationEnabled = true
        self.map_view.settings.myLocationButton = true
          is_map_set = true
        
    }
    
    
    func set_camera_position(lat:Double ,lon:Double){
        
         let current_position = GMSCameraPosition.camera(withLatitude: lat,
         longitude: lon,
         zoom: 18)
         self.map_view.animate(to: current_position)
        // self.map_view.camera = current_position
        
    }
    
    
    func set_up_job_marker(lat:Double , lon:Double, job_uid:String, job_title:String, job_description:String){
        
    let initialLocation = CLLocationCoordinate2DMake(lat, lon)
    let marker = GMSMarker(position: initialLocation)
    marker.title = job_title
    var job_data = Dictionary<String, String>()
    job_data["job_uid"] = job_uid
    job_data["description"] = job_description
    marker.userData = job_data
    marker.icon = UIImage(named: "job_icon_small")
    marker.appearAnimation = GMSMarkerAnimation.pop
    marker.map = map_view
    self.markers_array.append(marker)
        
    }
    
    
    // change this
    
    func get_all_jobs(){
        
        if(self.get_activity_state())
        {
            
            if(self.check_connection())
            {
                
                
                if(!is_getting_jobs)
                {
                    
                    if(self.is_map_set)
                    {
                        
                    is_getting_jobs = true
                        
                    // self.delete_all_markers()
                        
                    self.reset_table_view()
                
                
                firestore.collection("Jobs").getDocuments { (snapshot, error) in
                    
                    if(error != nil)
                    {
                        
                        self.is_getting_jobs = false
                        self.showToast(controller: self, message: error?.localizedDescription ?? "Error getting Jobs", seconds: 3.0)
                        
                    }else{
                        
                        guard let snapshot = snapshot else {
                              self.is_getting_jobs = false
                            print("Error fetching snapshots: \(error!)")
                            return
                        }
                        
                            if(snapshot.count > 0)
                            {
                                
                                DispatchQueue.main.async {
                                    
                                for ind_job in snapshot.documents{
                                    
                                    if(ind_job.get("job_location") != nil)
                                    {
                                        
                                        
                                        if (ind_job.get("job_location") as? GeoPoint) != nil{
                                            
                                            if let com_status = ind_job.get("is_complete") as? String{
                                                
                                                if(!(com_status == "true"))
                                                {
                                                    let job_obj = job_object(snapshot: ind_job)
                                                    
                                                    if let loc_dist = self.get_distance(first_loc: job_obj.job_location, second_loc: self.updated_user_location){
                                                        job_obj.current_user_distance = loc_dist
                                                    }
                                                    self.jobs_array.append(job_obj)
                                                }
                                                
                                            }else{
                                                
                                                let job_obj = job_object(snapshot: ind_job)
                                                
                                                if let loc_dist = self.get_distance(first_loc: job_obj.job_location, second_loc: self.updated_user_location){
                                                    job_obj.current_user_distance = loc_dist
                                                }
                                                
                                                self.jobs_array.append(job_obj)
                                                
                                            }
                                            
                                        }
                                        
                                        
                                        
                                        
                                        /*
                                        let geo_location = ind_job.get("job_location") as? GeoPoint
                                        
                                        let latitude = geo_location?.latitude
                                        let longitude = geo_location?.longitude
                                        let job_title = ind_job.get("title") as? String ?? "Job"
                                        let job_description = ind_job.get("description") as? String ?? "Details"
                                        let job_uid = ind_job.documentID
                                        
                                        if(latitude != nil && longitude != nil)
                                        {
                                            self.set_up_job_marker(lat: latitude!,lon: longitude!,job_uid: job_uid,job_title: job_title, job_description: job_description)
                                        }
 */
                                    
                                        
                                        
                                    }
                                    
                                }
                                    
                                self.jobs_array = self.jobs_array.sorted(by: { $0.current_user_distance < $1.current_user_distance })
                                self.show_table_view()
                                self.jobs_table_view.reloadData()
                                    
                                }
                                
                            }else{
                                self.showToast(controller: self, message: "No jobs found", seconds: 3.0)
                            }
                        
                        self.is_getting_jobs = false
                        
                    }
                    
                    }
                        
                    }else{
                        self.showToast(controller: self, message: "Map not initialized", seconds: 2.0)
                    }
                    
                }
                
               
                
            }else{
                showToast(controller: self, message: "No Internet Connection", seconds: 2.0)
            }
            
        }else if(Auth.auth().currentUser != nil && !is_activity_running)
        {
           is_activity_running = true
        }
        
    }
    
    
    
    func get_nearest_jobs(){
        
        if(self.get_activity_state())
        {
            
            if(self.check_connection())
            {
                
                if(!is_getting_jobs)
                {
                    if(self.updated_user_location != nil)
                    {
                    
                    if(self.is_map_set)
                    {
                        
                        is_getting_jobs = true
                        
                        // self.delete_all_markers()
                        
                        self.reset_table_view()
                        
                        
                        firestore.collection("Jobs").getDocuments { (snapshot, error) in
                            
                            if(error != nil)
                            {
                                
                                self.is_getting_jobs = false
                                self.showToast(controller: self, message: error?.localizedDescription ?? "Error getting Jobs", seconds: 3.0)
                                
                            }else{
                                
                                guard let snapshot = snapshot else {
                                    self.is_getting_jobs = false
                                    print("Error fetching snapshots: \(error!)")
                                    return
                                }
                                
                                if(snapshot.count > 0)
                                {
                                    
                                    DispatchQueue.main.async {
                                        
                                        for ind_job in snapshot.documents{
                                            
                                            if(ind_job.get("job_location") != nil)
                                            {
                                                
                                                
                                                if (ind_job.get("job_location") as? GeoPoint) != nil{
                                                    
                                                    if let com_status = ind_job.get("is_complete") as? String{
                                                        
                                                        if(!(com_status == "true"))
                                                        {
                                                            let job_obj = job_object(snapshot: ind_job)
                                                            
                                                            if let loc_dist = self.get_distance(first_loc: job_obj.job_location, second_loc: self.updated_user_location){
                                                                job_obj.current_user_distance = loc_dist
                                                            }
                                                            self.jobs_array.append(job_obj)
                                                        }
                                                        
                                                    }else{
                                                        
                                                        let job_obj = job_object(snapshot: ind_job)
                                                        
                                                        if let loc_dist = self.get_distance(first_loc: job_obj.job_location, second_loc: self.updated_user_location){
                                                            job_obj.current_user_distance = loc_dist
                                                        }
                                                        
                                                        self.jobs_array.append(job_obj)
                                                        
                                                    }
                                                    
                                                }
                                                
                                                
                                                
                                                
                                                /*
                                                 let geo_location = ind_job.get("job_location") as? GeoPoint
                                                 
                                                 let latitude = geo_location?.latitude
                                                 let longitude = geo_location?.longitude
                                                 let job_title = ind_job.get("title") as? String ?? "Job"
                                                 let job_description = ind_job.get("description") as? String ?? "Details"
                                                 let job_uid = ind_job.documentID
                                                 
                                                 if(latitude != nil && longitude != nil)
                                                 {
                                                 self.set_up_job_marker(lat: latitude!,lon: longitude!,job_uid: job_uid,job_title: job_title, job_description: job_description)
                                                 }
                                                 */
                                                
                                                
                                                
                                            }
                                            
                                        }
                                        
                                        self.jobs_array = self.jobs_array.sorted(by: { $0.current_user_distance < $1.current_user_distance })
                                        
                                        for (index, element) in self.jobs_array.enumerated(){
                                            if(index == 3)
                                            {
                                             break
                                            }else{
                                               self.first_three_jobs.append(element)
                                            }
                                        }
                                        self.jobs_array.removeAll()
                                        self.jobs_array = self.first_three_jobs
                                        self.show_table_view()
                                        self.jobs_table_view.reloadData()
                                        
                                    }
                                    
                                }else{
                                    self.showToast(controller: self, message: "No jobs found", seconds: 3.0)
                                }
                                
                                self.is_getting_jobs = false
                                
                            }
                            
                        }
                        
                    }else{
                        self.showToast(controller: self, message: "Map not initialized", seconds: 2.0)
                    }
                    
                    }else{
                      self.showToast(controller: self, message: "No User Location", seconds: 2.0)
                    }
                    
                }
                
            }else{
                showToast(controller: self, message: "No Internet Connection", seconds: 2.0)
            }
            
        }else if(Auth.auth().currentUser != nil && !is_activity_running)
        {
            is_activity_running = true
        }
        
    }
    
    
    func show_table_view(){
        jobs_outer_view.isHidden = false
    }
    
    func hide_table_view(){
        jobs_outer_view.isHidden = true
    }
    
    
    func delete_all_jobs(){
        
        jobs_array.removeAll()
        
    }
    
    func delete_all_markers(){
        for marker in markers_array{
            marker.map = nil
        }
        markers_array.removeAll()
    }
    
    func delete_user_markers(){
        for user in users{
        user.marker?.map = nil
        }
        self.user_ids.removeAll()
        self.users.removeAll()
    }
    
    // Change this
    
    func get_all_users(){
        
        if(self.get_activity_state())
        {
            if(self.check_connection())
            {
                
                if(is_map_set)
                {
                // continue here.........
                users_listener?.remove()
                delete_user_markers()
                
               users_listener = firestore.collection("Users").addSnapshotListener { (snapshot, error) in
              
                if(self.get_activity_state()){
                
                    if(error != nil)
                    {
                         self.showToast(controller: self, message: error?.localizedDescription ?? "Error getting Jobs", seconds: 3.0)
                    }else{
                        
                        guard let snapshot = snapshot else {
                            print("Error fetching snapshots: \(error!)")
                            return
                        }
                        
                        
                        snapshot.documentChanges.forEach { pulled_user in
                            
                            if let uid = Auth.auth().currentUser?.uid , uid != pulled_user.document.documentID
                            {
                            
                            if (pulled_user.type == .added) {
                                
                               if(!self.user_ids.contains(pulled_user.document.documentID))
                               {
                                
                                let doc_snapshot = pulled_user.document
                                
                              //  let obj = user_object.in
                                let obj = user_object(doc_snapshot: doc_snapshot)
                                
                                if let marker = obj.set_marker(user_loc: doc_snapshot.get("user_location") as? GeoPoint){
                                        marker.map = self.map_view
                                }
                                self.user_ids.append(doc_snapshot.documentID)
                                self.users.append(obj)
                                }
                                
                            }
                            
                            if (pulled_user.type == .modified) {
                                
                                
                                 let doc_snapshot = pulled_user.document
                                
                                if let index = self.user_ids.firstIndex(of: doc_snapshot.documentID){
                                    
                                    if(index < self.users.count)
                                    {
                                        
                                        if let marker = self.users[index].set_marker(user_loc: doc_snapshot.get("user_location") as? GeoPoint){
                                            if(marker.map == nil)
                                            {
                                                marker.map = self.map_view
                                            }
                                        }
                                        
                                        /*
                                         self.users[index] = user_object.init(id: doc_snapshot.documentID, name: doc_snapshot.get("name") as? String ?? "", designation: doc_snapshot.get("designation") as? String ?? "", email: doc_snapshot.get("email") as? String ?? "", type: doc_snapshot.get("type") as? String ?? "", user_location: doc_snapshot.get("user_location") as? GeoPoint ?? nil)
                                         */
                                    }
                                    
                                }
                                
                            }
                            
                            if (pulled_user.type == .removed) {
                                
                                if let index = self.user_ids.firstIndex(of: pulled_user.document.documentID)
                                {
                                        if(index < self.user_ids.count && index < self.users.count )
                                        {
                                            self.user_ids.remove(at: index)
                                            self.users[index].marker?.map = nil
                                            self.users.remove(at: index)
                                        }
                                }
                              //  print("Removed city: \(diff.document.data())")
                            }
                            
                        }
                        }
                        
                    }
                    }else{
                        self.users_listener?.remove()
                    }
                }
                }else{
                    self.showToast(controller: self, message: "Map not initialized", seconds: 2.0)
                }
            }else{
                self.showToast(controller: self, message: "No internet connection", seconds: 3.0)
            }
        }else if(Auth.auth().currentUser != nil && !is_activity_running)
        {
            is_activity_running = true
        }
    }
    
    func update_user_marker(user_obj:user_object, index: Int)
    {
        
        guard let user_location = user_obj.user_location else {
            return
        }
        
        let initialLocation = CLLocationCoordinate2DMake(user_location.latitude, user_location.longitude)
        let marker = GMSMarker(position: initialLocation)
        marker.title = user_obj.name
        var user_data = Dictionary<String, String>()
        user_data["user_uid"] = user_obj.id
        marker.userData = user_data
        marker.icon = UIImage(named: "user_icon")
        marker.appearAnimation = GMSMarkerAnimation.pop
        marker.map = map_view
        self.users_markers_array.append(marker)
        
    }
    
    /////////////////////////// Firestore update location //////////////////////////////////
    
    @objc func update_firestore_location(){
        if(get_activity_state())
        {
            if let uid = Auth.auth().currentUser?.uid, let user_cur_loc:GeoPoint = self.updated_user_location
            {
                let taskMap = ["user_location": user_cur_loc]
               firestore.collection("Users").document(uid).setData(taskMap, merge: true)
            }
        }
    }
        
    /////////////////////////// Activity State ///////////////////////////////
    
    func get_activity_state() -> Bool {
        
        if ( Auth.auth().currentUser != nil  && Auth.auth().currentUser?.uid != nil && is_activity_running){
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
    
    
    
    func get_distance(first_loc: GeoPoint?, second_loc : GeoPoint?)-> Double?
    {
        
        if let lat1 = first_loc?.latitude, let lon1 = first_loc?.longitude , let lat2 = second_loc?.latitude, let lon2 = second_loc?.longitude
        {
        let loc_one = CLLocation(latitude: lat1, longitude: lon1)
        let loc_two = CLLocation(latitude: lat2, longitude: lon2)
        return loc_one.distance(from: loc_two)
        }else{
           return nil
        }
        
    }
    
    
    ///////////////////////// Table View Methods ////////////////////////////////////
    
    
    func reset_table_view(){
        
        is_job_marker_set = false
        selected_job_marker?.map = nil
        self.jobs_array.removeAll()
        self.first_three_jobs.removeAll()
        self.jobs_table_view.reloadData()
        self.hide_table_view()
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        if(index < self.jobs_array.count)
        {
            self.selected_job_id = jobs_array[index].id
        }
        self.jobs_table_view.deselectRow(at: indexPath, animated: true)
        self.reset_table_view()
        self.start_navigation()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let index = indexPath.row
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "jobs_table_view_cell", for: indexPath) as! job_table_view_cell
        
       
        if(index < jobs_array.count)
        {
            
        let obj = jobs_array[index]
        cell.title_label.text = obj.title
            
            
            
        let dist_string = "Distance: " + String(format: "%.0f", obj.current_user_distance) + "m"
        cell.distance_label.text = dist_string
            
            
            
            /*
            
        if let loc_dist = get_distance(first_loc: obj.job_location, second_loc: self.updated_user_location){
                
               let dist_string = "Distance: " + String(format: "%.0f", loc_dist) + "m"
               cell.distance_label.text = dist_string
                
            }
 */
            
        }
            
        return cell
        
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return jobs_array.count
        
    }
    
    
    //////////////////////// User Navigation ////////////////////////////////////////////
    
    func start_navigation(){
        
        if let job_id = selected_job_id{
            
           job_listener = firestore.collection("Jobs").document(job_id).addSnapshotListener { (snapshot, error) in
                if(error == nil && snapshot != nil)
                {
                    self.set_job_marker(snapshot: snapshot!)
                }else{
                    
                    self.showToast(controller: self, message: error?.localizedDescription ?? "Error", seconds: 2.0)
                    
                }
            }
            
        }else{
            self.show_alert(heading: "Error", body: "Null Job id")
        }
        
    }
    
    func set_job_marker(snapshot:DocumentSnapshot){
        
        if(!is_job_marker_set)
        {
            if let job_loc = snapshot.get("job_location") as? GeoPoint{
                
            updated_job_location = job_loc
                
            let job_obj = job_object(snapshot: snapshot)
            let initialLocation = CLLocationCoordinate2DMake(job_loc.latitude, job_loc.longitude)
            selected_job_marker = GMSMarker(position: initialLocation)
           selected_job_marker?.title = job_obj.title
            var job_data = Dictionary<String, String>()
                
            job_data["job_uid"] = job_obj.id
          //  job_data["description"] = job_obj.
                
            selected_job_marker?.userData = job_data
            selected_job_marker?.icon = UIImage(named: "job_icon_small")
            selected_job_marker?.appearAnimation = GMSMarkerAnimation.pop
            selected_job_marker?.map = map_view
                
            self.is_job_marker_set = true
                
            self.start_tracking()
           // self.markers_array.append(marker)
                
            }else{
                self.job_listener?.remove()
                show_alert(heading: "Error", body: "Couln't set marker")
            }
            
        }else{
            
            if let is_complete_status = snapshot.get("is_complete") as? String{
                
                if(is_complete_status == "true")
                {
                    
                    
                    self.stop_tracking()
                    
                    let alert = UIAlertController(title: "Alert", message: "Job completed, consider navigating to other nearby jobs", preferredStyle: .alert)
                    
                    
                    let dismiss_action = UIAlertAction(title: "Dismiss", style: .default) { (dismiss_action) in
                        print("dismissed")
                    }
                    let show_nearby = UIAlertAction(title: "Show Nearby Jobs", style: .default) { (near_action) in
                        self.get_nearest_jobs()
                    }
                    
                    alert.addAction(dismiss_action)
                    alert.addAction(show_nearby)
                    present(alert, animated : true, completion : nil)
                    
                }
                
            }
            
        }
        
    }
    
    func start_tracking(){
        
        jobs_button.title = "Stop Tracking"
        self.compass_stack_view.isHidden = false
        self.should_track = true
        
    }
    
    func stop_tracking(){
        
        jobs_button.title = "Jobs"
        self.compass_distance_label.text = ""
        job_listener?.remove()
        self.compass_stack_view.isHidden = true
        self.should_track = false
        is_job_marker_set = false
        selected_job_marker?.map = nil
        
    }
    
    func show_job_details(){
        
        // selected_job_id
        self.stop_tracking()
        performSegue(withIdentifier: "main_to_job_segue", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "main_to_job_segue", let set_vc = segue.destination as? job_details_view_controller, let job_uid = selected_job_id{
            set_vc.job_uid = job_uid
        }
    }
    
    
    
        
    
    
}

extension CGFloat {
    
    var toRadians: CGFloat { return self * .pi / 180 }
    var toDegrees: CGFloat { return self * 180 / .pi }
    
}


//consider when in use loction updates



/*
 
 func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
 
 if (locations.last?.horizontalAccuracy != nil)
 {
 let accuracy:Double = (locations.last?.horizontalAccuracy)!
 
 if (accuracy < 0)
 {
 return
 }
 
 if (locations.last?.coordinate.latitude != nil && locations.last?.coordinate.longitude != nil)
 {
 let lat:Double = (locations.last?.coordinate.latitude)!
 let lon:Double  = (locations.last?.coordinate.longitude)!
 //  String(format: "%.0f",lat)
 latitude_label.text = "Latitude: " + String(format: "%.4f",lat)
 longitude_label.text = "Longitude: " + String(format: "%.4f",lon)
 
 getAddressFromLatLon(pdblLatitude: (String(lat)), withLongitude: String(lon))
 }
 
 }
 
 }
 */


/*
 override func loadView() {
 // Create a GMSCameraPosition that tells the map to display the
 // coordinate -33.86,151.20 at zoom level 6.
 let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
 let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
 view = mapView
 
 // Creates a marker in the center of the map.
 let marker = GMSMarker()
 marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
 marker.title = "Sydney"
 marker.snippet = "Australia"
 marker.map = mapView
 }
 
 */


/*


func getAddressFromLatLon(pdblLatitude: String, withLongitude pdblLongitude: String) {
    
    var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
    let lat: Double = Double("\(pdblLatitude)")!
    //21.228124
    let lon: Double = Double("\(pdblLongitude)")!
    //72.833770
    let ceo: CLGeocoder = CLGeocoder()
    center.latitude = lat
    center.longitude = lon
    
    let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
    
    
    ceo.reverseGeocodeLocation(loc, completionHandler:
        {(placemarks, error) in
            if (error != nil)
            {
                print("reverse geodcode fail: \(error!.localizedDescription)")
            }
            if(placemarks != nil)
            {
                
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                    print(pm.country ?? "country")
                    print(pm.locality ?? "locality")
                    print(pm.subLocality ?? "sublocality")
                    print(pm.thoroughfare ?? "fare")
                    print(pm.postalCode ?? "postal code")
                    print(pm.subThoroughfare ?? "sub fare")
                    var addressString : String = "Location Details:\n"
                    
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality! + ", "
                    }
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality! + ", "
                    }
                    if pm.country != nil {
                        addressString = addressString + pm.country! + ", "
                    }
                    if pm.postalCode != nil {
                        addressString = addressString + pm.postalCode! + " "
                    }
                    
                    if (pm.country != nil){
                        addressString = addressString + pm.country! + " "
                    }
                    
                    if (pm.locality != nil){
                        addressString = addressString + pm.locality! + " "
                    }
                    //  self.locationManager.stopUpdatingLocation()
                    // self.update_flag_code(countryName: pm.country!, cityName: pm.locality!)
                    
                    self.location_details_label.text = addressString
                }
            }
    })
    
}

*/


// let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)

//let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)

//   var mapView = GMSMapView.map(withFrame: CGRect(x:100,y:100,width: 200,height: 200), camera: camera)

//   let camera = GMSCameraPosition.camera(withLatitude: 52.520736, longitude: 13.409423, zoom: 12)

// self.mapView.camera = camera

//  let initialLocation = CLLocationCoordinate2DMake(52.520736, 13.409423)
//   let marker = GMSMarker(position: initialLocation)
//  marker.title = "Berlin"
//   marker.map = mapView

// self.view.addSubview(mapView)
/*
 self.map_view = mapView
 
 // Creates a marker in the center of the map.
 let marker = GMSMarker()
 marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
 marker.title = "Sydney"
 marker.snippet = "Australia"
 marker.map = mapView
 */
