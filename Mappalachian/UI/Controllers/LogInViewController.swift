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
            
            if let username = usernameCell.textField.text, !username.isEmpty, let password = passwordCell.textField.text, !password.isEmpty {
                UserManager.sharedInstance.login(username: username, password: password) {
                    print("Done I Guess")
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return section == 1 ? "Log in using your appstate.edu account to access your class schedule." : nil
    }
    
}
