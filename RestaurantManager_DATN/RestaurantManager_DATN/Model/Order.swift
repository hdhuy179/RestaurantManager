//
//  Order.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 5/17/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import ObjectMapper

struct Order: Decodable {
    
    var idorder: String! = UUID().uuidString
    var idhoadon: String? = ""
    var soluong: Int = 1
    var trangthai: Int = 0
    var idmonan: String? = ""
    var ngaytao: Date?
    var daxoa: Int? = 0
    
    var dish: MonAn?
    
    func getState(forNextState: Bool = false) -> String {
        var trangthai = self.trangthai
        if forNextState {
            trangthai += 1
        }
        switch trangthai {
        case 0:
            return "Đang chờ"
        case 1:
            return "Đang nấu"
        case 2:
            return "Đã nấu"
        case 3:
            return "Hoàn thành"
        default:
            return "nil"
        }
    }
    
    static func fetchAllDataAvailable(ofBill bill: HoaDon ,
                             completion: @escaping ([Order]?, Error?) -> Void) {
        
        var datas = [Order]()
        let db = Firestore.firestore()
        
        db.collection("Order").whereField("daxoa", isEqualTo: 0).whereField("idhoadon", isEqualTo: bill.idhoadon!).getDocuments { (snapshot, err) in
            if err != nil {
                
                print("Error getting HoaDon Data: \(err!.localizedDescription)")
                completion(nil, err)
                
            } else if snapshot != nil, !snapshot!.documents.isEmpty {
                
                snapshot!.documents.forEach({ (document) in
                    if var order = Order(JSON: document.data()) {
                        MonAn.fetchData(byOrder: order) { (dish, error) in
                            if let dish = dish {
                                order.dish = dish
                            }
                            datas.append(order)
                            if datas.count == snapshot?.documents.count {
                                completion(datas, nil)
                            }
                        }
                    }
                })
                
            } else {
                completion(datas, nil)
            }
        }
    }
    
    static func fetchAllData(ofBill bill: HoaDon ,
                             completion: @escaping ([Order]?, Error?) -> Void) {
        
        var datas = [Order]()
        let db = Firestore.firestore()
        
        db.collection("Order").whereField("idhoadon", isEqualTo: bill.idhoadon!).getDocuments { (snapshot, err) in
            if err != nil {
                
                print("Error getting HoaDon Data: \(err!.localizedDescription)")
                completion(nil, err)
                
            } else if snapshot != nil, !snapshot!.documents.isEmpty {
                
                snapshot!.documents.forEach({ (document) in
                    if var order = Order(JSON: document.data()) {
                        MonAn.fetchData(byOrder: order) { (dish, error) in
                            if let dish = dish {
                                order.dish = dish
                            }
                            datas.append(order)
                            if datas.count == snapshot?.documents.count {
                                completion(datas, nil)
                            }
                        }
                    }
                })
                
            } else {
                completion(datas, nil)
            }
        }
    }
    
