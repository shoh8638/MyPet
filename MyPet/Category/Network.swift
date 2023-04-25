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
    func isFirstTrueOrFalseDB(completion: @escaping (String) -> ()) {
        let userId = Utils().loadFromUserDefaults(key: "userId") as! String
        self.db.collection(userId).document("BasicInfo").getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                if let isFirst = data?["isFirst"] as? Bool {
                    if isFirst == true {
                        completion("true")
                    } else {
                        completion("false")
                    }
                }
            }
        }
    }
    func introVCCheckAuth(completion: @escaping (String) -> ()) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        guard let userId = Utils().loadFromUserDefaults(key: "userId") as? String else {
            return completion("Not")
        }
        appleIDProvider.getCredentialState(forUserID:userId) { (credentialState, error) in
            switch credentialState {
            case .authorized:
                completion("true")
            case .revoked, .notFound:
                completion("Not")
            default:
                break
            }
        }
    }
    
    func initSaveToDB(appleIDCredential: ASAuthorizationAppleIDCredential, vc: UIViewController) {
        let  userIdentifier = appleIDCredential.user
        if appleIDCredential.email == nil {
            Utils().saveToUserDefaults(value: userIdentifier, key: "userId")
            //BasicInfo -> isFirst값에 따라 나타나는 View 변경
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "HomeSecondVC")
            viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            viewController.modalPresentationStyle = .fullScreen
            vc.present(viewController, animated: true)
        } else {
            guard let fullName = appleIDCredential.fullName else { return }
            guard let email = appleIDCredential.email else { return }
            let userName = "\(fullName.familyName!)\(fullName.givenName!)"
            Utils().saveToUserDefaults(value: userIdentifier, key: "userId")
            self.db.collection(userIdentifier).document("BasicInfo").setData([
                "userIdentifier": userIdentifier,
                "userName": userName,
                "email": email,
                "isFirst": false
            ]){ error in
                if let err = error {
                    print("DB create Error: \(err)")
                } else {
                    print("Document added")
                    self.createInitData(vc: vc) {
                        //GalleryDB 및 초기 설정 진행
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = storyboard.instantiateViewController(withIdentifier: "GalleryInitVC") as! GalleryInitVC
                        viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                        viewController.modalPresentationStyle = .fullScreen
                        vc.present(viewController, animated: true)
                    }
                }
            }
        }
    }
    
    func createInitData(vc: UIViewController, completion: @escaping () -> ()) {
        //최초 FoodInfo db 생성
        //저장되는건 document안에 document
        let userId = Utils().loadFromUserDefaults(key: "userId") as! String
        self.db.collection(userId).document("FoodInfoDB").setData([:]){ error in
            if let err = error {
                print("FoodInfoDB create Error: \(err)")
            } else {
                print("FoodInfoDB create")
            }
        }
        //최초 Category db 생성
        //category를 고르면, 카테고리안에 userId.docuemnt("CategoryInfoDB").docuemnt(category).document(date)로 저장
        self.db.collection(userId).document("CategoryInfoDB").setData([:]){ error in
            if let err = error {
                print("DB create Error: \(err)")
            } else {
                self.db.collection(userId).document("CategoryInfoDB").collection("Food").document().setData([:]) { error in
                    if let err = error {
                        print("CategoryInfoDB- Food create Error: \(err)")
                    } else {
                        print("CategoryInfoDB- Food create")
                    }
                }
                self.db.collection(userId).document("CategoryInfoDB").collection("Trip").document().setData([:]) { error in
                    if let err = error {
                        print("CategoryInfoDB- Trip create Error: \(err)")
                    } else {
                        print("CategoryInfoDB- Trip create")
                    }
                }
                self.db.collection(userId).document("CategoryInfoDB").collection("Daily").document().setData([:]) { error in
                    if let err = error {
                        print("CategoryInfoDB- Daily create Error: \(err)")
                    } else {
                        print("CategoryInfoDB- Daily create")
                        completion()
                    }
                }
            }
        }
    }
    
    func loadDocumentData(vc: UIViewController, completion: @escaping (QuerySnapshot?) -> ()) {
        let userId = Utils().loadFromUserDefaults(key: "userId") as! String
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
    
    func createGalleryDB(vc: UIViewController, name: String, gender: String, date: String, info: [UIImagePickerController.InfoKey : Any], completion: @escaping () -> ()) {
        let userId = Utils().loadFromUserDefaults(key: "userId") as! String
        let userRef = storage.reference().child(userId)
        guard let imageURL = info[.imageURL] as? URL else { return }
        let imageName = imageURL.lastPathComponent
        let pathRef = userRef.child("Gallery").child(imageName)
        guard let imageData = try? Data(contentsOf: imageURL) else { return }
        
        pathRef.putData(imageData) {  (metadata, error) in
            guard error == nil else { return }
            pathRef.downloadURL { (url, error) in
                if let error = error {
                    print("Error uploading image to Firebase Storage: \(error.localizedDescription)")
                } else {
                    guard let url = url else { return }
                    let urlString = url.absoluteString
                    self.db.collection(userId).document("GalleryDB").collection(date).document().setData([
                        "name": name,
                        "gender": gender,
                        "date": date,
                        "downLoadUrls": [urlString]]) { error in
                            if let err = error {
                                print("CategoryInfoDB- Daily create Error: \(err)")
                            } else {
                                print("CategoryInfoDB- Daily create")
                                completion()
                            }
                        }
                }
            }
        }
    }
    
    func loadIsMain(vc: UIViewController, completion: @escaping () -> ()) {
        let userId = Utils().loadFromUserDefaults(key: "userId") as! String
        self.db.collection(userId).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    if document.documentID == "GalleryDB" {
                        
                    } else if document.documentID == "FoodInfoDB" {
                        
                    }
                }
            }
        }
    }
    
    func uploadImage(filePath: String, info: [UIImagePickerController.InfoKey : Any], completion: @escaping (URL) -> ()) {
        let userId = Utils().loadFromUserDefaults(key: "userId") as? String ?? ""
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
        let userId = Utils().loadFromUserDefaults(key: "userId") as? String ?? ""
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
