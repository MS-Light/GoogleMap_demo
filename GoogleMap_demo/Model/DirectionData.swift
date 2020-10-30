//
//  DirectionData.swift
//  GoogleMap_demo
//
//  Created by YANBO JIANG on 10/25/20.
//

import Foundation

struct DirectionData: Codable{
    let geocoded_waypoints: [Waypoints]
    let routes: [Routes]
    
}

struct Waypoints: Codable{
    let geocoder_status: String
    let place_id: String
    let types: [String]
    
}

struct Routes: Codable{
    let bounds: Bounds
    let legs: [Legs]
    let duration: Normal?
    let distance: Normal?
    let start_location: Location?
    let end_location: Location?
    let start_address: String?
    let end_address: String?
    let overview_polyline: Polyline1
    let waypoint_order: [Int]?
    let warnings: [String]?
    
    
}

struct Bounds: Codable{
    let northeast: Location
    let southwest: Location
}

struct Location: Codable{
    let lat: Double
    let lng: Double
}

struct Legs: Codable{
    let duration: Normal?
    let start_location: Location
    let end_location: Location
    let steps: [Steps]
}

struct Steps: Codable{
    let distance: Normal?
    let duration: Normal?
    let travel_mode: String
    let start_location: Location
    let end_location: Location
    let polyline: Polyline1
    let html_instructions: String

}

struct Polyline1: Codable{
    let points: String
}

struct Normal: Codable{
    let text: String?
    let value: Int?
}
