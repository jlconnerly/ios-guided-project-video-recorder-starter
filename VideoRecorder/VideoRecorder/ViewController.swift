//
//  ViewController.swift
//  VideoRecorder
//
//  Created by Paul Solt on 10/2/19.
//  Copyright © 2019 Lambda, Inc. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		checkVideoAuthorization()
	}

	private func checkVideoAuthorization() {
		
		// AVCaptureDevice
		let status = AVCaptureDevice.authorizationStatus(for: .video)
		
		switch status {
		case .notDetermined: // user hasn't made a decision
			// request permission
			requestVideoPermission()
		case .restricted: // Parental controls are disabling video
			fatalError("Present UI to user informing them to enable video to use this app")
		case .denied: // The user said no (might not be intentional, depends on how you ask)
			fatalError("Present UI on how to re-enable video for this app in Settings > Privacy")
		case .authorized: // User said yes, we can use video
			showCamera()
		@unknown default:
			fatalError("AVFoundation unexpected new status code")
		}
		
	}

	private func requestVideoPermission() {
		AVCaptureDevice.requestAccess(for: .video) { (granted) in
			guard granted == true else { fatalError("Present UI on how to enable Settings > Privacy") }
			
			DispatchQueue.main.async {
				self.showCamera()
			}
		}
	}
	
	private func showCamera() {
		performSegue(withIdentifier: "ShowCamera", sender: self)
	}
}
