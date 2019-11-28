//
//  ViewController.swift
//  Sample
//
//  Created by Tae Hyun Na on 2017. 3. 7.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var kingghidorahImageView: UIImageView!
    @IBOutlet var godzillaImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        P9ViewDragger.default().trackingView(self.godzillaImageView, parameters: nil, ready: nil, trackingHandler: nil, completion: nil)
        
        P9ViewDragger.default().trackingDecoyView(self.kingghidorahImageView, stageView: self.view, parameters: nil, ready: { [weak self] (trackingView:UIView?) in
            guard let `self` = self else {
                return
            }
            self.kingghidorahImageView.alpha = 0.2
        }, trackingHandler: nil) { [weak self] (trackingView:UIView?) in
            guard let `self` = self, let trackingView = trackingView else {
                return
            }
            self.kingghidorahImageView.alpha = 1.0
            self.view.bringSubviewToFront(self.kingghidorahImageView)
            self.kingghidorahImageView.transform = trackingView.transform
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

