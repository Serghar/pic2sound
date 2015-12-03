//
//  ViewController.swift
//  pic2sound
//
//  Created by Dylan Sharkey on 11/21/15.
//  Copyright © 2015 Dylan Sharkey. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, SoundEngineDelegate,  AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var imageProc: ImageProcessing?
    //  var sounds: soundsProc?
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var playing = false
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    //on start button pressed set playing to true and start loop
    //on stop button pressed set playing to false
    @IBAction func StartButtonPressed(sender: AnyObject) {
        startButton.hidden = true
        startButton.enabled = false
        stopButton.hidden = false
        stopButton.enabled = true
        playing = true
        autoPic()
    }
    
    @IBAction func StopButtonPressed(sender: AnyObject) {
        stopButton.hidden = true
        stopButton.enabled = false
        startButton.hidden = false
        startButton.enabled = true
        playing = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let mySoundEngine = SoundEngine()
        mySoundEngine.delegate = self
        mySoundEngine.startSound()
    }
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        cameraSetup()
//        //previewView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 150.0, alpha: 0.5)
//        previewLayer!.frame = previewView.bounds
//        stopButton.hidden = true
//        stopButton.enabled = false
//    }
    
    
    func cameraSetup() {
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        if error == nil && captureSession!.canAddInput(input) {
            captureSession!.addInput(input)
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if captureSession!.canAddOutput(stillImageOutput) {
                captureSession!.addOutput(stillImageOutput)
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                previewView.layer.addSublayer(previewLayer!)
                
                //This starts the capture session
                captureSession!.startRunning()
            }
        }

    }
    
    func autoPic() {
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo){
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in if (sampleBuffer != nil){
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                let dataProvider = CGDataProviderCreateWithCFData(imageData)
                let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                
                //IMAGE IS CREATED RIGHT HERE!!
                
                
                let imageStuff = ImageProcessing.Initialize(image)
                self.backgroundColorTransistion(self.previewView, originalColor: self.previewView.backgroundColor!, newColor: imageStuff.primaryUIColor, elapsedTime: 1.0)
                
                let mySoundEngine = SoundEngine()
                mySoundEngine.imageValues = imageStuff
                mySoundEngine.delegate = self
                mySoundEngine.startSound()
                
                }
            })
        }
    }
    
    //takes another picture and starts the loop again
    func resetLoop() {
        if (playing) {
            autoPic()
        }
    }
    
    
    var progress = 0.0
    
    func backgroundColorTransistion (item: UIView, originalColor: UIColor, newColor: UIColor, elapsedTime: Double) {
        progress += (0.05 / elapsedTime)
        print(progress)
    
        //get original color Red Green and Blue
        let red = originalColor.rgbArr()![1]
        let green = originalColor.rgbArr()![2]
        let blue = originalColor.rgbArr()![3]
    
        //get new Transition Color's Red green and Blue
        let finalRed = newColor.rgbArr()![1]
        let finalGreen = newColor.rgbArr()![2]
        let finalBlue = newColor.rgbArr()![3]
    
    
        //do background color change
        let newRed: CGFloat = CGFloat((1.0) - (progress)) * red + CGFloat(progress) * finalRed
        let newGreen: CGFloat = CGFloat((1.0) - (progress)) * green + CGFloat(progress) * finalGreen
        let newBlue: CGFloat = CGFloat((1.0) - (progress)) * blue + CGFloat(progress) * finalBlue
        let updatedColor = UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
        item.backgroundColor = updatedColor
    
        //build function loop
        if progress >= 1.0  {
            progress = 0.0
        }
        else {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.05 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue(), {
                self.backgroundColorTransistion(item, originalColor: originalColor, newColor: newColor, elapsedTime: elapsedTime)
            })
        }
    }

}




