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
    var results: [String]?
    var building: Building!
    var units: [Int: [Unit]] = [:]
    
    init(building: String) {
        super.init(style: .plain)
        
        self.building = AppDelegate.delegate().venue.buildings.first(where: { $0.identifier == building })
        for level in self.building.levels {
            var units = level.units.filter({ unit in
                return unit.properties!.category != "stairs" && unit.properties!.category != "concrete" && unit.properties!.category != "elevator" && unit.properties!.category != "wall"
            })
            units.sort { unitA, unitB in
                return unitA.identifier < unitB.identifier
            }
            self.units[level.properties!.ordinal] = units
            
        }
        
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "roomCell")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        self.title = building.properties!.name
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(goodbye))
        navigationItem.rightBarButtonItem = closeButton
    }
    
    @objc func goodbye() {
        self.dismiss(animated: true, completion: nil)
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
        return building.levels.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if empty {
            return self.units[section]!.count
        } else {
            return results?.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "roomCell", for: indexPath)
        if empty {
            cell.textLabel?.text = self.units[indexPath.section]![indexPath.row].identifier
        } else {
            
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.tableView(tableView, numberOfRowsInSection: section) > 0 {
            return "Floor \(building.levels[section].properties!.ordinal + 1)"
        }
        return nil
    }

}
