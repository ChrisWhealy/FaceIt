//
//  FacialExpression.swift
//  FaceIt
//
//  Created by Whealy, Chris on 28/06/2016.
//  Copyright © 2016 Whealy, Chris. All rights reserved.
//

import Foundation

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// Facial expression model
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
struct FacialExpression {
  enum Eyes: Int {
    case Open
    case Closed
    case Squinting
  }

  enum EyeBrows: Int {
    case Relaxed
    case Normal
    case Furrowed

    func moreRelaxedBrow()  -> EyeBrows { return EyeBrows(rawValue: rawValue - 1) ?? .Relaxed }
    func moreFurrowedBrow() -> EyeBrows { return EyeBrows(rawValue: rawValue + 1) ?? .Furrowed }
  }

  enum Mouth: Int {
    case Frown
    case Smirk
    case Neutral
    case Grin
    case Smile

    func sadderMouth()  -> Mouth { return Mouth(rawValue: rawValue - 1) ?? .Frown }
    func happierMouth() -> Mouth { return Mouth(rawValue: rawValue + 1) ?? .Smile }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Public API
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  var eyes     : Eyes
  var eyeBrows : EyeBrows
  var mouth    : Mouth
}