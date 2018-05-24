//
//  ALPrinterManager.swift
//  ALPrinterManager
//


import UIKit

//Alignment
enum kAlignmentType:UInt8 {
    case LeftAlignment = 48
    case MiddleAlignment = 49
    case RightAlignment = 50
}
//Printer status
enum kPrinterStatus:UInt8 {
    case PrintStatus = 0x01
    case OfflineStatus = 0x02
    case ErrorStatus = 0x03
    case PaperSensorStatus = 0x04
}
//Print area direction in page mode
enum kPrintOrientation:UInt8 {
    case LeftToRight = 48
    case DownToUP    = 49
    case RightToLeft = 50
    case UpToDown    = 51
}
//Character magnification
enum kCharScale:UInt8{
    case scale_1 = 0
    case scale_2 = 17
    case scale_3 = 34
    case scale_4 = 51
    case scale_5 = 68
    case scale_6 = 85
    case scale_7 = 102
    case scale_8 = 119
}
//Cut paper mode

enum kCutPaperModel:UInt8{
    case fullCut = 48
    case halfCut = 49
    case feedPaperHalfCut = 66
}
class ALPrinterManager: NSObject {
    
    let sendData = NSMutableData(capacity: 0)!
    let setData = NSMutableData(capacity: 0)!
    
    func addBytesCommand(command:UnsafeRawPointer, length:Int){
        self.sendData.append(command, length: length)
    }
    func addBytesCommandForSet(command:UnsafeRawPointer, length:Int){
        self.setData.append(command, length: length)
    }

    func addOtherData() {
        self.sendData.append(setData as Data)
    }
    
    
    func printAddText(text:String){
        let gbkeEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
        let data = text.data(using: String.Encoding(rawValue: gbkeEncoding))!
        let size = data.count
        var textData = [UInt8](repeating:0, count:size)
        
        data.copyBytes(to: &textData, count: data.count)
        addBytesCommand(command: textData, length: size)
        //        free(textData)
    }
    
