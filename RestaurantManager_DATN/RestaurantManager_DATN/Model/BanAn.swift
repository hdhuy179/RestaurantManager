//
//  BanAn.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 5/17/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//
import ObjectMapper

struct BanAn: Decodable {
    
    var idbanan: String! = UUID().uuidString
    var sobanan: String? = ""
    var soluongghe: Int? = -1
    var daxoa: Int? = 0
    
    var bill: HoaDon?
    
    static func fetchAllDataAvailable(completion: @escaping ([BanAn]?, Error?) -> Void) {
        var banans = [BanAn]()
        let db = Firestore.firestore()

        db.collection("BanAn").whereField("daxoa", isEqualTo: 0).order(by: "sobanan").getDocuments { (snapshot, err) in
            if err != nil {
                
                print("Error getting BanAn Data: \(err!.localizedDescription)")
                completion(nil, err)
                
            } else if snapshot != nil, !snapshot!.documents.isEmpty {
                
                snapshot!.documents.forEach({ (document) in
                    if let banan = BanAn(JSON: document.data()) {
                        banans.append(banan)
                    }
                })
                completion(banans, nil)
            } else {
                completion(banans, nil)
            }
        }
    }
    
    static func fetchAllData(completion: @escaping ([BanAn]?, Error?) -> Void) {
        var banans = [BanAn]()
        let db = Firestore.firestore()

        db.collection("BanAn").order(by: "sobanan").getDocuments { (snapshot, err) in
            if err != nil {
                
                print("Error getting BanAn Data: \(err!.localizedDescription)")
                completion(nil, err)
                
            } else if snapshot != nil, !snapshot!.documents.isEmpty {
                
                snapshot!.documents.forEach({ (document) in
                    if let banan = BanAn(JSON: document.data()) {
                        banans.append(banan)
                    }
                })
                completion(banans, nil)
            } else {
                completion(banans, nil)
            }
        }
    }
    
    static func fetchData(ofID id: String, completion: @escaping (BanAn?, Error?) -> Void) {
        if id == "" {
            completion(nil,nil)
            return
        }
        var banan: BanAn?
        let db = Firestore.firestore()

        db.collection("BanAn").document(id).getDocument { (snapshot, err) in
            if err != nil {
                
                print("Error getting BanAn Data: \(err!.localizedDescription)")
                completion(nil, err)
                
            } else if snapshot != nil, snapshot?.data() != nil {
                
                banan = BanAn(JSON: snapshot!.data()!)
                completion(banan, nil)
                
            } else {
                completion(banan, nil)
            }
        }
    }
}

extension BanAn: Hashable {
    static func == (lhs: BanAn, rhs: BanAn) -> Bool {
        return lhs.idbanan == rhs.idbanan
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(idbanan)
    }
}

extension BanAn: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        idbanan <- map["idbanan"]
        sobanan <- map["sobanan"]
        soluongghe <- map["soluongghe"]
        daxoa <- map["daxoa"]
    }
}
