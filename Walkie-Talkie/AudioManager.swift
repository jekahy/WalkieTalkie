//
//  AudioManager.swift
//  Walkie-Talkie
//
//  Created by Eugene on 19.02.17.
//  Copyright © 2017 Eugenious. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
//typealias AURenderCallback = (UnsafeMutableRawPointer, UnsafeMutablePointer<AudioUnitRenderActionFlags>, UnsafePointer<AudioTimeStamp>, UInt32, UInt32, UnsafeMutablePointer<AudioBufferList>?) -> OSStatus
//
//
//
//func renderCallback(inRefCon:UnsafeMutableRawPointer,
//                    ioActionFlags:UnsafeMutablePointer<AudioUnitRenderActionFlags>,
//                    inTimeStamp:UnsafePointer<AudioTimeStamp>,
//                    inBusNumber:UInt32,
//                    inNumberFrames:UInt32,
//                    ioData:UnsafeMutablePointer<AudioBufferList>?) -> OSStatus {
//    let delegate = unsafeBitCast(inRefCon, to: AURenderCallbackDelegate.self)
//    let result = delegate.performRender(ioActionFlags: ioActionFlags,
//                                        inTimeStamp: inTimeStamp,
//                                        inBusNumber: inBusNumber,
//                                        inNumberFrames: inNumberFrames,
//                                        ioData: ioData!)
//    return result
//}

//
//@objc protocol AURenderCallbackDelegate {
//    func performRender(ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
//                       inTimeStamp: UnsafePointer<AudioTimeStamp>,
//                       inBusNumber: UInt32,
//                       inNumberFrames: UInt32,
//                       ioData: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus
//}
//
//class AudioManager:AURenderCallbackDelegate {
//    
//    private let
//    preferredIOBufferDuration = 0.005, // a value of 5 ms seems to introduce ~1% of CPU usage on iPhone 5
//    inputBus  = AudioUnitElement(1),
//    outputBus = AudioUnitElement(0)
//    
//    private var
//    active = false,
//    audioUnit:AudioComponentInstance?
//    
//    
//    
//    
//    func prepareAudioInput() {
//      
//        active = true
//        
//        do {
//            try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(preferredIOBufferDuration)
//        } catch let error as NSError{
//            print("error: \(error)")
//        }
//        
//        
//        
//        var status:OSStatus
////        var audioUnit:AudioComponentInstance?
//        
//        var desc: AudioComponentDescription = AudioComponentDescription()
//        desc.componentType = kAudioUnitType_Output
//        desc.componentSubType = kAudioUnitSubType_VoiceProcessingIO
//        desc.componentFlags = 0
//        desc.componentFlagsMask = 0
//        desc.componentManufacturer = kAudioUnitManufacturer_Apple
//        
//        
//        let inputComponent:AudioComponent = AudioComponentFindNext(nil, &desc)!
//        assert(AudioComponentInstanceNew(inputComponent, &audioUnit) == noErr)
//        
//        status = AudioComponentInstanceNew(inputComponent, &audioUnit);
//        print (status)
//        
//        // Активируем IO для записи звука
//        var flag = UInt32(1)
//        status = AudioUnitSetProperty(audioUnit!, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, inputBus, &flag, UInt32(MemoryLayout<UInt32>.size))
//        print (status)
//        
//        status = AudioUnitSetProperty(audioUnit!, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, outputBus, &flag, UInt32(MemoryLayout<UInt32>.size))
//        print (status)
//
//
//        
//        var audioFormat:AudioStreamBasicDescription  = AudioStreamBasicDescription()
//        
//        // Описываем формат звука
//        audioFormat.mSampleRate = 8000.00;
//        audioFormat.mFormatID = kAudioFormatLinearPCM;
//        audioFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked
//        audioFormat.mFramesPerPacket = 1;
//        audioFormat.mChannelsPerFrame = 1;
//        audioFormat.mBitsPerChannel = 16;
//        audioFormat.mBytesPerPacket = 2;
//        audioFormat.mBytesPerFrame = 2;
//        
//        
//        do{
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
//        }catch{
//            print ("error\(error)")
//        }
//        
//        // Apply format
//        
//       status = AudioUnitSetProperty(
//            audioUnit!,
//            AudioUnitPropertyID(kAudioUnitProperty_StreamFormat),
//            AudioUnitScope(kAudioUnitScope_Output),
//            1,
//            &audioFormat,
//            UInt32(MemoryLayout<AudioStreamBasicDescription>.size)
//        )
//        print (status)
//        
//
//        status = AudioUnitSetProperty(audioUnit!,
//                                      AudioUnitPropertyID(kAudioUnitProperty_StreamFormat),
//                                      AudioUnitScope(kAudioUnitScope_Input),
//                                      0, // Output
//            &audioFormat,
//            UInt32(MemoryLayout<AudioStreamBasicDescription>.size))
//        
//        print (status)
//        
//        
//        
//        
//        
//        
//        
//        // Активируем Callback для записи звука
//        
//        
//        
////        var inputCallbackStruct = AURenderCallbackStruct(inputProc: renderCallback, inputProcRefCon:Unmanaged.passUnretained(self).toOpaque())
//        
////        var renderCallbackStruct = AURenderCallbackStruct(inputProc: renderCallback, inputProcRefCon: Unmanaged.passUnretained(self).toOpaque())
//        
////        status = AudioUnitSetProperty(audioUnit!, AudioUnitPropertyID(kAudioUnitProperty_SetRenderCallback), AudioUnitScope(kAudioUnitScope_Global), 0, &renderCallbackStruct, UInt32(MemoryLayout<AURenderCallbackStruct>.size))
////        print (status)
//        
//        flag = 0
//        status = AudioUnitSetProperty(audioUnit!, AudioUnitPropertyID(kAudioUnitProperty_ShouldAllocateBuffer), AudioUnitScope(kAudioUnitScope_Output), 1, &flag, UInt32(MemoryLayout<UInt32>.size))
//        print (status)
//        
//        status = AudioUnitInitialize(audioUnit!)
//        print (status)
//        status = AudioOutputUnitStart(audioUnit!)
//        print (status)
//        
//        status = AudioUnitAddRenderNotify(audioUnit!, renderCallback, Unmanaged.passUnretained(self).toOpaque())
//        print (status)
//        
//    }
//    
//
//    func performRender(ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
//                       inTimeStamp: UnsafePointer<AudioTimeStamp>,
//                       inBusNumber: UInt32,
//                       inNumberFrames: UInt32,
//                       ioData: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus
//    {
//        print("Hello there!")
//        return noErr
//    }

