//
//  BaoCao.swift
//  RestaurantManager_DATN
//
//  Created by HuyHoangDinh on 7/17/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import Foundation
import ObjectMapper

struct BaoCao: Decodable {
    var idbaocao: String! = UUID().uuidString
    var idnhanvien: String = ""
    var tieude: String = ""
    var noidung: String = ""
    var ngaytao: Date?
    var loaibaocao: Int = 0
    var daxoa: Int = 0
    
    var staff: NhanVien?
    
    static func getAllReferanceData(of snapshot: QuerySnapshot, completion: @escaping ([BaoCao]?, Error?) -> Void) {
        
        var reports = [BaoCao]()
        
        snapshot.documents.forEach({ (document) in
            if var baocao = BaoCao(JSON: document.data()) {
                
                NhanVien.fetchData(forID: baocao.idnhanvien) { (staff, error) in
                    baocao.staff = staff
                    reports.append(baocao)
                    if reports.count == snapshot.documents.count {
                        completion(reports, nil)
                    }
                }
            }
        })
    }
    
    static func fetchAllData(completion: @escaping ([BaoCao]?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("BaoCao").order(by: "ngaytao").getDocuments { (snapshot, err) in
            if err != nil {
                
                completion(nil, err)
                
            } else if let snapshot = snapshot, !snapshot.documents.isEmpty {
                
                getAllReferanceData(of: snapshot, completion: completion)
            } else {
                completion([], nil)
            }
        }
    }
    
    static func saveReport(data: BaoCao ,completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("BaoCao").document(data.idbaocao).setData([
            "idbaocao": data.idbaocao,
            "idnhanvien": data.idnhanvien,
            "loaibaocao": data.loaibaocao,
            "ngaytao": data.ngaytao,
            "tieude": data.tieude,
            "noidung": data.noidung,
            "daxoa": data.daxoa
        ]) { err in
            completion(err)
        }
    }
}

extension BaoCao: Mappable {
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        idbaocao <- map["idbaocao"]
        idnhanvien <- map["idnhanvien"]
        tieude <- map["tieude"]
        var timestamp: Timestamp?
        timestamp <- map["ngaytao"]
        ngaytao = timestamp?.dateValue().getDateFormatted() ?? Date()
        noidung <- map["noidung"]
        loaibaocao <- map["loaibaocao"]
        daxoa <- map["daxoa"]
    }
}
