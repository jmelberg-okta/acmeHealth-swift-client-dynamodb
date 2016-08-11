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

class RequestAppointmentViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var date: UIDatePicker!
    @IBOutlet weak var doctorLabel: UILabel!
    @IBOutlet weak var doctorPicker: UIPickerView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var reasonText: UITextView!
    @IBAction func datePickerValue(sender: AnyObject) {
        datePickerChanged()
    }
    
    @IBAction func requestAppointment(sender: AnyObject) {
        if date != nil || doctorLabel != nil || reasonText != nil{
            requestAppointment()
        } else {
            print("Missing fields")
        }
        
    }
    @IBAction func exitRequest(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    var datePickerHidden = true
    var pickerHidden = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePickerChanged()
        self.doctorPicker.dataSource = self
        self.doctorPicker.delegate = self
        self.doctorLabel.text = "\(physicians[0]["name"]!)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 1 && indexPath.row == 0 {
            toggleDatepicker()
        }
        if indexPath.section == 0 && indexPath.row == 0 {
            togglePicker()
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if datePickerHidden && indexPath.section == 1 && indexPath.row == 1 {
            return 0
        }
        else if pickerHidden && indexPath.section == 0 && indexPath.row == 1 {
            return 0
        }
        else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    
    func datePickerChanged () {
        dateLabel.text = NSDateFormatter.localizedStringFromDate(date.date, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
    }
    
    func toggleDatepicker() {
        datePickerHidden = !datePickerHidden
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func togglePicker() {
        pickerHidden = !pickerHidden
        tableView.beginUpdates()
        tableView.endUpdates()
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
        doctorLabel.text = physicians[row]["name"] as? String
    }
    
        
    func formatDate(date : String) -> String? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +SSSS"
        let formattedDate = dateFormatter.dateFromString(date)
        
        // Convert from date to string
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return dateFormatter.stringFromDate(formattedDate!)

    }
    
    func requestAppointment() {
        let id = getPhysicianID("\(self.doctorLabel.text!)")!
        let formattedDate = formatDate("\(self.date.date)")
        let params = [
            "comment" : self.reasonText.text,
            "startTime": formattedDate!,
            "providerId" : id
        ]
        
        createAppointment(params){
            response, error in
            print(response!)
            
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    

}
