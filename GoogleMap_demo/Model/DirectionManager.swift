//
//  DirectionManager.swift
//  GoogleMap_demo
//
//  Created by YANBO JIANG on 10/25/20.
//

import Foundation
import CoreLocation


protocol DirectionManagerDelegate{
    func didUpdateLocation(_ directionManager: DirectionManager, direction:DirectionModel)
    func didFailWithError(_ error: Error)
}

struct DirectionManager{
    var delegate: DirectionManagerDelegate?
    
    func fetchDirection(origin: String, destination: String){
        let url: String = "\(K.MapDirection)&origin=\(origin)&destination=\(destination)&alternatives=true&mode=walking&key=\(K.apiKey)"
        let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        performRequest(urlString!)
    }
    
    func performRequest(_ urlString: String){
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    self.delegate?.didFailWithError(error!)
                    return
                }
                
                if let safeData = data{
                    if let direction = self.parseJSON(safeData){
                        self.delegate?.didUpdateLocation(self, direction: direction)
                    }
                }
            }
            task.resume()
        }
    }
    func parseJSON(_ directionData: Data) -> DirectionModel?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(DirectionData.self, from: directionData)
            let origin = decodedData.routes[0].legs[0].start_location
            let destination = decodedData.routes[0].legs[0].end_location
            var polyline = [String]()
            for route in decodedData.routes{
                polyline.append(route.overview_polyline.points)
            }
            let direction = DirectionModel(origin: origin, destination: destination, polyline:polyline)
            return direction
        }catch{
            delegate?.didFailWithError(error)
            return nil
        }

    }
    
}
