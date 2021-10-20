//
//  ViewController.swift
//  Braga-AGX_native
//
//  Created by Mondo Mac 3 on 2021/10/16.
//

import UIKit
import MapKit

class ViewController: UIViewController  {
    
    @IBOutlet private var mapView: MKMapView!
    @IBOutlet weak var ShowNdviButton: UIButton!
    
    // This will be our coordinate system for sending to Google Earth
    var coordinates = [CLLocationCoordinate2D]()
    var coords = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set initial location in Honolulu
        let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
        mapView.centerToLocation(initialLocation)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        self.view.addGestureRecognizer(longPressRecognizer)
    }
    
    
    @IBAction func showNdviClicked(button: UIButton) {
        
    
         
        
        for c in coordinates {
            var theseCoords = [Any]()
            theseCoords.append(c.longitude)
            theseCoords.append(c.latitude)
            coords.append(theseCoords)
        }
        
        performSegue(withIdentifier: "GoToImage", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToImage" {
            let controller = segue.destination as! ViewControllerForViewImage
            controller.coords = coords
        }
    }
    
    @IBAction func startOverClicked(button: UIButton) {
        let annots = mapView.annotations
        mapView.removeAnnotations(annots)
        coordinates.removeAll()
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        print("longpressed")

    
        if (sender.state == .began) {
            let touchLocation = sender.location(in: mapView)
            let locationCoordinate = mapView.convert(touchLocation,toCoordinateFrom: mapView)
            print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
            coordinates.append(locationCoordinate)
            let annotation = MKPointAnnotation()
            let centerCoordinate = CLLocationCoordinate2D(latitude: locationCoordinate.latitude, longitude:locationCoordinate.longitude)
            annotation.coordinate = centerCoordinate
            annotation.title = "field boundary \(coordinates.count)"
            mapView.addAnnotation(annotation)
            
            print(coordinates)
        }
        
    }

}



private extension MKMapView {
  func centerToLocation(
    _ location: CLLocation,
    regionRadius: CLLocationDistance = 1000
  ) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }

}


