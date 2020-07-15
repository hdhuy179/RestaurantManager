//
//  CreateNewDishViewController.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 5/31/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

class DishManagerViewController : UIViewController {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var imvDishImage: UIImageView!
    @IBOutlet weak var txtDishName: UITextField!
    @IBOutlet weak var txtDishPrice: UITextField!
    @IBOutlet weak var txtDishUnit: UITextField!
    @IBOutlet weak var txtDishDescription: UITextField!
    @IBOutlet weak var txtDishCategory: UITextField!
    @IBOutlet weak var swIsInMenu: UISwitch!
    @IBOutlet weak var btnDelete: UIButton!
    
    var dish: MonAn?
    
    weak var delegate: ManagerDataViewController?
    
    private var pickedImageData: Data?
    private var dishCategory: TheLoaiMonAn?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addEndEditingTapGuesture()
        txtDishCategory.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(txtCategoryTapped))
        txtDishCategory.addGestureRecognizer(tapGesture)
        setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.fetchData()
    }
    
    func setupView() {
        if dish == nil {
            btnDelete.setTitle("Hủy", for: .normal)
//            btnDelete.isEnabled = false
//            btnDelete.backgroundColor = .gray
        }
        if let dish = dish {
            lbTitle.text = "Thay đổi món ăn"
            btnDelete.isEnabled = true
            
            if dish.daxoa == 1 {
                btnDelete.setTitle("Khôi phục", for: .normal)
            }
            
            TheLoaiMonAn.fetchData(forID: dish.idtheloaimonan) { [weak self] data, error in
                if data != nil {
                    self?.dishCategory = data
                    self?.txtDishCategory.text = self?.dishCategory?.tentheloaimonan
                }
            }
            imvDishImage.kf.setImage(with: URL(string: dish.diachianh))
            txtDishName.text = dish.tenmonan
            txtDishPrice.text = String(format: "%.f", dish.dongia)
            dishPriceWasChanged(txtDishPrice)
            txtDishUnit.text = dish.donvimonan
            txtDishDescription.text = dish.motachitiet
//            TheLoaiMonAn.
            swIsInMenu.setOn(dish.trongthucdon == 1, animated: true)
        }
        
        txtDishPrice.addTarget(self, action: #selector(dishPriceWasChanged(_:)), for: .editingChanged)
    }
    
    @objc private func txtCategoryTapped() {
        let presentHandler = PresentHandler()
        presentHandler.presentManagerDataVC(self, manageType: .dishCategory, isForPickData: true)
    }
    
    @objc func dishPriceWasChanged(_ textField: UITextField) {
       
        var money = textField.text ?? ""
        money.removeAll(where: { (char) -> Bool in
            return char == "."
        })
         textField.text = Double(money)?.splittedByThousandUnits()
    }

    @IBAction func imvDishImageWasTapped(_ sender: Any) {
        let imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.mediaTypes = ["public.image"]
        
        self.presentInFullScreen(imagePicker, animated: true)
    }
    
    @IBAction func btnConfirmWasTapped(_ sender: Any) {
        
        let dishName = txtDishName.text ?? ""
        var price = txtDishPrice.text ?? ""
        price.removeAll(where: { (char) -> Bool in
            return char == "."
        })
        let dishPrice = (price as NSString).floatValue
        let dishUnit = txtDishUnit.text ?? ""
        let dishDescription = txtDishDescription.text ?? ""
        let dishCategoryID = dishCategory?.idtheloaimonan ?? ""
        let isInMenu = swIsInMenu.isOn ? 1 : 0
        
        let db = Firestore.firestore()
        
        if dish == nil {
            dish = MonAn()
        }
        
        if let pickedImageData = pickedImageData {
            let storage = Storage.storage()
            let storageRef = storage.reference()
            
            let imageRef = storageRef.child("DishImage/" + dish!.idmonan + ".jpg")
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            imageRef.putData(pickedImageData, metadata: metaData) { (_, _) in
                
                imageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else { return }
                    db.collection("MonAn").document(self.dish!.idmonan!).setData([
                        "idmonan": self.dish!.idmonan!,
                        "tenmonan": dishName,
                        "donvimonan": dishUnit,
                        "dongia": dishPrice,
                        "motachitiet": dishDescription,
                        "idtheloaimonan": dishCategoryID,
                        "diachianh": downloadURL.absoluteString,
                        "trongthucdon": isInMenu,
                        "daxoa": 0
                    ]) { err in
                        
                    }
                }
            }
        } else {
            db.collection("MonAn").document(self.dish!.idmonan!).setData([
                "idmonan": self.dish!.idmonan!,
                "tenmonan": dishName,
                "donvimonan": dishUnit,
                "dongia": dishPrice,
                "motachitiet": dishDescription,
                "idtheloaimonan": dishCategoryID,
                "diachianh": dish?.diachianh ?? "",
                "trongthucdon": isInMenu,
                "daxoa": 0
            ]) { err in
                
            }
        }
        
        self.dismiss(animated: true)
    }
    
    @IBAction func btnDeleteTapped(_ sender: Any) {
        if btnDelete.titleLabel?.text == "Hủy" {
            self.dismiss(animated: true)
            return
        }
        let db = Firestore.firestore()
        let will = dish?.daxoa == 0 ? 1 : 0
        let message = will == 0 ? "Bạn có chắc chắn muốn khôi phục dữ liệu không" : "Bạn có chắc chắn muốn xóa dữ liệu không"
        let alert = UIAlertController(title: "Thông báo", message: message, preferredStyle: .alert)
        let xacnhan = UIAlertAction(title: "Xác nhận", style: .default) { (_) in
            db.collection("MonAn").document(self.dish!.idmonan!).updateData(["daxoa": will])
            self.dismiss(animated: true)
        }
        let huy = UIAlertAction(title: "Hủy", style: .cancel)
        alert.addAction(xacnhan)
        alert.addAction(huy)
        self.present(alert, animated: true)
    }
    
    @IBAction func btnBackTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension DishManagerViewController: UINavigationControllerDelegate {
    
}

extension DishManagerViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let type = info[.mediaType] as? String
        
        if type == "public.image",
            let image = info[.originalImage] as? UIImage,
            let data = image.jpegData(compressionQuality: 1.0) as NSData? {
            imvDishImage.image = image
            pickedImageData = data as Data
        }
        self.dismiss(animated: true)
    }
}

extension DishManagerViewController: ManagerPickedData {
    func dataWasPicked(data: Any) {
        if let data = data as? TheLoaiMonAn {
            txtDishCategory.text = data.tentheloaimonan
            dishCategory = data
        }
    }
    
}

extension DishManagerViewController: UITextFieldDelegate {
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if textField == txtDishCategory {
//            return false
//        }
//        return true
//    }
}
