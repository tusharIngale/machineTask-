//
//  ViewController.swift
//  machineTask
//
//  Created by Mac on 27/08/21.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: Global Variables
    
    @IBOutlet weak var sideView: UIView!
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var matchesTableView: UITableView!
    
    let menuArray = ["All Matches","Saved Matches"]
    var isSideViewOpen : Bool = false
    var isMatchedSelected : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sideView.isHidden = true
        isSideViewOpen = false
        
        NetworkManager.shared.callVenueAPI(onCompletion: { (status, _) in
            if status {
                DispatchQueue.main.async {
                    self.isMatchedSelected = true
                    self.matchesTableView.reloadData()
                }
            }
        })
    }
    
    //MARK: Handle Menu UI
    func handleMenu()  {
        menuTableView.isHidden = false
        sideView.isHidden = false
        self.view.bringSubviewToFront(sideView)
        if !isSideViewOpen {
            isSideViewOpen = true//0
            sideView.frame = CGRect(x: 0, y: 88, width: 0, height: 499)
            menuTableView.frame = CGRect(x: 0, y: 0, width: 0, height: 499)
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.view.layoutIfNeeded()
            }
            sideView.frame = CGRect(x: 0, y: 88, width: 259, height: 499)
            menuTableView.frame = CGRect(x: 0, y: 0, width: 259, height: 499)
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.view.layoutIfNeeded()
            }
            self.matchesTableView.isHidden = true
        } else {
            menuTableView.isHidden = true
            sideView.isHidden = true
            isSideViewOpen = false
            sideView.frame = CGRect(x: 0, y: 88, width: 259, height: 499)
            menuTableView.frame = CGRect(x: 0, y: 0, width: 259, height: 499)
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.view.layoutIfNeeded()
            }
            
            sideView.frame = CGRect(x: 0, y: 88, width: 0, height: 499)
            menuTableView.frame = CGRect(x: 0, y: 0, width: 0, height: 499)
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.view.layoutIfNeeded()
            }
            self.matchesTableView.isHidden = false
            
        }
    }
    
    @IBAction func menuButtonPressed(_ sender: Any) {
        self.handleMenu()
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate, cellDelegate {
    
    //MARK: UITableViewDataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == matchesTableView {
            if isMatchedSelected {
                return NetworkManager.shared.venues.count
            } else {
                return DBHelper.shared.read().count
            }
        }
        return menuArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == menuTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            cell?.textLabel?.text = menuArray[indexPath.row]
            return cell!
        } else if tableView == matchesTableView {
            if let matchCell = tableView.dequeueReusableCell(withIdentifier: "MatchesTableViewCell") as? MatchesTableViewCell {
                if isMatchedSelected {
                    matchCell.cellDelegate = self
                    
                    let venue = NetworkManager.shared.venues[indexPath.row]
                    matchCell.matchesLabel.text = venue.name
                    matchCell.starButton.tag = indexPath.row
                    //
                    if  DBHelper.shared.readVenue(venueObject: venue).count != 0 {
                        matchCell.starButton.setBackgroundImage(UIImage(named: "starSelected"), for: .normal)
                        matchCell.isStarSelected = true
                    } else {
                        matchCell.starButton.setBackgroundImage(UIImage(named: "star"), for: .normal)
                        matchCell.isStarSelected = false
                        
                    }
                } else {
                    // Get data from DB
                    let venue = DBHelper.shared.read()[indexPath.row]
                    matchCell.matchesLabel.text = venue.name
                    matchCell.starButton.tag = indexPath.row
                    matchCell.starButton.setBackgroundImage(UIImage(named: "starSelected"), for: .normal)
                }
                
                return matchCell
            }
        }
        return UITableViewCell()
    }
    
    //MARK: UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == menuTableView {
            if indexPath.row == 0 {
                isMatchedSelected = true
            } else  if indexPath.row == 1 {
                isMatchedSelected = false
            }
        }
        self.matchesTableView.reloadData()
        self.handleMenu()
    }
    
    //MARK: cellDelegate Protocol
    func editButtonPressed(tag: Int, cell: MatchesTableViewCell) {
        if isMatchedSelected {
            //Insert Into DB and change only that button icon
            let venue = NetworkManager.shared.venues[tag]
            DBHelper.shared.insert(venueObj: venue)
            
            
            //reload cell
            let indexPath = IndexPath(item: tag, section: 0)
            self.matchesTableView.reloadRows(at: [indexPath], with: .fade)
            // when star selected
            if cell.isStarSelected  {
                DBHelper.shared.deleteByID(venueObject: venue)
            }
            self.matchesTableView.reloadRows(at: [indexPath], with: .fade)
            
        } else {
            let venue = DBHelper.shared.read()[tag]
            DBHelper.shared.deleteByID(venueObject: venue)
            self.matchesTableView.reloadData()
        }
    }
}
