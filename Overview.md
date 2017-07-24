# Overview
IBM Cloud Video allows third-party clients to access IBM Cloud Video users' resources (data) via a HTTP-based (RESTful) API. It also provides a Broadcaster Library that is capable of broadcasting to a user's channel. Both the REST API and the Broadcaster Library uses the OAuth 2.0 protocol for authentication and authorization.

## Basic workflow
The basic workflow of a third-party Client is the following:

1. **Authorize the user:** Obtain and validate the user's credentials (username and password). The client must never store these credentials, only pass it to the server for authorization.
2. **Obtain an access token:** If the user's credentials were entered correctly, the third-party client can obtain an access token. Once this token is received, it can be used to access the user's resources until the token expires or the user revokes it on the IBM Cloud Video website.
3. **Access the user's resources:** The client can use Ustream's REST API or the IBM Cloud Video Broadcasting Library to access the user's resources (data) or to broadcast to the user's channel. The client authorizes itself using the access token, with methods described by the OAuth 2.0 Protocol Draft.

### Authorization Flows
The OAuth 2.0 protocol provides several flows (workflows) for the first two phases. It depends on the type and architecture of the client which flow is the most suitable. The following flows are supported:

* **Implicit flow:** Suitable for standalone, native clients (desktop / mobile). The user enters its credentials to a secure login webpage. After logging in, the browser is redirected to a special URL (defined by the client), passing the access token in the URL.
* **Authorization code flow:** Suitable for third-party websites which contain a client and a server component. The user enters its credentials to a secure login webpage. After logging in, the browser is redirected to a special URL (defined by the client), passing an authorization code in the URL. The third-party server obtains the access token with another HTTP request in the background, using the authorization code. This method is more secure than the implicit flow if the third-party client has a client+server model. See the OAuth2 Draft for details.

### Endpoints
The webpages and HTTP services invoked in during this authorization process are called Endpoints. IBM Cloud Video has the following endpoints:

* **Authorization endpoint:** this is the webpage where the user enters his/her credentials.
* **Token endpoint:** this is the HTTP service where the access token can be obtained in an authorization code flow (when using the implicit flow, the access token can be obtained directly from the authorization endpoint).

### Access tokens
There are two types of access tokens: **Bearer tokens** and **MAC tokens.** They are equivalent in the sense that they can access the same resources on the IBM Cloud Video REST API. The difference is that while bearer tokens can be only used on encrypted channels (HTTPS), MAC tokens are suitable on non-encrypted channels as well.

If the client uses the IBM Cloud Video Broadcasting Library, it must use MAC tokens: the broadcasting is done on the RTMP protocol, which is unencrypted. If the client only uses the REST API, the bearer tokens are preferred because their usage is very simple and lightweight.

Bearer tokens and MAC tokens can be obtained in the same way: the authorization endpoint has a token type parameter, so the client can specify what kind of token it wants to create.

### Token scopes, expiration
By default, access tokens have a limited lifetime (they expire in a day) and can access only a limited amount of resources. In the authorization process the client can request extra permissions (scopes) from the user to overcome these limitations. These requests are shown to the user on the authorization endpoint. IBM Cloud Video currently supports the following scopes:

* **Offline scope:** If this scope is enabled, the access token never expires.
* **Broadcaster scope:** If this Scope is enabled, the access token can be used for broadcasting with the IBM Cloud Video Broadcasting Library. This scope are enabled only for MAC tokens.
 