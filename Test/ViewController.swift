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
        let data = GridViewData(itemList: texts)
        gridView.configure(data: data) { (name, object) in
            print(name)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

