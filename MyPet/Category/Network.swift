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
                    self.db.collection(userId).document("GalleryDB").collection(current).document().setData([
                        "name": name,
                        "gender": gender,
                        "date": date,
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
                    self.db.collection(userId).document("BasicInfo").updateData(["isFirst": true]) { err in
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
    
    func loadIsGalleryKey(completion: @escaping ([String: Any]) -> ()) {
        guard let userId = Utils().loadFromUserDefaults(key: "userId") as? String else { return }
        self.db.collection(userId).document("GalleryDBKey").getDocument(completion: { (document, error) in
            if let err = error {
                print("Error load Key List: \(err)")
            } else {
                if let document = document, document.exists {
                    guard let data = document.data() else { return }
                    guard let keys = data["Key"] as? [String] else { return }
                    self.loadIsGalleryDB(keys: keys) { data in
                        completion(data)
                    }
                } else {
                    print("Document does not exist")
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
    
    func loadIsGalleryDB(keys: [String], completion: @escaping ([String: Any]) -> ()) {
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
                                print("Document with isMain = true: \(data)")
                                print("Document with isMain = true: \(url)")
                                completion(data)
                            }
                        }
                    }
            }
        }
    }
}
