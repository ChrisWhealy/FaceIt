//
//  FaceView.swift
//  FaceIt
//
//  Created by Whealy, Chris on 23/06/2016.
//  Copyright © 2016 Whealy, Chris. All rights reserved.
//

import UIKit

@IBDesignable

class FaceView: UIView {
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// Public API (Note, @IBInspectable variables must be typed explicitly because interface
//             builder cannot infer types)
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  @IBInspectable var scale         : CGFloat = 0.9   { didSet { setNeedsDisplay() } }
  @IBInspectable var mouthCurvature: Double  = 1.0   { didSet { setNeedsDisplay() } }
  @IBInspectable var eyeBrowTilt   : Double  = -0.66 { didSet { setNeedsDisplay() } }

  @IBInspectable var eyesOpen: Bool = true  {
    didSet {
      leftEye.eyesOpen  = eyesOpen
      rightEye.eyesOpen = eyesOpen
    }
  }

  @IBInspectable var lineWidth: CGFloat = 5.0   {
    didSet {
      setNeedsDisplay()

      leftEye.lineWidth  = lineWidth
      rightEye.lineWidth = lineWidth
    }
  }

  @IBInspectable var faceColour: UIColor = UIColor.blue {
    didSet {
      setNeedsDisplay()

      leftEye.color  = faceColour
      rightEye.color = faceColour
    }
  }

  func changeScale(_ recognizer: UIPinchGestureRecognizer) {
    switch recognizer.state {
      case .changed, .ended:
        scale *= recognizer.scale
        recognizer.scale = 1.0

      default: break
    }
  }

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// Internal control values
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  fileprivate let two_π = CGFloat(2 * M_PI)

  fileprivate var skullRadius: CGFloat { return min(bounds.size.width, bounds.size.height) / 2 * scale }
  fileprivate var skullCenter: CGPoint { return CGPoint(x: bounds.midX, y: bounds.midY) }

  fileprivate struct Ratios {
    static let SkullRadiusToEyeOffset  : CGFloat = 3
    static let SkullRadiusToEyeRadius  : CGFloat = 10
    static let SkullRadiusToMouthWidth : CGFloat = 1
    static let SkullRadiusToMouthHeight: CGFloat = 3
    static let SkullRadiusToMouthOffset: CGFloat = 3
    static let SkullRadiusToBrowOffset : CGFloat = 5
  }

  fileprivate enum Eye {
    case left
    case right
  }

  fileprivate func pathForCircleCentredAtPoint(_ midPoint: CGPoint, withRadius radius: CGFloat) -> UIBezierPath {
    let path = UIBezierPath(arcCenter : midPoint,
                            radius    : radius,
                            startAngle: 0.0,
                            endAngle  : two_π,
                            clockwise : false)
    path.lineWidth = lineWidth

    return path
  }

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// Eyes
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//  private func pathForEye(eye: Eye) -> UIBezierPath {
//    let eyeRadius = skullRadius / Ratios.SkullRadiusToEyeRadius
//    let eyeCenter = getEyeCenter(eye)
//
//    if eyesOpen {
//      return pathForCircleCentredAtPoint(eyeCenter, withRadius: eyeRadius)
//    }
//    else {
//      let path = UIBezierPath()
//
//      path.moveToPoint(CGPoint(x: eyeCenter.x - eyeRadius, y: eyeCenter.y))
//      path.addLineToPoint(CGPoint(x: eyeCenter.x + eyeRadius, y: eyeCenter.y))
//      path.lineWidth = lineWidth
//
//      return path
//    }
//  }

  fileprivate lazy var leftEye : EyeView = self.createEye()
  fileprivate lazy var rightEye: EyeView = self.createEye()

  fileprivate func createEye() -> EyeView {
    let eye = EyeView()

    eye.isOpaque    = false
    eye.color     = faceColour
    eye.lineWidth = lineWidth

    self.addSubview(eye)

    return eye
  }

  fileprivate func positionEye(_ eye: EyeView, center: CGPoint) {
    let size = skullRadius / Ratios.SkullRadiusToEyeRadius * 2

    eye.frame  = CGRect(origin: CGPoint.zero, size: CGSize(width: size, height: size))
    eye.center = center
  }
  
  fileprivate func getEyeCenter(_ eye: Eye) -> CGPoint {
    let eyeOffset = skullRadius / Ratios.SkullRadiusToEyeOffset
    var eyeCenter = skullCenter

    eyeCenter.y -= eyeOffset

    switch eye {
      case .left : eyeCenter.x -= eyeOffset
      case .right: eyeCenter.x += eyeOffset
    }

    return eyeCenter
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    positionEye(leftEye,  center: getEyeCenter(.left))
    positionEye(rightEye, center: getEyeCenter(.right))
  }

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// Eyebrows
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  fileprivate func pathForBrow(_ eye: Eye) -> UIBezierPath {
    let tilt = eyeBrowTilt * (eye == Eye.left ? -1.0 : 1.0)
    var browCenter = getEyeCenter(eye)

    browCenter.y -= skullRadius / Ratios.SkullRadiusToBrowOffset

    let eyeRadius  = skullRadius / Ratios.SkullRadiusToEyeRadius
    let tiltOffset = CGFloat(max(-1, min(tilt,1))) * eyeRadius / 2
    let browStart  = CGPoint(x: browCenter.x - eyeRadius, y: browCenter.y - tiltOffset)
    let browEnd    = CGPoint(x: browCenter.x + eyeRadius, y: browCenter.y + tiltOffset)
    let path       = UIBezierPath()

    path.move(to: browStart)
    path.addLine(to: browEnd)
    path.lineWidth = lineWidth

    return path
  }


// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// Mouth
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  fileprivate func pathForMouth() -> UIBezierPath {
    let mouthWidth  = skullRadius / Ratios.SkullRadiusToMouthWidth
    let mouthHeight = skullRadius / Ratios.SkullRadiusToMouthHeight
    let mouthOffset = skullRadius / Ratios.SkullRadiusToMouthOffset

    let mouthRect = CGRect(x: skullCenter.x - mouthWidth/2,
                           y: skullCenter.y + mouthOffset,
                           width : mouthWidth,
                           height: mouthHeight)


    let smileOffset = CGFloat(max(-1, min(mouthCurvature, 1))) * mouthRect.height
    let start       = CGPoint(x: mouthRect.minX, y: mouthRect.minY)
    let end         = CGPoint(x: mouthRect.maxX, y: mouthRect.minY)
    let cp1         = CGPoint(x: mouthRect.minX + mouthRect.width / 3, y: mouthRect.minY + smileOffset)
    let cp2         = CGPoint(x: mouthRect.maxX - mouthRect.width / 3, y: mouthRect.minY + smileOffset)

    let path = UIBezierPath()
    path.move(to: start)
    path.addCurve(to: end, controlPoint1: cp1, controlPoint2: cp2)
    path.lineWidth = lineWidth

    return path
  }

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// Override default draw method for view
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  override func draw(_ rect: CGRect) {
    faceColour.set()

    // Position the skull
    pathForCircleCentredAtPoint(skullCenter, withRadius: skullRadius).stroke()

    // Position the eyes
//    pathForEye(.Left).stroke()
//    pathForEye(.Right).stroke()

    // Position the mouth
    pathForMouth().stroke()

    // Position the eyebrows
    pathForBrow(.left).stroke()
    pathForBrow(.right).stroke()
  }
}







