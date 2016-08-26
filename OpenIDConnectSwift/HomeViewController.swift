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
import Alamofire

class HomeViewController: UIViewController, OIDAuthStateChangeDelegate {

    // MARK: Properties
    
    // Okta Configuration
    var appConfig = config
    
    // AppAuth authState
    var authState:OIDAuthState?
    var authServerState: OIDAuthState?
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBAction func signInAction(sender: AnyObject) {
        self.loadingIndicator.startAnimating()
        for key in Array(NSUserDefaults.standardUserDefaults().dictionaryRepresentation().keys) {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
        }
        NSUserDefaults.standardUserDefaults().synchronize()
        self.loadState()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /************************************************/
    /**********  Begin AppAuth Boilerplate **********/
    /************************************************/
    
    /**  Saves the current authState into NSUserDefaults  */
    func saveState() {
        if(authState == nil && authServerState == nil){
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: appConfig.kAppAuthExampleAuthStateKey)
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: appConfig.kAppAuthExampleAuthStateServerKey)
        }
        if(authState != nil){
            let archivedAuthState = NSKeyedArchiver.archivedDataWithRootObject(authState!)
            NSUserDefaults.standardUserDefaults().setObject(archivedAuthState, forKey: appConfig.kAppAuthExampleAuthStateKey)

        }
        if (authServerState != nil) {
            let archivedAuthServerState = NSKeyedArchiver.archivedDataWithRootObject(authServerState!)
            NSUserDefaults.standardUserDefaults().setObject(archivedAuthServerState, forKey: appConfig.kAppAuthExampleAuthStateServerKey)
        }
        
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    /**  Loads the current authState from NSUserDefaults */
    func loadState() {
        if let archivedAuthState = NSUserDefaults.standardUserDefaults().objectForKey(appConfig.kAppAuthExampleAuthStateKey) as? NSData {
            if let archivedAuthServerState = NSUserDefaults.standardUserDefaults().objectForKey(appConfig.kAppAuthExampleAuthStateServerKey) as? NSData {
                if let authState = NSKeyedUnarchiver.unarchiveObjectWithData(archivedAuthState) as? OIDAuthState {
                    if let authServerState = NSKeyedUnarchiver.unarchiveObjectWithData(archivedAuthServerState) as? OIDAuthState {
                        setAuthServerState(authServerState)
                    }
                    setAuthState(authState)
                } else {    authenticate()  }
            }
        } else { authenticate() }
    }
    
    private func setAuthState(authState:OIDAuthState?){
        self.authState = authState
        self.authState?.stateChangeDelegate = self
        self.stateChanged()
    }
    
    private func setAuthServerState(authState:OIDAuthState?){
        self.authServerState = authState
        self.authServerState?.stateChangeDelegate = self
        self.stateChanged()
    }
    
    /**  Required method  */
    func stateChanged(){ self.saveState() }
    
    /**  Required method  */
    func didChangeState(state: OIDAuthState) { self.stateChanged() }
    
    /**  Verifies authState was performed  */
    func checkAuthState() -> Bool {
        if (authState != nil){
            return true
        } else { return false }
    }
    
    /************************************************/
    /***********  End AppAuth Boilerplate ***********/
    /************************************************/

    
    func authorizationServerConfig(appDelegate : AppDelegate, completionHandler: (Bool?, NSError?) -> ()) {
        
        // Manually configure Authorization Server Call
        
        let authorizationEndpoint = appConfig.kAuthorizationServerEndpoint
        let tokenEndpoint = appConfig.kAuthorizationTokenEndpoint
        
        let config = OIDServiceConfiguration.init(authorizationEndpoint: authorizationEndpoint, tokenEndpoint: tokenEndpoint)
        
        // Build Authentication Request for accessToken
        let request = OIDAuthorizationRequest(configuration: config!,
                                              clientId: appConfig.kClientID,
                                              scopes: appConfig.authorizationServerScopes,
                                              redirectURL: NSURL(string: appConfig.kRedirectURI)!,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: nil)
        print("Initiating Authorization Request: \(request!)")
        appDelegate.currentAuthorizationFlow =
            OIDAuthState.authStateByPresentingAuthorizationRequest(request!, presentingViewController: self){
                authorizationResponse, error in
                if(authorizationResponse != nil) {
                    self.setAuthServerState(authorizationResponse)
                    completionHandler(true, nil)
                } else {
                    print("Authorization Error: \(error!.localizedDescription)")
                    self.setAuthServerState(nil)
                }
        }

    }

