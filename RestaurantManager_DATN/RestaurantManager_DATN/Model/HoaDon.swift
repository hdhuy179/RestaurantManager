//
//  HoaDon.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 5/17/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import ObjectMapper

struct HoaDon: Decodable {
    
    var idhoadon: String! = UUID().uuidString
    var dathanhtoan: Int? = 0
    //    var listidorder: [String]? =
    var idbanan: String? = ""
    var idnhanvien: String? = ""
    var ngaytao: Date = Date()
    var daxoa: Int? = 0
    
    var orderList: [Order]?
    var staff: NhanVien?
    
    func isBillServed() -> Bool? {
        if let orderList = orderList {
            for order in orderList {
                if order.trangthai < 0 || order.trangthai < 3 {
                    return false
                }
            }
            return true
        }
        return nil
    }
    
    func getTotalPayment() -> Double {
        var totalPayment = 0.0
        if let orderList = orderList {
            orderList.forEach({ (order) in
                if let price = order.dish?.dongia, order.soluong > 0 {
                    totalPayment += price * Double(order.soluong)
                }
            })
        }
        return totalPayment
    }
    
    static func getAllReferanceData(of snapshot: QuerySnapshot, completion: @escaping ([HoaDon]?, Error?) -> Void) {
        var bills = [HoaDon]()
        snapshot.documents.forEach({ (document) in
            if var hoadon = HoaDon(JSON: document.data()) {
                var orderLoaded = false
                var staffLoaded = false
                Order.fetchAllData(ofBill: hoadon) { (datas, error) in
                    if let orders = datas {
                        hoadon.orderList = orders
                    }
                    orderLoaded = true
                    if staffLoaded {
                        bills.append(hoadon)
                    }
                    if bills.count == snapshot.documents.count {
                        completion(bills, nil)
                    }
                    
                    if error != nil {
                        completion(nil, error)
                    }
                }
                if let idnv = hoadon.idnhanvien {
                    NhanVien.fetchData(forID: idnv) { (staff, error) in
                        hoadon.staff = staff
                        staffLoaded = true
                        if orderLoaded {
                            bills.append(hoadon)
                        }
                        if bills.count == snapshot.documents.count {
                            completion(bills, nil)
                        }
                        if error != nil {
                            completion(nil, error)
                        }
                    }
                } else {
                    staffLoaded = true
                    if orderLoaded {
                        bills.append(hoadon)
                    }
                    if bills.count == snapshot.documents.count {
                        completion(bills, nil)
                    }
                }
            }
        })
    }
    
    static func fetchAllDataAvailable(completion: @escaping ([HoaDon]?, Error?) -> Void) {
        let db = Firestore.firestore()
        db.collection("HoaDon").whereField("daxoa", isEqualTo: 0).order(by: "ngaytao").getDocuments { (snapshot, err) in
            if err != nil {
                
                print("Error getting HoaDon Data: \(err!.localizedDescription)")
                completion(nil, err)
                
            } else if snapshot != nil, !snapshot!.documents.isEmpty {
                getAllReferanceData(of: snapshot!) { (bills, error) in
                    let bills2 = bills?.sorted {
                        return $0.ngaytao.timeIntervalSince1970 > $1.ngaytao.timeIntervalSince1970
                    }
                    completion(bills2, error)
                }
            } else {
                completion([], nil)
            }
        }
    }
    
    static func fetchAllData(completion: @escaping ([HoaDon]?, Error?) -> Void) {
        let db = Firestore.firestore()
        db.collection("HoaDon").order(by: "ngaytao").getDocuments { (snapshot, err) in
            if err != nil {
                
                print("Error getting HoaDon Data: \(err!.localizedDescription)")
                completion(nil, err)
                
            } else if snapshot != nil, !snapshot!.documents.isEmpty {
                getAllReferanceData(of: snapshot!) { (bills, error) in
                    let bills2 = bills?.sorted {
                        return $0.ngaytao.timeIntervalSince1970 > $1.ngaytao.timeIntervalSince1970
                    }
                    completion(bills2, error)
                }
            } else {
                completion([], nil)
            }
        }
    }
    
    static func fetchTodayBill(completion: @escaping ([HoaDon]?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: Date())
        let start = calendar.date(from: components)!
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        
        db.collection("HoaDon").whereField("daxoa", isEqualTo: 0).whereField("ngaytao", isLessThan: end).whereField("ngaytao", isGreaterThan: start).order(by: "ngaytao").getDocuments { (snapshot, err) in
            if err != nil {
                
                print("Error getting HoaDon Data: \(err!.localizedDescription)")
                completion(nil, err)
                
            } else if snapshot != nil, !snapshot!.documents.isEmpty {
                
                getAllReferanceData(of: snapshot!) { (bills, error) in
                    completion(bills, error)
                }
            } else {
                completion([], nil)
            }
        }
    }
    
