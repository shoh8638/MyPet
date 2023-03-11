//
//  HomeVC.swift
//  MyPet
//
//  Created by 오승훈 on 2023/03/11.
//

import UIKit

class HomeVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var refreshControl: UIRefreshControl!
    
    enum Section {
        case imgInfo
        case foodInfo
        case listInfo
    }
    
    var datasoruce: UICollectionViewDiffableDataSource<Section, String>!
    var imgInfo   = [String]()
    var foodInfo  = [String]()
    var listInfo  = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData {
            self.configure()
            self.homeRefresh()
        }
    }
    
    func loadData(completion: @escaping () -> ()){
        //Web Data Load
        completion()
    }
    
    func configure() {
        self.datasoruce = UICollectionViewDiffableDataSource(collectionView: self.collectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "", for: indexPath) as? HomeCell else { return UICollectionViewCell() }
            return cell
        })
        //headerView
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.appendSections([.imgInfo, .foodInfo, .listInfo])
        snapshot.appendItems(imgInfo, toSection: .imgInfo)
        snapshot.appendItems(foodInfo, toSection: .foodInfo)
        snapshot.appendItems(listInfo, toSection: .listInfo)
        self.datasoruce.apply(snapshot)
        
        self.collectionView.collectionViewLayout = self.cellLayout()
    }
    
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
    
    func headLayout() {
        
    }
    
    func homeRefresh() {
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
