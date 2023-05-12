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
    @IBOutlet weak var downloadImg: UIView!
    @IBOutlet weak var miniImg: UIImageView!
    @IBOutlet weak var imgName: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var categoryList: [String]?
    var previousButton: CategoryCell?
    var imginfo: [UIImagePickerController.InfoKey : Any]! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure()
        self.fillPlaceHolderAndAccessory()
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
extension WriteVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else  { return }
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        guard let resizeImg = UIImage(data: data) else { return }
        self.imginfo = info
        guard let imageURL = info[.imageURL] as? URL else { return }
        let imageName = imageURL.lastPathComponent
        self.addImageView(image: resizeImg, imgName: imageName)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func openGallery(_ gesture: UITapGestureRecognizer) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    private func addImageView(image: UIImage, imgName: String) {
        self.miniImg.image = image
        self.miniImg.clipsToBounds = true
        self.miniImg.isUserInteractionEnabled = true
        self.imgName.text = imgName
    }
}

extension WriteVC: UITextFieldDelegate {
    func fillPlaceHolderAndAccessory() {
        self.titleField.delegate = self
        self.textField.delegate = self
        self.scrollView.isUserInteractionEnabled = true
        
        let dismissSelected = UITapGestureRecognizer(target: self, action: #selector(self.dismissSelectBox))
        dismissSelected.cancelsTouchesInView = false
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.openGallery(_:)))
        
        self.downloadImg.addGestureRecognizer(gesture)
        self.view.addGestureRecognizer(dismissSelected)
    }
    
    @objc func dismissSelectBox() {
        self.view.endEditing(true)
    }
}