    static func fetchUnpaidBill(completion: @escaping ([HoaDon]?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("HoaDon").whereField("daxoa", isEqualTo: 0).whereField("dathanhtoan", isEqualTo: 0).order(by: "ngaytao").getDocuments { (snapshot, err) in
            if err != nil {
                
                print("Error getting HoaDon Data: \(err!.localizedDescription)")
                completion(nil, err)
                
            } else if snapshot != nil, !snapshot!.documents.isEmpty {
                
                getAllReferanceData(of: snapshot!) { (bills, error) in
                    completion(bills, error)
                }
            } else {
                completion([], nil)
            }
        }
    }
    
    static func fetchData(ofBillID id: String, completion: @escaping (HoaDon?, Error?) -> Void) {
        if id == "" {
            completion(nil,nil)
            return
        }
        let db = Firestore.firestore()
        
        db.collection("HoaDon").document(id).getDocument { (snapshot, err) in
            if err != nil {
                
                print("Error getting HoaDon Data: \(err!.localizedDescription)")
                completion(nil, err)
                
            } else if let data = snapshot?.data() {
                
                if var hoadon = HoaDon(JSON: data) {
                    Order.fetchAllData(ofBill: hoadon) { (datas, error) in
                        if let orders = datas {
                            hoadon.orderList = orders
                        }
                        
                        completion(hoadon, nil)
                    }
                }
            } else {
                completion(nil, nil)
            }
        }
    }
    
    mutating func updateOrderList(withDish dish: MonAn, amount: Int) {
        if let _ = orderList {
            for (index, order) in orderList!.enumerated() {
                if order.dish == dish {
                    if orderList![index].soluong >= 0{
                        if amount == 0 {
                            orderList!.remove(at: index)
                            return
                        }
                        orderList![index].soluong = amount
                        return
                    }
                }
            }
            let order = Order(idhoadon: idhoadon, soluong: amount, trangthai: 0, idmonan: dish.idmonan, daxoa: 0, dish: dish)
            orderList!.append(order)
            return
        }
        orderList = [Order]()
        let order = Order(idhoadon: idhoadon, soluong: amount, trangthai: 0, idmonan: dish.idmonan, daxoa: 0, dish: dish)
        orderList!.append(order)
    }
    
    static func checkOutBill(forTable table: BanAn, completion: @escaping ( Error?) -> Void) {
        let db = Firestore.firestore()
        
        if let _ = table.bill, let _ = table.bill?.idhoadon, let _ = table.idbanan, let _ = table.bill?.dathanhtoan, let _ = table.bill?.daxoa {
            db.collection("HoaDon").document(table.bill!.idhoadon!).setData(["idhoadon": table.bill!.idhoadon!, "idbanan": table.idbanan!, "dathanhtoan": table.bill!.dathanhtoan!,  "ngaytao": table.bill!.ngaytao,"idnhanvien": table.bill?.idnhanvien ?? "", "daxoa": 0]) { err in
                if err != nil {
                    completion(err)
                } else {
                    print("BillModel: Checkout Bill \(table.bill!.idhoadon!) successful")
                }
            }
            table.bill!.orderList!.forEach({ order in
                order.makeOrder(forOrder: order) { (err) in
                    if err != nil {
                        print(err ?? "")
                    }
                    if order == table.bill!.orderList!.last {
                        completion(nil)
                    }
                }
            })
        }
    }
    
    static func updateBill(forBill bill: HoaDon, completion: @escaping ( Error?) -> Void) {
        let db = Firestore.firestore()
        
        if let _ = bill.idhoadon, let _ = bill.idbanan, let _ = bill.dathanhtoan, let _ = bill.daxoa, let uid = App.shared.staffInfo?.idnhanvien {
            db.collection("HoaDon").document(bill.idhoadon!).setData(["idhoadon": bill.idhoadon!, "idbanan": bill.idbanan!, "dathanhtoan": bill.dathanhtoan!,  "ngaytao": bill.ngaytao, "daxoa": bill.daxoa!, "idnhanvien": uid]) { err in
                if err != nil {
                    completion(err)
                } else {
                    print("BillModel: Checkout Bill \(bill.idhoadon!) successful")
                }
            }
            bill.orderList!.forEach({ order in
                order.updateOrder(forOrder: order) { (err) in
                    if err != nil {
                        print(err ?? "")
                    }
                }
                if order == bill.orderList!.last {
                    completion(nil)
                }
            })
        }
    }
}

extension HoaDon: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        idhoadon <- map["idhoadon"]
        dathanhtoan <- map["dathanhtoan"]
        //        listidorder <- map["listidorder"]
        idbanan <- map["idbanan"]
        idnhanvien <- map["idnhanvien"]
        var timestamp: Timestamp?
        timestamp <- map["ngaytao"]
        ngaytao = timestamp?.dateValue().getDateFormatted() ?? Date()
        daxoa <- map["daxoa"]
    }
}
