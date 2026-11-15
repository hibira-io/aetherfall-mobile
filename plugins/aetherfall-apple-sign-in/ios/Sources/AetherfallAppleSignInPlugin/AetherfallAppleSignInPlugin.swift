import AuthenticationServices
import Capacitor
import Foundation

/// Sign in with Apple in the system sheet (App Store guideline 4.8).
///
/// The game client (pixel-realm, net/appleSignIn.ts) calls
/// `AetherfallAppleSignIn.authorize({ nonce })` with the SHA-256 of a random
/// string it keeps. This plugin asks Apple for the name and email scopes and
/// hands back the one-time authorization code (and the name, which Apple only
/// gives on the first authorization). The game server redeems the code with
/// Apple using the app's bundle ID and its Sign in with Apple key, and checks
/// the nonce, so nothing here is trusted on its own.
@objc(AetherfallAppleSignInPlugin)
public class AetherfallAppleSignInPlugin: CAPPlugin, CAPBridgedPlugin, ASAuthorizationControllerDelegate,
    ASAuthorizationControllerPresentationContextProviding {
    public let identifier = "AetherfallAppleSignInPlugin"
    public let jsName = "AetherfallAppleSignIn"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "authorize", returnType: CAPPluginReturnPromise)
    ]
    private var pending: CAPPluginCall?
    private var controller: ASAuthorizationController?

    /// { nonce } → { authorizationCode, givenName?, familyName? }; rejects "cancelled" when closed.
    @objc func authorize(_ call: CAPPluginCall) {
        guard let nonce = call.getString("nonce"), !nonce.isEmpty, nonce.count <= 256 else {
            call.reject("bad_request")
            return
        }
        DispatchQueue.main.async {
            if self.pending != nil {
                call.reject("busy")
                return
            }
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = nonce
            let c = ASAuthorizationController(authorizationRequests: [request])
            c.delegate = self
            c.presentationContextProvider = self
            self.pending = call
            self.controller = c
            c.performRequests()
        }
    }

    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return bridge?.webView?.window ?? ASPresentationAnchor()
    }

    public func authorizationController(controller: ASAuthorizationController,
                                        didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let call = finish() else { return }
        guard let cred = authorization.credential as? ASAuthorizationAppleIDCredential,
              let data = cred.authorizationCode, let code = String(data: data, encoding: .utf8) else {
            call.reject("failed")
            return
        }
        var out: [String: Any] = ["authorizationCode": code]
        if let g = cred.fullName?.givenName { out["givenName"] = g }
        if let f = cred.fullName?.familyName { out["familyName"] = f }
        call.resolve(out)
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        guard let call = finish() else { return }
        if let e = error as? ASAuthorizationError, e.code == .canceled {
            call.reject("cancelled", "cancelled")
        } else {
            call.reject("failed")
        }
    }

    private func finish() -> CAPPluginCall? {
        let call = pending
        pending = nil
        controller = nil
        return call
    }
}
