//
//  BlurView.swift
//  BlurView
//
//  Created by Duncan Champney on 8/13/20.
//  Copyright © 2020 Duncan Champney. All rights reserved.
//

import UIKit
typealias  ImageCompletion  = (UIImage) -> Void
class BlurView: UIView {

    public var updateBlurImage: ImageCompletion? = nil

    lazy var blurLayer: CALayer = {
        let newLayer = CALayer()
        self.layer.addSublayer(newLayer)
        newLayer.isOpaque = true
        return newLayer
    }()

   public var blur: Bool = true {
        didSet {
            blurLayer.isHidden = !blur
        }
    }

    public var blurLevel: CGFloat = 10 {
        didSet {
            applyBlur()
        }
    }

    override var frame: CGRect {
        didSet {
            blurLayer.frame = self.bounds
            applyBlur()
        }
    }

    func applyBlur() {
        let context = CIContext(options: nil)
        self.makeBlurredImage(with: blurLevel, context: context, completed: { processedImage in
            self.blurLayer.contents = processedImage.cgImage
            self.updateBlurImage?(processedImage)
        })
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    private func makeBlurredImage(with level: CGFloat, context: CIContext, completed: @escaping (UIImage) -> Void) {
        // screen shot
        layer.isOpaque = true

        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 1)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let beginImage = CIImage(image: resultImage)


        //Clamp the image
        guard let clampFilter = CIFilter(name: "CIAffineClamp") else {
            fatalError()
        }
        clampFilter.setValue(beginImage, forKey: kCIInputImageKey)
        clampFilter.setValue(CGAffineTransform.identity, forKey: kCIInputTransformKey)
        var output = clampFilter.outputImage

        let blurFilter = CIFilter(name: "CIGaussianBlur")!
        blurFilter.setValue(level, forKey: kCIInputRadiusKey)
        blurFilter.setValue(output, forKey: kCIInputImageKey)


        let cropFilter = CIFilter(name: "CICrop")!
        cropFilter.setValue(blurFilter.outputImage, forKey: kCIInputImageKey)
        cropFilter.setValue(CIVector(cgRect: beginImage!.extent), forKey: "inputRectangle")

        output = cropFilter.outputImage
        var cgimg: CGImage?
        var extent: CGRect?

        let global = DispatchQueue.global(qos: .userInteractive)

        global.async {
            extent = output!.extent
            cgimg = context.createCGImage(output!, from: extent!)!
            let processedImage = UIImage(cgImage: cgimg!)

            DispatchQueue.main.async {
                completed(processedImage)
            }
        }
    }
}

