# acmehealth-swift
**Note: *Edit Profile* is for show only**
## Build Instructions
Once the project is cloned, install the required dependencies with [CocoaPods](https://guides.cocoapods.org/using/getting-started.html) by running the following from the project root.

    pod install
    

**Important:** Open `AcmeHealth.xcworkspace`. This file should be used to run/test your application.

Update the `OktaConfiguration.swift` `OktaConfiguration` object:
```swift
class OktaConfiguration {
    let issuer: String!                             // Base url of Okta Developer domain
    let clientID: String!                           // Client ID of Application
    let redirectURI: String!                        // Reverse DNS notation of base url with oauth route
    let authorizationServerURL: String!             // API URI for token authentication
    let authIssuer: String!                         // Authorization Issuer URI
    let idTokenScopes : [String]!
    let authorizationServerScopes: [String]!
    
    
    init(){
        issuer = "https://example.oktapreview.com"
        clientID = "Jw1nyzbsNihSuOETY3R1"
        redirectURI = "com.acmehealth://oauth"
        authorizationServerURL = "http://localhost:8088"
        authIssuer = "https://example.oktapreview.com/oauth2/aus7xbiefo72YS2QW0h7"
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


```
