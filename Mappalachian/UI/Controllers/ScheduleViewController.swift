//
//  AccountViewController.swift
//  Mappalachian
//
//  Created by Wilson Styres on 1/31/21.
//

import UIKit

class ScheduleViewController: UITableViewController {
    
    init() {
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("coder not supported")
    }
    
    override func loadView() {
        super.loadView()
        self.title = "Schedule"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 1;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()

        if indexPath.section == 0 {
            cell.backgroundColor = UIColor.systemBackground
            cell.textLabel?.textColor = UIColor.placeholderText
            if indexPath.row == 0 {
                cell.textLabel?.text = "Username"
            } else {
                cell.textLabel?.text = "Password"
            }
            cell.textLabel?.textAlignment = .left
        } else {
            cell.backgroundColor = UIColor.systemYellow
            cell.textLabel?.textColor = UIColor.white
            cell.textLabel?.text = "Log In"
            cell.textLabel?.textAlignment = .center
        }

        return cell
    }

}
