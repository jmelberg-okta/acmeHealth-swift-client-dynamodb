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

class ProfileViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var providerName: UILabel!
    @IBOutlet weak var physicianName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileEmail: UILabel!
    @IBOutlet weak var providerPicker: UIPickerView!
    
    var pickerHidden = true
    var submitHidden = true
    
    @IBAction func editProfile(sender: AnyObject) {
        submitHidden = false
        // NOT IMPLEMENTED
        toggleSubmit()
        tabBarController?.selectedIndex = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set profile content
        print("User: \(user.firstName) \(user.lastName)")
        profileName.text = "\(user.firstName) \(user.lastName)"
        profileEmail.text = "\(user.email)"
        providerName.text = "\(user.provider)"
        
        // Load image
        if let url = NSURL(string: user.picture){
            if let data = NSData(contentsOfURL: url) {
                profileImage.image = UIImage(data: data)
            }
        } else {
            profileImage.image = UIImage(named: "acme-logo")
        }
        
        // Format img
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        profileImage.layer.masksToBounds = false
        profileImage.clipsToBounds = true
        
        if let currentPhysician = user.physician {
            physicianName.text = "\(currentPhysician)"
        } else {
            physicianName.text = "Please Select Physician"
        }
        
        self.providerPicker.dataSource = self
        self.providerPicker.delegate = self
        self.tableView.reloadData()


    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 2 && indexPath.row == 0 {
            togglePicker()
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if pickerHidden && indexPath.section == 2 && indexPath.row == 1 {
            return 0
        }
        else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    func togglePicker() {
        pickerHidden = !pickerHidden
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func toggleSubmit() {
        submitHidden = !submitHidden
        
        
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return physicians.count;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let name = physicians[row]["name"] as? String
        return name!
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        physicianName.text = physicians[row]["name"] as? String
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
