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
	
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var cameraView: CameraPreviewView!


	override func viewDidLoad() {
		super.viewDidLoad()
		
		setUpSession()
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
		let camera = bestCamera()
		
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
		
		// TODO: Add the audio input
		
		// TODO: Add recording
		
		captureSession.commitConfiguration()
		cameraView.session = captureSession
	}
	
	private func bestCamera() -> AVCaptureDevice {
		if let device = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
			return device
		} else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
			return device
		}
		fatalError("ERROR: No cameras on the device or you are running on the Simulator")
	}


    @IBAction func recordButtonPressed(_ sender: Any) {

	}
}

