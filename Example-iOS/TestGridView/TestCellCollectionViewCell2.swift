//
//  TestCellCollectionViewCell.swift
//  Test
//
//  Created by pkh on 2020/08/21.
//  Copyright © 2020 pkh. All rights reserved.
//

import UIKit

class TestCellCollectionViewCell2: UICollectionViewCell, PkhGridViewProtocol {
    var actionClosure: ((_ name: String, _ object: Any?) -> Void)?
    var data: String?
    @IBOutlet weak var titleLabel: UILabel!

    // override 가능으로 높이 커스텀 가능 Default는 Xib width의 비율로 결정됨
    static func getWidthByHeight(gridView: PkhGridView, data: Any?, subData: [String: Any]?, width: CGFloat) -> CGFloat {
        return 100
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
        actionClosure?("CustomView Button", data)
    }
    

}
