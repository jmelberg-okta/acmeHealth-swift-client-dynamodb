
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
