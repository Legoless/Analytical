//
//  SecondViewController.swift
//  Analytical
//
//  Created by Dal Rupnik on 21/11/2016.
//  Copyright © 2016 Unified Sense. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        analytics.track(screen: .second)
    }
    
    @IBAction func closeButtonTap(_ sender: UIButton) {
        analytics.track(event: .closeTap)
        
        dismiss(animated: true, completion: nil)
    }
}
