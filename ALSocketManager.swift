//
//  ALSocketManager.swift
//  ALPrinterManager
//
//

import UIKit
import CocoaAsyncSocket


//import ColorInBitmapPerPiexl

class ALSocketManager: NSObject,GCDAsyncSocketDelegate {

    var asyncSocket:GCDAsyncSocket?
    
    var blockPrintData:(()->())? = nil
    var blockCheckData:(()->())? = nil
    override init() {
        super.init()
        
        self.asyncSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
    }

    func socketConnectToPrint(host:String, port:UInt16, timeout:TimeInterval) {
        if socketOpen(host: host, port: port, timeout: timeout) == nil {
            do{
                try self.asyncSocket!.connect(toHost: host, onPort: port, withTimeout: timeout)
            }
            catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    func socketOpen(host:String, port:UInt16, timeout:TimeInterval)->Int? {
        if !self.asyncSocket!.isConnected {
            do {
                try self.asyncSocket!.connect(toHost: host, onPort: port, withTimeout: timeout)
            }
            catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        return 0
    }
    
    func socketDisconnectSocket(){
        self.asyncSocket!.disconnect()
        
    }
    
   
    func socketIsConnected() -> Bool {
        if asyncSocket == nil {
            return false
        }
        let isConn = self.asyncSocket!.isConnected
        if isConn {
            print("host = \(self.asyncSocket!.connectedHost ?? "")\n port = \(self.asyncSocket!.connectedPort)\n localHost = \(self.asyncSocket!.localHost ?? "")\n localPort = \(self.asyncSocket!.localPort)")
        }
        return isConn
    }
    
    func socketWriteData(data:NSData){
        self.asyncSocket!.write(data as Data, withTimeout: 10, tag: 0)
    }

    //MARK:AsyncSocketDelegate
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        //blockPrintData!()
        sock.disconnectAfterWriting()
    }
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        print("\(sock.connectedHost ?? "")")
    }
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        print("\(sock.connectedHost ?? "")")
    }

}
