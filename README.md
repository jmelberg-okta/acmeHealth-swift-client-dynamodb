# AcmeHealth : iOS Native Application with AppAuth
Sample application for communicating with OAuth 2.0 and OpenID Connect providers. Demonstrates single-sign-on (SSO) with [AppAuth for iOS](https://github.com/openid/AppAuth-iOS) implemented in Swift.

## Running the Sample with your Okta Organization

###Pre-requisites
This sample application was tested with an Okta org. If you do not have an Okta org, you can easily [sign up for a free Developer Okta org](https://www.okta.com/developer/signup/).

1. Verify OpenID Connect is enabled for your Okta organization. `Admin -> Applications -> Add Application -> Create New App -> OpenID Connect`
  - If you do not see this option, email [developers@okta.com](mailto:developers@okta.com) to enable it.
2. In the **Create A New Application Integration** screen, click the **Platform** dropdown and select **Native app only**
3. Press **Create**. When the page appears, enter an **Application Name**. Press **Next**.
4. Add `com.acmeHealth://oauth` to your list of approved *Redirect URIs*.
5. Click **Finish** to redirect back to the *General Settings* of your application.
6. Select the **Edit** button in the *General Settings* section to configure the **Allowed Grant Types**
  - Ensure *Authorization Code* and *Refresh Token* are selected in **Allowed Grant Types**
  - **Save** the application
7. In the *Client Credentials* section verify *Proof Key for Code Exchange (PKCE)* is the default **Client Authentication**
8. Copy the **Client ID**, as it will be needed for the `OktaConfiguration.swift` configuration file.
9. Finally, select the **People** tab and **Assign to People** in your organization.

###Configure the Authorization Server
This project uses REST Service Authorization with JWTs to **cancel**, **confirm**, **create**, **edit**, and **retrieve** appointments. To enable this feature, contact [developers@okta.com](mailto:developers@okta.com).

1. In the navigation bar, select **Security**, then **API**.
2. Under the **Authorization Servers** tab, select **Add Authorization Server**.
  - *Name* : AcmeHealth Resource Domain
  - *Resource URI* : http://localhost:8080
  - *Description* : AcmeHealth Server
  - **Save**
3. Select the **Scopes** tab and click **Add Scope**. This project requires the following:
  - providers:read
  - appointments:read
  - appointments:write
  - appointments:cancel
  - appointments:confirm
  - appointments:edit
  - Add this name to the *name* field in the **Add Scope** window
4. Select the **Access Policies** tab, followed by **Add New Access Policy**.
  - *Name* : AcmeHealth Access Policy
  - *Assign To* : All Users
  - Click **Create Policy**
5. Finally, we will add three rules by selecting **Add Rule**
  - *Rule Name* : Patient Rule
  - *If* : User is a member of one of the following:
    - *Groups* : Patients
  - *Then scopes are* : appointments:read, appointments:write, providers:read, appointments:cancel
  - Repeat for rules **Provider Rule** and **Provider-read-only** and specify the *groups* and *scopes* accordingly.
6. Copy the **Issuer** under **Settings** - this will be used in `OktaConfiguration.swift`
7. Follow the [AcmeHealth Server instructions](https://github.com/jmelberg/acmehealth-server/blob/master/README.md)

### Configure the Sample Application
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