    /**
     1. Horizontal positioning
        Move the print position to the next horizontal position.
     */
    func printHorizontalLocate (){
        let char = [0x09]
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     2. Print and wrap
        Prints the data in the print buffer and advances the print paper one line at the current line spacing.
     */
    func printAndGotoNextLine(){
        let char = [0x0A]
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     3.Print and return to standard mode
        Prints all the data in the print buffer in page mode and returns to standard mode. (After printing, the data in the buffer is cleared, no cutting action is performed, the print position is the starting point of the line, and the page mode is valid)
     */
    func printAndBackToStandarModel(){
        let char = [0x0C]
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     4. Cancel print data in page mode
        Deletes all print data in the current print area (only valid in page mode, the previously set area overlaps the current area, and the overlapped portion is also deleted)
     */
    func printCancleData(){
        let char = [0x0C]
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     5. Real-time status transmission
        Use status to specify the status of the printer to be transferred. (The printer will return to the relevant state immediately after receiving the command. Try not to insert it in the command sequence of 2 or more bytes. When transmitting the status, it does not confirm whether the host has received the printer. The command is executed immediately, this command is only valid for the serial printer. The printer will immediately execute the command in any state)
     
     - parameter status: 打印机状态
     */
    func printStatus(status:kPrinterStatus){
        print("2222222222")
        let char:[UInt8] = [0x10,0x04,0x01]
        //        char.append(status.rawValue)
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     6.Request printers in real time
     
     - parameter n: 1 resumes from error state and continues to be interrupted by printing, 2 recovers from error condition in clear command receive buffer and print buffer
     */
    func printRealTimeRequest(n:Int8){
        var char:[Int8] = [0x10,0x05]
        char.append(n)
        addBytesCommand(command: char, length: char.count)
    }
    
    
    func printOpenCashBox(){
        var char = [0x10,0x14,0x01,0x00,0x00]
        char[4] = 8
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     8.Print in page mode
        Prints all the contents of the buffer. (This command is only valid in page mode. It does not clear the contents of the print buffer, ESC T and ESC W settings and character position after printing, etc.)
     
     */
    func printInPaperModel(){
        let char = [0x1B,0x0C]
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     9.Set the right spacing of characters
        0 ≤ n ≤ 255, set the right margin of the character to [n × horizontal movement unit or vertical movement unit] inch.
     - parameter space: <#space description#>
     */
    func printCharRightSpace(space:Int){
        var char = [0x1B,0x20,0x00]
        char[2] = space
        addBytesCommand(command: char, length: 3)
    }
    
    /**
     10.Select print mode
     
     
     - parameter state: 字符打印模式
     */
    func printModel(model:Int){
        var char = [0x1B,0x21]
        char.append(model)
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     11.Set absolute print position
        The current position is set to the beginning of the line (nL + nH × 256) × (horizontal or vertical movement unit).
     
     - parameter location: 绝对位置
     */
    func printAbsolutePosition(location:Int){
        var char:[UInt8] = [0x1B,0x24]
        
        char.append(UInt8(location%256))
        char.append(UInt8(location/256))
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     12.选择/取消用户自定义字符
     
     - parameter select: 0取消,1选择
     */
    func printCustomChar(select:Int){
        var char = [0x1B,0x25]
        char.append(select)
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     14.Select bitmap mode
     
     - parameter bitmap:    bitmap
     - parameter maxWidth:  Maximum width
     */
    func printBitmapModel(bitmap:UIImage){
        let data = IGThermalSupport.image(toThermalData: bitmap)
        let size = data?.count
        let picData = UnsafeMutablePointer<UInt8>.allocate(capacity: size!)
        data?.copyBytes(to: picData, count:size!)
        addBytesCommand(command: picData, length: size!)
        free(picData)
    }
    
    /**
     15.Select/Unset Underline Mode
     
     - parameter model: 0 Cancel, 1 underline 1 point wide, 2 underline 2 points wide
     */
    func printUnderLine(model:Int8){
        var char:[Int8] = [0x1B,0x2D]
        char.append(model)
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     16.Set the default line spacing
     约3.75mm
     */
    func printDefaultLineSpace(){
        let char = [0x1B,0x32]
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     17.Set line spacing
     Set the line spacing to [n × vertical or horizontal movement units] inches.
     - parameter space: <#space description#>
     */
    func printSetLineSpace(space:Int){
        var char = [0x1B,0x33,0x00]
        char[2] = space
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     18.Select the printer
        The selected printer can receive data sent from the host computer
               
       - parameter printer: 0 prohibited, 1 allowed
     */
    func printSelectPrinter(printer:Int){
        var char = [0x1B,0x3D,0x00]
        char[2] = printer
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     19.Cancel user defined characters
        Cancels characters with code n in user-defined characters. After cancellation, this character uses an internal font.
               
       - parameter char: custom character code
       32...127
     */
    func printCancleCustomChar(character:Int) {
        var char = [0x1B,0x3F,0x00]
        char[2] = character
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     20.Initialize the printer
     The print buffer data is cleared and the print mode is set to the default value mode at power-up.
     
     */
    func printInitialize(){
        let char = [0x1B,0x40]
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     21.Set the horizontal tab position
        Set a tab position from the beginning of row n; calculate: character width × n, character width include right spacing, if the character is double width, the tab spacing will also be doubled; this command cancels the previous tab position setting; When n = 8, the current position is the ninth column;
     
     - parameter jumps: Tabs array.count<=32
     
     1≤n≤255
     */
    func printJumpCell(jumps:[Int]){
        var char = [0x1B,0x44]
        let count = jumps.count
        for i in 0...count {
            char[i+2] = jumps[i]
        }
        char.append(0x00)
        let size = char.count
        addBytesCommand(command: char, length: size)
    }
    
    /**
     22.Select/Cancel bold mode
     
     - parameter model: Select or cancel bold mode, 0 cancel, 1 bold, default n = 0
     */
    func printBoldCharModel(model:Int8){
        var char:[Int8] = [0x1B,0x45]
        char.append(model)
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     23.Select/Cancel Double Print Mode
               
       - parameter model: 0 cancel, 1 select
     */
    func printDoublePrint(model:Int){
        var char = [0x1B,0x47]
        char.append(model)
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     24. Print and feed paper
        Prints buffer data and feeds [n × vertical or horizontal movement units] inches; after printing is finished, the current print position is placed at the beginning of the line
     
     - parameter lineSpace: Paper distance
     */
    func printPrintAndFeedPaper(lineSpace:Int){
        var char = [0x1B,0x4A,0x00]
        char[2] = lineSpace
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     25. Select page mode
         Switch from standard mode to page mode; this command is only valid at the beginning of the standard mode;
     */
    func printSetPaperModel(){
        let char = [0x1B,0x4C]
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     26. Select the font
               
        - parameter font: 0 standard ASCII font (12 × 24), 1 compressed ASCII font (9 × 17)
       */
    func printSelectFont(font:UInt8){
        var char:[UInt8] = [0x1B,0x4D]
        char.append(font)
        addBytesCommand(command: char, length: char.count)
    }
    
    
    /**
        28. Select standard mode
       Valid in page mode; clear page buffer print data; place current position at the beginning of the line; page mode area is initialized to default
       */
    func printSetStanderModel(){
        let char = [0x1B,0x53]
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
             29. Select the print area direction in page mode
               - parameter model: print direction
               */
    
    func printOrientationInPaperModel(model:Int){
        var char = [0x1B,0x54]
        char.append(model)
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     30. Select / cancel clockwise rotation by 90 degrees
     
     - parameter rotate:0 Cancel, 1 Select
     */
    func printRotateClockwise_90(rotate:Int){
        var char = [0x1B,0x56]
        char.append(rotate)
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     31. Setting the print area in page mode
               
            Horizontal start position: x0 = [( xL + xH × 256) × lateral movement unit]
         Vertical start position: y0 = [( yL + yH × 256) × vertical movement unit]
         Print area width: dx = [ dxL + dxH × 256] × horizontal movement unit]
         Print area height: dy = [ dyL + dyH × 256] × vertical movement unit]
         0...255
     - parameter xL:  <#xL description#>
     - parameter xH:  <#xH description#>
     - parameter yL:  <#yL description#>
     - parameter yH:  <#yH description#>
     - parameter dxL: <#dxL description#>
     - parameter dxH: <#dxH description#>
     - parameter dyL: <#dyL description#>
     - parameter dyH: <#dyH description#>
     */
    func printAreaInPaperModel(xL:Int, xH:Int, yL:Int, yH:Int, dxL:Int, dxH:Int, dyL:Int, dyH:Int){
        var char = [0x1B,0x57]
        char.append(xL)
        char.append(xH)
        char.append(yL)
        char.append(yH)
        char.append(dxL)
        char.append(dxH)
        char.append(dyL)
        char.append(dyH)
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     32. Set the relative horizontal print position
         Set horizontal relative displacement in horizontal or vertical movement units
         This command sets the print position to the current position [( nL + nH × 256) × horizontal or vertical movement units]
     
     - parameter nL: <#nL description#>
     - parameter nH: <#nH description#>
     */
    func printRelativePosition(nL:UInt8, nH:UInt8){
        var char:[UInt8] = [0x1B,0x5C]
        char.append(nL)
        char.append(nH)
        
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     33. Select Alignment
         Only valid at the beginning of the standard mode.
               
         - parameter type: alignment
     */
    func printAlignmentType(type:kAlignmentType){
        var char:[UInt8] = [0x1B,0x61]
        char.append(type.rawValue)
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     34. Select paper sensor to output paper out signal
           Multiple sensors can be selected to output the signal. If any sensor detects paper out, an out-of-paper signal is output; only valid for parallel interfaces
         If bit 0 or bit 1 is ON, the paper end sensor is selected as the paper sensor to output the paper out signal
         If bit 2 or bit 3 is ON, select the paper end sensor as a paper sensor to output the paper out signal
         When all sensors are disabled, the print paper presence signal is always output as the current state of the paper
                         
         - parameter n: 0 disables paper end sensor, 1/2 allows paper to run out of cgq, 3/4 allows paper end sensor
     */
    func printShortOfPaper(n:Int8){
        let char = [0x1B,0x63,0x33,0x00]
        //        char.append(n)
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     35. Select paper sensor to stop printing
        When this command is used to allow a paper sensor to be effective, printing stops only when the corresponding paper is selected for printing.
       When the roll paper sensor detects the end of the paper, the printer goes offline after printing stops.
       When Bit 0 or Bit 1 is ON, the printer selects the paper end sensor as a paper sensor to stop printing.
               
       - parameter n: 0 paper end sensor is disabled, 1/2 paper end sensor is allowed
     
     */
    func printShortOfPaperToStop(n:Int){
        var char = [0x1B,0x63,0x34]
        char.append(n)
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     36. Enable/Disable Buttons
               
          - parameter n: 0 button works, 1 button does not work
     */
    func printAllowButton(n:Int8){
        var char:[Int8] = [0x1B,0x63,0x35]
        char.append(n)
        addBytesCommand(command: char, length: char.count)
    }
    /**
     37. Print and advance paper n lines
         Print data in buffer and advance paper n lines
               
       - parameter lines: number of lines
     */
    func printAndFeedPaper(lines:Int8){
        var char:[Int8] = [0x1B,0x64]
        char.append(lines)
        addBytesCommand(command: char, length: char.count)
    }
    
    
    /**
     38.Generate cash box control pulses
     */
    func printOpenCashDrawer(){
        let char:[UInt8] = [0x1B, 0x70, 0x00, 0x80, 0xFF]
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
        40. Select/Cancel Inverse Print Mode
       This command is only valid at the beginning of the line in standard mode
               
       - parameter state: 0 cancels, 1 inverts
     */
    func printUpsidDown(state:Int){
        var char = [0x1B,0x7B]
        char.append(state)
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     43. Select character size
         1 ≤ longitudinal magnification ≤8,1≤ transverse multiple ≤8
       Select the character height from 0 to 2 and choose the character width from 4 to 7
       Height: 00~07 -> 1~8 times Width: 00~70 -> 1~8 times
       If n exceeds the specified range, this command is ignored
       When the magnification of the same line of characters is different, all the characters are aligned with the bottom line.
       - parameter scale: magnification
     
     */
    func printCharSize(scale:kCharScale){
        var char:[UInt8] = [0x1D,0x21]
        char.append(scale.rawValue)
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     44. Setting vertical position in page mode
         This command sets the absolute position in [(nL + nH × 256) × (vertical or horizontal moving units)] inches.
       After executing this command, the horizontal position does not change
     
     - parameter nL: <#nL description#>
     - parameter nH: <#nH description#>
     */
    func printAbsoluteVerticalPosition(nL:Int8, nH:Int8){
        var char:[Int8] = [0x1D,0x24]
        char.append(nL)
        char.append(nH)
        addBytesCommand(command: char, length: char.count)
    }
    
    
    /**
     48. Start/End Macro Definition
     */
    func printSetMacro(){
        printStartEndMacro()
        
        printStartEndMacro()
    }
    private func printStartEndMacro(){
        let char:[Int8] = [0x1D,0x3A]
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     49. Select/Cancel Black and White Reverse Print Mode
               
         - parameter model: 0 cancel, 1 reverse
     */
    func printBlackWhiteExchangeModel(model:Int8){
        var char:[Int8] = [0x1D,0x42]
        char.append(model)
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     50. Select the print position of HRI characters
               
         - parameter n: 0 does not print, above 1 bar code, below 2 bar code, 3 above and below
     */
    func printHRIChar(n:Int){
        var char = [0x1D,0x48]
        char.append(n)
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     51. Set the left margin
         The left margin is set to [( nL + nH × 256) × lateral movement units]] inches.
       In standard mode, this command is valid only at the beginning of the line
     
     - parameter nL: <#nL description#>
     - parameter nH: <#nH description#>
     */
    func printLeftMargin(nL:UInt8, nH:UInt8){
        var char:[UInt8] = [0x1D,0x4C]
        char.append(nL)
        char.append(nH)
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     52. Set horizontal and vertical mobile units
          Set the lateral movement unit approximately to 25.4/x mm (1/x inch) and the longitudinal movement unit to 25.4/y mm (1/y inch) respectively.
       - parameter horizontal: Landscape
       - parameter vertical: portrait
     
     */
    //    func printMove(horizontal horizontal:Int, vertical:Int){
    //        var char = [0x1D,0x50]
    //        char.append(horizontal)
    //        char.append(vertical)
    //        addBytesCommand(command: char, length: char.count)
    //    }
    
    /**
     52. Set horizontal and vertical mobile units
               
         - parameter w: lateral movement distance
       - parameter h: longitudinal movement distance
     */
    func printDotDistance(w:Float, h:Float){
        var char:[UInt8] = [0x1D,0x50]
        char.append(UInt8(25.4/w))
        char.append(UInt8(25.4/h))
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
        53. Select Cut Mode and Cut Paper
       This command is valid only at the beginning of the line
               
       - parameter model: 0 full cut, 1 half cut, 66 ([n × (longitudinal moving unit) inches]) and half cut
     */
    func printCutPaper(model:kCutPaperModel,n:UInt8?){
        var char:[UInt8] = [0x1D,0x56]
        char.append(model.rawValue)
        if model.rawValue == kCutPaperModel.feedPaperHalfCut.rawValue {
            if let temp = n {
                char.append(temp)
            }
            else
            {
                char.append(0)
            }
        }
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     54. Set the print area width
          Set the print area width to [( nL + nH × 256) × horizontal movement units]] inches.
       In standard mode, this command is only valid at the beginning of the line.
       If [Left margin + print area width] exceeds the printable area, the print area width is the printable area width minus the left margin.
       Default: nL = 76, nH = 2
     
     - parameter nL: <#nL description#>
     - parameter nH: <#nH description#>
     */
    func printAreaWidth(width:Float){
        
        var char:[UInt8] = [0x1D,0x57]
        let nL = UInt8((width/0.1).truncatingRemainder(dividingBy: 256))
        let nH = UInt8(width/0.1/256)
        char.append(nL)
        char.append(nH)
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
        55. Set vertical relative position in page mode
       Set the vertical movement distance relative to the current point to [( nL + nH × 256) × vertical or horizontal movement units] inches
       This command is only valid in page mode and is ignored in other modes.
     
     - parameter nL: <#nL description#>
     - parameter nH: <#nH description#>
     */
    func printRelativePositionInPaperModel(nL:Int, nH:Int){
        var char = [0x1D,0x5C]
        char.append(nL)
        char.append(nH)
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     58. Select HRI to use fonts
               
       - parameter font: 0 standard ASCII character (12 × 24), 1 compressed ASCII character (9 × 17)
     */
    func printSelectHRICharFont(font:Int){
        var char = [0x1D,0x66]
        char.append(font)
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     59. Select Barcode Height
               
        - parameter height: 1...255
     */
    func printBarCodeSetHeight(height:Int){
        var char = [0x1D,0x68]
        char.append(height)
        addBytesCommand(command: char, length: char.count)
    }
    
    
    func printBarCode(){
        //        print("print bar code")
    }
    
    /**
     61. Return status
         This command is executed after the data before this command in the receive buffer is processed. Therefore, there is a certain time lag between sending the command and receiving the return status.
       Return code see manual
               
       - parameter state: 0 returns paper sensor status, 1 returns cash drawer status
     */
    func printReceiveState(state:Int){
        var char = [0x1D,0x72]
        char.append(state)
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     64. Set Chinese character mode
         When the Double Width and Double Height modes are set at the same time, the characters are doubled horizontally and vertically (including left and right spacing).
       The printer can underline all characters, including left and right spacing. However, the space caused by the HT command (horizontal tabs) cannot be crossed and the characters rotated 90 degrees clockwise cannot be underlined.
       When the height of a character in a line is different, all the characters in the line are aligned with the bottom line
       You can use FS W or GS ! to bold characters, and the last command is valid
       Can also use FS - select or cancel underline mode, the last command is valid
               
       - parameter n: 0 cancel, 4 times wider, 8 times higher, 80 underline
     */
    func printHanziChar(n:Int){
        var char = [0x1C,0x21]
        char.append(n)
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     65. Select Chinese character mode
         When the Chinese character mode is selected, the printer determines whether the character is a Chinese character inner code. If it is a Chinese character inner code, the first byte is processed first, and then it is determined whether the second byte is a Chinese character inner code.
       Automatically select the Chinese character mode after the printer is powered on
     */
    func printSelectHanziModel(){
        let char = [0x1C,0x26]
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     66. Select/Cancel Chinese Underline Mode
         The printer can underline all characters, including left and right spacing. However, the spaces caused by the HT command (horizontal tabs) cannot be underlined, and the characters rotated 90 degrees clockwise cannot be underlined.
       After the underline mode is eliminated, the underline printing is no longer performed, but the original underline width is not changed.
       The default underline width is 1 point
       Even if you change the character size, the set underline width does not change
               
       - parameter n: 0 cancel, 1 underline 1 point wide, 2 2 point wide
     */
    func printHanziUnderLineModel(n:Int){
        var char = [0x1C,0x2D]
        char.append(n)
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     67.Cancel Chinese character mode
     */
    func printCancleHanziModel(){
        let char = [0x1C,0x2E]
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     69.Set the left and right spacing of Chinese characters
           0...255
       [n × horizontal or vertical movement units] inches
     - parameter leftSpace:  leftSpace description
     - parameter rightSpace: rightSpace description
     */
    func printHanziCharSpace(leftSpace:UInt8, rightSpace:UInt8){
        var char:[UInt8] = [0x1C,0x53]
        char.append(leftSpace)
        char.append(rightSpace)
        addBytesCommand(command: char, length: char.count)
    }
    
    /**
     70. Select/Cancel Chinese Characters Times Doubled Width
     
     - parameter n: 0Cancle,1Select
     */
    func printHanziCancleDoubleHeightWidth(n:Int){
        var char = [0x1C,0x57]
        char.append(n)
        addBytesCommand(command: char, length: char.count)
    }
    
    //Mark: Printer hint function
    /**
       72. The printer prints a buzzer prompt (for GP-80xxx series)
               
       - parameter n: number of times
       - parameter t: each tick time: t*50ms
       */
    func printerBuzzer(n:Int, t:Int){
        var char = [0x1B,0x42]
        char.append(n)
        char.append(t)
        addBytesCommand(command: char, length: char.count)
    }
}




