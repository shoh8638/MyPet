//
//  Utils.swift
//  MyPet
//
//  Created by shoh on 2023/03/13.
//

import UIKit
import AuthenticationServices
import FirebaseFirestore

class Utils: NSObject {
    let db = Firestore.firestore()
    
    func saveToUserDefaults(value: Any, key: String) {
        let userDefault = UserDefaults.standard
        userDefault.set(value, forKey: key)
    }
    
    func removeFromUserDefaults(key: String) {
        let userDefault = UserDefaults.standard
        userDefault.removeObject(forKey: key)
    }
    
    func loadFromUserDefaults(key: String) -> Any {
        let userDefault = UserDefaults.standard
        return userDefault.object(forKey: key) as Any
    }
    
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if length == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }        
        return result
    }
    
    func aa(nonce: String, appleIDCredential: ASAuthorizationAppleIDCredential) {
        
    }
    
    func saveToDB(appleIDCredential: ASAuthorizationAppleIDCredential) {
        let  userIdentifier = appleIDCredential.user
        guard let fullName = appleIDCredential.fullName else { return }
        guard let email = appleIDCredential.email else { return }
        let userName = "\(fullName.familyName!)\(fullName.givenName!)"
        Utils().saveToUserDefaults(value: email, key: "email")
        Utils().saveToUserDefaults(value: userIdentifier, key: "userIdentifier")
        Utils().saveToUserDefaults(value: userName, key: "userName")
        
        let data: [String: Any] = [
            "userIdentifier": userIdentifier,
            "userName": userName,
            "email": email
        ]
        //데이터베이스 쓰기
        self.db.collection(userIdentifier).document("BasicInfo").setData(data){ error in
            if let err = error {
                print("DB create Error: \(err)")
            } else {
                print("Document added")
            }
        }
        //데이터베이스 읽기
        self.db.collection(userIdentifier).document("user1").getDocument { document, error in
            if let err = error {
                print("DB create Error: \(err)")
            } else {
                if let document = document {
                    let data = document.data()
                    if(data == nil) {
                        
                    } else {
                        
                    }
                }
            }
        }
    }
}
