//
//  TestCellCollectionViewCell.swift
//  Test
//
//  Created by pkh on 2020/08/21.
//  Copyright © 2020 pkh. All rights reserved.
//

import UIKit

class TestCellCollectionViewCell: UICollectionViewCell, PkhGridViewProtocol {
    var actionClosure: OnActionClosure?
    var data: String?
    @IBOutlet weak var titleLabel: UILabel!

    // override 가능으로 높이 커스텀 가능 Default는 Xib width의 비율로 결정됨
    static func getWidthByHeight(gridView: PkhGridView, data: Any?, subData: [String: Any]?, width: CGFloat) -> CGFloat {

        if let data = data as? String {
            switch data {
            case "테스트1":
                return 100
            case "테스트2":
                return 200
            default:
                break
            }
        }
        return self.fromXibSize().ratioHeight(setWidth: width)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(gridView: PkhGridView, data: Any?, subData: [String : Any]?, indexPath: IndexPath, width: CGFloat) {
        guard let data = data as? String else { return }
        self.data = data
        
        titleLabel.text = data
    }
    
    @IBAction func onButton(_ sender: UIButton) {
        actionClosure?("image Button", data)
    }
    
    @IBAction func onButton2(_ sender: UIButton) {
        actionClosure?("label Button", data)
    }

}
