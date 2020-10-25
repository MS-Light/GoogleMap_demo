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

class ViewController: UIViewController {
    
    //instandtiate a location manager
    private var directionManager = DirectionManager()
    private let locationManager = CLLocationManager()
    var arrayPolyline = [GMSPolyline]()
    var selectedRought:String!
    
    func setMapMarkersRoute(vLoc: CLLocationCoordinate2D, toLoc: CLLocationCoordinate2D) {
        //add the markers for the 2 locations
        let markerTo = GMSMarker.init(position: toLoc)
        markerTo.map = Map
        let vMarker = GMSMarker.init(position: vLoc)
        vMarker.map = Map
        //zoom the map to show the desired area
        var bounds = GMSCoordinateBounds()
        bounds = bounds.includingCoordinate(vLoc)
        bounds = bounds.includingCoordinate(toLoc)
        self.Map.moveCamera(GMSCameraUpdate.fit(bounds))
        //finally get the route
        getRoute(from: vLoc, to: toLoc)
    }
    func getRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) {
        
        let source = MKMapItem(placemark: MKPlacemark(coordinate: from))
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: to))

        let request = MKDirections.Request()
        request.transportType = .walking
        request.source = source
        request.destination = destination
        request.requestsAlternateRoutes = false

        let directions = MKDirections(request: request)

        directions.calculate(completionHandler: { (response, error) in
            if let res = response {
                //the function to convert the result and show
                self.show(polyline: self.googlePolylines(from: res))
            }
        })
    }
    private func googlePolylines(from response: MKDirections.Response) -> GMSPolyline {
        let route = response.routes[0]
        var coordinates = [CLLocationCoordinate2D](
            repeating: kCLLocationCoordinate2DInvalid,
            count: route.polyline.pointCount)
        route.polyline.getCoordinates(
            &coordinates,
            range: NSRange(location: 0, length: route.polyline.pointCount))
        let polyline = Polyline(coordinates: coordinates)
        let encodedPolyline: String = polyline.encodedPolyline
        let path = GMSPath(fromEncodedPath: encodedPolyline)
        return GMSPolyline(path: path)
    }
    func show(polyline: GMSPolyline) {
        //add style to polyline
        polyline.strokeColor = UIColor.red
        polyline.strokeWidth = 3
        //add to map
        polyline.map = Map
    }
    
    /*
    func LoadMapRoute()
    {
        let origin = "40.5233, -74.4587"
        let destination = "40.5222, -74.4627"
        let position1 = CLLocationCoordinate2D(latitude: 40.5233, longitude: -74.4587)
        let position2 = CLLocationCoordinate2D(latitude: 40.5221, longitude: -74.4627)
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=YOUR_API_KEY"
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler:
            {
            (data, response, error) in
            if(error != nil)
            {
                print("error")
            }
            else
            {
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    let arrRouts = json["routes"] as! NSArray
                    for  polyline in self.arrayPolyline
                    {
                        polyline.map = nil;
                    }
                    self.arrayPolyline.removeAll()
                    let pathForRought:GMSMutablePath = GMSMutablePath()
                    if (arrRouts.count == 0)
                    {
                        let distance:CLLocationDistance = CLLocation.init(latitude: position1.latitude, longitude: position1.longitude).distance(from: CLLocation.init(latitude: position2.latitude, longitude: position2.longitude))
                        pathForRought.add(position1)
                        pathForRought.add(position2)
                        let polyline = GMSPolyline.init(path: pathForRought)
                        self.selectedRought = pathForRought.encodedPath()
                        polyline.strokeWidth = 5
                        polyline.strokeColor = UIColor.blue
                        polyline.isTappable = true

                        self.arrayPolyline.append(polyline)

                        if (distance > 8000000)
                        {
                            polyline.geodesic = false
                        }
                        else
                        {
                            polyline.geodesic = true
                        }
                        polyline.map = self.Map;
                    }
                    else
                    {
                        for (index, element) in arrRouts.enumerated()
                        {
                            let dicData:NSDictionary = element as! NSDictionary
                            let routeOverviewPolyline = dicData["overview_polyline"] as! NSDictionary
                            let path =  GMSPath.init(fromEncodedPath: routeOverviewPolyline["points"] as! String)
                            let polyline = GMSPolyline.init(path: path)
                            polyline.isTappable = true
                            self.arrayPolyline.append(polyline)
                            polyline.strokeWidth = 5
                            if index == 0
                            {
                                self.selectedRought = routeOverviewPolyline["points"] as? String
                                polyline.strokeColor = UIColor.blue;
                            }
                            else
                            {
                                polyline.strokeColor = UIColor.darkGray;
                            }
                            polyline.geodesic = true;
                        }
                        for po in self.arrayPolyline.reversed()
                        {
                            po.map = self.Map;
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                    {
                        let bounds:GMSCoordinateBounds = GMSCoordinateBounds.init(path: GMSPath.init(fromEncodedPath: self.selectedRought)!)
                        self.Map.animate(with: GMSCameraUpdate.fit(bounds))
                    }
                }
                catch let error as NSError
                {
                    print("error:\(error)")
                }
            }
        }).resume()
    }
    */
    // MARK: Create source location and destination location so that you can pass it to the URL
    @IBOutlet weak var Map: GMSMapView!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var destinationTextField: UITextField!
    
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
        let position1 = CLLocationCoordinate2D(latitude: 40.5233, longitude: -74.4587)
        let position2 = CLLocationCoordinate2D(latitude: 40.5221, longitude: -74.4627)
        //setMapMarkersRoute(vLoc: position1, toLoc: position2)
        
        
        /*
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
        */
        // Do any additional setup after loading the view.
    }
    
    
    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
      let geocoder = GMSGeocoder()
      geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
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
      reverseGeocodeCoordinate(position.target)
    }
}


//MARK: - DirectionManagerDelegate
extension ViewController: DirectionManagerDelegate{
    func didUpdateLocation(_ directionManager: DirectionManager, direction:DirectionModel){
        DispatchQueue.main.async{
            //change maps
            print("here")
            print(direction.destination.lat)
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

        if let destination = destinationTextField.text{
            directionManager.fetchDirection(origin: address.text ?? "", destination: destination)
        }

        destinationTextField.text = ""
    }
}
