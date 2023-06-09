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
import SDWebImage

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
    
    func isFirstCheck(completion: @escaping (String) -> ()) {
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
    
    func introCheckAuth(completion: @escaping (String) -> ()) {
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
            vc.present(Utils().nextMainFullVC(name: "HomeSecondVC"), animated: true)
        } else {
            Utils().saveToUserDefaults(value: userIdentifier, key: "userId")
            guard let fullName = appleIDCredential.fullName else { return }
            guard let email = appleIDCredential.email else { return }
            
            let userName = "\(fullName.familyName!)\(fullName.givenName!)"
            self.db.collection(userIdentifier).document("BasicInfo").setData([
                "userIdentifier": userIdentifier,
                "userName": userName,
                "email": email,
                "name": "",
                "gender": "",
                "date": "",
                "isFirst": false
            ]){ error in
                if let err = error {
                    print("DB create Error: \(err)")
                } else {
                    print("Document added")
                    self.createInitData {
                        vc.present(Utils().nextMainFullVC(name: "GalleryInitVC"), animated: true)
                    }
                }
            }
        }
    }
    
    func createInitData(completion: @escaping () -> ()) {
        guard let userId = Utils().loadFromUserDefaults(key: "userId") as? String else { return }
        self.db.collection(userId).document("CategoryInfoDB").setData([
            "Key": ["Daily", "Food", "Trip"]]){ error in
                if let err = error {
                    print("DB create Error: \(err)")
                } else {
                    completion()
                }
            }
    }
    /*
     카테고리 선택 시, 해당 카테고리 명으로 self.db.collection(userId).document("CategoryInfoDB").collection(카테고리명).document(카테고리명).setData([:]) <- 값 추가.
     
     타이틀+시간으로 키값으로 잡고 해당 카테고리명Key라는 이름으로 하나 생성
     self.db.collection(userId).document(카테고리명Key).setData([:]) <- 값(배열로) 추가.
     */
    func updateCategoryWriteDB(category: String, date: Date, title: String, text: String, downLoadUrls: String, completion: @escaping () -> ()) {
        guard let userId = Utils().loadFromUserDefaults(key: "userId") as? String else { return }
        self.db.collection(userId).document("CategoryInfoDB").collection(category).document(category).setData([
            "title": title,
            "text": text,
            "downLoadUrls": downLoadUrls,
            "date": date,
            "category": category]) {
            error in
            guard error == nil else { return }
            
        }
    }
    
    func loadBasicInfo(completion: @escaping ([String: Any]) -> ()) {
        guard let userId = Utils().loadFromUserDefaults(key: "userId") as? String else { return }
        self.db.collection(userId).document("BasicInfo").getDocument { (querySnapshot, error) in
            guard error == nil else { return }
            guard let data = querySnapshot?.data() as? [String: Any] else { return }
            completion(data)
        }
    }
    
    func loadDocumentData(completion: @escaping (QuerySnapshot?) -> ()) {
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
    
    func uploadGalleryDB(info: [UIImagePickerController.InfoKey: Any], completion: @escaping () -> ()) {
        let userId = Utils().loadFromUserDefaults(key: "userId") as! String
        let userRef = storage.reference().child(userId)
        guard let imageURL = info[.imageURL] as? URL else { return }
        let imageName = imageURL.lastPathComponent
        let pathRef = userRef.child("Gallery").child(imageName)
        guard let imageData = try? Data(contentsOf: imageURL) else { return }
        
        pathRef.putData(imageData) { (metadata, error) in
            guard error == nil else { return }
            pathRef.downloadURL { (url, error) in
                if let error = error {
                    print("Error uploading image to Firebase Storage: \(error.localizedDescription)")
                } else {
                    guard let url = url else { return }
                    let urlString = url.absoluteString
                    let current = Utils().stringFromDate(date: Date())
                    self.db.collection(userId).document("GalleryDB").collection(current).document(current).setData([
                        "date": current,
                        "isMain": false,
                        "downLoadUrls": urlString
                    ]) { error in
                        if let err = error {
                            print("GalleryDB create Error: \(err)")
                        } else {
                            print("GalleryDB create")
                        }
                    }
                    self.db.collection(userId).document("GalleryDBKey").getDocument { (document, error) in
                        if let document = document, document.exists {
                            var galleryKeyArray = document.get("Key") as? [String] ?? []
                            galleryKeyArray.append(current)
                            
                            self.db.collection(userId).document("GalleryDBKey").updateData(["Key": galleryKeyArray]){ error in
                                if let err = error {
                                    print("return err:\(err)")
                                } else {
                                    print("Success KeyDB")
                                    completion()
                                }
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    func createGalleryDB(name: String, gender: String, date: String, info: [UIImagePickerController.InfoKey : Any], completion: @escaping () -> ()) {
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
                    let current = Utils().stringFromDate(date: Date())
                    self.db.collection(userId).document("GalleryDB").collection(current).document(current).setData([
                        "isMain": true,
                        "downLoadUrls": urlString]) { error in
                            if let err = error {
                                print("GalleryDB create Error: \(err)")
                            } else {
                                print("GalleryDB create")
                            }
                        }
                    self.db.collection(userId).document("GalleryDBKey").setData(["Key": [current]]){ error in
                        if let err = error {
                            print("return err:\(err)")
                        } else {
                            print("Success KeyDB")
                        }
                    }
                    self.db.collection(userId).document("BasicInfo").updateData([
                        "date": date,
                        "isFirst": true,
                        "gender": gender,
                        "name": name]) { err in
                            if let err = err {
                                print("isFirst update Error: \(err)")
                            } else {
                                print("isFirst update")
                                completion()
                            }
                        }
                }
            }
        }
    }
    
    func loadIsGalleryKey(completion: @escaping ([String], [String: Any]) -> ()) {
        guard let userId = Utils().loadFromUserDefaults(key: "userId") as? String else { return }
        self.db.collection(userId).document("GalleryDBKey").getDocument(completion: { (document, error) in
            if let err = error {
                print("Error load Key List: \(err)")
            } else {
                if let document = document, document.exists {
                    guard let data = document.data() else { return }
                    guard let keys = data["Key"] as? [String] else { return }
                    self.loadIsMainGalleryDB(keys: keys) { keys, data in
                        completion(keys, data)
                    }
                } else {
                    print("Document does not exist")
                }
            }
        })
    }
    
    func loadGalleyKey(completion: @escaping ([String]) -> ()) {
        guard let userId = Utils().loadFromUserDefaults(key: "userId") as? String else { return }
        self.db.collection(userId).document("GalleryDBKey").getDocument(completion: { (document, error) in
            if let err = error {
                print("Error load Key List: \(err)")
            } else {
                if let document = document, document.exists {
                    guard let data = document.data() else { return }
                    guard let keys = data["Key"] as? [String] else { return }
                    completion(keys)
                }
            }
        })
    }
    
    func loadIsFoodInfo(completion: @escaping ([String: Any]) -> ()) {
        guard let userId = Utils().loadFromUserDefaults(key: "userId") as? String else { return }
        self.db.collection(userId).document("FoodInfo").getDocument { (document, error) in
            if let err = error {
                print("Error load FoodInfo List: \(err)")
            } else {
                if let document = document, document.exists {
                    guard let data = document.data() else { return }
                    completion(data)
                } else {
                    completion(["": ""])
                }
            }
        }
    }
    
    func loadIsMainGalleryDB(keys: [String], completion: @escaping ([String], [String: Any]) -> ()) {
        guard let userId = Utils().loadFromUserDefaults(key: "userId") as? String else { return }
        for i in keys {
            self.db.collection(userId).document("GalleryDB").collection(i).whereField("isMain", isEqualTo: true).getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching documents: \(error)")
                } else {
                    guard let documents = querySnapshot?.documents else {
                        print("No documents found")
                        return
                    }
                    for document in documents {
                        let data = document.data()
                        let isMain = data["isMain"] as? Bool ?? false
                        let url = data["downLoadUrls"] as? String ?? ""
                        if isMain {
                            completion(keys, data)
                        }
                    }
                }
            }
        }
    }
    
    func loadIsGalleryDB(keys: [String], completion: @escaping ([String]) -> ()) {
        guard let userId = Utils().loadFromUserDefaults(key: "userId") as? String else { return }
        var urlList = [String]()
        let count = keys.count
        for i in keys {
            self.db.collection(userId).document("GalleryDB").collection(i)
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error fetching documents: \(error)")
                    } else {
                        guard let documents = querySnapshot?.documents else {
                            print("No documents found")
                            return
                        }
                        for document in documents {
                            let data = document.data()
                            let url = data["downLoadUrls"] as? String ?? ""
                            urlList.append(url)
                        }
                        if (count == urlList.count) {
                            completion(urlList)
                        }
                    }
                }
        }
    }
    
    func checkIsMainGalleryDB(key: [String], url: String, completion: @escaping (Bool, [String], String) -> ()) {
        var keyList = key
        guard let userId = Utils().loadFromUserDefaults(key: "userId") as? String else { return }
        for i in key {
            self.db.collection(userId).document("GalleryDB").collection(i).whereField("downLoadUrls", isEqualTo: url).getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    for document in querySnapshot!.documents {
                        let isMain = document.data()["isMain"] as? Bool ?? false
                        if let index = keyList.firstIndex(of: i) {
                            keyList.remove(at: index)
                        }
                        completion(isMain, keyList, i)
                    }
                }
            }
        }
    }
    
    func changeIsMainValue(key: [String], completion: @escaping () -> ()) {
        guard let userId = Utils().loadFromUserDefaults(key: "userId") as? String else { return }
        for i in key {
            self.db.collection(userId).document("GalleryDB").collection(i).whereField("isMain", isEqualTo: true).getDocuments { (querySnapshot, error) in
                guard error == nil else { return }
                self.db.collection(userId).document("GalleryDB").collection(i).document(i).updateData(["isMain": false]) { err in
                    guard err == nil else { return }
                    completion()
                }
            }
        }
    }
    
    func changeIsMainSuccess(key: String, completion: @escaping () -> ()) {
        guard let userId = Utils().loadFromUserDefaults(key: "userId") as? String else { return }
        self.db.collection(userId).document("GalleryDB").collection(key).document(key).updateData(
            ["isMain": true]
        ) { err in
            guard err == nil else { return }
            completion()
        }
    }
    
    func changeMainImage(key: String, completion: @escaping () -> ()) {
        guard let userId = Utils().loadFromUserDefaults(key: "userId") as? String else { return }
        self.db.collection(userId).document("GalleryDB").collection(key).document(key).updateData(["isMain": true]) { error in
            guard error == nil else { return }
            completion()
        }
    }
    
    func loadCategoryList(completion: @escaping ([String]) -> ()){
        guard let userId = Utils().loadFromUserDefaults(key: "userId") as? String else { return }
        self.db.collection(userId).document("CategoryInfoDB").getDocument {  (document, error) in
            guard error == nil else { return }
            guard let dc = document?.data() as? [String: Any] else { return }
            guard let data = dc["Category"] as? [String] else { return }
            completion(data)
        }
    }
}
