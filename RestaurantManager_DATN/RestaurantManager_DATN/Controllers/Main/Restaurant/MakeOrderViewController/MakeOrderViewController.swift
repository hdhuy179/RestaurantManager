//
//  MakeOrderViewController.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 2/8/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import UIKit

protocol OrderViewControllerDelegate: class {
    var table: BanAn? { get set }
    func changeOrderAmount(dish: MonAn, amount: Int)
}

enum CartState {
    case expended
    case collapsed
}

class MakeOrderViewController: UIViewController {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var dishTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var bottomConstraintDishTableView: NSLayoutConstraint!
    @IBOutlet weak var topConstantTableView: NSLayoutConstraint!
    
    private struct tableViewProperties {
        static let headerNibName = "DishHeaderTableViewCell"
        static let headerID = "DishHeaderTableViewCell"
        static let headerHeight: CGFloat = 50.0
        
        static let rowNibName = "DishTableViewCell"
        static let rowID = "DishTableViewCell"
        static let rowHeight: CGFloat = 100.0
    }
    
    weak var delegate: RestaurantViewController?
    
    var table: BanAn?
    var dishData: [[MonAn]] = []
    var currentDishData: [[MonAn]] = []
    var dishCategoryData: [TheLoaiMonAn] = []
    
    var cartVisible = false
    
    var nextState: CartState {
        return cartVisible ? .collapsed : .expended
    }
    
    var cartViewController: CartViewController!
    var visualEffectView: UIVisualEffectView!
    
    var startCartHeight: CGFloat = 0
    var endCartHeight: CGFloat = 0
    
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupViews()
        setupCart()
        fetchData()
    }
    
    deinit {
        logger()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let present = presentingViewController as? TableBillDetailViewController {
            present.fetchBillData()
        }
        delegate?.fetchData()
    }
    
    private func setupViews() {
        if let sobanan = table?.sobanan {
            lbTitle.text = "Bàn " + sobanan
        }
        
        searchBar.showsCancelButton = true
        searchBar.delegate = self
        
        dishTableView.dataSource = self
        dishTableView.delegate = self
        
        dishTableView.register(UINib(nibName: tableViewProperties.headerNibName, bundle: nil), forCellReuseIdentifier: tableViewProperties.headerID)
        dishTableView.register(UINib(nibName: tableViewProperties.rowNibName, bundle: nil), forCellReuseIdentifier: tableViewProperties.rowID)
    }
    
    @IBAction func btnSearchTapped(_ sender: Any) {
        searchBar.becomeFirstResponder()
        topConstantTableView.constant = 53
    }
    
    func setupCart() {
        endCartHeight = self.view.frame.height * 0.8
        
        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = self.view.frame
        self.view.addSubview(visualEffectView)
        
        if !cartVisible {
            visualEffectView.isHidden = true
        }
        
        cartViewController = CartViewController(nibName: "CartViewController", bundle: nil)
        cartViewController.delegate = self
        
        self.addChild(cartViewController)
        self.view.addSubview(cartViewController.view)
        
        cartViewController.view.frame.size.width = self.view.frame.width
        cartViewController.view.frame.size.height = endCartHeight
    
        startCartHeight = cartViewController.handleArea.frame.height +
            (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
        
        cartViewController.view.frame.origin.x = 0
        cartViewController.view.frame.origin.y = self.view.frame.height - startCartHeight
        cartViewController.view.clipsToBounds = true

        cartViewController.view.isHidden = true
        cartViewController.cartTableView.isHidden = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleCartTap))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleCartPan))
        
        cartViewController.handleArea.addGestureRecognizer(tapGestureRecognizer)
        cartViewController.handleArea.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func handleCartTap(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            animateTransitionIfNeeded(state: nextState, duration: 0.8)
        default:
            return
        }
    }
    
    @objc func handleCartPan(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            startInteractiveTransition(state: nextState, duration: 0.5)
        case .changed:
            let translation = recognizer.translation(in: self.cartViewController.handleArea)
            var fractionComplete = translation.y / endCartHeight
            fractionComplete = cartVisible ? fractionComplete : -fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            continueInteractiveTransition()
        default:
            break
        }
    }
    
    func animateTransitionIfNeeded(state: CartState, duration: TimeInterval) {
            if runningAnimations.isEmpty {
                let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                    switch state {
                    case .expended:
                        self.cartViewController.view.frame.origin.y = self.view.frame.height - self.endCartHeight
                        self.visualEffectView.effect = UIBlurEffect(style: .light)
                        self.visualEffectView.isHidden = false
                        self.cartViewController.cartTableView.isHidden = false
                    case .collapsed:
                        self.cartViewController.view.frame.origin.y = self.view.frame.height - self.startCartHeight
                        self.visualEffectView.effect = nil
                    }
                }
                
                frameAnimator.addCompletion { _ in
                    self.cartVisible = !self.cartVisible
                    self.runningAnimations.removeAll()
                    if !self.cartVisible {
                        self.visualEffectView.isHidden = true
                        self.cartViewController.cartTableView.isHidden = true
                    }
                }
                
                frameAnimator.startAnimation()
                
                runningAnimations.append(frameAnimator)
                
    //            let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
    //                switch state {
    //                case .expended:
    //                    self.cartViewController.view.layer.cornerRadius = 12
    //                case .collapsed:
    //                    self.cartViewController.view.layer.cornerRadius = 0
    //                }
    //            }
    //
    //            cornerRadiusAnimator.startAnimation()
    //
    //            runningAnimations.append(cornerRadiusAnimator)
            }
        }
            
        func startInteractiveTransition(state: CartState, duration: TimeInterval) {
            if runningAnimations.isEmpty {
                animateTransitionIfNeeded(state: state, duration: duration)
            }
            
            for animator in runningAnimations {
                animator.pauseAnimation()
                animationProgressWhenInterrupted = animator.fractionComplete
            }
        }
        
        func updateInteractiveTransition(fractionCompleted: CGFloat) {
            for animator in runningAnimations {
                animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
            }
        }
        
        func continueInteractiveTransition() {
            for animator in runningAnimations {
                animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            }
        }
    
    func fetchData() {
        var counter = 0
        let maxCounter = 2
        MonAn.fetchMenuData { [weak self](data, error) in
            if error != nil {
                
            } else if let data = data {
                self?.dishData = [data]
                counter += 1
                if counter == maxCounter {
                    self?.setupData()
                }
            }
        }
        TheLoaiMonAn.fetchAllDataAvailable{ [weak self](data, error) in
            if error != nil {
                
            } else if let data = data {
                self?.dishCategoryData = data
                counter += 1
                if counter == maxCounter {
                    self?.setupData()
                }
            }
        }
        if table?.bill == nil {
            table?.bill = HoaDon()
        }
        table?.bill?.orderList = []
    }
    
    func setupData() {
        if !self.dishData.isEmpty, !self.dishCategoryData.isEmpty {
            let dishDataEmp = self.dishData[0]
            dishData.removeAll()
            for (index, dishCategory) in dishCategoryData.enumerated() {
                dishData.append([])
                for dish in dishDataEmp {
                    if dish.idtheloaimonan == dishCategory.idtheloaimonan {
                        dishData[index].append(dish)
                    }
                }
            }
        }
        currentDishData = dishData
        if table?.bill != nil {
            cartViewController.bill = table?.bill
//            cartViewController.view.isHidden = false
        }
        dishTableView.reloadData()
    }

    @IBAction func btnBackWasTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension MakeOrderViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dishCategoryData.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentDishData[section].count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if currentDishData[section].isEmpty == true {
            return nil
        }
        guard let headerCell = tableView.dequeueReusableCell(withIdentifier: tableViewProperties.headerID) as? DishHeaderViewCell else {
            fatalError("MakeOrderViewController: Can't dequeue for DishHeaderViewCell")
        }
        headerCell.dishCategoryLabel.text = dishCategoryData[section].tentheloaimonan
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: tableViewProperties.rowID, for: indexPath) as? DishTableViewCell else {
            fatalError("MakeOrderViewController: Can't dequeue for DishTableViewCell")
        }
        var amount = 0
        for order in table?.bill?.orderList ?? [] {
            if order.idmonan == currentDishData[indexPath.section][indexPath.item].idmonan {
                amount = order.soluong
            }
        }
        cell.configView(data: currentDishData[indexPath.section][indexPath.item], amount: amount)
        cell.delegate = self
        return cell
    }
    
    
}

