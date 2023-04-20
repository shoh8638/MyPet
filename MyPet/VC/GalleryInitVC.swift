//
//  GalleryInitVC.swift
//  MyPet
//
//  Created by shoh on 2023/04/20.
//

import UIKit

class GalleryInitVC: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var imgView: UIView!
    @IBOutlet weak var tapTitle: UILabel!
    var mainImg: UIImageView!
    var img: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainImg = UIImageView(frame: self.imgView.bounds)
//        self.mainImg.contentMode = .scaleAspectFit
        self.mainImg.clipsToBounds = true
        self.imgView.isUserInteractionEnabled = true // 터치 이벤트 사용 가능하도록 설정
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openGallery(_:)))
        self.imgView.addGestureRecognizer(tapGesture)
    }
    
    @objc func openGallery(_ gesture: UITapGestureRecognizer) {
        //추후 갤러리 권한에 따라 나타나는게 다름
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    private func addImageView(image: UIImage) {
        self.mainImg.image = image
        self.mainImg.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openGallery(_:)))
        self.mainImg.addGestureRecognizer(tapGesture)
        self.imgView.addSubview(self.mainImg)
        self.img = image
        self.tapTitle.isHidden = true
//        self.imgView.isUserInteractionEnabled = false
    }
    
    @IBAction func tap(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            let resizedImage = self.resizeImage(image: image, targetSize: self.mainImg.frame.size)
            self.addImageView(image: resizedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    // 이미지 선택 취소 시 호출되는 메서드
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
           let size = image.size

           // 이미지가 이미지뷰의 크기보다 작은 경우 원본 이미지 반환
           if size.width < targetSize.width && size.height < targetSize.height {
               return image
           }

           let widthRatio  = targetSize.width  / size.width
           let heightRatio = targetSize.height / size.height

           let newSize: CGSize
           if widthRatio > heightRatio {
               newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
           } else {
               newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
           }

           let rect = CGRect(origin: CGPoint.zero, size: newSize)

           UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
           image.draw(in: rect)
           let newImage = UIGraphicsGetImageFromCurrentImageContext()
           UIGraphicsEndImageContext()

           return newImage!
       }
}

extension GalleryInitVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 0
    }
    
}
