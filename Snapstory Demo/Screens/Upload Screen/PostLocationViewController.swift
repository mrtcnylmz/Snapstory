//
//  PostLocationViewController.swift
//  Snapstory Demo
//
//  Created by Mertcan Yılmaz
//

import UIKit
import SwiftUI
import MapKit
import CoreLocation

class PostLocationViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var popOutView: UIView!
    
    var locationName = "" {
        didSet {
            locationLabel.text = locationName
            addLocationButton.isEnabled = true
        }
    }
    var locationManager = CLLocationManager()
    var delegate: PostLocationDelegate?
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        
        popOutView.layer.cornerRadius = 15
        locationLabel.layer.cornerRadius = 15
        addLocationButton.layer.cornerRadius = 15
        locationLabel.layer.borderWidth = 0.5
        addLocationButton.layer.borderWidth = 0
        locationLabel.layer.backgroundColor = CGColor(red: 255, green: 255, blue: 255, alpha: 1)
        locationLabel.layer.borderColor = UIColor(named: "Text Color")!.cgColor
        addLocationButton.isEnabled = false
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let pinnGesture = UILongPressGestureRecognizer(target: self, action: #selector(selectLocation(pinGesture:)))
        pinnGesture.minimumPressDuration = 1
        mapView.addGestureRecognizer(pinnGesture)
        mapView.userLocation.title = auth.currentUser!.email
        mapView.userLocation.subtitle = "You are here."
    }
    
    //MARK: - viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        let selectedLatitude = mapView.userLocation.coordinate.latitude
        let selectedLongitude = mapView.userLocation.coordinate.longitude
        getLocationInfo(tmpLat: selectedLatitude, tmpLong: selectedLongitude)
    }
    
    // MARK: - selectLocation gesture
    @objc func selectLocation(pinGesture : UILongPressGestureRecognizer){
        if pinGesture.state == .began {
            let touchedPoint = pinGesture.location(in: mapView)
            let touchedCoordinates = mapView.convert(touchedPoint, toCoordinateFrom: mapView)
            let selectedLatitude = touchedCoordinates.latitude
            let selectedLongitude = touchedCoordinates.longitude
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinates

            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(annotation)
            getLocationInfo(tmpLat: selectedLatitude, tmpLong: selectedLongitude) { location, locality in
                annotation.title = location
                annotation.subtitle = locality
            }
        }
    }
    
    // MARK: - didUpdateLocations
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.20, longitudeDelta: 0.20)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    // MARK: - annotation template
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if pinView == nil{
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    // MARK: - getLocationInfo
    func getLocationInfo(tmpLat:Double, tmpLong:Double, complation: ((_ location: String, _ locality: String) -> ())? = nil) {
        locationManager.stopUpdatingLocation()
        let tmpDataLoc = CLLocation.init(latitude: tmpLat, longitude: tmpLong)
        
        CLGeocoder.init().reverseGeocodeLocation(tmpDataLoc, completionHandler: {(placemarks,error) in
            guard error == nil else { return }
            guard let placemarks = placemarks else { return }
            let placeMark = placemarks[0] as CLPlacemark
            guard let cityLocality = placeMark.locality else{return}
            guard let cityLocation = placeMark.administrativeArea else{return}
            self.locationName = "\(cityLocation), \(cityLocality)"
            complation?(cityLocation, cityLocality)
        })
    }
    
    // MARK: - addLocation Button
    @IBAction func addLocation(_ sender: Any) {
        delegate!.location(locationName: locationName)
        dismiss(animated: true, completion: nil)
    }
}
