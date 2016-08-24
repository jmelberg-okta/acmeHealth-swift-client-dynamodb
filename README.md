# acmehealth-swift
**Note: *Edit Profile* is for show only**
## Build Instructions
Once the project is cloned, install the required dependencies with [CocoaPods](https://guides.cocoapods.org/using/getting-started.html) by running the following from the project root.

    pod install
    

**Important:** Open `OpenIDConnectSwift.xcworkspace`. This file should be used to run/test your application.

Update the `Models.swift` `OktaConfiguration` object:
```swift
class OktaConfiguration {
    let kIssuer: String!
    let kClientID: String!
    let kRedirectURI: String!
    let kAppAuthExampleAuthStateKey: String!
    let kAppAuthExampleAuthStateServerKey: String!
    let kAuthorizationServerEndpoint: NSURL!
    let kAuthorizationTokenEndpoint: NSURL!
    
    init(){
        kIssuer = "https://example.oktapreview.com"                           // Base url of Okta Developer domain
        kClientID = "Jw1nyzbsNihSuOETY3R1"                                    // Client ID of Application
        kRedirectURI = "com.oktapreview.example:/oauth"                       // Reverse DNS notation of base url with oauth route
        kAppAuthExampleAuthStateKey = "com.okta.oauth.authState"              // Key for NSUserDefaults Auth Object
        kAppAuthExampleAuthStateServerKey = "com.okta.oauth.authServerState"  // Key for NSUserDefaults Auth Server Object
        kAuthorizationServerEndpoint = NSURL(string:"https://example.oktapreview.com/oauth2/aus7xbiefo72YS2QW0h7/v1/authorize")
        kAuthorizationTokenEndpoint = NSURL(string: "https://example.oktapreview.com/oauth2/aus7xbiefo72YS2QW0h7/v1/token")
    }
}
...

var API_URL = "https://example.ngrok.io" // Tunnel HTTP to HTTPS

```

Modify the `Info.plist` file by including a custom URI scheme **without** the route
  - `URL types -> Item 0 -> URL Schemes -> Item 0 ->  <kRedirectURI>` (*Ex: com.oktapreview.example*)
