//
//  ViewControllerForViewImage.swift
//  Braga-AGX_native
//
//  Created by Mondo Mac 3 on 2021/10/19.
//

import UIKit
import WebKit
import Foundation

class ViewControllerForViewImage: UIViewController  {
    
   
    var coords: [Any] = []
    
    
    @IBOutlet weak var BackButton: UIButton!
    var webView: WKWebView!
    
    

    @IBOutlet var loadingView: UIView! {
        didSet {
          loadingView.layer.cornerRadius = 6
        }
      }
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
  
    @IBOutlet var imageView: UIImageView!
    
    
    
    override func viewDidLoad() {
      
        super.viewDidLoad()
        
        showSpinner()
    
        
        let params = [
            "coords": "\(coords)"
        ] as Dictionary<String, String>

        var request = URLRequest(url: URL(string: "https://us-central1-agxactly-app-backend.cloudfunctions.net/braga-agx-native-cloud")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                //let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                //print(json)
                //let imageURL = json["imageURL"] as! String
                let imageURL = try "https://storage.googleapis.com/braga-agx-native/012654795295470989_2021-10-17.png"
                
                if let url = URL(string: imageURL) {
                    let task = URLSession.shared.dataTask(with: url) { data, response, error in
                        guard let tif_data = data, error == nil else { return }
                        
                        DispatchQueue.main.async { /// execute on main thread
                            self.imageView.image = UIImage(data: tif_data)
                            print("image should be showing...")
                            self.hideSpinner()
                            
                        }
                    }
                    
                    task.resume()
                }
            } catch {
                print("error")
            }
        })
        
        task.resume()
        
        

        
        
        
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


