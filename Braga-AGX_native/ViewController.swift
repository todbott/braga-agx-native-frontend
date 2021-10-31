//
//  ViewController.swift
//  Braga-AGX_native
//
//  Created by Mondo Mac 3 on 2021/10/16.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
  
    @IBOutlet weak var InitialPopup: UIView! {
        didSet {
          InitialPopup.layer.cornerRadius = 50
        }
      }
    
    @IBOutlet weak var LetsStartButton: UIButton!
    @IBOutlet weak var FetchingLabel: UILabel!

    @IBOutlet private var mapView: MKMapView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var TouchAndHoldLabel: UILabel!
    @IBOutlet weak var ShowNdviButton: UIButton!
    

    @IBOutlet weak var StartOverButton: UIButton!
    @IBOutlet weak var loadingView: UIView! {
        didSet {
          loadingView.layer.cornerRadius = 50
        }
      }
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    

    // This will be our coordinate system for sending to Google Earth
    var coordinates = [CLLocationCoordinate2D]()
    var coords = [Any]()
    var imageURL = String()
    var dateTaken = String()
    var weGood = String()
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        InitialPopup.isHidden = true;
        StartOverButton.isHidden = true;
        
        //mapView.delegate = self
        mapView.showsUserLocation = true
        
        InitialPopup.isHidden = false;

        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        hideSpinner()

        imageView.isHidden = true;
        
        mapView.mapType = .satellite

        

    }
    
    
    @IBAction func showNdviClicked(button: UIButton) {
               
        if (mapView.camera.altitude > 5000) {
         
                let alert = UIAlertController(title: "Please zoom in", message: "NDVI images from this zoom level might take over 5 minutes to render.", preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)
                Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
            
        } else {
        
            // Get the visible rectangle of the map as 2 coords
            var coords = [Any]()
            var theseCoords = [Any]()
            
            
            

            let nePoint = CGPoint(x: mapView.bounds.maxX, y: mapView.bounds.origin.y)
            let swPoint = CGPoint(x: mapView.bounds.minX, y: mapView.bounds.maxY)
            
            let ne = mapView.convert(nePoint, toCoordinateFrom: mapView)
            let sw = mapView.convert(swPoint, toCoordinateFrom: mapView)
            
            
            theseCoords.append(ne.longitude) //top x
            theseCoords.append(ne.latitude) // top y
            coords.append(theseCoords)
            theseCoords.removeAll()
            theseCoords.append(sw.longitude) // bottom x
            theseCoords.append(ne.latitude) // top y
            coords.append(theseCoords)
            theseCoords.removeAll()
            theseCoords.append(ne.longitude) // top x
            theseCoords.append(sw.latitude) // bottom y
            coords.append(theseCoords)
            theseCoords.removeAll()
            theseCoords.append(sw.longitude) // bottom x
            theseCoords.append(sw.latitude) // bottom y
            coords.append(theseCoords)
            
            print("The coords are \(coords)")
            
            showSpinner()
        
            let params = [
                "coords": "\(coords)"
            ] as Dictionary<String, String>

            var request = URLRequest(url: URL(string: "https://us-central1-agxactly-app-backend.cloudfunctions.net/braga-agx-native-cloud")!)
            request.httpMethod = "POST"
            request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = TimeInterval(300)
            configuration.timeoutIntervalForResource = TimeInterval(300)
            let session = URLSession(configuration: configuration)
            

            let task = session.dataTask(with: request) { data, response, error in
                print("Task completed")
                guard let data = data, error == nil else {
                    self.FetchingLabel.text = "There was a server error, please try again."
                    sleep(5)
                    self.hideSpinner()
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as! Dictionary<String, AnyObject>
                    print(json)

                    self.imageURL = json["imageURL"] as! String
                    self.dateTaken = json["dateTaken"] as! String
                    self.weGood = json["success"] as! String
                    self.putUrlDataInView()
                    
                    
                } catch let parseError {
                    print("JSON Error \(parseError.localizedDescription)")
                    self.FetchingLabel.text = "There was a server error, please try again."
                    sleep(5)
                    self.hideSpinner()
                    return
                }
            }

            task.resume()
            print("task is resuming")
        }

    }

        
    private func putUrlDataInView() {
        
        //Now, get the data from the URL and put it in the UIImageView
        print(self.imageURL)

        if let url = URL(string: self.imageURL) {
         
            let task_two = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let tif_data = data, error == nil else {
                    print("returning now")
                    return
                }
                        
                DispatchQueue.main.async { /// execute on main thread
                    self.imageView.image = UIImage(data: tif_data)
                    
                    self.TouchAndHoldLabel.text  = "Here is the NDVI overlay from a satellite flyover on \(self.dateTaken)."
                    
                    self.imageView.isHidden = false;
                    self.ShowNdviButton.isHidden = true;
                    self.hideSpinner()
                    self.mapView.isZoomEnabled = false;
                    self.mapView.isScrollEnabled  = false;
                    self.StartOverButton.isHidden = false;
                    
                }
            }
            task_two.resume()
        }
        if (self.imageURL == "none") {
            self.showErrorMessage()
            print("imag URL was none")
        }
        
    }
    
    func showErrorMessage() {
        DispatchQueue.main.async {
            self.FetchingLabel.text = "There was a server error, please try again."
            sleep(5)
            self.hideSpinner()
        }
        
    }


    
    @IBAction func startOverClicked(button: UIButton) {
        let annots = mapView.annotations
        mapView.removeAnnotations(annots)
        coordinates.removeAll()
        imageView.isHidden = true;
        ShowNdviButton.isHidden = false;
        TouchAndHoldLabel.text = "Zoom in to the area of interest, then click 'Show my NDVI'"
        StartOverButton.isHidden = true;
        mapView.isZoomEnabled  = true;
        mapView.isScrollEnabled  = true;
    }
    
    @IBAction func letsStartClicked(button: UIButton) {
        InitialPopup.isHidden = true;
    }
    
    
    private func showSpinner() {
        print("spinner should be showing")
        activityIndicator.startAnimating()
        loadingView.isHidden = false
    }

    private func hideSpinner() {
        activityIndicator.stopAnimating()
        loadingView.isHidden = true
    }
    
    
    
    
}






extension ViewController : CLLocationManagerDelegate {


    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationManager.requestLocation()
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    


    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(0.05), longitudeDelta: CLLocationDegrees(0.05))
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            manager.stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
}