    func authenticate() {
        let issuer = NSURL(string: appConfig.kIssuer)
        let redirectURI = NSURL(string: appConfig.kRedirectURI)
        // Discovers Endpoints
        OIDAuthorizationService.discoverServiceConfigurationForIssuer(issuer!) {
            config, error in
        
            if ((config == nil)) {
                print("Error retrieving discovery document: \(error?.localizedDescription)")
                return
            }
            print("Retrieved configuration: \(config!)")
            
            // Build Authentication Request for idToken
            let request = OIDAuthorizationRequest(configuration: config!,
                                                  clientId: self.appConfig.kClientID,
                                                  scopes: [
                                                    OIDScopeOpenID,
                                                    OIDScopeProfile,
                                                    OIDScopeEmail,
                                                    "offline_access"
                                                  ],
                                                  redirectURL: redirectURI!,
                                                  responseType: OIDResponseTypeCode,
                                                  additionalParameters: nil)
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            print("Initiating Authorization Request: \(request!)")
            appDelegate.currentAuthorizationFlow =
                OIDAuthState.authStateByPresentingAuthorizationRequest(request!, presentingViewController: self){
                    authorizationResponse, error in
                    if(authorizationResponse != nil) {
                        self.setAuthState(authorizationResponse)
                        self.authorizationServerConfig(appDelegate){
                            response, err in
                            self.pullAttributes()
                        }
                    } else {
                        print("Authorization Error: \(error!.localizedDescription)")
                        self.setAuthState(nil)
                    }
            }
        }
    }
    
    func pullAttributes() {
        // Call userinfo endpoint to retrieve user info
        let userinfoEndpoint = authState?.lastAuthorizationResponse
            .request.configuration.discoveryDocument?.userinfoEndpoint
        if(userinfoEndpoint  == nil ) {
            print("Userinfo endpoint not declared in discovery document")
            return
        }
        
        // send request
        var token = authState?.lastTokenResponse?.accessToken
        authState?.withFreshTokensPerformAction(){
            accessToken, idToken, error in
            if(error != nil){
                print("Error fetching fresh tokens: \(error!.localizedDescription)")
                return
            }
            // Update accessToken
            if(token != accessToken){ token = accessToken }
        }
        
        let request = NSMutableURLRequest(URL: userinfoEndpoint!)
        let authorizationHeaderValue = "Bearer \(token!)"
        request.addValue(authorizationHeaderValue, forHTTPHeaderField: "Authorization")
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        //Perform HTTP Request
        let postDataTask = session.dataTaskWithRequest(request) {
            data, response, error in
            dispatch_async( dispatch_get_main_queue() ){
                if let httpResponse = response as? NSHTTPURLResponse {
                    do{
                        let jsonDictionaryOrArray = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
                        if ( httpResponse.statusCode != 200 ){
                            let responseText = NSString(data: data!, encoding: NSUTF8StringEncoding)
                            if ( httpResponse.statusCode == 401 ){
                                let oauthError = OIDErrorUtilities.resourceServerAuthorizationErrorWithCode(0,
                                                errorResponse: jsonDictionaryOrArray as? [NSObject : AnyObject],
                                                underlyingError: error)
                                self.authState?.updateWithAuthorizationError(oauthError!)
                                print("Authorization Error (\(oauthError!)). Response: \(responseText!)")
                            }
                            else { print("HTTP: \(httpResponse.statusCode). Response: \(responseText)") }
                            return
                        }
                        print("\(jsonDictionaryOrArray)")
                        self.createUser(jsonDictionaryOrArray as! Dictionary<String, AnyObject>)

                    } catch {  print("Error while serializing data to JSON")  }
                } else {
                    print("Non-HTTP response \(error)")
                    return
                }
            }
        }
        postDataTask.resume()
    }
    
    /* Create local user based on OIDC idToken */
    func createUser(jsonDictionaryOrArray : Dictionary<String,AnyObject>) {
        
        let newUser = AcmeUser (
            firstName: "\(jsonDictionaryOrArray["given_name"]!)",
            lastName: "\(jsonDictionaryOrArray["family_name"]!)" ,
            email : "\(jsonDictionaryOrArray["email"]!)",
            provider: "Healthcare Cross",
            picture : (jsonDictionaryOrArray["picture"] != nil ? "\(jsonDictionaryOrArray["picture"]!)" : "https://randomuser.me/api/portraits/thumb/men/1.jpg"),
            id : "\(jsonDictionaryOrArray["sub"]!)"
        )
        
        /* Load appointments from auth server */
        let accessToken = authServerState?.lastTokenResponse?.accessToken
        loadAppointments(accessToken!, id: newUser.id) {
            response, err in
            appointmentData = response!
        }
        
        /* Load physicians from auth server */
        loadPhysicians(accessToken!) {
            response, err in
            physicians = response!
            // Segue after load
            let home = self.storyboard?.instantiateViewControllerWithIdentifier("MainController")
            self.presentViewController(home!, animated: false, completion: nil)
        }
        
        user = newUser
        print(user.getDetails())
    }
}