extension MakeOrderViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewProperties.rowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if currentDishData[section].isEmpty == true {
            return 0
        }
        return tableViewProperties.headerHeight
    }
}

extension MakeOrderViewController: OrderViewControllerDelegate {
    func changeOrderAmount(dish: MonAn, amount: Int) {
        table?.bill?.updateOrderList(withDish: dish, amount: amount)
        cartViewController.bill = table?.bill
        if let _ = table?.bill?.orderList {
            if table!.bill!.orderList!.isEmpty {
                animateTransitionIfNeeded(state: .collapsed, duration: 0)
                cartViewController.view.isHidden = true
                bottomConstraintDishTableView.constant = 0
            } else {
                cartViewController.view.isHidden = false
                bottomConstraintDishTableView.constant = cartViewController.handleArea.frame.height
            }
        }
        dishTableView.reloadData()
    }
}

extension MakeOrderViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        topConstantTableView.constant = 0
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty == true {
            currentDishData = dishData
            dishTableView.reloadData()
            return
        }
        let searchText = searchText.lowercased()
        let dishCategoryList = dishCategoryData.filter({ $0.tentheloaimonan.lowercased().contains(searchText)})
        currentDishData.removeAll()
        for list in dishData {
            let result = list.filter({
                let currentItem = $0
                return ($0.tenmonan.lowercased().contains(searchText) || dishCategoryList.filter({ $0.idtheloaimonan == currentItem.idtheloaimonan }).isEmpty == false) })
            currentDishData.append(result)
        }
        
        dishTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
