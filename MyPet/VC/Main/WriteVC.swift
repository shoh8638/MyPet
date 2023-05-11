//
//  WriteVC.swift
//  MyPet
//
//  Created by shoh on 2023/05/10.
//

import UIKit

class WriteVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var textField: UITextField!
    
    var categoryList: [String]?
    var previousButton: CategoryCell?
    var btnTag: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure()

    }
    
    private func configure() {
        self.collectionView.register(UINib(nibName: "CategoryCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCell")
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }

    @IBAction func closeTap(_ sender: Any) {
        print("CloseTap")
    }
    
    @IBAction func checkCloseTap(_ sender: Any) {
        print("checkTap")
    }

    @IBAction func saveTap(_ sender: Any) {
        print("saveTap")
    }
}

extension WriteVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categoryList!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as? CategoryCell else { return UICollectionViewCell() }
        cell.titleLabel.text = self.categoryList![indexPath.item]
        cell.backView.backgroundColor = .orange
        cell.backView.layer.cornerRadius = 10
       return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let prevBtn = self.previousButton {
            prevBtn.backView.backgroundColor = .orange
            prevBtn.backView.layer.cornerRadius = 10
        }
        guard let cell = collectionView.cellForItem(at: indexPath) as? CategoryCell else { return }
        cell.backView.backgroundColor = .lightGray
        cell.backView.layer.cornerRadius = 10

        self.previousButton = cell
        print(self.categoryList![indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.collectionView.bounds.width / 4 - 30
        let height = self.collectionView.bounds.height
        return CGSize(width: width, height: height)
    }
}

extension WriteVC: UITextFieldDelegate {
    func fillPlaceHolderAndAccessory() {
        self.titleField.delegate = self
        self.textField.delegate = self
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.titleField {
            return true
        } else if textField == self.textField {
            return true
        }
        return false
    }
}
