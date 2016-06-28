//
//  ViewController.swift
//  FaceIt
//
//  Created by Whealy, Chris on 23/06/2016.
//  Copyright © 2016 Whealy, Chris. All rights reserved.
//

import UIKit

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// Face controller
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
class FaceViewController: UIViewController {

  // Create model instance
  var expression = FacialExpression(eyes: .Closed, eyeBrows: .Relaxed, mouth: .Smirk) { didSet { updateUI() } }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Only called once at the start of the view controller's lifecycle
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  @IBOutlet weak var faceView: FaceView! {
    didSet {
      // Create swipe gesture recognisers for up and down
      let happierSwipeGestureRecogniser = UISwipeGestureRecognizer(target: self, action: #selector(self.increaseHappiness))
      let sadderSwipeGestureRecogniser  = UISwipeGestureRecognizer(target: self, action: #selector(self.decreaseHappiness))

      // Configure swipe gesture recognisers to point in the correct direction
      happierSwipeGestureRecogniser.direction = .Down
      sadderSwipeGestureRecogniser.direction = .Up
      
      // Add gesture recognisers programmatically
      faceView.addGestureRecognizer(UIPinchGestureRecognizer(target: faceView, action: #selector(FaceView.changeScale(_:))))
      faceView.addGestureRecognizer(happierSwipeGestureRecogniser)
      faceView.addGestureRecognizer(sadderSwipeGestureRecogniser)

      // Initial screen draw
      updateUI()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Dictionaries to provide concrete implementations of the model's state values
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  private var mouthCurvatures: Dictionary<FacialExpression.Mouth, Double> =
    [.Frown: -1.0, .Grin: 0.5, .Smile: 1.0, .Smirk: -0.5, .Neutral: 0.0]

  private var eyeBrowTilts: Dictionary<FacialExpression.EyeBrows, Double> =
    [.Relaxed: 0.5, .Normal: 0.0, .Furrowed: -0.5]


  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Change model values based on gesture detection
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  func increaseHappiness() { expression.mouth = expression.mouth.happierMouth() }
  func decreaseHappiness() { expression.mouth = expression.mouth.sadderMouth() }

  @IBAction func toggleEyes(recogniser: UITapGestureRecognizer) {
    if recogniser.state == .Ended {
      switch expression.eyes {
        case .Open      : expression.eyes = .Closed
        case .Closed    : expression.eyes = .Open
        case .Squinting : break
      }
    }
  }

  @IBAction func rotateEyeBrows(recogniser: UIRotationGestureRecognizer) {
    if recogniser.state == .Ended {
      let directionIsClockwise = recogniser.rotation > 0 ? true : false

      switch expression.eyeBrows {
        case .Furrowed : expression.eyeBrows = directionIsClockwise ? .Normal  : .Furrowed
        case .Normal   : expression.eyeBrows = directionIsClockwise ? .Relaxed : .Furrowed
        case .Relaxed  : expression.eyeBrows = directionIsClockwise ? .Relaxed : .Normal
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Redraw the UI
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  private func updateUI() {
    switch expression.eyes {
      case .Open      : faceView.eyesOpen = true
      case .Closed    : faceView.eyesOpen = false
      case .Squinting : faceView.eyesOpen = false
    }

    faceView.mouthCurvature = mouthCurvatures[expression.mouth] ?? 0.0
    faceView.eyeBrowTilt    = eyeBrowTilts[expression.eyeBrows] ?? 0.0
  }
  
}

