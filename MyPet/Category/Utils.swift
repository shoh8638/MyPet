//
//  Utils.swift
//  MyPet
//
//  Created by shoh on 2023/03/13.
//
/*
 saveToUserDefaults List
 -> 전면 수정 -> 하단 값은 firebase에서 받아오는걸로 변경
 -> 설정에 관련된 정보만 저장 하는 방식으로 변경하자
 1. userID = userIdentifier -> 필요
 2. isFirst = 최초 로그인 여부 체크
 3. email = 로그인Email
 4. userName = 로그인userName
 */

/*
 document name
 1. BasicInfo -> isFirst 및 로그인 회원 정보 저장
 */
import UIKit
import AuthenticationServices
import FirebaseAuth
import FirebaseFirestore
import ProgressHUD

class Utils: NSObject {
    let db = Firestore.firestore()
    
    func stringFromDate(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
    
    func nextMainFullVC(name: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: name)
        viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        viewController.modalPresentationStyle = .fullScreen
        return viewController
    }
    
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
    
    func introVCDidFinish(result: String, vc: UIViewController) {
        if result == "true" {
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "HomeSecondVC")
                viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                viewController.modalPresentationStyle = .fullScreen
                vc.present(viewController, animated: true)
            }
        } else if result == "false" {
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "GalleryInitVC") as! GalleryInitVC
                viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                viewController.modalPresentationStyle = .fullScreen
                vc.present(viewController, animated: true)
            }
        } else if result == "Not" {
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "InitVC")
                viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                viewController.modalPresentationStyle = .fullScreen
                vc.present(viewController, animated: true)
            }
        }
    }
}
