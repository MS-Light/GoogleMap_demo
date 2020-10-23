//
//  Data.swift
//  GoogleMap_demo
//
//  Created by User on 10/23/20.
//

import Foundation
import RealmSwift

class locationdata: Object {
    @objc dynamic var id = 0
    @objc dynamic var specimenDescription = ""
    @objc dynamic var latitude = 0.0
    @objc dynamic var longitude = 0.0
    @objc dynamic var created = Date()
    
    //primary key
    override static func primaryKey() -> String? {
            return "id"
        }
    
    //auto increment primary key
    func IncrementaID() -> Int{
        let realm = try! Realm()
        if let retNext = realm.objects(locationdata.self).sorted(byKeyPath: "id").last?.id {
            return retNext + 1
        }else{
            return 1
        }
    }
}

