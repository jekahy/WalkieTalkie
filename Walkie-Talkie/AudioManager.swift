//
//  AudioManager.swift
//  Walkie-Talkie
//
//  Created by Eugene on 06.03.17.
//  Copyright © 2017 Eugenious. All rights reserved.
//

import AVFoundation
import RxReachability
import RxSwift

final class AudioManager {
    
    enum MicState {
        case On
        case Off
    }
    
    enum SpeakerType:Int {
        case LoudSpeaker = 0
        case InternaSpeaker
    }
    
    fileprivate let audioEngine = AVAudioEngine()
    fileprivate let audioPlayer = AVAudioPlayerNode()
    fileprivate let downMixer = AVAudioMixerNode()
    fileprivate let outputSampleRate = 11025.0
    fileprivate let outputIOBufferSize = 250.0
    fileprivate let inputSampleRate = 11025.0
    
    fileprivate var playerCofigured = false
    
    fileprivate let incommingFormat = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatFloat32, sampleRate: 11025, channels: 1, interleaved: false)
    
    fileprivate let audioSession = AVAudioSession.sharedInstance()
    fileprivate let audioDataOutputSubj = PublishSubject<Data>()
    private (set) lazy var audioDataOutput:Observable<Data> = self.audioDataOutputSubj.asObservable()
    
    private let disposeBag = DisposeBag()

    init(_ micToggler:Observable<MicState>, speakerToggle:Observable<SpeakerType>)throws
    {
        
        try setupAudioSession()
        initAudioEngine()
        
        appDelegate.reachability?.rx.status.subscribe(onNext:{ [weak self] status in
            
            if case .reachableViaWiFi = status {
                try? self?.audioEngine.start()
            }else{
                self?.audioEngine.pause()
            }
        }).disposed(by:disposeBag)
        
        micToggler.subscribe(onNext: { [weak self] state in
            
            switch state {
            case .On:
                guard let srtSelf = self else {
                    return
                }
                srtSelf.downMixer.installTap(onBus: 0, bufferSize: UInt32(srtSelf.outputIOBufferSize), format: srtSelf.downMixer.outputFormat(forBus: 0), block: srtSelf.processMicData)
            case .Off:
                self?.downMixer.removeTap(onBus: 0)
            }

        }).disposed(by: disposeBag)
        
        speakerToggle.subscribe(onNext: {[weak self] speakerType in
            
            let port:AVAudioSessionPortOverride = speakerType == .LoudSpeaker ? .speaker : .none
            try? self?.audioSession.overrideOutputAudioPort(port)
            
        }).disposed(by: disposeBag)
    }
    
    private func setupAudioSession() throws
    {

        try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        
        try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.none)
        
        try audioSession.setPreferredSampleRate(outputSampleRate)
    
        try audioSession.setActive(true)
    }
    
    private func initAudioEngine()
    {
        
        if (!playerCofigured){
            setupMicInput()
            setupLocalOutput()
        }
        
        if(!audioEngine.isRunning){
            audioEngine.prepare()
        }
    }
    
    private func setupLocalOutput()
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
    
    
    private func setupMicInput()
    {
        let mainMixer = audioEngine.mainMixerNode
        audioEngine.attach(audioPlayer)
        audioEngine.connect(audioPlayer, to:mainMixer, format: incommingFormat)
        playerCofigured = true
    }
    
    
    func playData(data:Data){
        
        if (data.count  > 0 && playerCofigured && audioEngine.isRunning)
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
        buffer.frameLength = 250
        print ("time = \(timeE)")
        let data = self.toData(PCMBuffer: buffer)
        audioDataOutputSubj.onNext(data)
    }
    
}

extension AudioManager {
    
    fileprivate func toData(PCMBuffer: AVAudioPCMBuffer) -> Data
    {
        
        let channelCount = 1
        let channels = UnsafeBufferPointer(start: PCMBuffer.floatChannelData, count: channelCount)
        
        let ch0Data = NSData(bytes: channels[0], length:Int(PCMBuffer.frameLength *
            PCMBuffer.format.streamDescription.pointee.mBytesPerFrame))
        return ch0Data as Data
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

