//
//  ViewController.swift
//  Test
//
//  Created by pkh on 2018. 8. 14..
//  Copyright © 2018년 pkh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var gridView: PkhGridView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()


        let texts = ["테스트1","테스트2","테스트3","테스트4","테스트5","테스트6","테스트7","테스트8","테스트9"]

        let gridListData = GridViewListData()
        // 그리드뷰에 셋팅된 뷰를 사용하기에 CellType을 따호 하지 않는다.
        for item in texts {
            let gridViewData = GridViewData()
                .setContentObj(item)
                .setSubData(nil)
                .setActionClosure( { [weak self] (name, object) in
                    guard let self else { return }
                    self.showAlert(name: name, object: object)
                })
            gridListData.itemList.append(gridViewData)
        }

        // 그리드뷰에 셋팅된 뷰를 사용하지 않고 커스트 다른 셀을 추가 한다.
        let gridViewData = GridViewData()
            .setContentObj("CustomView")
            .setSubData(nil)
            .setCellType(TestCellCollectionViewCell2.self)
            .setActionClosure( { [weak self] (name, object) in
                guard let self else { return }
                self.showAlert(name: name, object: object)
            })

        gridListData.itemList.append(gridViewData)


        self.gridView.data = gridListData
//        self.gridView.showLineCount = 1
//        self.gridView.allItemHeightSame = true
        self.gridView.reloadData()
    }

    func showAlert(name: String, object: Any?) {
        DispatchQueue.main.async {
            func run() {
                let alert = UIAlertController(title: "\(name)", message: String(describing: object), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }

            if let presentedVC = self.presentedViewController, presentedVC is UIAlertController {
                // 이미 UIAlertController가 표시 중이면 이를 먼저 닫습니다.
                presentedVC.dismiss(animated: true, completion: {
                    // 경고창을 닫은 후 새로운 UIAlertController를 표시합니다.
                    run()
                })
            } else {
                // 표시 중인 UIAlertController가 없으면 바로 새로운 경고창을 표시합니다.
                run()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

