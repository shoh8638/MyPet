//
//  HomeSecondVC.swift
//  MyPet
//
//  Created by shoh on 2023/04/19.
//

import UIKit
import SDWebImage

class HomeSecondVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var galleryKeyList: [String]!
    var galleryList: [[String : Any]]!
    var untilDate: [[String : Any]]!
    var galleryImgUrl: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configuration()
    }
    
    func configuration() {
        Network().loadIsGalleryKey { data in
            print("HomeVC :\(data)")
            self.galleryImgUrl = data["downLoadUrls"] as? String ?? ""
            //FoodInfo 관련하여 정보 가져오기
            self.registerForCollectionView()
        }
    }
    
    func registerForCollectionView() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib(nibName: "HeadCell", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeadCell")
        self.collectionView.register(UINib(nibName: "HomeMainCell", bundle: nil), forCellWithReuseIdentifier: "HomeMainCell")
        self.collectionView.register(UINib(nibName: "HomeSubCell", bundle: nil), forCellWithReuseIdentifier: "HomeSubCell")
    }
}

extension HomeSecondVC: UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1{
            return 5
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeMainCell", for: indexPath) as? HomeMainCell else {
                return UICollectionViewCell()
            }
            if self.galleryImgUrl != nil {
                cell.mainImg.sd_setImage(with: URL(string: self.galleryImgUrl), placeholderImage: nil, options: []) { (image, error, cacheType, url) in
                    if let error = error {
                        print("Error downloading image: \(error.localizedDescription)")
                    } else {
                        print("Image downloaded successfully!")
                    }
                }
            }
            cell.goGallery.addTarget(self, action: #selector(tapGoGallery(_ :)), for: .touchUpInside)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeSubCell", for: indexPath) as? HomeSubCell else {
                return UICollectionViewCell()
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.bounds.width - 20
        let height = self.view.bounds.height / 3 - 20
        if indexPath.section == 0 {
            return CGSize(width: width, height: height)
        } else {
            return CGSize(width: width, height: 150)
        }
    }
    
    @objc func tapGoGallery(_ sender: UIButton) {
        print("tap go")
        //GalleryView로 넘어가 사진들이 쭉 보이고 마지막 한개는 추가 셀로 버튼을 누르면 갤러리가 나오고 사진 선택 시, 서버에 저장 및 reload하여 셀 다시 수정
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
              if indexPath.section == 0 {
                  guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeadCell", for: indexPath) as? HeadCell else { return UICollectionReusableView() }
                  headerView.headTitle.text = "main"
                  headerView.divide.isHidden = true
                  return headerView
              } else if indexPath.section == 1 {
                  guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeadCell", for: indexPath) as? HeadCell else { return UICollectionReusableView() }
                  headerView.headTitle.text = "sub"
                  headerView.btn.isHidden = true
                  headerView.divide.isHidden = false
                  return headerView
              }
          }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = self.view.bounds.width
        return CGSize(width: width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
}