    static func fetchKitchenData(completion: @escaping ([Order]?, Error?) -> Void) {
        
        var datas = [Order]()
        let db = Firestore.firestore()
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: Date())
        let start = calendar.date(from: components)!
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        db.collection("Order").whereField("daxoa", isEqualTo: 0).whereField("ngaytao", isLessThan: end).whereField("ngaytao", isGreaterThan: start).order(by: "ngaytao").order(by: "trangthai").getDocuments { (snapshot, err) in
            if err != nil {
                
                print("Error getting HoaDon Data: \(err!.localizedDescription)")
                completion(nil, err)
                
            } else if snapshot != nil, !snapshot!.documents.isEmpty {
                
                snapshot!.documents.forEach({ (document) in
                    if var order = Order(JSON: document.data()) {
                        MonAn.fetchData(byOrder: order) { (dish, error) in
                            if let dish = dish {
                                order.dish = dish
                            }
                            datas.append(order)
                            if datas.count == snapshot?.documents.count {
                                completion(datas, nil)
                            }
                        }
                    }
                })
                
            } else {
                completion(datas, nil)
            }
        }
    }
    
    static func fetchData(from: Date, toDate: Date ,completion: @escaping ([Order]?, Error?) -> Void) {
        
        var datas = [Order]()
        let db = Firestore.firestore()
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: from)
        let start = calendar.date(from: components)!
        let toComponents = calendar.dateComponents([.year, .month, .day], from: calendar.date(byAdding: .day, value: 1, to: toDate)!)
        let end = calendar.date(from: toComponents)!
        
        db.collection("Order").whereField("daxoa", isEqualTo: 0).whereField("ngaytao", isLessThanOrEqualTo: end).whereField("ngaytao", isGreaterThan: start).order(by: "ngaytao").order(by: "trangthai").getDocuments { (snapshot, err) in
            if err != nil {
                
                print("Error getting HoaDon Data: \(err!.localizedDescription)")
                completion(nil, err)
                
            } else if snapshot != nil, !snapshot!.documents.isEmpty {
                
                snapshot!.documents.forEach({ (document) in
                    if var order = Order(JSON: document.data()) {
                        MonAn.fetchData(byOrder: order) { (dish, error) in
                            if let dish = dish {
                                order.dish = dish
                            }
                            datas.append(order)
                            if datas.count == snapshot?.documents.count {
                                completion(datas, nil)
                            }
                        }
                    }
                })
                
            } else {
                completion(datas, nil)
            }
        }
    }
    
    func makeOrder(forOrder order: Order, completion: @escaping ( Error?) -> Void) {
        let db = Firestore.firestore()
        if order.soluong <= 0 {
            db.collection("Order").document(order.idorder).delete { (error) in
                completion(error)
            }
            return
        }
        if let _ = order.idorder, let _ = order.dish?.idmonan, order.soluong > 0, let _ = order.idhoadon {
            db.collection("Order").document(order.idorder).setData(["idorder": order.idorder!, "idmonan": order.dish!.idmonan!, "soluong": order.soluong, "trangthai": order.trangthai, "idhoadon": order.idhoadon!, "ngaytao": order.ngaytao == nil ? Date() : order.ngaytao!, "daxoa": 0]) { err in
                if err != nil {
                    completion(err)
                } else {
                    completion(nil)
                    print("BillModel: made Order \(order.idorder!) successful")
                }
            }
        }
    }
    
    func updateOrder(forOrder order: Order, completion: @escaping ( Error?) -> Void) {
        let db = Firestore.firestore()
        if order.soluong <= 0, let _ = order.idorder {
            db.collection("Order").document(order.idorder).delete { (error) in
                completion(error)
            }
            
            return
        }
        if let _ = order.idorder, let _ = order.idmonan, order.soluong > 0, order.trangthai >= 0, let _ = order.idhoadon, let _ = order.daxoa, let _ = order.ngaytao {
            db.collection("Order").document(order.idorder).setData(["idorder": order.idorder!, "idmonan": order.idmonan!, "soluong": order.soluong, "trangthai": order.trangthai, "idhoadon": order.idhoadon!, "ngaytao": order.ngaytao!, "daxoa": order.daxoa!]) { err in
                if err != nil {
                    completion(err)
                } else {
                    print("BillModel: made Order \(order.idorder!) successful")
                }
                completion(nil)
            }
        }
    }
    
    func fetchAll(OfBill bill: HoaDon, completion: @escaping ([Order]?, Error?) -> Void) {
        
        var datas: [Order] = []
        
        let db = Firestore.firestore()
        
        db.collection("Order").whereField("idhoadon", isEqualTo: bill.idhoadon!).getDocuments { snapshot, err in
            
            if err != nil {
                
                print("Error getting order Data: \(err!.localizedDescription)")
                completion(nil, err)
                
            } else if snapshot != nil, !snapshot!.documents.isEmpty {
                
                snapshot!.documents.forEach({ (document) in
                    if var order = Order(JSON: document.data()) {
                        MonAn.fetchData(byOrder: order) { (dish, error) in
                            if let dish = dish {
                                order.dish = dish
                            }
                            datas.append(order)
                            if datas.count == snapshot?.documents.count {
                                completion(datas, nil)
                            }
                        }
                    }
                })
                
            } else {
                completion(datas, nil)
            }
        }
    }
}

extension Order: Hashable {
    static func == (lhs: Order, rhs: Order) -> Bool {
        return lhs.idorder == rhs.idorder
    }
}

extension Order: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        idorder <- map["idorder"]
        idmonan <- map["idmonan"]
        idhoadon <- map["idhoadon"]
        soluong <- map["soluong"]
        trangthai <- map["trangthai"]
        var timestamp: Timestamp?
        timestamp <- map["ngaytao"]
        ngaytao = timestamp?.dateValue().getDateFormatted()
        daxoa <- map["daxoa"]
    }
}
