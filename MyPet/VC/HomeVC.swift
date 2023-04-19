//
//  HomeVC.swift
//  MyPet
//
//  Created by 오승훈 on 2023/03/11.
//

import UIKit
import FirebaseFirestore
import ProgressHUD
import SDWebImage

class HomeVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var refreshControl: UIRefreshControl!
    @IBOutlet weak var imageInfoButton: UIButton!
    //상단 imgInfo -> img만 보여주면 된다.
    //중단 foodInfo ->
    //하단 listInfo ->
    enum Section {
        case imgInfo
        case foodInfo
        case listInfo
    }
    
    var datasoruce: UICollectionViewDiffableDataSource<Section, String>!
    var imgInfo   = ImgInfo(imgName: [""], date: [Date()] , key: [""])
    var foodInfo  = FoodInfo(name: [""], until: [Date()], description: [""], key: [""])
    var listInfo  = ListInfo(date: [Date()], title: [""], img: [""], text: [""], key: [""])
    var urlArr = [String]()
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareData() {
            Network().downloadURL(pathName: "ImageList") { urlArr in
                self.urlArr = urlArr
            }
        }
    }
    
   private func prepareData(completion: @escaping () -> ()) {
       self.imagePicker.sourceType = .photoLibrary
       self.imagePicker.delegate = self
       let dateFormatter = DateFormatter()
       dateFormatter.dateFormat = "yyyy-MM-dd"
       dateFormatter.locale = Locale(identifier: "ko_KR")
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
                        var imgKeyArr = [String]()
                        if keys.count > 0 {
                            for i in keys {
                                let imgNames = document.data()["imgName"] as? [String: Any] ?? [:]
                                let imgSaveTimes = document.data()["imgSaveTime"] as? [String: Any] ?? [:]
                                imgNameArr.append(imgNames[i] as! String)
                                imgSaveTimeArr.append(dateFormatter.date(from: imgSaveTimes[i] as! String)!)
                                imgKeyArr.append(i)
                            }
                            self.imgInfo = ImgInfo(imgName: imgNameArr, date: imgSaveTimeArr, key: imgKeyArr)
                        }
                    }
                } else if document.documentID == "FoodInfo"  {
                    if document.get("Key")as! [String] != [] {
                        let keys = document.get("Key") as! [String]
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        
                        var foodNameArr = [String]()
                        var foodDescriptionArr = [String]()
                        var foodUntilArr = [Date]()
                        var foodKeyArr = [String]()
                        if keys.count > 0 {
                            for i in keys {
                                let foodName = document.data()["foodName"] as? [String: Any] ?? [:]
                                let foodDescription = document.data()["foodDescription"] as? [String: Any] ?? [:]
                                let foodUntil = document.data()["foodUntil"] as? [String: Any] ?? [:]
                                foodNameArr.append(foodName[i] as! String)
                                foodDescriptionArr.append(foodDescription [i] as! String)
                                foodUntilArr.append(dateFormatter.date(from: foodUntil[i] as! String) ?? Date())
                                foodKeyArr.append(i)
                            }
                            self.foodInfo = FoodInfo(name: foodNameArr, until: foodUntilArr, description: foodDescriptionArr, key: foodKeyArr)
                        }
                    }
                } else if document.documentID == "ListInfo" {
                    if document.get("Key")as! [String] != [] {
                        let keys = document.get("Key") as! [String]
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        
                        var listImgArr = [String]()
                        var listNumberArr = [String]()
                        var listTitleArr = [String]()
                        var listUntilArr = [Date]()
                        var listTextArr = [String]()
                        var listKeyArr = [String]()
                        if keys.count > 0 {
                            for i in keys {
                                let listImg = document.data()["listImg"] as? [String: Any] ?? [:]
                                let listNumber = document.data()["litsNumber"] as? [String: Any] ?? [:]
                                let listTitle = document.data()["listTitle"] as? [String: Any] ?? [:]
                                let listUntil = document.data()["listUntil"] as? [String: Any] ?? [:]
                                let listText = document.data()["listText"] as? [String: Any] ?? [:]
                                
                                listImgArr.append(listImg[i] as! String)
                                listNumberArr.append(listNumber[i] as? String ?? "")
                                listTitleArr.append(listTitle [i] as? String ?? "")
                                listUntilArr.append(dateFormatter.date(from: listUntil[i] as! String) ?? Date())
                                listTextArr.append(listText[i] as! String)
                                listKeyArr.append(i)
                            }
                            
                            self.listInfo = ListInfo(date: listUntilArr, title: listTitleArr, img: listImgArr, text: listTextArr, key: listKeyArr)
                        }
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
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "", for: indexPath) as? HomeMainCell else { return UICollectionViewCell() }
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
        DispatchQueue.main.async {
            //reloadData 관련
        }
    }
    
    @IBAction func didTapAddButton(sender: Any) {
        self.present(self.imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        Network().uploadImage(filePath: "ImageList", info: info) { url in
            let a = url.absoluteString
        }
        picker.dismiss(animated: true)
    }
}
