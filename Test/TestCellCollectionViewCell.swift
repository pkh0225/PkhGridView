//
//  TestCellCollectionViewCell.swift
//  Test
//
//  Created by pkh on 2020/08/21.
//  Copyright © 2020 pkh. All rights reserved.
//

import UIKit

class TestCellCollectionViewCell: UICollectionViewCell, PkhGridViewCellProtocol {
    var actionClosure: OnActionClosure?
    var data: String?
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    static func getGridViewHeight(data: Any?, width: CGFloat) -> CGFloat {
        // 이미지 1:1비율 처리를 위해 이미지 비율 높이를 더해준다.
        return width + 40
    }
    
    func configure(_ data: Any?) {
        guard let data = data as? String else { return }
        self.data = data
        
        titleLabel.text = data
    }
    
    @IBAction func onButton(_ sender: UIButton) {
        actionClosure?("\(data)", data)
    }
    
}
