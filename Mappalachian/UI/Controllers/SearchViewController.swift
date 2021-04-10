//
//  SearchViewController.swift
//  Mappalachian
//
//  Created by Wilson Styres on 4/10/21.
//

import UIKit

class SearchViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    var searchController = UISearchController()
    var empty = true
    var recentSearches: [String]?
    var results: [String]?
    var building: String!
    
    init(building: String) {
        super.init(style: .plain)
        
        self.building = building
        
        searchController.obscuresBackgroundDuringPresentation = false;
        searchController.hidesNavigationBarDuringPresentation = false;
        searchController.searchResultsUpdater = self;
        searchController.searchBar.placeholder = "Room Number";
        searchController.searchBar.autocapitalizationType = .none;
//        searchController.searchBar.showsCancelButton = false;
        searchController.searchBar.delegate = self
        searchController.searchBar.setImage(UIImage(systemName: "number"), for: .search, state: .normal)
        
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        self.title = building
    }
    
    private var _title: String?
    override var title: String? {
        set {
            _title = newValue!
            
            if let titleLabel = navigationItem.leftBarButtonItem?.customView as? UILabel {
                let animation = CATransition()
                animation.duration = 0.25
                animation.type = .fade
                
                titleLabel.layer.add(animation, forKey: "fadeText")
                titleLabel.text = _title
            } else {
                let titleLabel = UILabel()
                titleLabel.textColor = .label
                titleLabel.text = _title
                
                let titleFont = UIFont.preferredFont(forTextStyle: .title2)
                let largeTitleFont = UIFont(descriptor: titleFont.fontDescriptor.withSymbolicTraits(.traitBold)!, size: titleFont.pointSize)
                titleLabel.font = largeTitleFont
                
                navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
            }
        }
        get {
            return _title
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchTerm = searchController.searchBar.text {
            
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if empty {
            return recentSearches?.count ?? 0
        } else {
            return results?.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if empty && recentSearches?.count != nil {
            return "Recent Searches"
        }
        return nil
    }

}
