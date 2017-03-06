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


class WalkieTalkieVC: UIViewController {
    
    @IBOutlet weak var connectionIndicator: UIView!
    @IBOutlet weak var talkBtn: UIButton!
    @IBOutlet weak var connectBtn: LoadingButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        _ = AudioManager.manager
        
        setupNotifications()
    }

    private func setupNotifications()
    {
        NotificationCenter.default.addObserver(forName: UDP.didConnect, object: nil, queue: OperationQueue.main, using:connectionChanged)
        NotificationCenter.default.addObserver(forName: UDP.didDisconnect, object: nil, queue: OperationQueue.main, using:connectionChanged)
        NotificationCenter.default.addObserver(forName: UDP.failedToConnect, object: nil, queue: OperationQueue.main, using:connectionChanged)
    }
    
    
    private func connectionChanged(not:Notification)
    {
        switch not.name {
            case UDP.didConnect:
                self.toggleConnectionIndicator(enable: true)
                self.connectBtn.hideLoading()
                self.connectBtn.isEnabled=false
                self.talkBtn.isEnabled = true
            default:
                // Failed to connect or did disconnect
                self.toggleConnectionIndicator(enable: false)
                self.connectBtn.hideLoading()
                self.connectBtn.isEnabled=true
                self.talkBtn.isEnabled = false
        }
    }
    
    // MARK: IBActions
    
    @IBAction func connectTapped(_ sender: LoadingButton)
    {
        connectBtn.showLoading()
        ConnectionManager.manager.connect(receiveBlock: AudioManager.manager.playData)
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
        AudioManager.manager.toggleSpeaker(type: SpeakerType(rawValue:sender.selectedSegmentIndex)!)
        
    }
    
    // MARK:
    
    private func toggleConnectionIndicator(enable:Bool){
        
        connectionIndicator.backgroundColor = enable ? .green : .gray
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
}

