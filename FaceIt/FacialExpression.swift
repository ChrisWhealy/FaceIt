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
    case open
    case closed
    case squinting
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Public API
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  var eyes     : Eyes
  var eyeBrows : Double
  var mouth    : Double
}
