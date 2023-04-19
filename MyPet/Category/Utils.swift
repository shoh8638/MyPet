//
//  Utils.swift
//  MyPet
//
//  Created by shoh on 2023/03/13.
//

import UIKit
import AuthenticationServices
import FirebaseAuth
import FirebaseFirestore
import ProgressHUD

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
    
    func introVCDidFinish(result: Bool, vc: UIViewController) {
        if result {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "HomeSecondVC") as! HomeSecondVC
            viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            viewController.modalPresentationStyle = .fullScreen
            vc.present(viewController, animated: true)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "InitVC")
            viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            viewController.modalPresentationStyle = .fullScreen
            vc.present(viewController, animated: true)
        }
    }
}
