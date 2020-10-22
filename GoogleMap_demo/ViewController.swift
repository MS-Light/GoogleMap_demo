//
//  ViewController.swift
//  GoogleMap_demo
//
//  Created by YANBO JIANG on 10/22/20.
//

import UIKit
import GoogleMaps
import GooglePlaces

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
        // Do any additional setup after loading the view.
    }


}

