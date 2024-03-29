//
//  LogInViewController.swift
//  Mappalachian
//
//  Created by Wilson Styres on 2/1/21.
//

import UIKit

class LogInViewController: UITableViewController {

    init() {
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("coder not supported")
    }
    
    override func loadView() {
        super.loadView()
        self.navigationItem.title = "Log In"
        self.tableView.register(TextInputTableViewCell.self, forCellReuseIdentifier: "TextInputTableViewCell")
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
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextInputTableViewCell", for: indexPath) as! TextInputTableViewCell
            
            cell.backgroundColor = UIColor.systemBackground
            cell.textField.spellCheckingType = .no
            cell.textField.autocorrectionType = .no
            cell.textField.autocapitalizationType = .none
            if indexPath.row == 0 {
                cell.textField.placeholder = "Username"
                cell.textField.textContentType = .username
            } else {
                cell.textField.placeholder = "Password"
                cell.textField.textContentType = .password
                cell.textField.isSecureTextEntry = true
            }
            
            return cell
        } else {
            let cell = UITableViewCell()
            
            cell.backgroundColor = UIColor.systemYellow
            cell.textLabel?.textColor = UIColor.white
            cell.textLabel?.text = "Log In"
            cell.textLabel?.textAlignment = .center
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 { // This is our log in button
            let usernameCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! TextInputTableViewCell
            let passwordCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! TextInputTableViewCell
            if let username = usernameCell.textField.text, let password = passwordCell.textField.text {
                if username.isEmpty {
                    let alertController = UIAlertController(title: "Please enter your username", message: "Enter your appstate username to continue.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                } else if password.isEmpty {
                    let alertController = UIAlertController(title: "Please enter your password", message: "Enter your appstate password to continue.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    UserManager.shared.storeLoginInformation(username: username, password: password)
                    UserManager.shared.authenticate { (success, error) in
                        DispatchQueue.main.async {
                            if success {
                                let schedule = ScheduleViewController()
                                self.navigationController?.setViewControllers([schedule], animated: true)
                            } else if error != nil {
                                passwordCell.textLabel?.text = ""
                                let alertController = UIAlertController(title: "Could not log in", message: "An error occurred: \(error!.localizedDescription)", preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                                alertController.addAction(okAction)
                                
                                self.present(alertController, animated: true, completion: nil)
                            } else {
                                passwordCell.textLabel?.text = ""
                                let alertController = UIAlertController(title: "Could not log in", message: "Incorrect username and/or password", preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                                alertController.addAction(okAction)
                                
                                self.present(alertController, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return section == 1 ? "Log in using your appstate.edu account to access your class schedule." : nil
    }
    
}
