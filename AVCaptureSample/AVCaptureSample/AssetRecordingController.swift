//
//  AssetWritingController.swift
//  AVCaptureSample
//
//  Created by Simon Kim on 9/26/16.
//  Copyright © 2016 DZPub.com. All rights reserved.
//

import Foundation
import AVCapture

import AVFoundation

class AssetRecordingController {
    
    var fileWriter: AVCFileWriter? = nil
    
    static var writerQueue: DispatchQueue = {
            return DispatchQueue(label: "writer")
    }()
    
    var recording: Bool {
        return fileWriter != nil
    }
    
    var videoSize: CGSize? = nil
    
    func recordingFilePath(with name:String) -> String? {
        let URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let path = URL.appendingPathComponent(name).path
        
        if FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
            } catch {
                print( "Can't remove file: \(path)")
                return nil
            }
        }
        return path
    }
    
    public func toggleRecording(on: Bool) {
        if on {
            if let path = recordingFilePath(with: "recording.mov"),
                let videoSize = self.videoSize {
                let audioSettings = AVCWriterSettings(compress: true)
                let videoSettings = AVCWriterVideoSettings(compress:false, width:Int(videoSize.width), height: Int(videoSize.height))
                
                let writer = AVCFileWriter(URL: Foundation.URL(fileURLWithPath: path), videoSettings: videoSettings, audioSettings: audioSettings) {
                    sender, status, info in
                    
                    print("Writer \(status.rawValue)")
                    switch(status) {
                    case .writerInitFailed, .writerStartFailed, .writerStatusFailed:
                        print("     : \(info)")
                        self.fileWriter = nil
                        sender.finish(silent: true)
                        break
                    case .finished:
                        print("Video recorded at \(path)")
                        break
                    default:
                        break
                    }
                }
                
                fileWriter = writer
            }
            
        } else {
            if let fileWriter = fileWriter {
                fileWriter.finish()
                self.fileWriter = nil
            }
        }
    }
    
    func append(sbuf: CMSampleBuffer) {
        type(of:self).writerQueue.async() {
            self.fileWriter?.append(sbuf: sbuf)
        }
    }
}
