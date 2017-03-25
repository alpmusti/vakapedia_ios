//
//  ViewController.swift
//  Auto Complete
//
//  Created by Agus Cahyono on 24/03/2017.
//  Copyright © 2017 Mustafa ALP. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import KeychainAccess

class MainVC : UIViewController, UISearchBarDelegate , CLLocationManagerDelegate , GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate {
	
    @IBOutlet weak var datePickerTxt: UITextField!
    //DATEPICKER
    @IBOutlet weak var datePickerEnd: UITextField!
    let datePicker = UIDatePicker()
    let datePicker2 = UIDatePicker()
    var isMarked : Bool = false
    
    let keyChain : Keychain = Keychain(service: "Vakapedia")
	// OUTLETS
    @IBOutlet weak var googleMapsView: GMSMapView!
	
	
	// VARIABLES
	var locationManager = CLLocationManager()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		locationManager = CLLocationManager()
		locationManager.delegate = self
		locationManager.requestWhenInUseAuthorization()
		locationManager.startUpdatingLocation()
		locationManager.startMonitoringSignificantLocationChanges()
       
		//initGoogleMaps()
        
        let camera = GMSCameraPosition.camera(withLatitude: -33.20, longitude: 44.8, zoom: 14.0)
        let mapView = GMSMapView.map(withFrame: .zero   , camera: camera)
        mapView.isMyLocationEnabled = true
        self.googleMapsView.camera = camera
        
        
        self.googleMapsView.delegate = self
        self.googleMapsView.isMyLocationEnabled = true
        self.googleMapsView.settings.myLocationButton = true
        
        createStartDatePicker()
        createEndDatePicker()
	}
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }

    func markSelectedPlace(_ lat : CLLocationDegrees , _ lon : CLLocationDegrees , _ title : String) {
	
        googleMapsView.clear()
		// Creates a marker in the center of the map.
        let position = CLLocationCoordinate2DMake(lat, lon)
        let marker = GMSMarker(position : position)
        
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 16.0)
        self.googleMapsView.camera = camera
		marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
		marker.title = title
		marker.map = self.googleMapsView
        isMarked = true
        
        keyChain["location_x"] = "\(lat)"
        keyChain["location_y"] = "\(lon)"
	}
	
	// MARK: CLLocation Manager Delegate
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Error while get location \(error)")
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let location = locations.last
		
		let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
		
		self.googleMapsView.animate(to: camera)
		self.locationManager.stopUpdatingLocation()
		
	}
	
	// MARK: GMSMapview Delegate
	func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
		self.googleMapsView.isMyLocationEnabled = true
	}
	
	func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
		
		self.googleMapsView.isMyLocationEnabled = true
		if (gesture) {
			mapView.selectedMarker = nil
		}
		
	}
	
	// MARK: GOOGLE AUTO COMPLETE DELEGATE
	
	func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
		
		let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 15.0)
		self.googleMapsView.camera = camera
        print(place.coordinate.longitude)
        print(place.coordinate.latitude)
        print(place.name)
        markSelectedPlace(place.coordinate.latitude, place.coordinate.longitude, place.name)
		self.dismiss(animated: true, completion: nil) // dismiss after select place
		
	}
	
	func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
		
		print("ERROR AUTO COMPLETE \(error)")
		
	}
	
	func wasCancelled(_ viewController: GMSAutocompleteViewController) {
		self.dismiss(animated: true, completion: nil) // when cancel search
	}
	
    @IBAction func openSearchAdress(_ sender: Any) {
        
        let autoCompleteController = GMSAutocompleteViewController()
        		autoCompleteController.delegate = self
        
        self.locationManager.startUpdatingLocation()
        self.present(autoCompleteController, animated: true, completion: nil)
    }
    
    func createStartDatePicker(){
        
        //Formatting the date
        datePicker.datePickerMode = .dateAndTime
        
        //TOOLBAR
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        //Bar button item
        let doneButton = UIBarButtonItem(title : "Bitti" , style: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: false)
        
        datePickerTxt.inputAccessoryView = toolbar
        
        datePickerTxt.inputView = datePicker
    }
    
    func donePressed(){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .medium
        
        datePickerTxt.text = dateFormatter.string(from : datePicker.date)
        self.view.endEditing(true)
    }
    
    func createEndDatePicker(){
        
        //Formatting the date
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .minute, value: 30, to: Date())
        
        datePicker2.datePickerMode = .dateAndTime
        datePicker2.minimumDate = date
        
        //TOOLBAR
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        //Bar button item
        let doneButton = UIBarButtonItem(title : "Bitti" , style: .done, target: nil, action: #selector(doneEndPressed))
        toolbar.setItems([doneButton], animated: false)
        
        datePickerEnd.inputAccessoryView = toolbar
        
       datePickerEnd.inputView = datePicker2
    }
    
    func doneEndPressed(){
        
        if (datePickerTxt.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!{
            showAlert(msg : "İlk önce başlangıç zamanını seçiniz")
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .medium
        
        datePickerEnd.text = dateFormatter.string(from : datePicker2.date)
        self.view.endEditing(true)
    }
    
    func showAlert(msg : String){
        let alert = UIAlertController(title: "Uyarı!", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction internal func setMatchUp(_ sender: Any){
        if (datePickerTxt.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!{
            showAlert(msg: "Başlangıç tarihi boş bırakılamaz!")
            return
        }else if (datePickerEnd.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!{
            showAlert(msg : "Bitiş tarihi boş bırakılamaz !")
            return
        }else if !isMarked{
            showAlert(msg: "Lokasyon seçmeniz gerekmektedir!")
            return
        }
        // MARK : TODO matching logic
    }

}

