//
//  ALReceiptManager.swift
//  ALPrinterManager
//
//

import UIKit

var nL1 = 200

var Foodname = ""


//var nL2 = 50
//var nL3 = 60
//var nL4 = 80
var nH = 0 //设置相对横向打印位置的nl和nh值

class ALReceiptManager: NSObject {

    var asyncSocket = ALSocketManager()
    let printerManager = ALPrinterManager()
    
    override init() {
        
    }
    
    init(host:String, port:UInt16,timeout:TimeInterval) {
        super.init()
        self.asyncSocket.socketConnectToPrint(host: host, port: port, timeout: timeout)
        
//        basicSetting()
    }
    
    func basicSetting(){
        //初始化打印机
        printerManager.printInitialize()
        //标准模式
        printerManager.printSetStanderModel()
        printerManager.printDotDistance(w:0.1, h: 0.1)
        //设置左边距,1点*100
        printerManager.printLeftMargin(nL: 20, nH: 0)
        //默认行间距,1点*10
        printerManager.printDefaultLineSpace()
        //打印区域宽度,60mm
        printerManager.printAreaWidth(width: 80)
        //字体,标准12*12
        printerManager.printSelectFont(font: UInt8(48))
    }
   
    /**
     添加标题
     居中,放大
     - parameter title: 标题
     */
    func writeData_Title(title:String,scale:kCharScale?){
        printerManager.printAlignmentType(type: .MiddleAlignment)
        //放大倍数
        if let charScale:kCharScale = scale {
            printerManager.printCharSize(scale: charScale)
        }
        printerManager.printAddText(text: title)
        printerManager.printAndGotoNextLine()
    }
    /**
     Print multiple texts
     Left alignment
     - parameter items: An array of text
     */
    func writeData_item(items:[String]){
        printerManager.printCharSize(scale: kCharScale.scale_1)
        printerManager.printAlignmentType(type: .LeftAlignment)
       
        for item in items {
            printerManager.printAddText(text: item)
            printerManager.printAndGotoNextLine()
        }
    }
    
    func printReceipt(){
        printerManager.printCutPaper(model: kCutPaperModel.feedPaperHalfCut, n: 10)
        asyncSocket.socketWriteData(data: printerManager.sendData)
    }
    
    func writeData_Picture(image:UIImage,alignment:kAlignmentType,maxWidth:CGFloat){
        //Alignment
       // printerManager.printAlignmentType(type: alignment)
        
        var inImage = image
        let width = image.size.width
        if width>maxWidth {
            let height = image.size.height
            let maxHeight = maxWidth*height/width
            inImage = createCurrentImage(inImage: inImage, width:maxWidth, height: maxHeight)
        }
        //bitmap
        printerManager.printBitmapModel(bitmap: inImage)
        //Print and wrap
        printerManager.printAndGotoNextLine()
    }
    
   
    func createCurrentImage(inImage:UIImage, width:CGFloat, height:CGFloat)->UIImage{
//        let w = CGFloat(width)
//        let h = CGFloat(height)
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(size)
        inImage.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func checkPrintStatus(status:kPrinterStatus) {
        printerManager.printStatus(status: .PrintStatus)
    }
    func checkPaper(){
        printerManager.printShortOfPaper(n: 0)
    }
    
    func openCashDrawer(){
        printerManager.printOpenCashDrawer()
    }
    
    func writeData_Content(items:[[String:String]]){
        printerManager.printCharSize(scale: kCharScale.scale_1)
        printerManager.printAlignmentType(type: .LeftAlignment)
        
        for index in 0..<items.count {
            if let dict:[String:String] = items[index] {
                
                if let name = dict["tradeName"]{
                    printerManager.printAddText(text: name)
                }
                printerManager.printAbsolutePosition(location: 350)
                var price = "1"
                if let myprice = dict["price"] {
                    printerManager.printAddText(text: myprice)
                    price = myprice
                }
                printerManager.printAbsolutePosition(location: 510)
                
                var count = "1"
                if let mycount = dict["count"] {
                    printerManager.printAddText(text: mycount)
                    count = mycount
                }
                printerManager.printAbsolutePosition(location: 640)
  
                let totalprice = Float(price)! * Float(count)!
                let totalpricestr = String(format:"%.2f",totalprice)
                printerManager.printAddText(text: totalpricestr)
                printerManager.printAndGotoNextLine()
            }
        }
    }
    
    func writeData_line(){
        
        printerManager.printAddText(text: "----------------------------------------------")
        printerManager.printAndGotoNextLine()
    }
    
    func writeData_Ordername(items:[String:String]) {
        
        printerManager.printCharSize(scale: kCharScale.scale_1)
        
        printerManager.printAlignmentType(type: .LeftAlignment)
        
        printerManager.printAddText(text: items["foodName"]!)
        printerManager.printAbsolutePosition(location: 350)
        printerManager.printAddText(text: items["foodPrice"]!)
        printerManager.printAbsolutePosition(location: 500)
        printerManager.printAddText(text: items["foodCount"]!)
        
        printerManager.printAbsolutePosition(location: 640)
        printerManager.printAddText(text: items["totalPrice"]!)
        
        printerManager.printAndGotoNextLine()
    }
    
    func initPrint() {
        printerManager.sendData.length = 0
//        self.basicSetting()
    }
    
    func disconnectPrint() {
        if asyncSocket.socketIsConnected() {
            asyncSocket.socketDisconnectSocket()
        }
    }
    func check_printer_connectivity() -> Bool{
        return asyncSocket.socketIsConnected()
    }
}
