//
//  ViewController.swift
//  GoogleMap_demo
//
//  Created by YANBO JIANG on 10/22/20.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation
import RealmSwift
import MapKit
import SwiftSocket


class ViewController: UIViewController {
    
    //instandtiate a location manager
    var directionManager = DirectionManager()
    private let locationManager = CLLocationManager()
    var arrayPolyline = [GMSPolyline]()
    var selectedRought:String!
    
   
    // MARK: Create source location and destination location so that you can pass it to the URL
    @IBOutlet weak var Map: GMSMapView!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var destinationTextField: UITextField!
    let client = Client(host:"192.168.0.126" , port: 80)
    let server = Server(port: 80)
    @IBAction func Startclient(_ sender: Any) {
        DispatchQueue.global().async {
            self.client.start()
            let data = Data("hi".utf8)
            self.client.connection.send(data: data)
        }
    }
    
    @IBAction func Stopclient(_ sender: Any) {
        client.stop()
    }
    
    @IBAction func Startserver(_ sender: Any) {
        DispatchQueue.global().async {
            try! self.server.start()
        }
    }

    @IBAction func Sropserver(_ sender: Any) {
        server.stop()
    }
    
    //record current position
    @IBAction func record(_ sender: Any) {
        var currentLoc: CLLocation!
        currentLoc = locationManager.location
        let mylocation = locationdata()
        mylocation.id = mylocation.IncrementaID()
        mylocation.latitude = currentLoc.coordinate.latitude
        mylocation.longitude = currentLoc.coordinate.longitude
        
        let realm = try! Realm()
        try! realm.write {
            realm.add(mylocation)
        }
    }
    
    //show marker on map
    @IBAction func showdata(_ sender: Any) {
        //var iconBase = "https://maps.google.com/mapfiles/kml/shapes/"
        
        let realm = try! Realm()
        // Read some data from the bundled Realm
        let results = realm.objects(locationdata.self)
        for a in results {
              let marker = GMSMarker()
            print(a.latitude)
            print(a.longitude)
              marker.position = CLLocationCoordinate2D(latitude: a.latitude, longitude: a.longitude)
              marker.map = Map
            //marker.icon = self.imageWithImage(image: UIImage(named: "virus.png")!, scaledToSize: CGSize(width: 30.0, height: 30.0))
          }
    }
    /*
    func echoService(client: TCPClient) {
        print("Newclient from:\(client.address)[\(client.port)]")
        let d = client.read(1024*10)
        client.send(data: d!)
        client.close()
    }
    
    func testServer() {
        let server = TCPServer(address: "192.168.0.174", port: 80)
        sleep(10)
        print("server listen")
        sleep(3)
        switch server.listen() {
          case .success:
            while true {
                if let client = server.accept(timeout:1000) {
                    echoService(client: client)
                } else {
                    print("accept error")
                }
            }
          case .failure(let error):
            print("server failed")
            print(error)
        }
    }
    */
    
    
    
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        Map.delegate = self
        directionManager.delegate = self
        destinationTextField.delegate = self
        //testServer()
        let servertask = DispatchQueue(label: "server")
          servertask.async {
           // Add your serial task
          
          }
    }
    
    
    private func reverseGeocodeCoordinate(_ coordinate: CLLocation) {
      let geocoder = GMSGeocoder()
        let coordinate1:CLLocationCoordinate2D = coordinate.coordinate
      geocoder.reverseGeocodeCoordinate(coordinate1) { response, error in
        guard let address = response?.firstResult(), let lines = address.lines else {
          return
        }
        self.address.text = lines.joined(separator: "\n")
        UIView.animate(withDuration: 0.25) {
          self.view.layoutIfNeeded()
        }
      }
    }


}

// MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    guard status == .authorizedWhenInUse else {
      return
    }
    locationManager.startUpdatingLocation()
    Map.isMyLocationEnabled = true
    Map.settings.myLocationButton = true
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.first else {
      return
    }
    Map.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
    locationManager.stopUpdatingLocation()
  }
}

// MARK: - GMSMapViewDelegate
extension ViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if let position:CLLocation = self.locationManager.location {
            reverseGeocodeCoordinate(position)
        }
    }
}


//MARK: - DirectionManagerDelegate
extension ViewController: DirectionManagerDelegate{
    func didUpdateLocation(_ directionManager: DirectionManager, direction:DirectionModel){
        DispatchQueue.main.async{
            //change maps
            self.Map.clear()
            print("here")
            print(direction.destination.lat)
            
            let start = GMSMarker()
            start.position = CLLocationCoordinate2D(latitude: direction.origin.lat, longitude: direction.origin.lng)
            start.title = "start point"
            start.snippet = "Hi"
            start.map = self.Map
            start.icon = GMSMarker.markerImage(with: UIColor.green)
            
            let end = GMSMarker()
            end.position = CLLocationCoordinate2D(latitude: direction.destination.lat, longitude: direction.destination.lng)
            end.title = "end point"
            end.snippet = "Hi"
            end.map = self.Map
            end.icon = GMSMarker.markerImage(with: UIColor.green)
            
            for route in direction.polyline{
                let path = GMSPath.init(fromEncodedPath: route)
                let polyline = GMSPolyline.init(path: path)
                polyline.strokeWidth = 3
                self.Map.animate(with: GMSCameraUpdate.fit(GMSCoordinateBounds(path: path!), withPadding: 30))
                polyline.map = self.Map
            }
        }
    }
    func didFailWithError(_ error: Error) {
        print(error)
    }
}

//MARK: - UITextFieldDelegate

extension ViewController: UITextFieldDelegate{

    @IBAction func searchPressed(_ sender: UIButton) {
        destinationTextField.endEditing(true)
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        destinationTextField.endEditing(true)
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != ""{
            return true
        }else{
            textField.placeholder = "Type in the Destination"
            return false
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        let geocoder = CLGeocoder()
         
        if let destination = destinationTextField.text{
            print("hi")
            geocoder.geocodeAddressString(destination){(place, error) in
                if error == nil{
                    if let myplace = place?[0]{
                        let geo_destination = myplace.location!
                       print(geo_destination)
                        return
                    }
                }
            }
            
            directionManager.fetchDirection(origin: address.text ?? "", destination: destination)
        }

        destinationTextField.text = ""
    }
}

// Handle the user's selection.
