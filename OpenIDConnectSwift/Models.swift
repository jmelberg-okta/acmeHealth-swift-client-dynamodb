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

import Foundation
import Alamofire

class OktaConfiguration {
    let kIssuer: String!
    let kClientID: String!
    let kRedirectURI: String!
    let kAppAuthExampleAuthStateKey: String!
    let kAppAuthExampleAuthStateServerKey: String!
    let kAuthorizationServerEndpoint: NSURL!
    let kAuthorizationTokenEndpoint: NSURL!
    
    init(){
        kIssuer = "https://jordandemo.oktapreview.com"                  // Base url of Okta Developer domain
        kClientID = "Jw1nyzbsNihSuOETY3R1"                              // Client ID of Application
        kRedirectURI = "com.oktapreview.jordandemo:/oauth"              // Reverse DNS notation of base url with oauth route
        kAppAuthExampleAuthStateKey = "com.okta.oauth.authState"        // Key for NSUser
        kAppAuthExampleAuthStateServerKey = "com.okta.oauth.authServerState"
        kAuthorizationServerEndpoint = NSURL(string: "https://jordandemo.oktapreview.com/oauth2/aus7xbiefo72YS2QW0h7/v1/authorize")
        kAuthorizationTokenEndpoint = NSURL(string: "https://jordandemo.oktapreview.com/oauth2/aus7xbiefo72YS2QW0h7/v1/token")
    }
}

let config = OktaConfiguration()


// Sample Data
var appointmentData: [NSDictionary]!
var user:AcmeUser!
var physicians : [NSDictionary]!

var API_URL = "https://20136853.ngrok.io"

class AcmeUser {
    var firstName : String!
    var lastName : String!
    var provider : String!
    var email : String!
    var physician : String!
    var picture : String!
    var id : String!
    
    func setFirst(firstName: String) {   self.firstName = firstName}
    func setLast(lastName: String) {self.lastName = lastName }
    func setProvider(provider: String) { self.provider = provider }
    func getDetails() -> String { return "\(firstName) \(lastName) \nEmail: \(email) \nPicture: \(picture)" }

    init(firstName: String, lastName:String, email: String?, provider:String, picture:String, id: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.provider = provider
        self.physician = "Dr. John Doe"
        self.picture = picture
        self.id = id
    }
}

class Provider {
    var id : String!
    var name : String!
    
    init(id: String, name : String) {
        self.id = id
        self.name = name
    }
}

/* Given physican id -> returns physician name */
func getPhysician(id: String) -> String? {
    for physician in physicians {
        let physician = physician as NSDictionary
        if (id == "\(physician["id"]!)") {
            return "\(physician["name"]!)"
        }
    }
    return nil
}

/* Given physican name -> returns physician id */
func getPhysicianID(name: String) -> String? {
    for physician in physicians {
        let physician = physician as NSDictionary
        if (name == "\(physician["name"]!)") {
            return "\(physician["id"]!)"
        }
    }
    return nil
}

/* Given physican id -> returns physician profile image url */
func getPhysicianUrl(id: String) -> String? {
    for physician in physicians {
        let physician = physician as NSDictionary
        if (id == "\(physician["id"]!)") {
            return "\(physician["profileImageUrl"]!)"
        }
    }
    return nil
}

/* Given accessToken and provider/user id -> returns all appointments */
func loadAppointments(token: String, id: String, completionHandler: ([NSDictionary]?, NSError?) -> ()){
    let headers = ["Authorization" : "Bearer \(token)",
                   "Accept" :  "application/json"]
    Alamofire.request(.GET, API_URL + "/appointments/"+id, headers: headers)
        .validate()
        .responseJSON { response in
            if let JSON = response.result.value {
                // Only pull appointments that match patient ID
                completionHandler(JSON as? [NSDictionary], nil)
            }
    }
}

/* Given accessToken  -> returns all providers */
func loadPhysicians(token: String, completionHandler: ([NSDictionary]?, NSError?) -> ()){
    let headers = ["Authorization" : "Bearer \(token)",
                   "Accept" :  "application/json"]
    Alamofire.request(.GET, API_URL + "/providers", headers : headers)
        .validate()
        .responseJSON { response in
            if let JSON = response.result.value {
                completionHandler(JSON as? [NSDictionary], nil)
            }
    }
}

/* Creates new appointment */
func createAppointment(params: [String:String!], completionHandler: (NSDictionary?, NSError?) -> ()){
    Alamofire.request(.POST, API_URL + "/appointments", parameters: params)
    .responseJSON { response in
        if let JSON = response.result.value {
            completionHandler(JSON as? NSDictionary, nil)
        }
    }
}

/* Deletes appointment */
func removeAppointment(token: String, id : String, completionHandler: (Bool?, NSError?) -> ()){
    let headers = ["Authorization" : "Bearer \(token)",
                   "Accept" :  "application/json"]
    Alamofire.request(.DELETE, API_URL + "/appointments/" + id, headers: headers)
    .validate()
    .responseJSON { response in
        if response.response?.statusCode == 204{
            completionHandler(true, nil)
        }
    }

}


func getActiveUser() -> AcmeUser { return user}

/* Loads user image */
func loadImage() -> UIImage {
    if let url = NSURL(string: activeUser.picture) {
        if let data = NSData(contentsOfURL: url) {
            return UIImage(data: data)!
        }
    }
    return UIImage(named: "acme-logo")!
}


/* Loads provider image */
func loadProviderImage(name: String) -> UIImage {
    let urlString = getPhysicianUrl(getPhysicianID(name)!)
    if let url = NSURL(string: urlString!) {
        if let data = NSData(contentsOfURL: url) {
            return UIImage(data: data)!
        }
    }
    return UIImage(named: "acme-logo")!
}

