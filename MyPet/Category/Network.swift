//
//  Network.swift
//  MyPet
//
//  Created by shoh on 2023/03/15.
//

import UIKit
import AuthenticationServices
import FirebaseAuth
import FirebaseFirestore
import ProgressHUD
import FirebaseStorage

class Network: NSObject {
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    func checkLoginInfo(appleIDCredential: ASAuthorizationAppleIDCredential, authCrendetial:  OAuthCredential, completion: @escaping (Bool) -> ()) {
        Auth.auth().signIn(with: authCrendetial) { (result, error) in
            if let err = error {
                print("appleIDCredential Error: \(err)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func introVCCheckAuth(completion: @escaping (Bool) -> ()) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID:"001304.74940427db3540a290e6ecf38315f167.0444") { (credentialState, error) in
            switch credentialState {
            case .authorized:
                completion(true)
            case .revoked, .notFound:
                completion(false)
            default:
                break
            }
        }
    }
    
    func initSaveToDB(appleIDCredential: ASAuthorizationAppleIDCredential, vc: UIViewController) {
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
                self.createHomeData(vc: vc) {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "HomeVC")
                    viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                    viewController.modalPresentationStyle = .fullScreen
                    vc.present(viewController, animated: true)
                }
            }
        }
        /*
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
         */
    }
    
    func createHomeData(vc: UIViewController, completion: @escaping () -> ()) {
        let userId = Utils().loadFromUserDefaults(key: "userIdentifier") as? String ?? ""
        if userId != "" {
            //최초 ImgInfo db 생성
            self.db.collection(userId).document("ImgInfo").setData([
                "imgName": [String: Any](),
                "imgSaveTime": [String: Any](),
                "key": [String]()
            ]) { error in
                    if let err = error {
                        print("DB create Error: \(err)")
                    } else {
                        Utils().saveToUserDefaults(value: "save", key: "ImgInfo")
                    }
                }
            //최초 FoodInfo db 생성
            self.db.collection(userId).document("FoodInfo").setData([
                "foodName": [String: Any](),
                "foodUntil": [String: Any](),
                "foodDescription": [String: Any](),
                "key": [String]()
            ]){ error in
                if let err = error {
                    print("DB create Error: \(err)")
                } else {
                    Utils().saveToUserDefaults(value: "save", key: "FoodInfo")
                }
            }
            
            //최초 ListInfo db 생성
            self.db.collection(userId).document("ListInfo").setData([
                "listTitle": [String: Any](),
                "listUntil": [String: Any](),
                "listImg": [String: Any](),
                "listText": [String: Any](),
                "key": [String]()
            ]){ error in
                if let err = error {
                    print("DB create Error: \(err)")
                } else {
                    Utils().saveToUserDefaults(value: "save", key: "ListInfo")
                }
                completion()
            }
        } else {
            Alert().exitOKAlert(vc: vc)
        }
    }
    
    func loadDocumentData(vc: UIViewController, completion: @escaping (QuerySnapshot?) -> ()) {
        let userId = Utils().loadFromUserDefaults(key: "userIdentifier") as? String ?? ""
        if userId != ""{
            self.db.collection(userId).getDocuments { (querySnapshot, error) in
                if let error = error {
                        print("Error getting documents: \(error)")
                    } else {
                        for document in querySnapshot!.documents {
                            print("\(document.documentID) => \(document.data())")
                        }
                        completion(querySnapshot)
                    }
            }
        }
    }
    
    func uploadImage(filePath: String, info: [UIImagePickerController.InfoKey : Any], completion: @escaping (URL) -> ()) {
        let userId = Utils().loadFromUserDefaults(key: "userIdentifier") as? String ?? ""
        let userRef = storage.reference().child(userId)
        guard let imageURL = info[.imageURL] as? URL else { return }
        let imageName = imageURL.lastPathComponent
        let pathRef = userRef.child(filePath).child(imageName)
        guard let imageData = try? Data(contentsOf: imageURL) else { return }
        
        pathRef.putData(imageData) {  (metadata, error) in
            guard error == nil else { return }
            pathRef.downloadURL { (url, error) in
                guard let url = url else { return }
                completion(url)
            }
        }
    }
    
    func downloadURL(pathName: String, completion: @escaping ([String]) -> ()) {
        let userId = Utils().loadFromUserDefaults(key: "userIdentifier") as? String ?? ""
        let pathRef = storage.reference().child("\(userId)/\(pathName)")
        var urlArr = [String]()
        pathRef.listAll { (result, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            for item in result!.items {
                item.downloadURL { (url, error) in
                    if let err = error {
                        print("Error: \(err.localizedDescription)")
                    }
                    if let url = url {
                        let urlString = url.absoluteString
                        urlArr.append(urlString)
                    }
                    if result!.items.count == urlArr.count {
                        completion(urlArr)
                    }
                }
            }
        }
    }
    
    func downloanImages(pathName: String, completion: @escaping ([UIImage]) -> ()) {
        self.downloadURL(pathName: pathName) { urlArr in
            print("DownloadImagesURLArr: \(urlArr)")
        }
    }
    /*
     딕셔너리값안에 특정 데이터 불러오는 방법
     let db = Firestore.firestore()
     let collectionRef = db.collection("my   Collection")
     let docRef = collectionRef.document("doc1")

     docRef.getDocument { (documentSnapshot, error) in
         if let error = error {
             print("Error getting document: \(error)")
         } else if let documentSnapshot = documentSnapshot, documentSnapshot.exists {
             let userInfo = documentSnapshot.data()?["userInfo"] as? [String: Any] ?? [:]
             let name = userInfo["name"] as? String ?? ""
             // name 필드 데이터 출력
             print("Name: \(name)")
         } else {
             print("Document does not exist")
         }
     }
     */
}