//    ===============
//    private var renderCallback: AURenderCallback = { (inRefCon, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, ioData) -> OSStatus in
//        
//        let audioMetering = unsafeBitCast(inRefCon, to: AudioManager.self) // get object
//        
////        if audioMetering.active == true {
//            // ioData holds the samples and is used for audio output
//            switch AudioUnitRender(audioMetering.audioUnit!, ioActionFlags, inTimeStamp, audioMetering.inputBus, inNumberFrames, ioData!) {
//            case noErr:
//                print("o kurwa!!")
//                break
//                
//            case kAudioUnitErr_CannotDoInCurrentContext: // it seems safe to continue with this error; output is just muted...
//                print("kAudioUnitErr_CannotDoInCurrentContext")
//                
//            default: assert(false)
//            }
//            
//            // 'look-at-samples-to-render-cool-graphics-code' (deterministic and non-blocking code)
////        }
//        
//        return noErr
//    }
    
    
//    init() {
//        
//        var status: OSStatus
//        
//        do {
//            try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(preferredIOBufferDuration)
//        } catch let error as NSError {
//            print(error)
//        }
//        
//        
//        var desc: AudioComponentDescription = AudioComponentDescription()
//        desc.componentType = kAudioUnitType_Output
//        desc.componentSubType = kAudioUnitSubType_VoiceProcessingIO
//        desc.componentFlags = 0
//        desc.componentFlagsMask = 0
//        desc.componentManufacturer = kAudioUnitManufacturer_Apple
//        
//        let inputComponent: AudioComponent = AudioComponentFindNext(nil, &desc)!
//        
//        status = AudioComponentInstanceNew(inputComponent, &audioUnit)
//        checkStatus(status)
//        
//        var flag = UInt32(1)
//        status = AudioUnitSetProperty(audioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, kInputBus, &flag, UInt32(sizeof(UInt32)))
//        checkStatus(status)
//        
//        status = AudioUnitSetProperty(audioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, kOutputBus, &flag, UInt32(sizeof(UInt32)))
//        checkStatus(status)
//        
//        var audioFormat: AudioStreamBasicDescription! = AudioStreamBasicDescription()
//        audioFormat.mSampleRate = 8000
//        audioFormat.mFormatID = kAudioFormatLinearPCM
//        audioFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked
//        audioFormat.mFramesPerPacket = 1
//        audioFormat.mChannelsPerFrame = 1
//        audioFormat.mBitsPerChannel = 16
//        audioFormat.mBytesPerPacket = 2
//        audioFormat.mBytesPerFrame = 2
//        
//        status = AudioUnitSetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, kInputBus, &audioFormat, UInt32(sizeof(UInt32)))
//        checkStatus(status)
//        
//        
//        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
//        status = AudioUnitSetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, kOutputBus, &audioFormat, UInt32(sizeof(UInt32)))
//        checkStatus(status)
//        
//        
//        // Set input/recording callback
//        var inputCallbackStruct = AURenderCallbackStruct(inputProc: recordingCallback, inputProcRefCon: UnsafeMutablePointer(unsafeAddressOf(self)))
//        AudioUnitSetProperty(audioUnit, AudioUnitPropertyID(kAudioOutputUnitProperty_SetInputCallback), AudioUnitScope(kAudioUnitScope_Global), 1, &inputCallbackStruct, UInt32(sizeof(AURenderCallbackStruct)))
//        
//        
//        // Set output/renderar/playback callback
//        var renderCallbackStruct = AURenderCallbackStruct(inputProc: playbackCallback, inputProcRefCon: UnsafeMutablePointer(unsafeAddressOf(self)))
//        AudioUnitSetProperty(audioUnit, AudioUnitPropertyID(kAudioUnitProperty_SetRenderCallback), AudioUnitScope(kAudioUnitScope_Global), 0, &renderCallbackStruct, UInt32(sizeof(AURenderCallbackStruct)))
//        
//        
//        flag = 0
//        status = AudioUnitSetProperty(audioUnit, kAudioUnitProperty_ShouldAllocateBuffer, kAudioUnitScope_Output, kInputBus, &flag, UInt32(sizeof(UInt32)))
//    }
    
    
//    
//    func startRecording() {
////        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
//        
//        let settings = [
//            AVFormatIDKey: Int(kAudioFormatLinearPCM),
//            AVSampleRateKey: 8000,
//            AVNumberOfChannelsKey: 1,
//            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
//        ]
//        
//        do {
//            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
//            audioRecorder.delegate = self
//            audioRecorder.record()
//            
//            recordButton.setTitle("Tap to Stop", for: .normal)
//        } catch {
//            finishRecording(success: false)
//        }
//    }
    
    
//    void AudioInputCallback(void * inUserData,
//    AudioQueueRef inAQ,
//    AudioQueueBufferRef inBuffer,
//    const AudioTimeStamp * inStartTime,
//    UInt32 inNumberPacketDescriptions,
//    const AudioStreamPacketDescription * inPacketDescs)
//    {
//    RecordState * recordState = (RecordState*)inUserData;
//    if (!recordState->recording)
//    {
//    printf("Not recording, returning\n");
//    }
//    
//    //printf("Writing buffer %lld\n", recordState->currentPacket);
//    OSStatus status = AudioFileWritePackets(recordState->audioFile,
//    false,
//    inBuffer->mAudioDataByteSize,
//    inPacketDescs,
//    recordState->currentPacket,
//    &inNumberPacketDescriptions,
//    inBuffer->mAudioData);
//    if (status == 0)
//    {
//    recordState->currentPacket += inNumberPacketDescriptions;
//    
//    NSUInteger length = inNumberPacketDescriptions * 2;
//    NSData* audioData = [NSData dataWithBytes:inBuffer->mAudioData length:length];
//    
//    // send data to service through a websocket we previously setup
//    [webSocket send: audioData];
//    }
    
