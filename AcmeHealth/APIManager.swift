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

/* Given accessToken and provider/user id -> returns all appointments */
func loadAppointments(token: String, id: String, completionHandler: ([NSDictionary]?, NSError?) -> ()){
    let headers = ["Authorization" : "Bearer \(token)",
                   "Accept" :  "application/json"]
    Alamofire.request(.GET, config.authorizationServerURL + "/appointments/" + id, headers: headers)
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
    Alamofire.request(.GET, config.authorizationServerURL + "/providers", headers : headers)
        .validate()
        .responseJSON { response in
            if let JSON = response.result.value {
                completionHandler(JSON as? [NSDictionary], nil)
            }
    }
}

/* Creates new appointment */
func createAppointment(params: [String:String!], completionHandler: (NSDictionary?, NSError?) -> ()){
    Alamofire.request(.POST, config.authorizationServerURL + "/appointments", parameters: params)
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
    Alamofire.request(.DELETE, config.authorizationServerURL + "/appointments/" + id, headers: headers)
        .validate()
        .responseJSON { response in
            if response.response?.statusCode == 204 {
                completionHandler(true, nil)
            }
    }
}
