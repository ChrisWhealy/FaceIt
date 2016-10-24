//
//  BlinkingFaceViewController.swift
//  FaceIt
//
//  Created by Whealy, Chris on 12/09/2016.
//  Copyright © 2016 Whealy, Chris. All rights reserved.
//

import UIKit

class BlinkingFaceViewController: FaceViewController {
  var blinking = false { didSet { startBlink() } }

  private struct BlinkRate {
    private static let precInt: UInt32 = 1000
    private static let precDbl: Double = Double(precInt)

    private static func rndNumber() -> Double {
      let v1 = arc4random()
      let v2 = (v1 / precInt) * precInt
      return Double(v1 - v2) / precDbl
    }

//    static let ClosedDuration = 0.1  + BlinkRate.rndNumber()
//    static let OpenDuration   = 2.0 + BlinkRate.rndNumber()
    static let ClosedDuration = 0.4
    static let OpenDuration   = 2.5
  }

  private func scheduleBlinkEvent(duration: Double, sel: Selector) {
    // Whatever selector is received here must be exposed to Objective C.
    // By default, private functions are not exposed to Objective C!
    NSTimer.scheduledTimerWithTimeInterval(duration,
      target: self,
      selector: sel,
      userInfo: nil,
      repeats: false)
  }

  // This function is used as a selector for the NSTimer, therefore it must ve visible to the Objective C runtime
  // Hence the @objc directive
  @objc private func startBlink() {
    if blinking {
      faceView.eyesOpen = false
      scheduleBlinkEvent(BlinkRate.ClosedDuration, sel: #selector(BlinkingFaceViewController.endBlink))
    }
  }
  
  // This function is used as a selector for the NSTimer, therefore it must ve visible to the Objective C runtime
  // Hence the @objc directive
  @objc private func endBlink() {
    faceView.eyesOpen = true
    scheduleBlinkEvent(BlinkRate.OpenDuration, sel: #selector(BlinkingFaceViewController.startBlink))
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    blinking = true

  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    blinking = false
  }
}
