//
//  ViewController.swift
//  Walkie-Talkie
//
//  Created by Eugene on 18.02.17.
//  Copyright © 2017 Eugenious. All rights reserved.
//

import UIKit
import CocoaAsyncSocket
import AVFoundation



class ViewController: UIViewController , GCDAsyncUdpSocketDelegate {
    
    @IBOutlet weak var connectionIndicator: UIView!
    @IBOutlet weak var talkBtn: UIButton!
    @IBOutlet weak var connectBtn: LoadingButton!

    private let audioEngine: AVAudioEngine = AVAudioEngine()
    private let audioPlayer: AVAudioPlayerNode = AVAudioPlayerNode()
    private let outputSampleRate = 11025.0
    private let outputIOBufferSize = 250.0
    private let inputSampleRate = 11025.0
    
    private var socket:GCDAsyncUdpSocket!
    private var playerStarted = false
    private var socketInit = false
    private let incommingFormat = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatFloat32, sampleRate: 11025, channels: 1, interleaved: false)

    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupAudioSession()
        initAudioEngine()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(UDP_DID_CONNECT), object: nil, queue: OperationQueue.main) { not in
            self.toggleConnectionIndicator(enable: true)
            self.connectBtn.hideLoading()
            self.connectBtn.isEnabled=false
            self.talkBtn.isEnabled = true
            
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(UDP_DID_DISCONNECT), object: nil, queue: OperationQueue.main) { not in
            self.toggleConnectionIndicator(enable: false)
            self.connectBtn.hideLoading()
            self.connectBtn.isEnabled=true
            self.talkBtn.isEnabled = false
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(UDP_FAILED_TO_CONNECT), object: nil, queue: OperationQueue.main) { not in
            self.toggleConnectionIndicator(enable: false)
            self.connectBtn.hideLoading()
            self.connectBtn.isEnabled=true
            self.talkBtn.isEnabled = false
        }
    }

    
    // MARK: IBActions
    
    @IBAction func connectTapped(_ sender: LoadingButton) {
        connectBtn.showLoading()
        ConnectionManager.manager.connect(receiveBlock: playReceivedData)
    }
    
    @IBAction func startTalking(_ sender: Any) {
        do{
            try audioEngine.start()
        }catch{
            print("startTalking err=\(error)")
        }
    }
    
    @IBAction func stopTalking(_ sender: Any) {
        audioEngine.pause()
    }
    
    // MARK:
    
    private func initAudioEngine(){
        
        if (!playerStarted){
            setupInput()
            setupOutput()
        }
        
        if(!audioEngine.isRunning){
            audioEngine.prepare()
        }
    }
    
    
    private func setupOutput(){
    
        assert(audioEngine.inputNode != nil)
        
        let input = audioEngine.inputNode
        
        print ("\(input?.outputFormat(forBus: 1))")
        
        
        let downMixer = AVAudioMixerNode()
        downMixer.volume = 0.0
        let mainMixer = audioEngine.mainMixerNode
        let format16KHzMono = AVAudioFormat.init(commonFormat: .pcmFormatFloat32, sampleRate: inputSampleRate, channels: 1, interleaved: false)
        
        audioEngine.attach(downMixer)
        
        audioEngine.connect(input!, to: downMixer, format: input?.inputFormat(forBus: 0))//use default input format
        audioEngine.connect(downMixer, to: mainMixer, format: format16KHzMono)
        
        
//        mainMixer.volume = 0
//        mainMixer.outputVolume = 0
        
        
        print ("out format=\(downMixer.outputFormat(forBus: 0))")
        downMixer.installTap(onBus: 0, bufferSize: 250, format: downMixer.outputFormat(forBus: 0), block: self.micInputBlock)
        
    }
    
    private func setupInput(){
        let mainMixer = audioEngine.mainMixerNode
        audioEngine.attach(audioPlayer)
        audioEngine.connect(audioPlayer, to:mainMixer, format: incommingFormat)
        playerStarted = true
    }

    
    private func micInputBlock(buffer : AVAudioPCMBuffer, timeE: AVAudioTime){
        
//        buffer.frameLength = AVAudioFrameCount(self.outputIOBufferSize)
        buffer.frameLength = 250
        print ("time = \(timeE)")
//        print (self.toNSData(PCMBuffer: buffer).length)
        
        ConnectionManager.manager.sendData(data:self.toNSData(PCMBuffer: buffer) as Data)
    }
    
    private func playReceivedData(data:Data){
        if (data.count  > 0 && playerStarted && audioEngine.isRunning){
            let buffer = toPCMBuffer(data: data as NSData)
            audioPlayer.scheduleBuffer(buffer, completionHandler: nil)
            audioPlayer.prepare(withFrameCount: buffer.frameCapacity)
            
            audioPlayer.play()
        }else{
            audioPlayer.stop()
        }
    }

    
   
    
    private func toNSData(PCMBuffer: AVAudioPCMBuffer) -> NSData {
        
        let channelCount = 1
        let channels = UnsafeBufferPointer(start: PCMBuffer.floatChannelData, count: channelCount)
        
        let ch0Data = NSData(bytes: channels[0], length:Int(PCMBuffer.frameLength *
            PCMBuffer.format.streamDescription.pointee.mBytesPerFrame))
//        print(ch0Data)
        
        return ch0Data
    }
    
    private func toPCMBuffer(data: NSData) -> AVAudioPCMBuffer {
       
        let PCMBuffer = AVAudioPCMBuffer(pcmFormat: incommingFormat, frameCapacity: UInt32(data.length) / incommingFormat.streamDescription.pointee.mBytesPerFrame)
        PCMBuffer.frameLength = PCMBuffer.frameCapacity
        
        let channels = UnsafeBufferPointer(start: PCMBuffer.floatChannelData, count: Int(PCMBuffer.format.channelCount))
        data.getBytes(UnsafeMutableRawPointer(channels[0]) , length: data.length)
        return PCMBuffer
    }
    
    private func setupAudioSession() {
        do {
            
            let audioSession = AVAudioSession.sharedInstance()
            
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
//            try audioSession.setMode(AVAudioSessionModeSpokenAudio)
            try audioSession.setPreferredSampleRate(outputSampleRate)
//            try audioSession.setPreferredInputNumberOfChannels(1)
//            try audioSession.setPreferredOutputNumberOfChannels(1)
//            try audioSession.setPreferredIOBufferDuration(outputIOBufferSize)
            try audioSession.setActive(true)
        } catch  let error as NSError {
            print ("error\(error)")
        }
    }

    
    
