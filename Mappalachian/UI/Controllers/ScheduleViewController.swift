//
//  AccountViewController.swift
//  Mappalachian
//
//  Created by Wilson Styres on 1/31/21.
//

import UIKit

class ScheduleViewController: UITableViewController {
    
    var userInfo: User?
    var schedule: [Schedule]?
    
    init() {
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("coder not supported")
    }
    
    override func loadView() {
        super.loadView()
        self.title = "Schedule"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOut))
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

    @objc func signOut() {
        UserManager.shared.signOut()
        self.navigationController?.setViewControllers([LogInViewController()], animated: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        let hasUserInfo = userInfo != nil
        let hasCourses = schedule?.count ?? 0 > 0
        
        return hasCourses ? 2 : hasUserInfo ? 1 : 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return schedule?.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "AccountCell")
        
        cell.textLabel?.text = userInfo?.username
        cell.detailTextLabel?.text = userInfo?.bannerID

        return cell
    }

}
