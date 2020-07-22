//
//  PhieuXuat.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 6/23/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//
import ObjectMapper

struct PhieuXuat: Decodable {
    var idphieuxuat: String! = UUID().uuidString
    var idnhanvientaophieu: String = ""
    var idnhanvienxuatphieu: String = ""
    var idphieunhap: String = ""
    var ngaytao: Date?
    var soluong: Float = 0
    var trangthai: Int = 0
    var daxoa: Int = 0
    
    var creatorStaff: NhanVien?
    var exportStaff: NhanVien?
    
    static func getAllReferanceData(of snapshot: QuerySnapshot, completion: @escaping ([PhieuXuat]?, Error?) -> Void) {
        var bills = [PhieuXuat]()
        snapshot.documents.forEach({ (document) in
            if var hoadon = PhieuXuat(JSON: document.data()) {
                var counter = 0
                
                NhanVien.fetchData(forID: hoadon.idnhanvientaophieu) { (staff, error) in
                    hoadon.creatorStaff = staff
                    counter += 1
                    if counter == 2 {
                        bills.append(hoadon)
                    }
                    if bills.count == snapshot.documents.count {
                        completion(bills, nil)
                    }
                    
                    if error != nil {
                        completion(nil, error)
                    }
                }
                
                NhanVien.fetchData(forID: hoadon.idnhanvienxuatphieu) { (staff, error) in
                    hoadon.exportStaff = staff
                    counter += 1
                    if counter == 2 {
                        bills.append(hoadon)
                    }
                    if bills.count == snapshot.documents.count {
                        completion(bills, nil)
                    }
                    if error != nil {
                        completion(nil, error)
                    }
                }
            }
        })
    }
    static func fetchAllDataAvailable(completion: @escaping ([PhieuXuat]?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("PhieuXuat").whereField("daxoa", isEqualTo: 0).order(by: "ngaytao").getDocuments { (snapshot, err) in
            if err != nil {
                
                //                print("Error getting BanAn Data: \(err!.localizedDescription)")
                completion(nil, err)
                
            } else if let snapshot = snapshot, !snapshot.documents.isEmpty {
                
//                snapshot.documents.forEach({ (document) in
//                    if let data = PhieuXuat(JSON: document.data()) {
//                        datas.append(data)
//                    }
//                })
                
                getAllReferanceData(of: snapshot, completion: completion)
            } else {
                completion([], nil)
            }
        }
    }
    
    static func fetchAllData(completion: @escaping ([PhieuXuat]?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("PhieuXuat").order(by: "ngaytao").getDocuments { (snapshot, err) in
            if err != nil {
                
                completion(nil, err)
                
            } else if let snapshot = snapshot, !snapshot.documents.isEmpty {
                
//                snapshot.documents.forEach({ (document) in
//                    if let data = PhieuXuat(JSON: document.data()) {
//                        datas.append(data)
//                    }
//                })
//                completion(datas, nil)
                getAllReferanceData(of: snapshot, completion: completion)
            } else {
                completion([], nil)
            }
        }
    }
    
    static func fetchData(from: Date, toDate: Date ,completion: @escaping ([PhieuXuat]?, Error?) -> Void) {
        
        let db = Firestore.firestore()
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: from)
        let start = calendar.date(from: components)!
        let toComponents = calendar.dateComponents([.year, .month, .day], from: calendar.date(byAdding: .day, value: 1, to: toDate)!)
        let end = calendar.date(from: toComponents)!
        
        db.collection("PhieuXuat").whereField("daxoa", isEqualTo: 0).whereField("trangthai", isEqualTo: 1).whereField("ngaytao", isLessThanOrEqualTo: end).whereField("ngaytao", isGreaterThan: start).order(by: "ngaytao").getDocuments { (snapshot, err) in
            if err != nil {
                
                print("Error getting HoaDon Data: \(err!.localizedDescription)")
                completion(nil, err)
                
            } else if snapshot != nil, !snapshot!.documents.isEmpty {
                
                getAllReferanceData(of: snapshot!, completion: completion)
                
            } else {
                completion(nil, nil)
            }
        }
    }
    
    static func createBill(data: PhieuXuat, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("PhieuXuat").document(data.idphieuxuat).setData([
            
            "idphieuxuat": data.idphieuxuat!,
            "idnhanvientaophieu": App.shared.staffInfo?.idnhanvien ?? "",
            "idnhanvienxuatphieu": "",
            "idphieunhap": data.idphieunhap,
            "ngaytao": data.ngaytao,
            "soluong": data.soluong,
            "trangthai": data.trangthai,
            "daxoa": data.daxoa
        ]) { err in
            completion(err)
        }
    }
    
    static func confirmExportBill(data: PhieuXuat, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("PhieuXuat").document(data.idphieuxuat).updateData([
            "idnhanvienxuatphieu": App.shared.staffInfo?.idnhanvien ?? "",
            "trangthai": 1,
        ]) { err in
            completion(err)
        }
    }
    
    static func deleteExportBill(data: PhieuXuat, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("PhieuXuat").document(data.idphieuxuat).updateData([
            
            "daxoa": 1
        ]) { err in
            completion(err)
        }
    }
}

extension PhieuXuat: Mappable {
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        idphieuxuat <- map["idphieuxuat"]
        idnhanvientaophieu <- map["idnhanvientaophieu"]
        idnhanvienxuatphieu <- map["idnhanvienxuatphieu"]
        var timestamp: Timestamp?
        timestamp <- map["ngaytao"]
        ngaytao = timestamp?.dateValue().getDateFormatted() ?? Date()
        idphieunhap <- map["idphieunhap"]
        soluong <- map["soluong"]
        trangthai <- map["trangthai"]
        daxoa <- map["daxoa"]
    }
}
