//
//  ImageProcessing.swift
//  pic2sound
//
//  Created by Dylan Sharkey on 11/22/15.
//  Copyright © 2015 Dylan Sharkey. All rights reserved.
//

import UIKit

extension Double {
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self) as String
    }
}

class ImageProcessing {
    
    var primaryUIColor: UIColor
    var secondaryUIColor: UIColor
    var meanUIcolor: UIColor
    var primary: [Int]
    var secondary: [Int]
    var mean: [Int]
    init(primaryColor: UIColor, secondaryColor: UIColor, meanColor: UIColor) {
        self.primaryUIColor = primaryColor
        self.secondaryUIColor = secondaryColor
        self.meanUIcolor = meanColor
        self.primary = primaryColor.rgb()!
        self.secondary = secondaryColor.rgb()!
        self.mean = meanColor.rgb()!
    }
    
    static func Initialize(inImage: UIImage) -> ImageProcessing {
        let processColors = inImage.getColors(CGSize(width: 100, height: 100))
        //convert to CGImage for averge color calculation
        let originalImage = CIImage(image: inImage.resize(CGSize(width: 100, height: 100)))
        let contextCI = CIContext(options: nil)
        let cgimg = contextCI.createCGImage(originalImage!, fromRect: originalImage!.extent)
        
        
        //save all values to new image processing object
        let primary = processColors.primaryColor
        let secondary = processColors.secondaryColor
        let mean = getAverageColorOfImage(cgimg)
        return ImageProcessing(primaryColor: primary, secondaryColor: secondary, meanColor: mean)
    }
    
    
    
    static func createARGBBitmapContext(inImage: CGImage) -> CGContext {
        var bitmapByteCount = 0
        var bitmapBytesPerRow = 0
        
        //Get image width, height
        let pixelsWide = CGImageGetWidth(inImage)
        let pixelsHigh = CGImageGetHeight(inImage)
        
        //Declare the number of bytes per row. Each pixel in the bitmap in this
        //example is represented by 4 bytes, 8 bits each of red, green, blue, and alpha
        bitmapBytesPerRow = Int(pixelsWide) * 4
        bitmapByteCount = bitmapBytesPerRow * Int(pixelsHigh)
        
        //use the generic RGB color space
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        //allocate memory for image data. This is the destination in memory
        //where any drawing to the bitmap context will be renedered
        let bitmapData = malloc(bitmapByteCount)
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
        
        //create the bitmap context. We want pre-multiplied ARGB, 8-bits
        //per component. Regarless of what the source image format is it
        //will be convered over to the format specified here by
        //CGBitmapContextCreate
        
        let context = CGBitmapContextCreate(bitmapData, pixelsWide, pixelsHigh, 8, bitmapBytesPerRow, colorSpace, bitmapInfo.rawValue)
        
        return context!
    }
    
    
    // Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
    static func getPixelColorAtLocation(point:CGPoint, inImage:CGImageRef) -> UIColor {
        let context = self.createARGBBitmapContext(inImage)
        
        let pixelsWide = CGImageGetWidth(inImage)
        let pixelsHigh = CGImageGetHeight(inImage)
        let rect = CGRect(x:0, y:0, width:Int(pixelsWide), height:Int(pixelsHigh))
        
        CGContextClearRect(context, rect)
        CGContextDrawImage(context, rect, inImage)
        
        let data: COpaquePointer = COpaquePointer(CGBitmapContextGetData(context))
        let dataType = UnsafePointer<UInt8>(data)
        var color = UIColor.redColor()
        
        let offset = 4*((Int(pixelsWide) * Int(point.y)) + Int(point.x))
        let alpha = dataType[offset]
        let red = dataType[offset+1]
        let green = dataType[offset+2]
        let blue = dataType[offset+3]
        let range: Float = 255.0
        color = UIColor(red: CGFloat(Float(red)/range), green: CGFloat(Float(green)/range), blue: CGFloat(Float(blue)/range), alpha: CGFloat(Float(alpha)/range))
        print("[\(alpha), \(red), \(green), \(blue)]")
        
        return color;
    }
    
    //Prints a brightness map of the image
    static func printBrightnessMap(inImage: CGImageRef) {
        let context = self.createARGBBitmapContext(inImage)
        let width = CGImageGetWidth(inImage)
        let height = CGImageGetHeight(inImage)
        let imgSize = Int(width * height)
        var str = ""
        
        //total value of all pixel brightnesses
        //var average = 0.0
        
        //change rect values to get different grid sections
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        
        CGContextDrawImage(context, rect, inImage)
        
        let data = COpaquePointer(CGBitmapContextGetData(context))
        let dataType = UnsafePointer<UInt8>(data)
        
        for var idx = 0; idx < imgSize; idx++ {
            let offset = 4 * idx
            let red = dataType[offset+1]
            let green = dataType[offset+2]
            let blue = dataType[offset+3]
            let someDouble = ((Double(red) + Double(green) + Double(blue)) / 3.0), someDoubleFormat = ".1"
            str += "\(someDouble.format(someDoubleFormat)),   "
            if(width == (idx % width) + 1)
            {
                str += "\n"
            }
        }
        print(str)
    }
    
    static func getAverageColorOfImage(inImage: CGImageRef) -> UIColor {
        let context = self.createARGBBitmapContext(inImage)
        let width = CGImageGetWidth(inImage)
        let height = CGImageGetHeight(inImage)
        let imgSize = Double(width * height)
        var red = 0.0
        var blue = 0.0
        var green = 0.0
        
        //change rect values to get different grid sections
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        
        CGContextDrawImage(context, rect, inImage)
        
        let data = COpaquePointer(CGBitmapContextGetData(context))
        let dataType = UnsafePointer<UInt8>(data)
        
        for var idx = 0; idx < Int(imgSize); idx++ {
            let offset = 4 * idx
            red += Double(dataType[offset+1])
            green += Double(dataType[offset+2])
            blue += Double(dataType[offset+3])
        }
        let range = 255.0 * imgSize
        let alpha = (red + blue + green) / 3
        let avgColor = UIColor(red: CGFloat(red/range), green: CGFloat(green/range), blue: CGFloat(blue/range), alpha: CGFloat(alpha/imgSize))
        return avgColor
    }
}
