//
//  ViewController.swift
//  FaceIt
//
//  Created by Whealy, Chris on 23/06/2016.
//  Copyright © 2016 Whealy, Chris. All rights reserved.
//

import UIKit

private let π_by_4: CGFloat = CGFloat(M_PI / 4)

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// Face controller
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
class FaceViewController: UIViewController {

  // Create model instance
  var expression = FacialExpression(eyes: .Open, eyeBrows: 0.0, mouth: 0.0) { didSet { updateUI() } }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Only called once at the start of the view controller's lifecycle
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  @IBOutlet weak var faceView: FaceView! {
    didSet {
      // Add recogniser for pinch gesture
      faceView.addGestureRecognizer(UIPinchGestureRecognizer(target: faceView, action: #selector(FaceView.changeScale(_:))))

      // Initial screen draw
      updateUI()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Change model values based on gesture detection
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  private func panHeading(thisPoint: CGPoint) -> Double {
    // Translate the "translationInView" to a heading (in degrees)
    return thisPoint.x == 0.0        // Any East/West movement?
           ? thisPoint.y > 0            // No, so check for any North/South movement
             ? 180.0                       // Due South
             : 0.0                         // Due North
           : thisPoint.y == 0.0         // Yes, so check for any North/South movement
              ? thisPoint.x > 0.0          // Moving East with no North/South?
                 ? 90.0                       // Yes, due East
                 : 270.0                      // No, due West
                                           // Some other direction
               : acos(Double(thisPoint.y / thisPoint.x)) * 180 / M_PI
  }

  @IBAction func changeHappiness(recogniser: UIPanGestureRecognizer) {
    let heading = panHeading(recogniser.translationInView(faceView))

    // Ignore pan headings of due east and due west
    if heading > 270 || heading < 90 {
      expression.mouth -= 0.1
    }
    else if heading > 90 || heading < 270 {
      expression.mouth += 0.1
    }

    expression.mouth = max(-1, min(expression.mouth, 1))
    recogniser.setTranslation(CGPoint(x:0.0, y:0.0), inView: faceView)
  }

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
    expression.eyeBrows = Double(recogniser.rotation / π_by_4)

    recogniser.rotation = max(-π_by_4, min(recogniser.rotation, π_by_4))
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

    faceView.mouthCurvature = expression.mouth
    faceView.eyeBrowTilt = expression.eyeBrows
  }
  
}