//    func convertPCMBufferToAAC(inBuffer : AVAudioPCMBuffer) -> Void {
//        let inputFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32,
//                                        sampleRate: 8000, channels: 1,
//                                        interleaved: false)
//        
//        var outDesc = AudioStreamBasicDescription(mSampleRate: 8000,
//                                                  mFormatID: kAudioFormatMPEG4AAC,
//                                                  mFormatFlags: 0,
//                                                  mBytesPerPacket: 0,
//                                                  mFramesPerPacket: 0,
//                                                  mBytesPerFrame: 0,
//                                                  mChannelsPerFrame: 1,
//                                                  mBitsPerChannel: 0,
//                                                  mReserved: 0)
//        
//        let outputFormat = AVAudioFormat(streamDescription: &outDesc)
//        let converter = AVAudioConverter(from: inputFormat, to: outputFormat)
//        
//
//        let outBuffer = AVAudioCompressedBuffer(format: outputFormat,
//                                                packetCapacity: 8,
//                                                maximumPacketSize: converter.maximumOutputPacketSize)
//        
//        let inputBlock : AVAudioConverterInputBlock = {
//            inNumPackets, outStatus in
//            outStatus.pointee = AVAudioConverterInputStatus.haveData
//            return inBuffer
//        }
//        var error : NSError?
//        let status = converter.convert(to: outBuffer, error: &error, withInputFrom: inputBlock)
//        print (status)
//    }
//    
    
    private func toggleConnectionIndicator(enable:Bool){
        
        connectionIndicator.backgroundColor = enable ? .green : .gray
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
}

