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
  var expression = FacialExpression(eyes: .open, eyeBrows: 0.0, mouth: 0.0) { didSet { updateView() } }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Only called once at the start of the view controller's lifecycle
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  @IBOutlet weak var faceView: FaceView! {
    didSet {
      // Add recogniser for pinch gesture
      faceView.addGestureRecognizer(UIPinchGestureRecognizer(target: faceView, action: #selector(FaceView.changeScale(_:))))

      // Initial screen draw
      updateView()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Change model values based on gesture detection
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  fileprivate func panHeading(_ thisPoint: CGPoint) -> Double {
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

  @IBAction func changeHappiness(_ recogniser: UIPanGestureRecognizer) {
    let heading = panHeading(recogniser.translation(in: faceView))

    // Ignore pan headings of due east and due west
    if heading > 270 || heading < 90 {
      expression.mouth -= 0.1
    }
    else if heading > 90 || heading < 270 {
      expression.mouth += 0.1
    }

    expression.mouth = max(-1, min(expression.mouth, 1))
    recogniser.setTranslation(CGPoint(x:0.0, y:0.0), in: faceView)
  }

  @IBAction func toggleEyes(_ recogniser: UITapGestureRecognizer) {
    if recogniser.state == .ended {
      switch expression.eyes {
        case .open      : expression.eyes = .closed
        case .closed    : expression.eyes = .open
        case .squinting : break
      }
    }
  }

  fileprivate struct Animation {
    static let shakeAngle    = CGFloat(M_PI / 6)
    static let shakeDuration = 0.5
  }

  fileprivate func _shakeHead(_ angle: CGFloat, duration: Double) {
    UIView.animate(
      withDuration: duration,
      animations: {
        self.faceView.transform = self.faceView.transform.rotated(by: angle)
       },
      completion: { finished in
        if finished {
          UIView.animate(
            withDuration: duration,
            animations: {
              self.faceView.transform = self.faceView.transform.rotated(by: -angle * 2)
            },
            completion: { finished in
              if finished {
                UIView.animate(
                  withDuration: duration,
                  animations: {
                    self.faceView.transform = self.faceView.transform.rotated(by: angle)
                  },
                  completion: { finished in
                    if finished {
                    }
                  }
                )
              }
            }
          )
        }
      }
    )
  }

  @IBAction func shakeHead(_ sender: UITapGestureRecognizer) {
    _shakeHead(Animation.shakeAngle, duration: Animation.shakeDuration)
  }

  @IBAction func rotateEyeBrows(_ recogniser: UIRotationGestureRecognizer) {
    expression.eyeBrows = Double(recogniser.rotation / π_by_4)

    recogniser.rotation = max(-π_by_4, min(recogniser.rotation, π_by_4))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Redraw the UI
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  fileprivate func updateView() {
    if faceView != nil {
      switch expression.eyes {
        case .open      : faceView.eyesOpen = true
        case .closed    : faceView.eyesOpen = false
        case .squinting : faceView.eyesOpen = false
      }

      faceView.mouthCurvature = expression.mouth
      faceView.eyeBrowTilt    = expression.eyeBrows
    }
  }
  
}

