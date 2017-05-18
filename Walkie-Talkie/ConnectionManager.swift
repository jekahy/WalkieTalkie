//
//  ConnectionManager.swift
//  Walkie-Talkie
//
//  Created by Eugene on 26.02.17.
//  Copyright © 2017 Eugenious. All rights reserved.
//


import Foundation
import CocoaAsyncSocket
import ReachabilitySwift

private let INCOMMING_PORT_KEY = "INCOMMING_PORT_KEY"
private let REMOTE_PORT_KEY = "REMOTE_PORT_KEY"
private let REMOTE_ADDRESS_KEY = "REMOTE_ADDRESS_KEY"


enum UDPError:Error {
    case paramsMissing
    case socketWasClosed
    case noWifi
    
    var localizedDescription:String {
        switch self {
        case .noWifi: return "WiFi is not connected."
        case .paramsMissing: return "Not all required parameters were set."
        case .socketWasClosed: return "Socket was closed. Probably because no one was listening on the other end."
        }
    }
}


enum UDP {
    static let didConnect = NSNotification.Name("UDP_DID_CONNECT")
    static let didDisconnect = NSNotification.Name("UDP_DID_DISCONNECT")
    static let failedToConnect = NSNotification.Name("UDP_FAILED_TO_CONNECT")
}


final class ConnectionManager: NSObject, GCDAsyncUdpSocketDelegate{
    
    
    static let manager: ConnectionManager = ConnectionManager()
    
    fileprivate var socket:GCDAsyncUdpSocket!
    fileprivate var _remotePort:Int?
    fileprivate var _incommingPort:Int?
    fileprivate var _remoteAddress:String?
    fileprivate var _receiveBlock:((Data)->())?
    
    var incommingPort:Int?
    {
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
    
    var remotePort:Int?
    {
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
    
    var remoteAddress:String?
    {
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
// MARK: 
//    ======================================================================================
    private override init()
    {
        super.init()
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: ReachabilityChangedNotification, object: nil)
    }
    
    
    @objc fileprivate func reachabilityChanged()
    {
        NotificationCenter.default.post(name: UDP.didDisconnect, object: nil)
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
}


extension ConnectionManager {
    
    func connect(receiveBlock:@escaping (Data)->()) throws
    {
        if let reachabilityStatus = appDelegate.reachability?.currentReachabilityStatus, case .reachableViaWiFi = reachabilityStatus{
            
            _receiveBlock = receiveBlock
            if let rmPort = remotePort, let inPort = incommingPort, let addr = remoteAddress{
            
                try socket.bind(toPort: UInt16(inPort))
                try socket.connect(toHost: addr ,onPort : UInt16(rmPort))
                try socket.beginReceiving()
               
            }else{
                throw(UDPError.paramsMissing)
            }
        }else{
            throw(UDPError.noWifi)
        }
        
    }
    
    func sendData(data:Data)
    {
        if socket.isConnected(){
            socket.send(data, withTimeout: 0, tag: 0)
        }
    }

}


extension ConnectionManager {
    
    internal func
        udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data)
    {
        
        NotificationCenter.default.post(name: UDP.didConnect, object: nil)
        
    }
    
    internal func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?)
    {
        NotificationCenter.default.post(name: UDP.failedToConnect, object: error)
    }
    
    internal func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?)
    {
        NotificationCenter.default.post(name: UDP.didDisconnect, object: error)
        let alert = UIAlertController(title: "Error", message:"Socket was closed. Probably because the remote host stopped accepting connections.", preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .cancel, handler: nil))
        appDelegate.visibleVC(nil)?.present(alert, animated: true, completion: nil)
    }
    
    internal func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?)
    {
        if let recBlock = _receiveBlock{
            recBlock(data)
        }
    }
    
    internal func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?)
    {
        NotificationCenter.default.post(name: UDP.didDisconnect, object: error)
    }
    
}


extension ConnectionManager {
    
    static func getWiFiAddress() -> String? {
        var address : String?
        let interfaceName = Platform.isSimulator ? "en1" : "en0"
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                
                if  name == interfaceName {
                    
                    // Convert interface address to a human readable string:
                    var addr = interface.ifa_addr.pointee
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(&addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return address
    }
}

