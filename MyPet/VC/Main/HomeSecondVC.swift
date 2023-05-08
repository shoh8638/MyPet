//
//  HomeSecondVC.swift
//  MyPet
//
//  Created by shoh on 2023/04/19.
//

import UIKit
import SDWebImage
import ProgressHUD

protocol ReloadMainImg {
    func reloadMain()
}

class HomeSecondVC: UIViewController, ReloadMainImg {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var galleryImgUrl: String!
    var galleryKeys: [String]!
    var foodInfoList: [String: Any]!
    let refreshControll = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configuration()
    }
    
    func configuration() {
        ProgressHUD.show("로딩중...")
        Network().loadIsGalleryKey { keys, data in
            print("HomeVC :\(data)")
            self.galleryImgUrl = data["downLoadUrls"] as? String ?? ""
            self.galleryKeys = keys
            Network().loadIsFoodInfo { data in
                ProgressHUD.remove()
                if data as? [String: String] == ["": ""] {
                    self.foodInfoList = ["key": "empty"]
                } else {
                    self.foodInfoList = data
                }
                self.registerForCollectionView()
            }
        }
    }
    
    func registerForCollectionView() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib(nibName: "HeadCell", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeadCell")
        self.collectionView.register(UINib(nibName: "HomeMainCell", bundle: nil), forCellWithReuseIdentifier: "HomeMainCell")
        self.collectionView.register(UINib(nibName: "HomeSubCell", bundle: nil), forCellWithReuseIdentifier: "HomeSubCell")
        refreshControll.addTarget(self, action: #selector(self.reloadMainView), for: .valueChanged)
        self.collectionView.refreshControl = refreshControll
    }
    
    @objc func tapGoGallery(_ sender: UIButton) {
        print("tap go")
        //GalleryView로 넘어가 사진들이 쭉 보이고 마지막 한개는 추가 셀로 버튼을 누르면 갤러리가 나오고 사진 선택 시, 서버에 저장 및 reload하여 셀 다시 수정
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GalleryVC") as! GalleryVC
        vc.imgKey = self.galleryKeys
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    @objc func reloadMainView() {
        ProgressHUD.show("로딩중...")
        Network().loadIsGalleryKey { keys, data in
            print("HomeVC :\(data)")
            self.galleryImgUrl = data["downLoadUrls"] as? String ?? ""
            self.galleryKeys = keys
            Network().loadIsFoodInfo { data in
                ProgressHUD.remove()
                if data as? [String: String] == ["": ""] {
                    self.foodInfoList = ["key": "empty"]
                } else {
                    self.foodInfoList = data
                }
                self.collectionView.reloadData()
                self.refreshControll.endRefreshing()
            }
        }
    }
    
    func reloadMain() {
        self.reloadMainView()
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
            return  self.foodInfoList["key"] as! String == "empty" ? 1 : 5
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeMainCell", for: indexPath) as? HomeMainCell else {
                return UICollectionViewCell()
            }
            if self.galleryImgUrl != nil {
                cell.mainImg.clipsToBounds = true
                cell.mainImg.sd_setImage(with: URL(string: self.galleryImgUrl))
                cell.mainImg.sd_setImage(with: URL(string: self.galleryImgUrl))
            }
            cell.goGallery.addTarget(self, action: #selector(tapGoGallery(_ :)), for: .touchUpInside)
            return cell
        } else if indexPath.section == 1{
            if self.foodInfoList["key"] as! String == "empty" {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeSubCell", for: indexPath) as? HomeSubCell else {
                    return UICollectionViewCell()
                }
                cell.dateTitle.text = "아무것도 없어용"
                return cell
            } else {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeSubCell", for: indexPath) as? HomeSubCell else {
                    return UICollectionViewCell()
                }
                cell.dateTitle.text = "몬가가 있네용"
                return cell
            }
        } else {
            return UICollectionViewCell()
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
              if indexPath.section == 0 {
                  guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeadCell", for: indexPath) as? HeadCell else { return UICollectionReusableView() }
                  headerView.headTitle.text = "main"
                  headerView.btn.isHidden = true
                  headerView.divide.isHidden = true
                  return headerView
              } else if indexPath.section == 1 {
                  guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeadCell", for: indexPath) as? HeadCell else { return UICollectionReusableView() }
                  headerView.headTitle.text = "sub"
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
