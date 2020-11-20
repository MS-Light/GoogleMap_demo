//
//  SecondViewController.swift
//  GoogleMap_demo
//
//  Created by User on 11/13/20.
//

import Foundation
import UIKit
import RealmSwift

class SecondViewController: UIViewController {
    
    
    let realm = try! Realm()
    // Read some data from the bundled Realm
    let results = try! Realm().objects(locationdata.self)
    
    let tableview: UITableView = {
            let tv = UITableView()
            tv.backgroundColor = UIColor.white
            tv.translatesAutoresizingMaskIntoConstraints = false
            return tv
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    func setupTableView() {
        tableview.register(Cell.self, forCellReuseIdentifier: "cellId")
        
        view.addSubview(tableview)
        
        NSLayoutConstraint.activate([
            tableview.topAnchor.constraint(equalTo: self.view.topAnchor),
            tableview.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            tableview.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            tableview.leftAnchor.constraint(equalTo: self.view.leftAnchor)
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 10
        }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! Cell
        
        var object: locationdata
        object = self.results[indexPath.row] as locationdata
        var formatter = DateFormatter()
        formatter.dateFormat = "dd-MM"
        cell.textLabel!.text =  formatter.string(from: object.created)
        cell.detailTextLabel!.text = object.description
        tableView.reloadRows(at: [indexPath], with: .automatic)
        return cell

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}



