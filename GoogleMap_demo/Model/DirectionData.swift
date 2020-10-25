//
//  DirectionData.swift
//  GoogleMap_demo
//
//  Created by YANBO JIANG on 10/25/20.
//

import Foundation

struct DirectionData: Codable{
    let geocoded_waypoints: [Waypoints]
    let route: [Route]
    
}

struct Waypoints: Codable{
    let geocoder_status: String
    let place_id: String
    let types: [String]
    
}

struct Route: Codable{
    let bound: Bound
    let legs: [Legs]
    let duration: Normal
    let distance: Normal
    let start_location: Location
    let end_location: Location
    let start_address: String
    let end_address: String
    let overview_polyline: Polyline
    let waypoint_order: [Int]
    let warnings: [String]
    
    
}

struct Bound: Codable{
    let northeast: Location
    let southwest: Location
}

struct Location: Codable{
    let lat: Double
    let lng: Double
}

struct Legs: Codable{
    let steps: [Steps]
}

struct Steps: Codable{
    let travel_mode: String
    let start_location: Location
    let end_location: Location
    let polyline: Polyline
    let duration: Normal
    let html_instructions: String
    let distance: Normal
}

struct Polyline: Codable{
    let points: String
}

struct Normal: Codable{
    let value: Int
    let text: String
}
