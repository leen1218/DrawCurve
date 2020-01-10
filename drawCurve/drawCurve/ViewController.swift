//
//  ViewController.swift
//  drawCurve
//
//  Created by en li on 2018/2/10.
//  Copyright © 2018年 xqf. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		
		let canvasV = MyCanvas(frame: self.view.bounds)
		canvasV.backgroundColor = UIColor.white
		self.view.addSubview(canvasV)
	}

}

