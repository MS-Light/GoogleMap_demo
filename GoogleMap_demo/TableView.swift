//
//  TableView.swift
//  GoogleMap_demo
//
//  Created by User on 11/19/20.
//

import UIKit
import SwipeCellKit
import RealmSwift

class Cell: SwipeTableViewCell{
   
}

class TableView: UIViewController, UITableViewDelegate, UITableViewDataSource,
                 SwipeTableViewCellDelegate {
    
    var results = try! Realm().objects(locationdata.self)

    var tableView:UITableView?
    
    var apps = [locationdata]()
    
    func preparedata(){
        for result in results{
            apps.append(result)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preparedata()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return apps.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        //cell.delegate = self
        // Configure the cell...
        cell.textLabel?.text = apps[indexPath.row].specimenDescription
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        if orientation == .left {
            let unreadAction = SwipeAction(style: .default, title: "mark") {
                action, indexPath in UIAlertController.showAlert(message: "u mark this cell")
            }
            unreadAction.backgroundColor = UIColor(red: 52/255, green: 120/255, blue: 246/255, alpha: 1)
                return [unreadAction]
        } else{
            let favoriteAction = SwipeAction(style: .default, title: "flag") {
                action, indexPath in UIAlertController.showAlert(message: "u add it flag")
            }
            favoriteAction.backgroundColor = .orange
            let deleteAction = SwipeAction(style: .destructive, title: "delete") {
                action, indexPath in self.apps.remove(at: indexPath.row)
                tableView.reloadData()
            }
            return [deleteAction, favoriteAction]
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIAlertController {
    static func showAlert(message: String, in viewController: UIViewController) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "done", style: .cancel))
        viewController.present(alert, animated: true)
    }

    static func showAlert(message: String) {
        if let vc = UIApplication.shared.keyWindow?.rootViewController {
            showAlert(message: message, in: vc)
        }
    }
}
