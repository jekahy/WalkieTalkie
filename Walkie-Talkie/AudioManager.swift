//
//  AudioManager.swift
//  Walkie-Talkie
//
//  Created by Eugene on 06.03.17.
//  Copyright © 2017 Eugenious. All rights reserved.
//

import Foundation
import AVFoundation
import ReachabilitySwift

enum MicState {
    case On
    case Off
}

enum SpeakerType:Int {
    case LoudSpeaker = 0
    case InternaSpeaker
}

final class AudioManager {
    
    static let manager: AudioManager = AudioManager()
    
    fileprivate let audioEngine = AVAudioEngine()
    fileprivate let audioPlayer = AVAudioPlayerNode()
    fileprivate let downMixer = AVAudioMixerNode()
    fileprivate let outputSampleRate = 11025.0
    fileprivate let outputIOBufferSize = 250.0
    fileprivate let inputSampleRate = 11025.0
    
    fileprivate var playerStarted = false
    
    fileprivate let incommingFormat = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatFloat32, sampleRate: 11025, channels: 1, interleaved: false)
    
    fileprivate let audioSession = AVAudioSession.sharedInstance()
    
    private init()
    {
        setupAudioSession()
        initAudioEngine()
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: ReachabilityChangedNotification, object: nil)
    }
    
    private func setupAudioSession()
    {
        do {
            
            //            let audioSession = AVAudioSession.sharedInstance()
            
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            
            try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.none)
            
            try audioSession.setPreferredSampleRate(outputSampleRate)
            //            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with:.defaultToSpeaker)
            //            try audioSession.setPreferredInputNumberOfChannels(1)
            //            try audioSession.setPreferredOutputNumberOfChannels(1)
            //            try audioSession.setPreferredIOBufferDuration(outputIOBufferSize)
            try audioSession.setActive(true)
        } catch  let error as NSError {
            print ("Audio session error: \(error)")
        }
    }
    
    private func initAudioEngine()
    {
        
        if (!playerStarted){
            setupInput()
            setupOutput()
        }
        
        if(!audioEngine.isRunning){
            audioEngine.prepare()
        }
    }
    
    private func setupOutput()
    {
        
        assert(audioEngine.inputNode != nil)
        
        let input = audioEngine.inputNode
        
        print ("\(String(describing: input?.outputFormat(forBus: 1)))")
        
        downMixer.volume = 0.0
        
        let mainMixer = audioEngine.mainMixerNode
        audioEngine.attach(downMixer)
        audioEngine.connect(input!, to: downMixer, format: input?.inputFormat(forBus: 0))//use default input format
        audioEngine.connect(downMixer, to: mainMixer, format: incommingFormat)
    
        
        print ("out format=\(downMixer.outputFormat(forBus: 0))")
        
        do{
            try audioEngine.start()
        }catch{
            print("startTalking err=\(error)")
        }
        
    }
    
    
    private func setupInput()
    {
        let mainMixer = audioEngine.mainMixerNode
        audioEngine.attach(audioPlayer)
        audioEngine.connect(audioPlayer, to:mainMixer, format: incommingFormat)
        playerStarted = true
    }

    
    
    func playData(data:Data){
        if (data.count  > 0 && playerStarted && audioEngine.isRunning)
        {
            let buffer = toPCMBuffer(data: data as NSData)
            audioPlayer.scheduleBuffer(buffer, completionHandler: nil)
            audioPlayer.prepare(withFrameCount: buffer.frameCapacity)
            
            audioPlayer.play()
        }else{
            audioPlayer.stop()
        }
    }
    
    
    
    fileprivate func processMicData(buffer : AVAudioPCMBuffer, timeE: AVAudioTime)
    {
        
        //        buffer.frameLength = AVAudioFrameCount(self.outputIOBufferSize)
        
        buffer.frameLength = 250
        print ("time = \(timeE)")        
        ConnectionManager.manager.sendData(data:self.toNSData(PCMBuffer: buffer) as Data)
    }
    
    
    @objc fileprivate func reachabilityChanged()
    {
        guard let reachability = appDelegate.reachability else {
            return
        }
        if case .reachableViaWiFi = reachability.currentReachabilityStatus {
            try? audioEngine.start()
        }else{
            audioEngine.pause()
        }
    }
    
}

extension AudioManager {
    
    fileprivate func toNSData(PCMBuffer: AVAudioPCMBuffer) -> NSData
    {
        
        let channelCount = 1
        let channels = UnsafeBufferPointer(start: PCMBuffer.floatChannelData, count: channelCount)
        
        let ch0Data = NSData(bytes: channels[0], length:Int(PCMBuffer.frameLength *
            PCMBuffer.format.streamDescription.pointee.mBytesPerFrame))
        return ch0Data
    }
    
    fileprivate func toPCMBuffer(data: NSData) -> AVAudioPCMBuffer
    {
        
        let PCMBuffer = AVAudioPCMBuffer(pcmFormat: incommingFormat, frameCapacity: UInt32(data.length) / incommingFormat.streamDescription.pointee.mBytesPerFrame)
        PCMBuffer.frameLength = PCMBuffer.frameCapacity
        
        let channels = UnsafeBufferPointer(start: PCMBuffer.floatChannelData, count: Int(PCMBuffer.format.channelCount))
        data.getBytes(UnsafeMutableRawPointer(channels[0]) , length: data.length)
        return PCMBuffer
    }
}


extension AudioManager {
    
    func toggleMicToState(state:MicState)
    {
        switch state {
        case .On:
            downMixer.installTap(onBus: 0, bufferSize: 250, format: downMixer.outputFormat(forBus: 0), block: processMicData)
        default:
            downMixer.removeTap(onBus: 0)
        }
    }
    
    
    func toggleSpeaker(type:SpeakerType) throws
    {
        switch type {
        case .LoudSpeaker:
            try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
            break
        default:
            try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.none)
        }
       
    }
}
