//
//  HomeSecondVC.swift
//  MyPet
//
//  Created by shoh on 2023/04/19.
//

import UIKit

class HomeSecondVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib(nibName: "HeadCell", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeadCell")
        self.collectionView.register(UINib(nibName: "HomeMainCell", bundle: nil), forCellWithReuseIdentifier: "HomeMainCell")
        self.collectionView.register(UINib(nibName: "HomeSubCell", bundle: nil), forCellWithReuseIdentifier: "HomeSubCell")
//        self.configure()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.configure()
    }
    func configure() {
//        let isFirst = false
//        if isFirst {
            //isFirst == true -> galleryDB load 및 foodInfoDB load
//        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "GalleryInitVC") as! GalleryInitVC
            viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true)
//        }
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
