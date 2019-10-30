//
//  CameraViewController.swift
//  VideoRecorder
//
//  Created by Paul Solt on 10/2/19.
//  Copyright © 2019 Lambda, Inc. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

	// AVCaptureSession
	lazy private var captureSession = AVCaptureSession()
    lazy private var fileOutput = AVCaptureMovieFileOutput()
    var player: AVPlayer!
    
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var cameraView: CameraPreviewView!
    

	override func viewDidLoad() {
		super.viewDidLoad()
		
		setUpSession()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        view.addGestureRecognizer(tapGesture)
	}
    
    @objc func handleTapGesture(_ tapGuesture: UITapGestureRecognizer) {
        print("HandleTap")
        
        switch tapGuesture.state {
        case .ended:
            playRecording()
        default:
            print("Handle otehr states")
        }
    }
    
    private func playRecording() {
        if let player = player {
            player.seek(to: CMTime.zero)
            player.play()
        }
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		print("Start capture session")
		captureSession.startRunning()
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		print("Stop capture session")
		captureSession.stopRunning()
	}

	
	private func setUpSession() {
		
		captureSession.beginConfiguration()
		
		// Add the camera input
		let camera = bestBackCamera()
		
		guard let cameraInput = try? AVCaptureDeviceInput(device: camera) else {
			fatalError("Cannot create a device input from camera")
		}
		
		guard captureSession.canAddInput(cameraInput) else {
			fatalError("Cannot add camera to capture session")
		}
		captureSession.addInput(cameraInput)
		
		
		// Set video mode
		if captureSession.canSetSessionPreset(.hd4K3840x2160) {
			captureSession.sessionPreset = .hd4K3840x2160
			print("4K support!!!")
		}
		
        // Add the audio input
        // Add audio input
        let microphone = bestAudio()
        guard let audioInput = try? AVCaptureDeviceInput(device: microphone) else {
            fatalError("Can't create input from microphone")
        }
        guard captureSession.canAddInput(audioInput) else {
            fatalError("Can't add audio input")
        }
        captureSession.addInput(audioInput)
		
		// TODO: Add recording
        guard captureSession.canAddOutput(fileOutput) else {
            fatalError("Cannot record video to a movie file")
        }
        captureSession.addOutput(fileOutput)
        
		
		captureSession.commitConfiguration()
		cameraView.session = captureSession
	}

	private func bestBackCamera() -> AVCaptureDevice {
		if let device = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
			return device
		} else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
			return device
		}
		fatalError("ERROR: No cameras on the device or you are running on the Simulator")
	}

	private func bestFrontCamera() -> AVCaptureDevice {
		if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
			return device
		}
		fatalError("ERROR: No cameras on the device or you are running on the Simulator")
	}
    
    private func bestAudio() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(for: .audio) {
            return device
        }
        fatalError("ERROR: No audio device")
    }

    @IBAction func recordButtonPressed(_ sender: Any) {
        if fileOutput.isRecording {
            // stop recording
            fileOutput.stopRecording()
            // play video
        } else {
            // start recording
            fileOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
	}
    
    // helper to save to documents directory
    func newRecordingURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        
        let name = formatter.string(from: Date())
        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
        
        return fileURL
    }
    
    private func playMovie(url: URL) {
        player = AVPlayer(url: url)
        
        // create the layer
        let playerLayer = AVPlayerLayer(player: player)
        var topCornerRect = self.view.bounds
        
        // configure size
        topCornerRect.size.width /= 4
        topCornerRect.size.height /= 4
        topCornerRect.origin.y = view.layoutMargins.top
        
        playerLayer.frame = topCornerRect
        self.view.layer.addSublayer(playerLayer)
        
        player.play()
    }
}
// conform to delegate: AVCaptureFileOutputRecordingDelegate
extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("File recording error: \(error)")
        }
        print("didFinishRecordingTo: \(outputFileURL)")
        
        playMovie(url: outputFileURL)
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
    }
}