//    AudioQueueEnqueueBuffer(recordState->queue, inBuffer, 0, NULL);
//    }
//    
    
    
//
//}



//final class AudioMetering: NSObject {
//    
//    private let
//    preferredIOBufferDuration = 0.005, // a value of 5 ms seems to introduce ~1% of CPU usage on iPhone 5
//    inputBus  = AudioUnitElement(1),
//    outputBus = AudioUnitElement(0)
//    
//    private var
//    active = false,
//    audioUnit:AudioUnit?
//    
//    /*
//     This method is called when the Remote I/O audio unit has new samples available. The method
//     renders new samples; process them if needed and returns them for output. The callback is
//     called from AURemoteIO::IOThread and has to return ASAP (hard deadline).
//     */
//    private let renderCallback: AURenderCallback = { (inRefCon, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, ioData) -> OSStatus in
//        
//        let audioMetering = unsafeBitCast(inRefCon, to: AudioMetering.self) // get object
//        
//        if audioMetering.active == true {
//            // ioData holds the samples and is used for audio output
//            switch AudioUnitRender(audioMetering.audioUnit!, ioActionFlags, inTimeStamp, audioMetering.inputBus, inNumberFrames, ioData!) {
//            case noErr:
//                break
//                
//            case kAudioUnitErr_CannotDoInCurrentContext: // it seems safe to continue with this error; output is just muted...
//                print("kAudioUnitErr_CannotDoInCurrentContext")
//                
//            default: assert(false)
//            }
//            
//            // 'look-at-samples-to-render-cool-graphics-code' (deterministic and non-blocking code)
//        }
//        
//        return noErr
//    }
//    
//    func recordingCallback(inRefCon: UnsafeMutablePointer<Void>,
//                           ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
//                           inTimeStamp: UnsafePointer<AudioTimeStamp>,
//                           inBufNumber: UInt32,
//                           inNumberFrames: UInt32,
//                           ioData: UnsafeMutablePointer<AudioBufferList>) -> OSStatus {
//        
//        print("recordingCallback got fired  >>>")
//        
//        
//        return noErr
//    }
//
//    
//    func start() {
//        assert(active == false)
//        active = true
//        
//        // set-up AudioSession...
//        
//        do {
//            try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(preferredIOBufferDuration)
//        } catch let error as NSError {
////            dumpError(error, functionName: "setPreferredIOBufferDuration")
//        }
//        
//        var audioComponentDescription =
//            AudioComponentDescription(
//                componentType: OSType(kAudioUnitType_Output),
//                componentSubType: OSType(kAudioUnitSubType_RemoteIO),
//                componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
//                componentFlags: 0,
//                componentFlagsMask: 0)
//        
//        let audioComponent = AudioComponentFindNext(nil, &audioComponentDescription)
//        assert(AudioComponentInstanceNew(audioComponent!, &audioUnit) == noErr)
//        
//        var flag = UInt32(1)
//        assert(AudioUnitSetProperty(audioUnit!, AudioUnitPropertyID(kAudioOutputUnitProperty_EnableIO), AudioUnitScope(kAudioUnitScope_Input), inputBus, &flag, UInt32(MemoryLayout<UInt32>.size)) == noErr)
//        assert(AudioUnitSetProperty(audioUnit!, AudioUnitPropertyID(kAudioOutputUnitProperty_EnableIO), AudioUnitScope(kAudioUnitScope_Output), outputBus, &flag, UInt32(MemoryLayout<UInt32>.size)) == noErr)
//        
//        
//        
//        
//        
//        // add a callback and render explicitly; callback to be used for fancy graphics and/or possible DSP :]
//        var renderCallbackStruct = AURenderCallbackStruct(inputProc: renderCallback, inputProcRefCon:Unmanaged.passUnretained(self).toOpaque())
//        assert(AudioUnitSetProperty(audioUnit!, AudioUnitPropertyID(kAudioUnitProperty_SetRenderCallback), AudioUnitScope(kAudioUnitScope_Global), 0, &renderCallbackStruct, UInt32(MemoryLayout<AURenderCallbackStruct>.size)
//            ) == noErr)
//        
//        assert(AudioUnitInitialize(audioUnit!) == noErr)
//        assert(AudioOutputUnitStart(audioUnit!) == noErr)
//    }
//    
//    func stop() {
//        assert(active == true)
//        active = false
//        
//        assert(AudioOutputUnitStop(audioUnit!) == noErr)
//        assert(AudioUnitUninitialize(audioUnit!) == noErr)
//        assert(AudioComponentInstanceDispose(audioUnit!) == noErr)
//        
//        // inactivate AudioSession  
//    }  
//}


