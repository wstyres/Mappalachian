//
//  AccountViewController.swift
//  Mappalachian
//
//  Created by Wilson Styres on 1/31/21.
//

import UIKit

class ScheduleViewController: UITableViewController {
    
    var userInfo: User? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
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
        
        DispatchQueue.global(qos: .userInitiated).async {
            UserManager.shared.fetchUserInfo { (userInfo, error) in
                if error != nil {
                    print("Could not get userInfo. Reason: \(error!.localizedDescription)")
                } else {
                    self.userInfo = userInfo
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "AccountCell")
        
        cell.textLabel?.text = userInfo?.username
        cell.detailTextLabel?.text = userInfo?.bannerID

        return cell
    }

}
