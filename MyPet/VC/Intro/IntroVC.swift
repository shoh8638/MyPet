//
//  IntroVC.swift
//  MyPet
//
//  Created by 오승훈 on 2023/03/11.
//

import UIKit
import ProgressHUD

class IntroVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //configure전에 업버전 체크 로직 추가
        self.configure()
    }
    override func viewWillDisappear(_ animated: Bool) {
        ProgressHUD.remove()
    }
    private func configure() {
        //network관련 정보 확인
        ProgressHUD.show("로딩중...")
        Network().introVCCheckAuth { result in
            if result == "true" || result == "fasle" {
                ProgressHUD.remove()
                Network().isFirstTrueOrFalseDB { result in
                    Utils().introVCDidFinish(result: result, vc: self)
                }
            } else if result == "Not" {
                ProgressHUD.remove()
                Utils().introVCDidFinish(result: result, vc: self)
            }
        }
    }
}
