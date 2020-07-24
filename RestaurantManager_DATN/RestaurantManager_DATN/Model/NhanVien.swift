//
//  NhanVien.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 5/31/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import ObjectMapper

struct NhanVien: Decodable {
    var idnhanvien: String! = UUID().uuidString
    var tennhanvien: String = ""
    var sodienthoai: String = ""
    var email: String = ""
    var diachi: String = ""
    var quyen: Int = -1
    var idtaikhoandangnhap: String = ""
    var daxoa: Int = 0
    
    func getPosition() -> String {
        switch quyen {
        case 0:
            return "Admin"
        case 1:
            return "Quản lý nhà hàng"
        case 2:
            return "Nhân viên thu ngân"
        case 3:
            return "Nhân viên phục vụ"
        case 4:
            return "Quản lý nhà bếp"
        case 5:
            return "Quản lý nhà kho"
        default:
            return "nil"
        }
    }
    
    static func fetchAllDataAvailable(completion: @escaping ([NhanVien]?, Error?) -> Void) {
        var datas = [NhanVien]()
        let db = Firestore.firestore()

        db.collection("NhanVien").whereField("daxoa", isEqualTo: 0).order(by: "tennhanvien").getDocuments { (snapshot, err) in
            if err != nil {
                
//                print("Error getting BanAn Data: \(err!.localizedDescription)")
                completion(nil, err)
                
            } else if let snapshot = snapshot, !snapshot.documents.isEmpty {
                
                snapshot.documents.forEach({ (document) in
                    if let data = NhanVien(JSON: document.data()) {
                        datas.append(data)
                    }
                })
                completion(datas, nil)
            } else {
                completion(datas, nil)
            }
        }
    }
    
     static func fetchAllData(completion: @escaping ([NhanVien]?, Error?) -> Void) {
            var datas = [NhanVien]()
            let db = Firestore.firestore()

            db.collection("NhanVien").order(by: "tennhanvien").getDocuments { (snapshot, err) in
                if err != nil {
                    
    //                print("Error getting BanAn Data: \(err!.localizedDescription)")
                    completion(nil, err)
                    
                } else if let snapshot = snapshot, !snapshot.documents.isEmpty {
                    
                    snapshot.documents.forEach({ (document) in
                        if let data = NhanVien(JSON: document.data()) {
                            datas.append(data)
                        }
                    })
                    completion(datas, nil)
                } else {
                    completion(datas, nil)
                }
            }
        }
    
    static func fetchData(forID id: String, completion: @escaping (NhanVien?, Error?) -> Void) {
        if id == "" {
            completion(nil,nil)
            return
        }
        var result = NhanVien()
        let db = Firestore.firestore()

        db.collection("NhanVien").document(id).getDocument { (snapshot, err) in
            if err != nil {
                
                print("Error getting BanAn Data: \(err!.localizedDescription)")
                completion(nil, err)
                
            } else if let data = snapshot?.data() {
                
                if let data = NhanVien(JSON: data) {
                    result = data
                }
                completion(result, nil)
            } else {
                completion(nil, nil)
            }
        }
    }
    
    static func fetchData(forAccountID id: String, completion: @escaping (NhanVien?, Error?) -> Void) {
        if id == "" {
            completion(nil,nil)
            return
        }
        var result = NhanVien()
        let db = Firestore.firestore()

        db.collection("NhanVien").whereField("idtaikhoandangnhap", isEqualTo: id).whereField("daxoa", isEqualTo: 0).getDocuments { (snapshot, err) in
            if err != nil {
                
                print("Error getting BanAn Data: \(err!.localizedDescription)")
                completion(nil, err)
                
            } else if let data = snapshot?.documents.first?.data() {
                
                if let data = NhanVien(JSON: data) {
                    result = data
                }
                completion(result, nil)
            } else {
                completion(nil, nil)
            }
        }
    }
}

extension NhanVien: Mappable {
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        idnhanvien <- map["idnhanvien"]
        tennhanvien <- map["tennhanvien"]
        sodienthoai <- map["sodienthoai"]
        email <- map["email"]
        diachi <- map["diachi"]
        quyen <- map["quyen"]
        idtaikhoandangnhap <- map["idtaikhoandangnhap"]
        daxoa <- map["daxoa"]
    }
    
}
