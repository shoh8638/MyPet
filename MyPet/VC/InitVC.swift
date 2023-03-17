//
//  InitVC.swift
//  MyPet
//
//  Created by 오승훈 on 2023/03/11.
//

import UIKit
import AuthenticationServices
import FirebaseAuth

class InitVC: UIViewController, ASAuthorizationControllerDelegate {

    @IBOutlet weak var appleLogin: UIView!
    
    var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure()
    }
    
    private func configure() {
        let appleButton = ASAuthorizationAppleIDButton()
        appleButton.addTarget(self, action: #selector(appleIDButtonPress), for: .touchUpInside)
        self.appleLogin.addSubview(appleButton)
        
        appleButton.translatesAutoresizingMaskIntoConstraints = false
        appleButton.leadingAnchor.constraint(equalTo: self.appleLogin.leadingAnchor).isActive = true
        appleButton.trailingAnchor.constraint(equalTo: self.appleLogin.trailingAnchor).isActive = true
        appleButton.topAnchor.constraint(equalTo: self.appleLogin.topAnchor).isActive = true
        appleButton.bottomAnchor.constraint(equalTo: self.appleLogin.bottomAnchor).isActive = true
    }
    
    @objc private func appleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let nonce = Utils().randomNonceString()
        self.currentNonce = nonce
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension InitVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("authoriztion Error: \(error)")
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        print("Success")
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        
        guard let nonce = self.currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }
        guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to fetch identity token")
            return
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            return
        }
        
        let authCrendetial = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
        
        Network().checkLoginInfo(appleIDCredential: appleIDCredential, authCrendetial: authCrendetial) { result in
            if result {
                Network().initSaveToDB(appleIDCredential: appleIDCredential, vc: self)
            } else {

            }
        }
    }
}
