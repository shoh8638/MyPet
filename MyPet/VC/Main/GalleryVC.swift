//
//  GalleryVC.swift
//  MyPet
//
//  Created by shoh on 2023/05/08.
//

import UIKit
import SDWebImage
import ProgressHUD

class GalleryVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var imgKey: [String]?
    var urlList = [String]()
    var delegate: ReloadMainImg?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configuration()
    }
    
    private func configuration() {
        if let keys = self.imgKey {
            print("Ok")
            Network().loadIsGalleryDB(keys: keys) { urlList in
                self.urlList = urlList
                self.registerForCollectionView()
            }
        } else {
            Alert().basicOKAlert(message: "정상적인 접근방식이 아닙니다.", vc: self)
        }
    }
    
    private func registerForCollectionView() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib(nibName: "GalleryCell", bundle: nil), forCellWithReuseIdentifier: "GalleryCell")
    }
}

extension GalleryVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.urlList.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == self.urlList.count  {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath) as? GalleryCell else { return UICollectionViewCell()}
            cell.mainImg.image = UIImage(systemName: "star.fill")
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath) as? GalleryCell else { return UICollectionViewCell()}
            cell.mainImg.sd_setImage(with: URL(string: self.urlList[indexPath.item]))
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == self.urlList.count {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            Network().checkIsMainGalleryDB(key: self.imgKey!, url: self.urlList[indexPath.item]) { result, list, key in
                if result == true {
                    //현재 main Image일 경우
                    Alert().backAlert(messgae: "현재 메인 이미지 입니다.", vc: self)
                } else {
                    //현재 main Image아닐 경우
                    Alert().okAlert(message: "현재 이미지를 메인으로 하시겠습니까?", vc: self) {
                        Network().changeIsMainSuccess(key: key) {
                            Network().changeIsMainValue(key: list) {
                                self.dismiss(animated: true) {
                                    self.delegate?.reloadMain()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.bounds.width / 3 - 10
        let height = self.view.bounds.width / 3
        return CGSize(width: width, height: height)
    }
}

extension GalleryVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        ProgressHUD.show("로딩중...")
        Network().uploadGalleryDB(info: info) {
            picker.dismiss(animated: true) {
                Network().loadGalleyKey { key in
                    self.imgKey = key
                    if let imgKey = self.imgKey {
                        Network().loadIsGalleryDB(keys: imgKey) { urlList in
                            ProgressHUD.remove()
                            self.urlList = urlList
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
        }
    }
}
