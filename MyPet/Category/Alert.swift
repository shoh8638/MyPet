//
//  Alert.swift
//  MyPet
//
//  Created by shoh on 2023/03/15.
//

import UIKit

class Alert: NSObject {
    func basicOKAlert(message: String, vc: UIViewController) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .cancel))
        vc.present(alert, animated: true)
    }
    
    func exitOKAlert(vc: UIViewController) {
        let alert = UIAlertController(title: "알림", message: "비정상적 로그인입니다.", preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .cancel) {_ in
            exit(0)
        }
        alert.addAction(action)
        vc.present(alert, animated: true)
    }
}