final class AudioMetering: NSObject {
    
    var sessionActive  = false
    var audioSetupDone  = false
    var running        = false
    private var active = false
    private var auAudioUnit: AUAudioUnit!
    private var interrupted = false
    
    var sampleRate : Double =  8000.0      // desired audio sample rate
    
    let mBufferSize         =   8192        // for Audio Unit AudioBufferList mData buffer

    let callback:(Data)->()

    
    let audioFormat = AVAudioFormat(
        commonFormat: AVAudioCommonFormat.pcmFormatFloat32,   // short int samples
        sampleRate: Double(8000),
        channels:AVAudioChannelCount(1),
        interleaved: true )
    
    lazy var micPermission:Bool = {
        var res = false
        AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
            res = granted
            if (!granted){
                print("no mic permissions!")
            }
//                let alert = UIAlertController(title: "Error", message: "Mic permissions were not granted.", preferredStyle: .alert)
        })
        return res
    }()
    
    
    
    private let
    preferredIOBufferDuration = 1000.0, // a value of 5 ms seems to introduce ~1% of CPU usage on iPhone 5
    // below description is used to pick the specific audio unit we need to use
    audioComponentDescription = AudioComponentDescription(componentType: kAudioUnitType_Output, componentSubType: kAudioUnitSubType_RemoteIO, componentManufacturer: kAudioUnitManufacturer_Apple, componentFlags:0, componentFlagsMask: 0)
    
    
    
    init(callback:@escaping (Data)->()) {
        self.callback = callback
    }
    
    func start() {
        
        if (!sessionActive) {
//            setupAudioSession()
        }
        
        // set-up AudioSession...
        
//        do {
//            let audioSession = AVAudioSession.sharedInstance()
//            
//            try audioSession.setCategory(AVAudioSessionCategorySoloAmbient)
//            
////            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategorySoloAmbient)
//            try audioSession.setPreferredIOBufferDuration(preferredIOBufferDuration)
//            try audioSession.setPreferredSampleRate(8000)
//            try audioSession.setPreferredInputNumberOfChannels(1)
//            try audioSession.setPreferredOutputNumberOfChannels(1)
//            try audioSession.setActive(true)
//            print ("hardware rate = \(audioSession.sampleRate)")
//        } catch let error as NSError {
////            dumpError(error, functionName: "setPreferredIOBufferDuration")
//            print ("error = \(error)")
//        }
//        
        do {
            
            if (auAudioUnit==nil){
                setupRemoteIOAudioUnit(audioFormat: audioFormat)
            }
//            try auAudioUnit = AUAudioUnit(componentDescription: audioComponentDescription)
            
            auAudioUnit.isOutputEnabled = true
            auAudioUnit.isInputEnabled = true
            
            
            let renderBlock = auAudioUnit.renderBlock
            
//            
//            if (micPermission && audioSetupDone && sessionActive) {
////                let pcmBufferSize : UInt32 = UInt32(mBufferSize)
////                let inputBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: pcmBufferSize)
//                
//                auAudioUnit.isInputEnabled  = true
//                auAudioUnit.isOutputEnabled  = true
//                
////                let bus1 = auAudioUnit.outputBusses[1]
//                
////                try bus1.setFormat(audioFormat)
//                auAudioUnit.outputProvider = {        // AUInputHandler?
//                    (actionFlags, timestamp, frameCount, inputBusNumber, inputData) -> AUAudioUnitStatus in
//                    
//                    
////                    let err : OSStatus = renderBlock(actionFlags, timestamp,
////                                    AUAudioFrameCount(frameCount), Int(inputBusNumber),
////                                    inputBuffer.mutableAudioBufferList, nil)
//                    
////                    if err == noErr {
//                        // save samples from current input buffer to circular buffer
////                        self.copyMicrophoneInputSamples( inputBuffer.mutableAudioBufferList,
////                                                         frameCount: UInt32(frameCount) )
////                        let mBuffers=inputBuffer.floatChannelData
//                    
//                    let mBuffers=inputData.pointee.mBuffers
//                    ////
////                    let bufferPointer  = UnsafeMutableRawPointer(mBuffers.mData)
//                    ////
//                   let data = Data(bytes: mBuffers.mData!, count: Int(mBuffers.mDataByteSize))
////                        let data = Data(bytes: inputBuffer.floatChannelData!, count: Int(inputBuffer.frameLength * inputBuffer.format.streamDescription.pointee.mBytesPerFrame))
//                        self.callback(data)
////                    }
//                    
//                    return noErr
//                }
//                
//                do {
//                   
//                    try auAudioUnit.allocateRenderResources()
//                    try auAudioUnit.startHardware()         // equivalent to AudioOutputUnitStart ???
//                    running = true
//                    
//                } catch {
//                    // placeholder for error handling
//                }
//            }
            
            let bus0 = auAudioUnit.outputBusses[1]
            
            try bus0.setFormat(audioFormat)
            
//            auAudioUnit.inputHandler = {
//                (actionFlags, timestamp, frameCount, inputBusNumber) -> Void in
//                print("bla")
//            }

            auAudioUnit.outputProvider = {
                (actionFlags, timestamp, frameCount, inputBusNumber, inputData) -> AUAudioUnitStatus in
//  
                let status = renderBlock(actionFlags, timestamp, frameCount, 1, inputData, .none)
                print (status)
                switch status {
                case noErr:
                    let mBuffers=inputData.pointee.mBuffers
//
//                    let bufferPointer = UnsafeMutableRawPointer(mBuffers.mData)
//
                    let data = Data(bytes: mBuffers.mData!, count: Int(mBuffers.mDataByteSize))
                    self.callback(data)
////
                    break
////
                case kAudioUnitErr_CannotDoInCurrentContext: print("kAudioUnitErr_CannotDoInCurrentContext")
                default: print("")
                }
//
                return noErr
            }
            
            
            try auAudioUnit.allocateRenderResources()
            try auAudioUnit.startHardware()
        
        } catch {
//            dumpError(error, functionName: "AUAudioUnit failed")
            assert(false)
        }
    }
    
    
    // set up and activate Audio Session
    private func setupAudioSession() {
        do {
            
            let audioSession = AVAudioSession.sharedInstance()
//
//            if (micPermission) {
//                self.start()
//            }
            
//            if enableRecord {
                try audioSession.setCategory(AVAudioSessionCategorySoloAmbient)
//            }
//            var preferredIOBufferDuration = 0.0058  // 5.8 milliseconds = 256 samples
//            let hwSRate = audioSession.sampleRate           // get native hardware rate
//            if hwSRate == 48000.0 { sampleRate = 48000.0 }  // fix for iPhone 6s
//            if hwSRate == 48000.0 { preferredIOBufferDuration = 0.0053 }
            try audioSession.setPreferredSampleRate(sampleRate)
            try audioSession.setPreferredInputNumberOfChannels(1)
            try audioSession.setPreferredOutputNumberOfChannels(1)

            try audioSession.setPreferredIOBufferDuration(preferredIOBufferDuration)
            
//            NotificationCenter.defaultCenter().addObserverForName(
//                AVAudioSessionInterruptionNotification,
//                object: nil, queue: nil,
//                usingBlock: myAudioSessionInterruptionHandler)
            
            try audioSession.setActive(true)
            sessionActive = true
        } catch /* let error as NSError */ {
            // placeholder for error handling
        }
    }
    
    private func setupRemoteIOAudioUnit(audioFormat : AVAudioFormat) {
        
        do {
            
            try auAudioUnit = AUAudioUnit(componentDescription: audioComponentDescription)
            
            // bus 1 is for data that the microphone exports out to the handler block
            let bus1 = auAudioUnit.inputBusses[0]
            
            try bus1.setFormat(audioFormat)  //      for microphone bus
            audioSetupDone = true
        } catch /* let error as NSError */ {
            // placeholder for error handling
        }
    }
}



