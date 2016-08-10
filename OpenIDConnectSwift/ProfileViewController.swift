/** Author: Jordan Melberg **/

/** Copyright © 2016, Okta, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import UIKit
import AppAuth

class ProfileViewController: UITableViewController {
    
    // Okta Configuration
    var appConfig = config
    
    // AppAuth authState
    var authState:OIDAuthState?

    
    @IBAction func editProfile(sender: AnyObject) {
        user.setFirst(firstName.text!)
        user.setLast(lastName.text!)
        user.setProvider(insuranceProvider.text!)
        // Navigate to home tab
        tabBarController?.selectedIndex = 0
    }
    @IBAction func cancelEdit(sender: AnyObject) {
        // Navigate to home tab
        tabBarController?.selectedIndex = 0


    }
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var insuranceProvider: UITextField!
    @IBOutlet weak var primaryCare: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(user.getDetails())

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        firstName.text = "\(user.firstName)"
        lastName.text = "\(user.lastName)"
        insuranceProvider.text = "\(user.provider)"
        self.tableView.reloadData()
    }
    
    /**  Loads the current authState from NSUserDefaults */
    func loadState() {
        if let archivedAuthState = NSUserDefaults.standardUserDefaults().objectForKey(appConfig.kAppAuthExampleAuthStateKey) as? NSData {
            if let authState = NSKeyedUnarchiver.unarchiveObjectWithData(archivedAuthState) as? OIDAuthState {
                self.authState = authState
            } else {  return  }
        } else { return }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func createAlert(alertTitle: String, alertMessage: String) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
        alert.view.tintColor = UIColor.blackColor()
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
        let textIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(10, 5, 50, 50)) as UIActivityIndicatorView
        alert.view.addSubview(textIndicator)
        
        presentViewController(alert, animated: true, completion: nil)
    }
}
