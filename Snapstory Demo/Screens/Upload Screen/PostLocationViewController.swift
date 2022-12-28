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
    
    var selectedLongitude = Double()
    var selectedLatitude = Double()
    var annotation = MKPointAnnotation()
    var inputAnnotation : UUID?
    var locationName = ""
    var picked = false
    var locationManager = CLLocationManager()

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        locationManager.delegate = self
        addLocationButton.isEnabled = false
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        let pinnGesture = UILongPressGestureRecognizer(target: self, action: #selector(selectLocation(pinGesture:)))
        pinnGesture.minimumPressDuration = 2
        mapView.addGestureRecognizer(pinnGesture)
        mapView.userLocation.title = UserSingleton.sharedUserInfo.username
        mapView.userLocation.subtitle = "You are here."
    }
    
    //MARK: - viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        selectedLatitude = mapView.userLocation.coordinate.latitude
        selectedLongitude = mapView.userLocation.coordinate.longitude
        getLocationInfo(tmpLat: selectedLatitude, tmpLong: selectedLongitude)
    }

    // MARK: - selectLocation gesture
    @objc func selectLocation(pinGesture : UILongPressGestureRecognizer){
        if pinGesture.state == .began {
            let touchedPoint = pinGesture.location(in: mapView)
            let touchedCoordinates = mapView.convert(touchedPoint, toCoordinateFrom: mapView)
            selectedLatitude = touchedCoordinates.latitude
            selectedLongitude = touchedCoordinates.longitude
            annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinates
            //annotation.title =
            //annotation.subtitle =
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(annotation)
            getLocationInfo(tmpLat: selectedLatitude, tmpLong: selectedLongitude)
            picked = true
        }
    }

    // MARK: - didUpdateLocations
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.20, longitudeDelta: 0.20)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        picked = true
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

    // MARK: - calloutAccessoryControlTapped
    // Only fires once pin accessory tapped (Pin have to have accessory).
//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        if inputAnnotation != nil {
//            let requestLocation = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
//            CLGeocoder().reverseGeocodeLocation(requestLocation) { placemarks, error in
//                if placemarks != nil {
//                    let newPlacemark = MKPlacemark(placemark: placemarks![0])
//                    let item = MKMapItem(placemark: newPlacemark)
//                    item.name = self.annotation.title
//                    let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
//                    item.openInMaps(launchOptions: launchOptions)
//                }
//            }
//        }
//    }

    // MARK: - getLocationInfo
    func getLocationInfo(tmpLat:Double,tmpLong:Double) {
        let tmpCLGeocoder = CLGeocoder.init()
        let tmpDataLoc = CLLocation.init(latitude: tmpLat, longitude: tmpLong)
        
        tmpCLGeocoder.reverseGeocodeLocation(tmpDataLoc, completionHandler: {(placemarks,error) in
            guard let tmpPlacemarks = placemarks else{return}
            let placeMark = tmpPlacemarks[0] as CLPlacemark
            guard let cityLocality = placeMark.locality else{return}
            guard let cityLocation = placeMark.administrativeArea else{return}

            self.locationName = "\(cityLocation), \(cityLocality)"
            self.locationLabel.text = self.locationName
            self.addLocationButton.isEnabled = true
        })
    }
    
    // MARK: - addLocation Button
    @IBAction func addLocation(_ sender: Any) {
        if picked{
            UserDefaults.standard.set(locationName, forKey: "locationString")
            UserDefaults.standard.set(annotation.coordinate.longitude, forKey: "locationCoordinateLongitude")
            UserDefaults.standard.set(annotation.coordinate.latitude, forKey: "locationCoordinateLatitude")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "locationData"), object: nil)
            dismiss(animated: true, completion: nil)
        }
    }
}
