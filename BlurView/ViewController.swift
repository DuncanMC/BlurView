//
//  ViewController.swift
//  BlurView
//
//  Created by Duncan Champney on 8/13/20.
//  Copyright © 2020 Duncan Champney. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var picView: UIImageView!
    @IBOutlet weak var blurSwitch: UISwitch!
    @IBOutlet weak var blurSlider: UISlider!
    @IBOutlet weak var blurView: BlurView!
    @IBOutlet weak var blurOutputImageView: UIImageView!
    @IBOutlet weak var radiusLabel: UITextField!

    var radiusValue: CGFloat = 0 {
        didSet {
            radiusLabel.text = String(format: "%.1f", radiusValue)
            blurView.blurLevel = radiusValue
            blurSlider.value = Float(radiusValue)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        radiusValue = 0.1
        blurView.updateBlurImage = { image in
            self.blurOutputImageView.image = image
        }
    }

    override func viewDidLayoutSubviews() {
        blurView.handleResize()
    }
    override func viewDidAppear(_ animated: Bool) {
        blurView.applyBlur()
        UIView.animate(withDuration: 0.2, delay: 0.5, options: [], animations: {
            self.blurView.alpha = 1 },
                       completion: nil
        )
    }

    @IBAction func handleBlurSwitch(_ sender: Any) {
        blurView.blur = blurSwitch.isOn
    }
    @IBAction func handleBlurSlider(_ sender: Any) {
        radiusValue = max( CGFloat(blurSlider.value), 0)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        radiusValue = min(max(CGFloat(Float(radiusLabel.text ?? "0.1") ?? 0), 0), 100)
        print(radiusValue)
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        DispatchQueue.main.async { textField.selectAll(textField) }
        return true
    }
}

