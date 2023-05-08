//
//  GalleryVC.swift
//  MyPet
//
//  Created by shoh on 2023/05/08.
//

import UIKit
import SDWebImage

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
         //팝업이 뜨면서 종료
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.bounds.width / 3 - 10
        let height = self.view.bounds.width / 3
        return CGSize(width: width, height: height)
    }
}
