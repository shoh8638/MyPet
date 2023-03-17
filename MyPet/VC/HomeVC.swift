//
//  HomeVC.swift
//  MyPet
//
//  Created by 오승훈 on 2023/03/11.
//

import UIKit
import FirebaseFirestore
import ProgressHUD

class HomeVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var refreshControl: UIRefreshControl!
    
    enum Section {
        case imgInfo
        case foodInfo
        case listInfo
    }
    
    var datasoruce: UICollectionViewDiffableDataSource<Section, String>!
    var imgInfo   = ImgInfo(imgName: [""], date: [Date()] , key: [""])
    var foodInfo  = FoodInfo(name: [""], until: [Date()], description: [""], key: [""])
    var listInfo  = ListInfo(date: [Date()], title: [""], img: [""], text: [""], key: [""])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareData() {
        }
    }
    
   private func prepareData(completion: @escaping () -> ()) {
        Network().loadDocumentData(vc: self) { quetysnapshot in
            for document in quetysnapshot!.documents {
                if document.documentID == "ImgInfo" {
                //해당 field -> field안에 key값을 가지고 처리
                    if document.get("Key")as! [String] != [] {
                        let keys =  document.get("Key") as! [String]
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        
                        var imgNameArr = [String]()
                        var imgSaveTimeArr = [Date]()
                        var keyArr = [String]()
                        for i in keys {
                            let imgNames = document.data()["imgName"] as? [String: Any] ?? [:]
                            let imgSaveTimes = document.data()["imgSaveTime"] as? [String: Any] ?? [:]
                            imgNameArr.append(imgNames[i] as! String)
                            imgSaveTimeArr.append(dateFormatter.date(from: imgSaveTimes[i] as! String)!)
                            keyArr.append(i)
                        }
                        self.imgInfo = ImgInfo(imgName: imgNameArr, date: imgSaveTimeArr, key: keyArr)
                    }
                } else if document.documentID == "FoodInfo"  {
                    if document.get("Key")as! [String] != [] {
                        
                    }
                } else if document.documentID == "ListInfo" {
                    if document.get("Key")as! [String] != [] {
                        
                    }
                }
            }
            completion()
        }
    }
    
    
    //공통으로 묶을 예정
    func loadData(completion: @escaping () -> ()){
        //Web Data Load
        completion()
    }
    
    private func configure() {
        self.datasoruce = UICollectionViewDiffableDataSource(collectionView: self.collectionView, cellProvider: { collectionView, indexPath, item in
            //section별 다른 UI적용
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "", for: indexPath) as? HomeCell else { return UICollectionViewCell() }
            return cell
        })
        //headerView
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.appendSections([.imgInfo, .foodInfo, .listInfo])
        snapshot.appendItems(imgInfo.imgName, toSection: .imgInfo)
        snapshot.appendItems(foodInfo.name, toSection: .foodInfo)
        snapshot.appendItems(listInfo.title, toSection: .listInfo)
        self.datasoruce.apply(snapshot)
        
        self.collectionView.collectionViewLayout = self.cellLayout()
    }
    //공통으로 묶을 예정
    func cellLayout() -> UICollectionViewCompositionalLayout{
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(10), heightDimension: .estimated(10))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.33))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)
        group.interItemSpacing = .fixed(10)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        section.interGroupSpacing = 10
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    //공통으로 묶을 예정
    func headLayout() {
        
    }
    
    private func homeRefresh() {
        self.refreshControl.addTarget(self, action: #selector(refreshControl(re:)), for: .valueChanged)
        self.refreshControl.backgroundColor = .lightGray
        self.refreshControl.tintColor = .black
        self.refreshControl.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
        self.collectionView.refreshControl = self.refreshControl
    }
    
    @objc func refreshControl(re: UIRefreshControl) {
        print("HomeVC: refreshControl")
        DispatchQueue.main.async {
            //reloadData 관련
        }
    }
}
