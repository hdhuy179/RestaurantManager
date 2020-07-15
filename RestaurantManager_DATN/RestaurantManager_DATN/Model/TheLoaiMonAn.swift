//
//  TheLoaiMonAn.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 5/17/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//
import ObjectMapper

struct TheLoaiMonAn: Decodable {
    
    var idtheloaimonan: String! = UUID().uuidString
    var tentheloaimonan: String = ""
    var daxoa: Int = 0
    
    static func fetchAllDataAvailable(completion: @escaping ([TheLoaiMonAn]?, Error?) -> Void) {
        var datas = [TheLoaiMonAn]()
        let db = Firestore.firestore()

        db.collection("TheLoaiMonAn").whereField("daxoa", isEqualTo: 0).order(by: "tentheloaimonan").getDocuments { (snapshot, err) in
            if err != nil {
                
                print("Error getting BanAn Data: \(err!.localizedDescription)")
                completion(nil, err)
                
            } else if let snapshot = snapshot, !snapshot.documents.isEmpty {
                
                snapshot.documents.forEach({ (document) in
                    if let data = TheLoaiMonAn(JSON: document.data()) {
                        datas.append(data)
                    }
                })
                completion(datas, nil)
            } else {
                completion(datas, nil)
            }
        }
    }
    
    static func fetchAllData(completion: @escaping ([TheLoaiMonAn]?, Error?) -> Void) {
        var datas = [TheLoaiMonAn]()
        let db = Firestore.firestore()

        db.collection("TheLoaiMonAn").order(by: "tentheloaimonan").getDocuments { (snapshot, err) in
            if err != nil {
                
                print("Error getting BanAn Data: \(err!.localizedDescription)")
                completion(nil, err)
                
            } else if let snapshot = snapshot, !snapshot.documents.isEmpty {
                
                snapshot.documents.forEach({ (document) in
                    if let data = TheLoaiMonAn(JSON: document.data()) {
                        datas.append(data)
                    }
                })
                completion(datas, nil)
            } else {
                completion(datas, nil)
            }
        }
    }
    
    static func fetchData(forID id: String, completion: @escaping (TheLoaiMonAn?, Error?) -> Void) {
        if id == "" {
            completion(nil,nil)
            return
        }
        var category = TheLoaiMonAn()
        let db = Firestore.firestore()

        db.collection("TheLoaiMonAn").document(id).getDocument { (snapshot, err) in
            if err != nil {
                
                print("Error getting BanAn Data: \(err!.localizedDescription)")
                completion(nil, err)
                
            } else if let data = snapshot?.data() {
                
                if let data = TheLoaiMonAn(JSON: data) {
                    category = data
                }
                completion(category, nil)
            } else {
                completion(nil, nil)
            }
        }
    }
}

extension TheLoaiMonAn: Hashable {
    static func == (lhs: TheLoaiMonAn, rhs: TheLoaiMonAn) -> Bool {
        return lhs.idtheloaimonan == rhs.idtheloaimonan
    }
}

extension TheLoaiMonAn: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        idtheloaimonan <- map["idtheloaimonan"]
        tentheloaimonan <- map["tentheloaimonan"]
        daxoa <- map["daxoa"]
    }
    
    
}
