//
//  RadioPickerViewController.swift
//  testing
//
//  Created by Razgaitis, Paul on 2/17/17.
//  Copyright © 2017 Razgaitis, Paul. All rights reserved.
//

import UIKit

class RadioPickerViewController: UIViewController {
    
    var refreshControl: UIRefreshControl!
    var stations = [RadioStation]()
    
    var searchedStations = [RadioStation]()
    var searchController : UISearchController!
    
    @IBOutlet weak var tableView: UITableView!
    
    //*************************************************************
    // MARK: - viewDidLoad
    //*************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Register 'Nothing Found' cell xib
        let cellNib = UINib(nibName: "NothingFoundCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "NothingFound")
        
        // Load data
        loadStationsFromJSON()
        
        // setup TableView
        tableView.backgroundColor = UIColor.clear
        tableView.backgroundView = nil
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        // Setup Pull To Refresh
        setupPullToRefresh()
        
        // Set up Search Bar
        setupSearchController()

        // Do any additional setup after loading the view.
    }
    
    //*************************************************************
    // MARK: - Setup UI
    //*************************************************************
    
    func setupPullToRefresh(){
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.backgroundColor = UIColor.black
        self.refreshControl.tintColor = UIColor.white
        self.refreshControl.addTarget(self, action: #selector(RadioPickerViewController.refresh), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    func setupSearchController() {
        //set the UISearchController
        searchController = UISearchController(searchResultsController: nil)
        
        if searchable {
            searchController.searchResultsUpdater = self
            searchController.dimsBackgroundDuringPresentation = false
            searchController.searchBar.sizeToFit()
            
            // Add UISearchController to tableView
            tableView.tableHeaderView = searchController?.searchBar
            tableView.tableHeaderView?.backgroundColor = UIColor.clear
            definesPresentationContext = true
            searchController.hidesNavigationBarDuringPresentation = false
            
            // Style the UISearchController
            searchController.searchBar.barTintColor = UIColor.clear
            searchController.searchBar.tintColor = UIColor.white
            
            // Hide the UISearchController
            tableView.setContentOffset(CGPoint(x: 0.0, y: searchController.searchBar.frame.size.height), animated: false)
            
            // Set a black keyboard for UISearchController's TextField
            let searchTextField = searchController.searchBar.value(forKey: "_searchField") as! UITextField
            searchTextField.keyboardAppearance = UIKeyboardAppearance.dark
        }
    }
    
    //*************************************************************
    // MARK: - Actions
    //*************************************************************
    
    func refresh(sender: AnyObject) {
        // Pull To Refresh
        stations.removeAll(keepingCapacity: false)
        loadStationsFromJSON()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.refreshControl.endRefreshing()
            self.view.setNeedsDisplay()
        }
    }
    
    //*************************************************************
    // MARK: - Load Station Data
    //*************************************************************
    
    func loadStationsFromJSON() {
        
        // Turn on network indicator in status bar
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        // Get radio stations
        DataManager.getStationDataWithSuccess() { (data) in
            
            print("Stations JSON Found")
            
            let json = JSON(data: data! as Data)
            
            if let stationArray = json["station"].array {
                
                for stationJSON in stationArray {
                    let station = RadioStation.parseStation(stationJSON: stationJSON)
                    self.stations.append(station)
                }
                
                print("Stations: \(self.stations.count)")
                
                // stations array populated, update the table on the main queue
                DispatchQueue.main.async(execute: {
                    print("async display")
                    self.tableView.reloadData()
                    self.view.setNeedsDisplay()
                })
            } else {
                print("loading error")
            }
            
            // Turn off network indicator
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    //*************************************************************
    // MARK: - Segue
    //*************************************************************

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        let cell = sender as! RadioTableViewCell
        print(cell.stationNameLabel.text ?? "name not found")
        print(cell.streamUrl ?? "stream url not found")
        
        if segue.identifier == "toSettings" {
            if let nextVC = segue.destination as? RadioStationSettingsViewController {
                nextVC.stationTitle = cell.stationNameLabel.text
                nextVC.streamUrl = cell.streamUrl
            }
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//*****************************************************************
// MARK: - TableViewDataSource
//*****************************************************************

extension RadioPickerViewController: UITableViewDataSource {
    
    // MARK: - Table view data source
    @objc(tableView:heightForRowAtIndexPath:)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // The UISeachController is active
        if searchController.isActive {
            return searchedStations.count
            
            // The UISeachController is not active
        } else {
            if stations.count == 0 {
                return 1
            } else {
                return stations.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if stations.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NothingFound", for: indexPath)
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StationCell", for: indexPath) as! RadioTableViewCell
            
            // alternate background color
            if indexPath.row % 2 == 0 {
                cell.backgroundColor = UIColor.clear
            } else {
                cell.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            }
            
            // Configure the cell...
            let station = stations[indexPath.row]
            cell.configureStationCell(station: station)
            
            // The UISeachController is active
            if searchController.isActive {
                let station = searchedStations[indexPath.row]
                cell.configureStationCell(station: station)
                
                // The UISeachController is not active
            } else {
                let station = stations[indexPath.row]
                cell.configureStationCell(station: station)
            }
            
            return cell
        }
    }
}

//*****************************************************************
// MARK: - TableViewDelegate
//*****************************************************************

extension RadioPickerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if !stations.isEmpty {
        }
    }
}


//*****************************************************************
// MARK: - UISearchControllerDelegate
//*****************************************************************

extension RadioPickerViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        // Empty the searchedStations array
        searchedStations.removeAll(keepingCapacity: false)
        
        // Create a Predicate
        let searchPredicate = NSPredicate(format: "SELF.stationName CONTAINS[c] %@", searchController.searchBar.text!)
        
        // Create an NSArray with a Predicate
        let array = (self.stations as NSArray).filtered(using: searchPredicate)
        
        // Set the searchedStations with search result array
        searchedStations = array as! [RadioStation]
        
        // Reload the tableView
        self.tableView.reloadData()
    }
    
}

