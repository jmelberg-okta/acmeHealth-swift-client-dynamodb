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
    let apiEndpoint: NSURL!
    
    init(){
        kIssuer = "https://example.oktapreview.com"                  // Base url of Okta Developer domain
        kClientID = "79arVRKBcBEYMuMOXrYF"                           // Client ID of Application
        kRedirectURI = "com.oktapreview.example:/oauth"              // Reverse DNS notation of base url with oauth route
        kAppAuthExampleAuthStateKey = "com.okta.openid.authState"
        apiEndpoint = NSURL(string: "https://example.com/protected") // Resource Server URL
    }
}

let config = OktaConfiguration()


// Sample Data
var appointmentData: [NSDictionary]!
var user:User!
var physicians : [NSDictionary]!

var API_URL = "https://5ef909db.ngrok.io"

class User {
    var firstName : String!
    var lastName : String!
    var provider : String!
    
    func setFirst(firstName: String) {   self.firstName = firstName}
    func setLast(lastName: String) {self.lastName = lastName }
    func setProvider(provider: String) { self.provider = provider }
    func getDetails() -> String { return "\(firstName) \(lastName)" }

    init(firstName: String, lastName:String, provider:String) {
        self.firstName = firstName
        self.lastName = lastName
        self.provider = provider
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

func getPhysician(id: String) -> String? {
    for physician in physicians {
        let physician = physician as NSDictionary
        if (id == "\(physician["id"]!)") {
            return "\(physician["name"]!)"
        }
    }
    return nil
}

func getPhysicianID(name: String) -> String? {
    for physician in physicians {
        let physician = physician as NSDictionary
        if (name == "\(physician["name"]!)") {
            return "\(physician["id"]!)"
        }
    }
    return nil
}

func loadAppointments(completionHandler: ([NSDictionary]?, NSError?) -> ()){
    Alamofire.request(.GET, API_URL + "/appointments")
        .validate()
        .responseJSON { response in
            if let JSON = response.result.value {
                completionHandler(JSON as? [NSDictionary], nil)
            }
    }
}

func loadPhysicians(completionHandler: ([NSDictionary]?, NSError?) -> ()){
    
    Alamofire.request(.GET, API_URL + "/providers")
        .validate()
        .responseJSON { response in
            if let JSON = response.result.value {
                completionHandler(JSON as? [NSDictionary], nil)
            }
    }
}

func createAppointment(params: [String:String!], completionHandler: (NSDictionary?, NSError?) -> ()){
    Alamofire.request(.POST, API_URL + "/appointments", parameters: params)
    .responseJSON { response in
        if let JSON = response.result.value {
            completionHandler(JSON as? NSDictionary, nil)
        }
    }
}


