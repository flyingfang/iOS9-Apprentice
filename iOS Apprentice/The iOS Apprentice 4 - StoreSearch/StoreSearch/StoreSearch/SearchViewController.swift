//
//  SearchViewController.swift
//  StoreSearch
//
//  Created by FLYing on 16/3/20.
//  Copyright © 2016年 FLY. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
//    var searchResults = [SearchResult]()
//    var hasSearched = false
//    var isLoading = false
//    var dataTask: NSURLSessionTask?
    var landscapeViewController: LandscapeViewController?
    let search = Search()
    
    weak var splitViewDetail: DetailViewController?
    
    
    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        
        tableView.rowHeight = 80
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
        
        title = NSLocalizedString("Search", comment: "Split-view master button")
        if UIDevice.currentDevice().userInterfaceIdiom != .Pad {
            searchBar.becomeFirstResponder()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
//        Dispose of any resources that can be recreated.
    }
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        performSearch()
    }


    // Animation
    func hideMasterPane() {
        UIView.animateWithDuration(0.25, animations: {
            self.splitViewController!.preferredDisplayMode = .PrimaryHidden
            }, completion: { _ in
                self.splitViewController!.preferredDisplayMode = .Automatic
        })
    }
    
    func showLandscapeViewWithCoordinator(coordinator: UIViewControllerTransitionCoordinator) {
    
        // 1
//        precondition(landscapeViewController == nil)
        
        // 2
        landscapeViewController = storyboard!.instantiateViewControllerWithIdentifier("LandscapeViewController") as? LandscapeViewController
        
        if let controller = landscapeViewController {
            // 3
            controller.search = search
            controller.view.frame = view.bounds
            controller.view.alpha = 0
            
            // 4
            view.addSubview(controller.view)
            addChildViewController(controller)
            
            coordinator.animateAlongsideTransition({ _ in
                controller.view.alpha = 1
                self.searchBar.resignFirstResponder()
                if self.presentedViewController != nil {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }, completion: { _ in
                controller.didMoveToParentViewController(self)
            })
        }
    }
        
    func hideLandscapeViewWithCoordinator(coordinator: UIViewControllerTransitionCoordinator) {
        if let controller = landscapeViewController {
            controller.willMoveToParentViewController(nil)
            
            coordinator.animateAlongsideTransition({ _ in
                controller.view.alpha = 0
                if self.presentedViewController != nil {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }, completion: { _ in
                    controller.view.removeFromSuperview()
                    controller.removeFromParentViewController()
                    self.landscapeViewController = nil
            })
        }
    }
    
    override func willTransitionToTraitCollection(newCollection: UITraitCollection,withTransitionCoordinator coordinator:UIViewControllerTransitionCoordinator){
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
        let rect = UIScreen.mainScreen().bounds
        if (rect.width == 736 && rect.height == 414) ||  // portrait
            (rect.width == 414 && rect.height == 736) {  // landscape
            if presentedViewController != nil {
                dismissViewControllerAnimated(true, completion: nil)
            }
            
        } else if UIDevice.currentDevice().userInterfaceIdiom != .Pad {
            switch newCollection.verticalSizeClass {
            case .Compact:
                showLandscapeViewWithCoordinator(coordinator)
            case .Regular, .Unspecified:
                hideLandscapeViewWithCoordinator(coordinator)
            }
        }
        
    }

    // MARK - error Alert
    func showNetworkError() {
        let alert = UIAlertController (
            title: NSLocalizedString("Whoops...", comment: "Error alert: title"),
            message: NSLocalizedString("There was an error reading from the iTunes Store. Please try again.", comment: "Error alert: message"),
            preferredStyle: .Alert)
        
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        
        presentViewController(alert,animated: true, completion: nil)
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        performSearch()
    }
    
    func performSearch() {
        
        if let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex) {
            search.performSearchForText(searchBar.text!, category: category,completion: {
                success in
                if !success {
                    self.showNetworkError()
                }
                self.tableView.reloadData()
                self.landscapeViewController?.searchResultsReceived()
            })
            
            tableView.reloadData()
            searchBar.resignFirstResponder()
        }
        

        
//        if !searchBar.text!.isEmpty{
//            searchBar.resignFirstResponder()
//            
//            dataTask?.cancel()
//            isLoading = true
//            tableView.reloadData()
//            
//            hasSearched = true
//            searchResults = [SearchResult]()
//            
//            // Create the NSURL object
//            let url = urlWithSearchText(searchBar.text!, category: segmentedControl.selectedSegmentIndex)
//            // Obtain the NSURLSession object with standard "shared" session,which uses a default configuration with respect to caching,cookies,and other web stuff.
//            let session = NSURLSession.sharedSession()
//            // create a data task for HTTPS GET requests
//            dataTask = session.dataTaskWithURL(url,completionHandler:  {
//              data, response, error in
//                // 4
//                if let error = error where error.code == -999 {
//                    print("Failure! \(error)")
//                    return
//                } else if let httpResponse = response as? NSHTTPURLResponse
//                    where httpResponse.statusCode == 200 {
//                    if let data = data, dictionary = self.parseJSON(data) {
//                        self.searchResults = self.parseDictionary(dictionary)
//                        self.searchResults.sortInPlace(<)
//                        
//                        dispatch_async(dispatch_get_main_queue(), {
//                            self.isLoading = false
//                            self.tableView.reloadData()
//                        })
//                        return
//                    }
//                } else {
//                    print("Failure! \(response!)")
//                }
//                
//                dispatch_async(dispatch_get_main_queue()) {
//                    self.hasSearched = false
//                    self.isLoading = false
//                    self.tableView.reloadData()
//                    self.showNetworkError()
//                }
//            })
//
//            // to start the data task
//            dataTask?.resume()
//
//         }
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch search.state {
        case .NotSearchedYet:
            return 0
        case .Loading:
            return 1
        case .NoResults:
            return 1
        case .Results(let list):
            return list.count
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch search.state {
        case .NotSearchedYet:
            fatalError("Should never get here")
            
        case .Loading:
            let cell = tableView.dequeueReusableCellWithIdentifier(
                TableViewCellIdentifiers.loadingCell, forIndexPath:indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
            
        case .NoResults:
            return tableView.dequeueReusableCellWithIdentifier(
                TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath)
            
        case .Results(let list):
            let cell = tableView.dequeueReusableCellWithIdentifier(
                TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath)
                as! SearchResultCell
            let searchResult = list[indexPath.row]
            cell.configureForSearchResult(searchResult)
            return cell
            
        }
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        searchBar.resignFirstResponder()
        if view.window!.rootViewController!.traitCollection.horizontalSizeClass == .Compact {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            performSegueWithIdentifier("ShowDetail", sender: indexPath)
        } else {
            if case .Results(let list) = search.state {
                splitViewDetail?.searchResult = list[indexPath.row]
            }
            if splitViewController!.displayMode != .AllVisible {
                hideMasterPane()
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            if case .Results(let list) = search.state {
                let detailViewController = segue.destinationViewController
                    as! DetailViewController
                let indexPath = sender as! NSIndexPath
                let searchResult = list[indexPath.row]
                detailViewController.searchResult = searchResult
                detailViewController.isPopUp = true
            }
        }
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        switch search.state {
        case .NotSearchedYet, .Loading, .NoResults:
            return nil
        case .Results:
            return indexPath
        }
    }
}