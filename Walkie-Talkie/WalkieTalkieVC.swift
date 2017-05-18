//
//  WalkieTalkieVC.swift
//  Walkie-Talkie
//
//  Created by Eugene on 18.02.17.
//  Copyright © 2017 Eugenious. All rights reserved.
//

import UIKit
import CocoaAsyncSocket
import AVFoundation
import ReachabilitySwift


class WalkieTalkieVC: UIViewController {
    
    fileprivate let failedToObtainIPMess = "Failed to obtain =("
    
    @IBOutlet weak var connectionIndicator: UIView!
    @IBOutlet weak var talkBtn: UIButton!
    @IBOutlet weak var connectBtn: LoadingButton!
    @IBOutlet weak var speakerSegmContr: UISegmentedControl!
    @IBOutlet weak var addressView: AddressView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        setupNotifications()
        updateReachability()

    }
    

    private func setupNotifications()
    {
        NotificationCenter.default.addObserver(forName: UDP.didConnect, object: nil, queue: nil, using:connectionChanged)
        NotificationCenter.default.addObserver(forName: UDP.didDisconnect, object: nil, queue: nil, using:connectionChanged)
        NotificationCenter.default.addObserver(forName: UDP.failedToConnect, object: nil, queue:nil, using:connectionChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(updateReachability), name: ReachabilityChangedNotification, object: nil)
    }
    
    private func connectionChanged(not:Notification)
    {
        self.connectBtn.hideLoading()

        switch not.name {
            case UDP.didConnect:
                toggleConnectionIndicator(enable: true)
                connectBtn.isEnabled=false
                talkBtn.backgroundColor = UIColor.green
                talkBtn.isEnabled = true
                speakerSegmContr.isEnabled = true
            default:
                // Failed to connect or did disconnect
                toggleConnectionIndicator(enable: false)
                if let reachability = appDelegate.reachability, case .reachableViaWiFi = reachability.currentReachabilityStatus {
                    connectBtn.isEnabled = true
                }
                talkBtn.backgroundColor = UIColor.red
                talkBtn.isEnabled = false
                speakerSegmContr.isEnabled = false
        }
    }
    
    private func toggleConnectionIndicator(enable:Bool)
    {
        
        connectionIndicator.backgroundColor = enable ? .green : .gray
    }
    
    
    @objc fileprivate func updateReachability()
    {
        
        guard let reachability = appDelegate.reachability else {
            return
        }
        addressView.update(reachability: reachability.currentReachabilityStatus, address: ConnectionManager.getWiFiAddress())
        if case .reachableViaWiFi = reachability.currentReachabilityStatus {
            connectBtn.isEnabled = true
        }else{
            connectBtn.hideLoading()
            connectBtn.isEnabled = false
        }
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension WalkieTalkieVC {
    
    @IBAction func connectTapped(_ sender: LoadingButton)
    {
        connectBtn.showLoading()
        do {
            try ConnectionManager.manager.connect(receiveBlock: AudioManager.manager.playData)
        }catch{
            let errMess = error.localizedDescription
            showAlert(title: "Error", mess: errMess)
        }
    }
    
    
    @IBAction func startTalking(_ sender: Any)
    {
        AudioManager.manager.toggleMicToState(state: .On)
    }
    
    
    @IBAction func stopTalking(_ sender: Any)
    {
        AudioManager.manager.toggleMicToState(state: .Off)
    }
    
    
    @IBAction func speakerChanged(_ sender: UISegmentedControl)
    {
        do {
            try AudioManager.manager.toggleSpeaker(type: SpeakerType(rawValue:sender.selectedSegmentIndex)!)
        }catch {
            sender.selectedSegmentIndex = sender.selectedSegmentIndex == 0 ? 1 : 0
            showAlert(title: "Error", mess: "An error occured while trying to switch the speaker: \(error.localizedDescription)")
        }
    }

}
