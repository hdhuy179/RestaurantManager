//
//  PhieuNhap.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 6/19/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//
import ObjectMapper

struct PhieuNhap: Decodable {
    var idphieunhap: String! = UUID().uuidString
    var idnhanvien: String = ""
    var maphieu: String = ""
    var ngaytao: Date?
    var quahan: Int = 0
    var soluong: Float = 0
    var donvi: String = ""
    var tenvatpham: String = ""
    var daxoa: Int = 0
    
    var creatorStaff: NhanVien?
    
    static func getAllReferanceData(of snapshot: QuerySnapshot, completion: @escaping ([PhieuNhap]?, Error?) -> Void) {
        var bills = [PhieuNhap]()
        snapshot.documents.forEach({ (document) in
            if var hoadon = PhieuNhap(JSON: document.data()) {
                
                NhanVien.fetchData(forID: hoadon.idnhanvien) { (staff, error) in
                    hoadon.creatorStaff = staff
                    bills.append(hoadon)
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
    
    static func fetchAllDataAvailable(completion: @escaping ([PhieuNhap]?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("PhieuNhap").whereField("daxoa", isEqualTo: 0).order(by: "ngaytao").getDocuments { (snapshot, err) in
            if err != nil {
                
                //                print("Error getting BanAn Data: \(err!.localizedDescription)")
                completion(nil, err)
                
            } else if let snapshot = snapshot, !snapshot.documents.isEmpty {
                
                getAllReferanceData(of: snapshot, completion: completion)
            } else {
                completion([], nil)
            }
        }
    }
    
    static func fetchAllData(completion: @escaping ([PhieuNhap]?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("PhieuNhap").order(by: "ngaytao").getDocuments { (snapshot, err) in
            if err != nil {
                
                //                print("Error getting BanAn Data: \(err!.localizedDescription)")
                completion(nil, err)
                
            } else if let snapshot = snapshot, !snapshot.documents.isEmpty {
                
                getAllReferanceData(of: snapshot, completion: completion)
            } else {
                completion([], nil)
            }
        }
    }
    
    static func deleteExportBill(data: PhieuNhap, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("PhieuNhap").document(data.idphieunhap).updateData([
            
            "daxoa": 1
        ]) { err in
            completion(err)
        }
    }
}

extension PhieuNhap: Hashable {
    static func == (lhs: PhieuNhap, rhs: PhieuNhap) -> Bool {
        return lhs.idphieunhap == rhs.idphieunhap
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(idphieunhap)
    }
}

extension PhieuNhap: Mappable {
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        idphieunhap <- map["idphieunhap"]
        idnhanvien <- map["idnhanvien"]
        maphieu <- map["maphieu"]
        var timestamp: Timestamp?
        timestamp <- map["ngaytao"]
        ngaytao = timestamp?.dateValue().getDateFormatted() ?? Date()
        quahan <- map["quahan"]
        soluong <- map["soluong"]
        donvi <- map["donvi"]
        tenvatpham <- map["tenvatpham"]
        daxoa <- map["daxoa"]
    }
    
}
