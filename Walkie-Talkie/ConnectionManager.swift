//
//  ConnectionManager.swift
//  Walkie-Talkie
//
//  Created by Eugene on 26.02.17.
//  Copyright © 2017 Eugenious. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

let UDP_DID_CONNECT = "UDP_DID_CONNECT"
let UDP_DID_DISCONNECT = "UDP_DID_DISCONNECT"
let UDP_FAILED_TO_CONNECT = "UDP_FAILED_TO_CONNECT"

private let INCOMMING_PORT_KEY = "INCOMMING_PORT_KEY"
private let REMOTE_PORT_KEY = "REMOTE_PORT_KEY"
private let REMOTE_ADDRESS_KEY = "REMOTE_ADDRESS_KEY"

enum UDPError:Error {
    case paramsMissing
    case socketWasClosed
}

final class ConnectionManager: NSObject, GCDAsyncUdpSocketDelegate{
    
    
    static let manager: ConnectionManager = ConnectionManager()
    
    private var socket:GCDAsyncUdpSocket!
    private var _socketInitialized = false
    private var _remotePort:Int?
    private var _incommingPort:Int?
    private var _remoteAddress:String?
    private var _receiveBlock:((Data)->())?
    
    var socketInitialized:Bool {
        get{
            return _socketInitialized
        }
        set{
            _socketInitialized = newValue
        }
    }
    
    var incommingPort:Int? {
        get {
            if (_incommingPort == nil){
                let storedPort = UserDefaults.standard.integer(forKey: INCOMMING_PORT_KEY)
                _incommingPort = storedPort == 0 ? nil : storedPort
            }
            return _incommingPort
        }
        set{
            _incommingPort = newValue
            UserDefaults.standard.set(newValue, forKey: INCOMMING_PORT_KEY)
            UserDefaults.standard.synchronize()
        }
    }
    
    var remotePort:Int? {
        get {
            if (_remotePort == nil){
                let storedPort = UserDefaults.standard.integer(forKey: REMOTE_PORT_KEY)
                _remotePort = storedPort == 0 ? nil : storedPort
            }
            return _remotePort
        }
        set{
            _remotePort = newValue
            UserDefaults.standard.set(newValue, forKey: REMOTE_PORT_KEY)
            UserDefaults.standard.synchronize()
        }
    }
    
    var remoteAddress:String? {
        get {
            if (_remoteAddress == nil){
                _remoteAddress = UserDefaults.standard.string(forKey: REMOTE_ADDRESS_KEY)
            }
            return _remoteAddress
        }
        set{
            _remoteAddress = newValue
            UserDefaults.standard.set(newValue, forKey: REMOTE_ADDRESS_KEY)
            UserDefaults.standard.synchronize()

        }
    }
//======================================================================================
    private override init(){
        super.init()
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
    }
    
    
    func connect(receiveBlock:@escaping (Data)->()) {
        
        _receiveBlock = receiveBlock
        if let rmPort = remotePort, let inPort = incommingPort, let addr = remoteAddress{
            
            do {
                try socket.bind(toPort: UInt16(inPort))
                try socket.connect(toHost: addr ,onPort : UInt16(rmPort))
                try socket.beginReceiving()
            }catch{
                print ("connect error = \(error.localizedDescription)")
            }
        }else{
            NotificationCenter.default.post(name: NSNotification.Name(UDP_FAILED_TO_CONNECT), object: UDPError.paramsMissing)
            let alert = UIAlertController(title: "Error", message:"Some of the required parameters were not set.", preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .cancel, handler: nil))
            appDelegate.visibleVC(nil)?.present(alert, animated: true, completion: nil)
        }
    }
    
    func sendData(data:Data){
        if socket.isConnected(){
            socket.send(data, withTimeout: 0, tag: 0)
        }
    }
    
//======================================================================================
    
    internal func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {

        NotificationCenter.default.post(name: NSNotification.Name(UDP_DID_CONNECT), object: nil)
        
    }
    
    internal func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
        NotificationCenter.default.post(name: NSNotification.Name(UDP_FAILED_TO_CONNECT), object: error)
    }
    
    internal func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        NotificationCenter.default.post(name: NSNotification.Name(UDP_DID_DISCONNECT), object: error)
        let alert = UIAlertController(title: "Error", message:"Socket was closed. Probably because the remote host stopped accepting connections.", preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .cancel, handler: nil))
        appDelegate.visibleVC(nil)?.present(alert, animated: true, completion: nil)
    }
    
    internal func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        if let recBlock = _receiveBlock{
            recBlock(data)
        }
    }
    
    internal func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?) {
        NotificationCenter.default.post(name: NSNotification.Name(UDP_DID_DISCONNECT), object: error)
    }
    
    
    
    
    
}
