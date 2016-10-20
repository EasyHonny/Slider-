//
//  ViewController.swift
//  SliderView
//
//  Created by EasyHoony on 2016/10/12.
//  Copyright © 2016年 EasyHoony. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        let sliderView = SliderView()
        sliderView.frame = CGRect(x: 10, y: 200, width: 300, height: 50)
        view.addSubview(sliderView)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

