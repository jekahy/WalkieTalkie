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
    @IBOutlet weak var speakerSegmContr: UISegmentedControl!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        _ = AudioManager.manager
        
        setupNotifications()
    }

    private func setupNotifications()
    {
        NotificationCenter.default.addObserver(forName: UDP.didConnect, object: nil, queue: nil, using:connectionChanged)
        NotificationCenter.default.addObserver(forName: UDP.didDisconnect, object: nil, queue: nil, using:connectionChanged)
        NotificationCenter.default.addObserver(forName: UDP.failedToConnect, object: nil, queue:nil, using:connectionChanged)
    }
    
    
    private func connectionChanged(not:Notification)
    {
        self.connectBtn.hideLoading()

        switch not.name {
            case UDP.didConnect:
                toggleConnectionIndicator(enable: true)
                connectBtn.isEnabled=false
                talkBtn.isEnabled = true
                speakerSegmContr.isEnabled = true
            default:
                // Failed to connect or did disconnect
                toggleConnectionIndicator(enable: false)
                connectBtn.isEnabled=true
                talkBtn.isEnabled = false
                speakerSegmContr.isEnabled = false
        }
    }
    
    private func toggleConnectionIndicator(enable:Bool)
    {
        
        connectionIndicator.backgroundColor = enable ? .green : .gray
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension WalkieTalkieVC {
    
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
        do {
            try AudioManager.manager.toggleSpeaker(type: SpeakerType(rawValue:sender.selectedSegmentIndex)!)
        }catch {
            sender.selectedSegmentIndex = sender.selectedSegmentIndex == 0 ? 1 : 0
            showAlert(titles: "Error", mess: "An error occured while trying to switch the speaker: \(error.localizedDescription)")
        }
    }

}
