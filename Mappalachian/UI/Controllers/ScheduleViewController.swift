//
//  AccountViewController.swift
//  Mappalachian
//
//  Created by Wilson Styres on 1/31/21.
//

import UIKit

class ScheduleViewController: UITableViewController {
    
    let spinner = UIActivityIndicatorView(style: .medium)
    
    var userInfo: User?
    var schedule: Schedule?
    
    init() {
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        self.title = "Schedule"
        
        showSpinner()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOut))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global(qos: .userInitiated).async {
            UserManager.shared.fetchUserInfo { (userInfo, error) in
                if error != nil {
                    print("Could not get userInfo. Reason: \(error!.localizedDescription)")
                } else if userInfo != nil {
                    self.userInfo = userInfo
                    UserManager.shared.fetchSchedule(for: userInfo!) { (schedule, error) in
                        self.schedule = schedule
                        
                        if let name = schedule?.person.name {
                            var comps = name.components(separatedBy: " ")
                            if comps.count > 0 {
                                comps.removeLast() // Removes middle initial
                                
                                var lastName = comps.removeFirst()
                                lastName.removeLast()
                                let firstName = comps.joined(separator: " ")
                                self.userInfo?.name = "\(firstName) \(lastName)"
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.hideSpinner()
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }

    @objc func signOut() {
        UserManager.shared.signOut()
        self.navigationController?.setViewControllers([LogInViewController()], animated: true)
    }
    
    func showSpinner() {
        DispatchQueue.main.async {
            self.spinner.startAnimating()
            self.tableView.backgroundView = self.spinner
        }
    }
    
    func hideSpinner() {
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            self.tableView.backgroundView = nil
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        let hasUserInfo = userInfo != nil
        let hasCourses = schedule != nil
        
        return hasCourses ? 2 : hasUserInfo ? 1 : 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return schedule?.terms.first?.courses.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "AccountCell")
        
        if indexPath.section == 0 {
            cell.textLabel?.text = userInfo?.name
            cell.detailTextLabel?.text = "\(userInfo!.username)@appstate.edu"
        } else {
            cell.textLabel?.text = schedule?.terms.first?.courses[indexPath.row].name
            cell.detailTextLabel?.text = schedule?.terms.first?.courses[indexPath.row].title.capitalized
            cell.accessoryType = .disclosureIndicator
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let meetingPattern = schedule?.terms.first?.courses[indexPath.row].meetingPatterns?.first
        let mapNavController = self.tabBarController?.viewControllers?.first as? UINavigationController
        let map = mapNavController?.viewControllers.first as? MapViewController
        
        self.tabBarController?.selectedIndex = 0
        map?.focusOnRoom(room: meetingPattern!.room, in: meetingPattern!.buildingID)
    }
    
}
