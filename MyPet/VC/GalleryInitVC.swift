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
    @IBOutlet weak var goBtn: UIButton!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var genderText: UITextField!
    @IBOutlet weak var dateText: UITextField!
    
    var mainImg: UIImageView!
    var imgUrl: String!
    var imginfo: [UIImagePickerController.InfoKey : Any]! = nil
    let pickerView = UIPickerView()
    let datePicker = UIDatePicker()
    let option1 = ["남", "여"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainImg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width - 60, height: self.view.bounds.width - 60))
        self.mainImg.clipsToBounds = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openGallery(_:)))
        self.imgView.addGestureRecognizer(tapGesture)
        self.view.bringSubviewToFront(self.goBtn)
        self.fillPlaceHolderAndAccessory()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissSelectBox))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func openGallery(_ gesture: UITapGestureRecognizer) {
        //추후 갤러리 권한에 따라 나타나는게 다름
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func dismissSelectBox() {
        self.nameText.resignFirstResponder()
        self.genderText.resignFirstResponder()
        self.dateText.resignFirstResponder()
    }
    
    private func addImageView(image: UIImage) {
        self.mainImg.image = image
        self.mainImg.clipsToBounds = true
        self.mainImg.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openGallery(_:)))
        
        self.mainImg.addGestureRecognizer(tapGesture)
        self.imgView.addSubview(self.mainImg)
        self.tapTitle.isHidden = true
    }
    
    @IBAction func tap(_ sender: Any) {
        //이미지, 이름, 성별 정보3개가 있어야 저장 및 메인으로 전달 -> GalleryDB에 저장되면 메인에서 reload후 보여지게끔
        //저장 시, imgUrl.lastPathComponent이름으로 하여금 저장

//        Utils().introVCDidFinish(result: "true", vc: self)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let imageURL = info[.imageURL] as? URL else { return }
        /*
         이미지 코덱 사용
         이미지 코덱을 사용하여 이미지를 불러올 때, 이미지의 압축률을 조정하여 이미지의 크기를 줄이는 방법입니다. 이 방법을 사용하면 이미지의 크기를 줄이면서도 이미지의 화질을 유지할 수 있습니다.
         */
        guard let image = info[.originalImage] as? UIImage else  { return }
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        guard let resizeImg = UIImage(data: data) else { return }
        self.imginfo = info
        self.addImageView(image: resizeImg)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    // 이미지 선택 취소 시 호출되는 메서드
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension GalleryInitVC: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    func fillPlaceHolderAndAccessory() {
        self.nameText.delegate = self
        self.genderText.delegate = self

        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.datePicker.datePickerMode = .date
        
        self.datePicker.datePickerMode = .date
        self.datePicker.preferredDatePickerStyle = .wheels
        self.datePicker.timeZone = .current
        self.datePicker.addTarget(self, action: #selector(self.tapDatePicker(_:)), for: .valueChanged)
        
        self.genderText.inputView = self.pickerView
        self.dateText.inputView = self.datePicker
    }
    
    @objc func tapDatePicker(_ datePieker: UIDatePicker) {
        let formmater = DateFormatter()
        formmater.dateFormat = "yyyy 년 MM 월 dd 일"
        formmater.locale = Locale(identifier: "ko_KR")
        self.dateText.text = formmater.string(from: datePieker.date)
    }
    // UIPickerViewDataSource 프로토콜 구현
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.option1.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.genderText.text = self.option1[row]
        return self.option1[row]
    }
    
    // UIPickerViewDelegate 프로토콜 구현
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.genderText.text = self.option1[row]
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.nameText {
            return true
        } else if textField == self.genderText {
            return true
        } else if textField == self.dateText {
            return true
        }
        return false
    }
}
