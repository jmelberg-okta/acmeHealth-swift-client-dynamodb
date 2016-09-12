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
    let issuer: String!
    let clientID: String!
    let redirectURI: String!
    let appAuthExampleAuthStateKey: String!
    let appAuthExampleAuthStateServerKey: String!
    let authorizationServerURL: String!
    let authorizationServerEndpoint: NSURL!
    let authorizationTokenEndpoint: NSURL!
    let idTokenScopes : [String]!
    let authorizationServerScopes: [String]!
    
    
    init(){
        issuer = "https://jordandemo.oktapreview.com"                   // Base url of Okta Developer domain
        clientID = "Jw1nyzbsNihSuOETY3R1"                               // Client ID of Application
        redirectURI = "com.acmehealth://oauth"                          // Reverse DNS notation of base url with oauth route
        appAuthExampleAuthStateKey = "com.okta.oauth.authState"         // Key for NSUserDefaults
        appAuthExampleAuthStateServerKey = "com.okta.oauth.authServerState"
        authorizationServerURL = "http://localhost:8088"
        authorizationServerEndpoint = NSURL(string: "https://jordandemo.oktapreview.com/oauth2/aus7xbiefo72YS2QW0h7/v1/authorize")
        authorizationTokenEndpoint = NSURL(string: "https://jordandemo.oktapreview.com/oauth2/aus7xbiefo72YS2QW0h7/v1/token")
        idTokenScopes = [
            "openid",
            "profile",
            "email",
            "offline_access"
        ]
        authorizationServerScopes = [
            "appointments:read",
            "appointments:write",
            "appointments:cancel",
            "providers:read"
        ]
    }
}