//final class RecordAudio: NSObject {
//    
//    var auAudioUnit: AUAudioUnit! = nil
//    
//    var enableRecord   = true
//    var sessionActive  = false
//    var audioSetupDone  = false
//    var running        = false
//    
//    var sampleRate : Double =  44100.0      // desired audio sample rate
//    
//    var f0                  =    880.0      // default frequency of tone
//    var v0                  =  16383.0      // default volume of tone
//    
//    let mBufferSize         =   8192        // for Audio Unit AudioBufferList mData buffer
//    
//    let cirBuffSize         =  32768        // lock-free circular fifo/buffer size
//    var circBuffer          = [Int16](repeating: 0, count: 32768)
//    var circInIdx  : Int    =  0            // sample input  index
//    var circOutIdx : Int    =  0            // sample output index
//    
//    private var micPermission = false
//    private var micPermissionDispatchToken: dispatch_once_t = 0
//    private var interrupted = false     // for restart from audio interruption notification
//    
//    func startRecording() {
//        
//        if running { return }
//        
//        self.enableRecord = true
//        
//        if (sessionActive == false) {
//            // configure and activate Audio Session, this might change the sampleRate
//            setupAudioSession()
//        }
//        
//        let audioFormat = AVAudioFormat(
//            commonFormat: AVAudioCommonFormat.PCMFormatInt16,   // short int samples
//            sampleRate: Double(sampleRate),
//            channels:AVAudioChannelCount(2),
//            interleaved: true )                                 // interleaved stereo
//        
//        if (auAudioUnit == nil) {
//            setupRemoteIOAudioUnit(audioFormat)
//        }
//        
//        // not running, so start hardware
//        let renderBlock = auAudioUnit.renderBlock
//        
//        if (enableRecord && micPermission && audioSetupDone && sessionActive) {
//            let pcmBufferSize : UInt32 = UInt32(mBufferSize)
//            let inputBuffer = AVAudioPCMBuffer(
//                PCMFormat: audioFormat, frameCapacity: pcmBufferSize)
//            
//            auAudioUnit.inputEnabled  = true
//            auAudioUnit.inputHandler = {        // AUInputHandler?
//                (actionFlags, timestamp, frameCount, inputBusNumber) -> Void in
//                
//                let err : OSStatus =
//                    renderBlock(actionFlags, timestamp,
//                                AUAudioFrameCount(frameCount), Int(inputBusNumber),
//                                inputBuffer.mutableAudioBufferList, nil)
//                
//                if err == noErr {
//                    // save samples from current input buffer to circular buffer
//                    self.copyMicrophoneInputSamples( inputBuffer.mutableAudioBufferList,
//                                                     frameCount: UInt32(frameCount) )
//                }
//            }
//            
//            do {
//                circInIdx   =   0                       // initialize circular buffer pointers
//                circOutIdx  =   0
//                try auAudioUnit.allocateRenderResources()
//                try auAudioUnit.startHardware()         // equivalent to AudioOutputUnitStart ???
//                running = true
//                
//            } catch {
//                // placeholder for error handling
//            }
//        }
//    }
//    
//    func stopRecording() {
//        
//        if (running) {
//            auAudioUnit.stopHardware()
//            running = false
//        }
//        if (sessionActive) {
//            let audioSession = AVAudioSession.sharedInstance()
//            do {
//                try audioSession.setActive(false)
//            } catch /* let error as NSError */ {
//            }
//            sessionActive = false
//        }
//    }
//    
//    private func copyMicrophoneInputSamples(   // process RemoteIO Buffer from mic input
//        inputDataList : UnsafeMutablePointer<AudioBufferList>,
//        frameCount : UInt32 )
//    {
//        let inputDataPtr = UnsafeMutableAudioBufferListPointer(inputDataList)
//        let mBuffers : AudioBuffer = inputDataPtr[0]
//        let count = Int(frameCount)
//        
//        // Microphone Input Analysis
//        let data      = UnsafePointer<Int16>(mBuffers.mData)
//        let dataArray = UnsafeBufferPointer<Int16>(
//            start:data,
//            count: Int(mBuffers.mDataByteSize)/sizeof(Int16) )   // words
//        
//        var j = self.circInIdx          // current circular array input index
//        let n = self.cirBuffSize
//        for i in 0..<(count/2) {
//            self.circBuffer[j    ] = dataArray[i+i  ]   // copy left  channel sample
//            self.circBuffer[j + 1] = dataArray[i+i+1]   // copy right channel sample
//            j += 2 ; if j >= n { j = 0 }                // into circular buffer
//        }
//        OSMemoryBarrier();              // C11 call from libkern/OSAtomic.h
//        self.circInIdx = j              // circular index will always be less than size
//    }
//    
//    var measuredMicVol : Float = 0.0
//    
//    func dataAvailable(enough : Int) -> Bool {
//        let buff = self.circBuffer
//        var idx  = self.circOutIdx
//        var d    = self.circInIdx - idx
//        // set ttd to always try to consume more data
//        // than can be produced during about 1 measurement timer interval
//        if d < 0 { d = d + self.cirBuffSize }
//        if d >= enough {      // enough data in fifo
//            var sum = 0.0
//            for _ in 0..<enough {
//                // read circular buffer and increment circular index
//                let x = Double(buff[idx])
//                idx = idx + 1 ; if idx >= 32768 { idx = 0 }
//                // calculate total energy in buffer
//                sum = sum + (x * x)
//            }
//            self.circOutIdx = idx
//            measuredMicVol = sqrt( Float(sum) / Float(enough) ) // scaled volume
//            return(true)
//        }
//        return(false)
//    }
//    
//    // set up and activate Audio Session
//    private func setupAudioSession() {
//        do {
//            
//            let audioSession = AVAudioSession.sharedInstance()
//            
//            if (enableRecord && micPermission == false) {
//                dispatch_once(&micPermissionDispatchToken) {
//                    audioSession.requestRecordPermission({(granted: Bool)-> Void in
//                        if granted {
//                            self.micPermission = true
//                            self.startRecording()
//                            return
//                        } else {
//                            self.enableRecord = false
//                            // dispatch in main/UI thread an alert
//                            //   informing that mic permission is not switched on
//                        }
//                    })
//                }
//            }
//            
//            if enableRecord {
//                try audioSession.setCategory(AVAudioSessionCategoryRecord)
//            }
//            var preferredIOBufferDuration = 0.0058  // 5.8 milliseconds = 256 samples
//            let hwSRate = audioSession.sampleRate           // get native hardware rate
//            if hwSRate == 48000.0 { sampleRate = 48000.0 }  // fix for iPhone 6s
//            if hwSRate == 48000.0 { preferredIOBufferDuration = 0.0053 }
//            try audioSession.setPreferredSampleRate(sampleRate)
//            try audioSession.setPreferredIOBufferDuration(preferredIOBufferDuration)
//            
//            NSNotificationCenter.defaultCenter().addObserverForName(
//                AVAudioSessionInterruptionNotification,
//                object: nil, queue: nil,
//                usingBlock: myAudioSessionInterruptionHandler)
//            
//            try audioSession.setActive(true)
//            sessionActive = true
//        } catch /* let error as NSError */ {
//            // placeholder for error handling
//        }
//    }
//    
//    // find and set up the sample format for the RemoteIO Audio Unit
//    private func setupRemoteIOAudioUnit(audioFormat : AVAudioFormat) {
//        
//        do {
//            let audioComponentDescription = AudioComponentDescription(
//                componentType: kAudioUnitType_Output,
//                componentSubType: kAudioUnitSubType_RemoteIO,
//                componentManufacturer: kAudioUnitManufacturer_Apple,
//                componentFlags: 0,
//                componentFlagsMask: 0 )
//            
//            
//            try auAudioUnit = AUAudioUnit(componentDescription: audioComponentDescription)
//            
//            // bus 1 is for data that the microphone exports out to the handler block
//            let bus1 = auAudioUnit.outputBusses[1]
//            
//            try bus1.setFormat(audioFormat)  //      for microphone bus
//            audioSetupDone = true
//        } catch /* let error as NSError */ {
//            // placeholder for error handling
//        }
//    }
//    
//    private func myAudioSessionInterruptionHandler(notification: NSNotification) {
//        let interuptionDict = notification.userInfo
//        if let interuptionType = interuptionDict?[AVAudioSessionInterruptionTypeKey] {
//            let interuptionVal = AVAudioSessionInterruptionType(
//                rawValue: interuptionType.unsignedIntegerValue )
//            if (interuptionVal == AVAudioSessionInterruptionType.Began) {
//                // [self beginInterruption];
//                if (running) {
//                    auAudioUnit.stopHardware()
//                    running = false
//                    let audioSession = AVAudioSession.sharedInstance()
//                    do {
//                        try audioSession.setActive(false)
//                        sessionActive = false
//                    } catch {
//                        // placeholder for error handling
//                    }
//                    interrupted = true
//                }
//            } else if (interuptionVal == AVAudioSessionInterruptionType.Ended) {
//                // [self endInterruption];
//                if (interrupted) {
//                    let audioSession = AVAudioSession.sharedInstance()
//                    do {
//                        try audioSession.setActive(true)
//                        sessionActive = true
//                        if (auAudioUnit.renderResourcesAllocated == false) {
//                            try auAudioUnit.allocateRenderResources()
//                        }
//                        try auAudioUnit.startHardware()
//                        running = true
//                    } catch {
//                        // placeholder for error handling
//                    }
//                }
//            }
//        }
//    }
//}

