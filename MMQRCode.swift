//
//  MMQRCode.swift
//  RevoSys
//
//

import UIKit

class MMQRCode: NSObject {

    class func mmCreateQRCode(strInfo:String?, logo:String?, size:CGFloat) -> UIImage?{
        if let requestStr = strInfo {
            let strData = requestStr.data(using: String.Encoding.utf8, allowLossyConversion: false)
            //创建二维码滤镜
            let qrFilter = CIFilter(name: "CIQRCodeGenerator")!
            qrFilter.setValue(strData, forKey: "inputMessage")
            qrFilter.setValue("H", forKey: "inputCorrectionLevel")
            let qrCIImage = qrFilter.outputImage
            
            //创建颜色滤镜 黑白
            let colorFilter = CIFilter(name: "CIFalseColor")!
            colorFilter.setDefaults()
            colorFilter.setValue(qrCIImage, forKey: "inputImage")
            colorFilter.setValue(CIColor(red: 0, green: 0, blue: 0), forKey: "inputColor0")
            colorFilter.setValue(CIColor(red: 0.3, green: 0.8, blue: 0.2), forKey: "inputColor1")
           
            let colorImage = colorFilter.outputImage!
            //返回二维码
            //10:10 -> 310*310 
            let scale = size/31
            let codeImage = UIImage(ciImage: colorImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale)))
            //定制图片
            if let iconImageName = logo {
                let icon = UIImage(named: iconImageName)!
                //二维码图片的rect
                let rect = CGRect(x: 0, y: 0, width: codeImage.size.width, height: codeImage.size.height)
                UIGraphicsBeginImageContext(rect.size)
                codeImage.draw(in: rect)
                //icon尺寸
//                UIBezierPath.
                let iconSize = CGSize(width: rect.width * 0.2, height: rect.height * 0.2)
                let x = rect.midX - iconSize.width * 0.5
                let y = rect.midX - iconSize.height * 0.5
                let iconFrame = CGRect(x: x, y: y, width: iconSize.width, height: iconSize.height)
                UIBezierPath(roundedRect: iconFrame, cornerRadius: 10).addClip()
                
                icon.draw(in: iconFrame)
                let resultImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                print(resultImage?.size.width ?? "error")
                return resultImage
            }
            return codeImage
        }
        return nil
    }
    
}
