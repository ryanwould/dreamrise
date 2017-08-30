//
//  PodcastTableViewController.swift
//  testing
//
//  Created by Razgaitis, Paul on 2/18/17.
//  Copyright © 2017 Razgaitis, Paul. All rights reserved.
//

import UIKit
import MediaPlayer


class PodcastTableViewController: UIViewController {
    
    var podcasts = [Podcast]()
    var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var tableView: UITableView!
    var searchedPodcasts = [Podcast]()
    var searchController : UISearchController!

    //*************************************************************
    // MARK: - viewDidLoad
    //*************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load data
        loadPodcasts()
        
        // setup TableView
        tableView.backgroundColor = UIColor.black
        tableView.backgroundView = nil
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        // Setup Pull To Refresh
        setupPullToRefresh()
        
        // Set up Search Bar
        setupSearchController()
        
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //*************************************************************
    // MARK: - Load Podcast Data
    //*************************************************************

    func loadPodcasts(){
        let results: [MPMediaItem]? = MPMediaQuery.podcasts().items
        if let results = results {
            
            print("Found \(results.count) podcasts")
            
            for mediaItem in results {
                print("Media Item:\n\(mediaItem.debugDescription)\n---")
                let podcast = Podcast.parseMediaItem(mediaItem: mediaItem)
                self.podcasts.append(podcast)
            }
            
            DispatchQueue.main.async(execute: {
                print("async display")
                self.tableView.reloadData()
                self.view.setNeedsDisplay()
            })
        }
    }
    
    //*************************************************************
    // MARK: - Actions
    //*************************************************************
    
    func refresh(sender: AnyObject) {
        // Pull To Refresh
        podcasts.removeAll(keepingCapacity: false)
        loadPodcasts()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.refreshControl.endRefreshing()
            self.view.setNeedsDisplay()
        }
    }
    
    //*************************************************************
    // MARK: - Segue
    //*************************************************************
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        
        if segue.identifier == "podcast_detail" {
            
            let cell = sender as! PodcastTableViewCell
            
            if let detail = segue.destination as? PodcastDetailViewController {
                detail.podcast = cell.podcast
                cell.podcast?.debug()
            }
        }
    }
    
    //*************************************************************
    // MARK: - Setup UI
    //*************************************************************
    
    func setupPullToRefresh(){
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.backgroundColor = UIColor.black
        //self.refreshControl.tintColor = UIColor.white
        self.refreshControl.addTarget(self, action: #selector(PodcastTableViewController.refresh), for: UIControlEvents.valueChanged)
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
            tableView.tableHeaderView?.backgroundColor = UIColor.black
            definesPresentationContext = true
            searchController.hidesNavigationBarDuringPresentation = false
            
            // Style the UISearchController
            searchController.searchBar.barTintColor = UIColor.clear
            //searchController.searchBar.tintColor = UIColor.white
            
            // Hide the UISearchController
            tableView.setContentOffset(CGPoint(x: 0.0, y: searchController.searchBar.frame.size.height), animated: false)
            
            // Set a black keyboard for UISearchController's TextField
            let searchTextField = searchController.searchBar.value(forKey: "_searchField") as! UITextField
            searchTextField.keyboardAppearance = UIKeyboardAppearance.dark
        }
    }

    @IBAction func goToPodcastsApp(_ sender: Any) {
        if let url = URL(string: "https://itunes.apple.com/us/podcast"){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

//***********************************
// Mark: - TableViewDataSource
//***********************************

extension PodcastTableViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // The UISeachController is active
        if searchController.isActive {
            if searchedPodcasts.count == 0 {
                //return the "none found" cell
                return 1
            } else {
                return searchedPodcasts.count
            }
        // The UISeachController is not active
        } else {
            if podcasts.count == 0 {
                return 1
            } else {
                return podcasts.count
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableData = searchController.isActive ? searchedPodcasts : podcasts
        
        if tableData.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoPodcastsFoundCell")!
            return cell
        } else {
            let podcast = tableData[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "PodcastCell",for: indexPath) as!PodcastTableViewCell
            cell.configurePodcastCell(podcast: podcast)
            return cell
        }
    }
}

//*****************************************************************
// MARK: - UISearchControllerDelegate
//*****************************************************************

extension PodcastTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        // Empty the searchedStations array
        searchedPodcasts.removeAll(keepingCapacity: false)
        
        // Create a Predicate
        let searchPredicate = NSPredicate(format: "SELF.podcastTitle CONTAINS[c] %@", searchController.searchBar.text!)
        
        // Create an NSArray with a Predicate
        let array = (self.podcasts as NSArray).filtered(using: searchPredicate)
        
        // Set the searchedStations with search result array
        searchedPodcasts = array as! [Podcast]
        
        // Reload the tableView
        self.tableView.reloadData()
    }
    
}



