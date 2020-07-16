//
//  TableViewCell.swift
//  Firebase_demo
//
//  Created by Hoang Dinh Huy on 10/18/19.
//  Copyright © 2019 Hoang Dinh Huy. All rights reserved.
//

import UIKit

enum TableState: Int {
    case empty, inUsed, waiting
}

final class TableCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imvTable: UIImageView!
    @IBOutlet weak var imvState: UIImageView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var vState: UIView!
    
    var state: TableState = .empty
    
    func configView(data: BanAn) {
        if let size = data.soluongghe, let number = data.sobanan {
            numberLabel.text = number
            sizeLabel.text = "\(size)"
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
//                //        setupHexagonImageView(imageView: imvTable,sides: 4)
//                if size <= 2 {
//                    return
//                }
//                self.setupHexagonImageView(imageView: self.imvTable,sides: size)
//                // Flip imageView vertical.
//                self.imvTable.transform = CGAffineTransform(scaleX: 1, y: -1)
//            }
        }
        switch state {
        case .empty:
//            stateLabel.text = "Trống"
//            stateLabel.backgroundColor =  UIColor.green
            imvState.image = nil
            vState.backgroundColor = .systemGreen
        case .waiting:
//            stateLabel.text = "Đang đợi món"
//            stateLabel.backgroundColor = UIColor.orange
            imvState.image = UIImage(named: "wait")
            imvState.tintColor = .systemYellow
            vState.backgroundColor = .systemYellow
        case .inUsed:
//            stateLabel.text = "Đang sử dụng"
//            stateLabel.backgroundColor = UIColor.yellow
            imvState.image = UIImage(named: "used")
            imvState.tintColor = .systemRed
            vState.backgroundColor = .systemRed
        }
        
    }
    
    func setupHexagonImageView(imageView: UIImageView, sides : Int) {
        let lineWidth: CGFloat = 5
        let path = self.roundedPolygonPath(rect: imageView.bounds, lineWidth: lineWidth, sides: sides, cornerRadius: 10, rotationOffset: CGFloat(Double.pi / 2.0))

        let mask = CAShapeLayer()
        mask.path = path.cgPath
        mask.lineWidth = lineWidth
        mask.strokeColor = UIColor.clear.cgColor
        mask.fillColor = UIColor.white.cgColor
        imageView.layer.mask = mask

        let border = CAShapeLayer()
        border.path = path.cgPath
        border.lineWidth = lineWidth
        border.strokeColor = UIColor.white.cgColor
        border.fillColor = UIColor.clear.cgColor
        imageView.layer.addSublayer(border)
    }
    
    func roundedPolygonPath(rect: CGRect, lineWidth: CGFloat, sides: NSInteger, cornerRadius: CGFloat, rotationOffset: CGFloat = 0)
     -> UIBezierPath {
        let path = UIBezierPath()
        let theta: CGFloat = CGFloat(2.0 * Double.pi) / CGFloat(sides) // How much to turn at every corner
        let _: CGFloat = cornerRadius * tan(theta / 2.0)     // Offset from which to start rounding corners
        let width = min(rect.size.width, rect.size.height)        // Width of the square

        let center = CGPoint(x: rect.origin.x + width / 2.0, y: rect.origin.y + width / 2.0)

        // Radius of the circle that encircles the polygon
        // Notice that the radius is adjusted for the corners, that way the largest outer
        // dimension of the resulting shape is always exactly the width - linewidth
        let radius = (width - lineWidth + cornerRadius - (cos(theta) * cornerRadius)) / 2.0

        // Start drawing at a point, which by default is at the right hand edge
        // but can be offset
        var angle = CGFloat(rotationOffset)

        
        let corner = CGPoint(x: center.x + (radius - cornerRadius) * cos(angle), y: center.y + (radius - cornerRadius) * sin(angle))
        
        path.move(to: CGPoint(x :corner.x + cornerRadius * cos(angle + theta), y: corner.y + cornerRadius * sin(angle + theta)))

        for _ in 0 ..< sides {
            angle += theta

            let corner = CGPoint(x: center.x + (radius - cornerRadius) * cos(angle), y: center.y + (radius - cornerRadius) * sin(angle))
            let tip = CGPoint(x: center.x + radius * cos(angle),y:  center.y + radius * sin(angle))
            let start = CGPoint(x: corner.x + cornerRadius * cos(angle - theta),y: corner.y + cornerRadius * sin(angle - theta))
            let end = CGPoint(x: corner.x + cornerRadius * cos(angle + theta),y: corner.y + cornerRadius * sin(angle + theta))

            path.addLine(to: start)
            path.addQuadCurve(to: end, controlPoint: tip)
        }

        path.close()

        // Move the path to the correct origins
        let bounds = path.bounds
        let transform = CGAffineTransform(translationX: -bounds.origin.x + rect.origin.x + lineWidth / 2.0,
                                          y: -bounds.origin.y + rect.origin.y + lineWidth / 2.0)

        path.apply(transform)

        return path
    }
}
