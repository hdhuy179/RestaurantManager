//
//  MonAn.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 5/17/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import ObjectMapper

struct MonAn: Decodable {
    
    var idmonan: String! = UUID().uuidString
    var tenmonan: String = ""
    var donvimonan: String = ""
    var dongia: Double = 0
    var motachitiet: String = ""
    var diachianh: String = ""
    var idtheloaimonan: String = ""
    var trongthucdon: Int = -1
    var daxoa: Int = 0
    
    static func fetchMenuData(completion: @escaping ([MonAn]?, Error?) -> Void) {
        let db = Firestore.firestore()
        var datas = [MonAn]()

        db.collection("MonAn").whereField("daxoa", isEqualTo: 0).whereField("trongthucdon", isEqualTo: 1).order(by: "tenmonan").getDocuments { (snapshot, err) in
            if err != nil {
                
                print("Error getting BanAn Data: \(err!.localizedDescription)")
                completion(nil, err)
                
            } else if let snapshot = snapshot, !snapshot.documents.isEmpty {
                
                snapshot.documents.forEach({ (document) in
                    if let data = MonAn(JSON: document.data()) {
                        datas.append(data)
                    }
                })
                completion(datas, nil)
            } else {
                completion(datas, nil)
            }
        }
    }
    
    static func fetchAllDataAvailable(completion: @escaping ([MonAn]?, Error?) -> Void) {
        let db = Firestore.firestore()
        var datas = [MonAn]()

        db.collection("MonAn").whereField("daxoa", isEqualTo: 0).order(by: "tenmonan").getDocuments { (snapshot, err) in
            if err != nil {
                
                print("Error getting BanAn Data: \(err!.localizedDescription)")
                completion(nil, err)
                
            } else if let snapshot = snapshot, !snapshot.documents.isEmpty {
                
                snapshot.documents.forEach({ (document) in
                    if let data = MonAn(JSON: document.data()) {
                        datas.append(data)
                    }
                })
                completion(datas, nil)
            } else {
                completion(datas, nil)
            }
        }
    }
    
    static func fetchAllData(completion: @escaping ([MonAn]?, Error?) -> Void) {
        let db = Firestore.firestore()
        var datas = [MonAn]()

        db.collection("MonAn").order(by: "tenmonan").getDocuments { (snapshot, err) in
            if err != nil {
                
                print("Error getting BanAn Data: \(err!.localizedDescription)")
                completion(nil, err)
                
            } else if let snapshot = snapshot, !snapshot.documents.isEmpty {
                
                snapshot.documents.forEach({ (document) in
                    if let data = MonAn(JSON: document.data()) {
                        datas.append(data)
                    }
                })
                completion(datas, nil)
            } else {
                completion(datas, nil)
            }
        }
    }
    
    static func fetchData(byOrder order: Order, completion: @escaping (MonAn?, Error?) -> Void) {
        let db = Firestore.firestore()
        guard let idmonan = order.idmonan else {
            return
        }
        db.collection("MonAn").document(idmonan).getDocument { (snapshot, err) in
            if err != nil {
                
                print("Error getting BanAn Data: \(err!.localizedDescription)")
                completion(nil, err)
                
            } else if let data = snapshot?.data() {
                
                let dish = MonAn(JSON: data)

                completion(dish, nil)
            } else {
                completion(MonAn(), nil)
            }
        }
    }
    
    func updateInMenu(forDish dish: MonAn, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()

        db.collection("MonAn").document(dish.idmonan).updateData([
            "trongthucdon": dish.trongthucdon,
        ]) { err in
            completion(err)
        }
        completion(nil)
    }
}

extension MonAn: Hashable {
    static func == (lhs: MonAn, rhs: MonAn) -> Bool {
        return lhs.idmonan == rhs.idmonan
    }
}

extension MonAn: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        idmonan <- map["idmonan"]
        tenmonan <- map["tenmonan"]
        donvimonan <- map["donvimonan"]
        dongia <- map["dongia"]
        motachitiet <- map["motachitiet"]
        diachianh <- map["diachianh"]
        idtheloaimonan <- map["idtheloaimonan"]
        trongthucdon <- map["trongthucdon"]
        daxoa <- map["daxoa"]
    }
}
