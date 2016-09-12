//
//  AppAuthExtension.swift
//  OpenIDConnectSwift
//
//  Created by Jordan Melberg on 9/7/16.
//  Copyright © 2016 Jordan Melberg. All rights reserved.
//

import Foundation
import AppAuth
import Alamofire

class AppAuthExtension: NSObject, OIDAuthStateChangeDelegate {
    
    // AppAuth authState
    var authState:OIDAuthState?
    var authServerState: OIDAuthState?
    
    /**  Saves the current authState into NSUserDefaults  */
    func saveState() {
        if(authState == nil && authServerState == nil){
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: config.appAuthExampleAuthStateKey)
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: config.appAuthExampleAuthStateServerKey)
        }
        if(authState != nil){
            let archivedAuthState = NSKeyedArchiver.archivedDataWithRootObject(authState!)
            NSUserDefaults.standardUserDefaults().setObject(archivedAuthState, forKey: config.appAuthExampleAuthStateKey)
        }
        if (authServerState != nil) {
            let archivedAuthServerState = NSKeyedArchiver.archivedDataWithRootObject(authServerState!)
            NSUserDefaults.standardUserDefaults().setObject(archivedAuthServerState, forKey: config.appAuthExampleAuthStateServerKey)
        }
        
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    /**  Loads the current authState from NSUserDefaults */
    func loadState() -> Bool? {
        if let archivedAuthState = NSUserDefaults.standardUserDefaults().objectForKey(config.appAuthExampleAuthStateKey) as? NSData {
            if let archivedAuthServerState = NSUserDefaults.standardUserDefaults().objectForKey(config.appAuthExampleAuthStateServerKey) as? NSData {
                if let authState = NSKeyedUnarchiver.unarchiveObjectWithData(archivedAuthState) as? OIDAuthState {
                    if let authServerState = NSKeyedUnarchiver.unarchiveObjectWithData(archivedAuthServerState) as? OIDAuthState {
                        setAuthServerState(authServerState)
                        return true
                    }
                    setAuthState(authState)
                }
            }
        }
        return false
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
        if (authState != nil) { return true  }
        else { return false }
    }
    
    func authenticate(controller: UIViewController, completionHandler: (Bool?, NSError?) -> ()){
        let issuer = NSURL(string: config.issuer)
        let redirectURI = NSURL(string: config.redirectURI)
        
        // Discovers Endpoints
        OIDAuthorizationService.discoverServiceConfigurationForIssuer(issuer!) {
            serviceConfig, error in
            
            if ((serviceConfig == nil)) {
                print("Error retrieving discovery document: \(error?.localizedDescription)")
                return
            }
            print("Retrieved configuration: \(serviceConfig!)")
            
            // Build Authentication Request for idToken
            let request = OIDAuthorizationRequest(configuration: serviceConfig!,
                                                  clientId: config.clientID,
                                                  scopes: config.idTokenScopes,
                                                  redirectURL: redirectURI!,
                                                  responseType: OIDResponseTypeCode,
                                                  additionalParameters: nil)
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            print("Initiating Okta Authorization Request: \(request!)")
            appDelegate.currentAuthorizationFlow =
                OIDAuthState.authStateByPresentingAuthorizationRequest(request!, presentingViewController: controller){
                    authorizationResponse, error in
                    if(authorizationResponse != nil) {
                        self.setAuthState(authorizationResponse)
                        completionHandler(true, nil)
                    } else {
                        print("Authorization Error: \(error!.localizedDescription)")
                        self.setAuthState(nil)
                    }
            }
        }
    }
    
    func authorizationServerConfig(controller: UIViewController, completionHandler: (Bool?, NSError?) -> ()) {
        
        // Manually configure Authorization Server Call
        
        let authorizationEndpoint = config.authorizationServerEndpoint
        let tokenEndpoint = config.authorizationTokenEndpoint
        
        let authServerConfig = OIDServiceConfiguration.init(authorizationEndpoint: authorizationEndpoint, tokenEndpoint: tokenEndpoint)
        
        // Build Authentication Request for accessToken
        let request = OIDAuthorizationRequest(configuration: authServerConfig!,
                                              clientId: config.clientID,
                                              scopes: config.authorizationServerScopes,
                                              redirectURL: NSURL(string: config.redirectURI)!,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: nil)
        print("Initiating Authorization Server Request: \(request!)")
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.currentAuthorizationFlow =
            OIDAuthState.authStateByPresentingAuthorizationRequest(request!, presentingViewController: controller){
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
    
    /* Calls userInfo endpoint and returns JSON reponse */
    func pullAttributes(completionHandler: (NSDictionary?, NSError?) ->()){
        // Call userinfo endpoint to retrieve user info
        let userinfoEndpoint = authState?.lastAuthorizationResponse
            .request.configuration.discoveryDocument?.userinfoEndpoint
        if(userinfoEndpoint  == nil ) {
            print("Userinfo endpoint not declared in discovery document")
            return
        }

        // Update OIDC accessToken
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
        
        /* Given accessToken  -> returns all providers */
        func callUserInfoEndpoint(token: String, url: String, completionHandler: (NSDictionary?, NSError?) -> ()){
            let headers = ["Authorization" : "Bearer \(token)",
                           "Accept" :  "application/json"]
            Alamofire.request(.POST, url, headers : headers)
                .validate()
                .responseJSON { response in
                    if let JSON = response.result.value {
                        completionHandler(JSON as? NSDictionary , nil)
                    }
            }
        }
        
        callUserInfoEndpoint(token!, url: userinfoEndpoint!.absoluteString) {
            response, err in
            completionHandler(response!, nil)
        }
    }
}