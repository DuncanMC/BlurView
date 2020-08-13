//
//  ViewController.swift
//  BlurView
//
//  Created by Duncan Champney on 8/13/20.
//  Copyright © 2020 Duncan Champney. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var blurSwitch: UISwitch!
    @IBOutlet weak var blurSlider: UISlider!
    @IBOutlet weak var blurView: BlurView!
    @IBOutlet weak var blurOutputImageView: UIImageView!
    @IBOutlet weak var radiusLabel: UILabel!

    var radiusValue: CGFloat = 0 {
        didSet {
            radiusLabel.text = String(format: "%.1f", radiusValue)
            blurView.blurLevel = radiusValue
            blurSlider.value = Float(radiusValue)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        radiusValue = 10
        blurView.updateBlurImage = { image in
            self.blurOutputImageView.image = image
        }
    }

    override func viewDidAppear(_ animated: Bool) {
       blurView.applyBlur()
    }
    @IBAction func handleBlurSwitch(_ sender: Any) {
        blurView.blur = blurSwitch.isOn
    }
    @IBAction func handleBlurSlider(_ sender: Any) {
        radiusValue = CGFloat(blurSlider.value)
    }


}

