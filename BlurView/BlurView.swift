//
//  BlurView.swift
//  BlurView
//
//  Created by Duncan Champney on 8/13/20.
//  Copyright © 2020 Duncan Champney. All rights reserved.
//

import UIKit
typealias  ImageCompletion  = (UIImage?) -> Void

/**
 This class adds a blur layer on top of its contents to blur iteslf and it's subviews by a variable amount.
 It is similar to the blur effect created by a UIVisualEffectView, but it provides a variable blur amount. It also blurs the view and it's subviews rather than blurring the content that appears under it.

 */
class BlurView: UIView {

    //MARK: Set this completion handler to receive updated blur images if desired
    public var updateBlurImage: ImageCompletion? = nil


   //MARK: Set blur = true to add a blur layer, blur = false to disable view blurring
   public var blur: Bool = true {
        didSet {
            blurLayer.isHidden = !blur
            applyBlur()
        }
    }

    //MARK: This controls the blur radius for the blur. 0 = no blur. Larger values = more blur. Default = 10
    public var blurLevel: CGFloat = 10 {
        didSet {
            applyBlur()
        }
    }

    lazy var blurLayer: CALayer = {
        let newLayer = CALayer()
        newLayer.isOpaque = true
        return newLayer
    }()

    override func awakeFromNib() {
        self.layer.addSublayer(blurLayer)
        self.clipsToBounds = true
    }



    override var bounds: CGRect {
        didSet {
            blurLayer.frame = self.bounds
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                self.applyBlur()
            }
        }
    }

    public func applyBlur() {
        let context = CIContext(options: nil)

        self.makeBlurredImage(with: blurLevel, context: context, completed: { processedImage in
            self.blurLayer.contents = nil
            self.blurLayer.contents = processedImage?.cgImage
            self.updateBlurImage?(processedImage)
        })
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    private func makeBlurredImage(with level: CGFloat, context: CIContext, completed: @escaping (UIImage?) -> Void) {
        // screen shot
        layer.isOpaque = true
        blurLayer.isHidden = true
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 1)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        blurLayer.isHidden = !blur
        let beginImage = CIImage(image: resultImage)

        guard level != 0  && blur else {
            completed(resultImage)
            return
        }


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

