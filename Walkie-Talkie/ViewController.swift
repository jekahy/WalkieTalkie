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
    
    @IBOutlet weak var hostAddrTF: UITextField!
    var avAudioEngine : AVAudioEngine?
    
    
    @IBAction func btnAction(sender: UIButton) {
        
        avAudioEngine = AVAudioEngine()
        let input = avAudioEngine!.inputNode
        
        let downMixer = AVAudioMixerNode()
        avAudioEngine?.attach(downMixer)
        
        
        let socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        if let remoteAddress = hostAddrTF.text {
            do {
                try socket.bind(toPort: 4445)
                try socket.connect(toHost: remoteAddress ,onPort : 4444)
                
                try socket.beginReceiving()
                
                
                
                input?.installTap(onBus: 0, bufferSize: 1000, format: input?.inputFormat(forBus: 0), block: { (buffer : AVAudioPCMBuffer, timeE: AVAudioTime) -> Void in
//                downMixer.installTap(onBus: 0, bufferSize: 1000, format: downMixer.inputFormat(forBus: 0), block: { (buffer : AVAudioPCMBuffer, timeE: AVAudioTime) -> Void in
//                    self.convertPCMBufferToAAC(inBuffer: buffer)
                    buffer.frameLength = 1000
                    print ("time = \(timeE)")
                    print (self.toNSData(PCMBuffer: buffer).length)
                    
//                    for chunk in self.splitDataIntoChunks(data: self.toNSData(PCMBuffer: buffer)){
                        socket.send(self.toNSData(PCMBuffer: buffer) as Data, withTimeout: 0, tag: 0)
//                    }
                })
//                let format = input!.inputFormat(forBus: 0)
//                let format16KHzMono = AVAudioFormat.init(commonFormat: AVAudioCommonFormat.pcmFormatFloat32, sampleRate: 8000, channels: 1, interleaved: true)
//
                
//                avAudioEngine!.connect(input!, to: downMixer, format: format)//use default input format
//                avAudioEngine!.connect(downMixer, to: avAudioEngine!.mainMixerNode, format: format16KHzMono)
//
                avAudioEngine?.prepare()
                try avAudioEngine?.start()
                
                // with nc -l -u -p 4444 and uncomment below block I can get "someText"
                //socket.sendData("someText\n".dataUsingEncoding(NSUTF8StringEncoding), withTimeout: 0, tag: 0)
                // socket.close()
                }
                    
                catch{
                    print("err")
                }
                
            }
            

        
        
    }
    
    //socket.sendData just accepts NSData, So I think that we must convert it to NSData!
    
    func toNSData(PCMBuffer: AVAudioPCMBuffer) -> NSData {
        
        let channelCount = 1  // given PCMBuffer channel count is 1
        let channels = UnsafeBufferPointer(start: PCMBuffer.floatChannelData, count: channelCount)
        let ch0Data = NSData(bytes: channels[0], length:Int(PCMBuffer.frameLength * PCMBuffer.format.streamDescription.pointee.mBytesPerFrame))
        
        return ch0Data
    }
    
    
    func splitDataIntoChunks(data:NSData) -> [Data] {
        let length = data.length
        let chunkSize = 1500      // 1mb chunk sizes
        var offset = 0
        var chunks = [Data]()
        repeat {
            // get the length of the chunk
            let thisChunkSize = ((length - offset) > chunkSize) ? chunkSize : (length - offset);
            
            // get the chunk
            let chunk = data.subdata(with: NSMakeRange(offset, thisChunkSize))
            chunks.append(chunk)
            
            // -----------------------------------------------
            // do something with that chunk of data...
            // -----------------------------------------------
            
            // update the offset
            offset += thisChunkSize;
            
        } while (offset < length);
        return chunks
    }
    
    
    func convertPCMBufferToAAC(inBuffer : AVAudioPCMBuffer) -> Void {
        let inputFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                        sampleRate: 8000, channels: 1,
                                        interleaved: false)
        
        var outDesc = AudioStreamBasicDescription(mSampleRate: 8000,
                                                  mFormatID: kAudioFormatMPEG4AAC,
                                                  mFormatFlags: 0,
                                                  mBytesPerPacket: 0,
                                                  mFramesPerPacket: 0,
                                                  mBytesPerFrame: 0,
                                                  mChannelsPerFrame: 1,
                                                  mBitsPerChannel: 0,
                                                  mReserved: 0)
        
        let outputFormat = AVAudioFormat(streamDescription: &outDesc)
        let converter = AVAudioConverter(from: inputFormat, to: outputFormat)
        

        let outBuffer = AVAudioCompressedBuffer(format: outputFormat,
                                                packetCapacity: 8,
                                                maximumPacketSize: converter.maximumOutputPacketSize)
        
        let inputBlock : AVAudioConverterInputBlock = {
            inNumPackets, outStatus in
            outStatus.pointee = AVAudioConverterInputStatus.haveData
            return inBuffer
        }
        var error : NSError?
        let status = converter.convert(to: outBuffer, error: &error, withInputFrom: inputBlock)
        print (status)
    }
    
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?) {
        if let er = error {
            print ("error = \(er.localizedDescription)")
        }
      print("failed")
    
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        print("succeed")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {
        print("did connect!")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
        print("did not connect!")
    }

    
    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        if let er = error {
            print ("error = \(er.localizedDescription)")
        }
        print("did close!")
    }
}

