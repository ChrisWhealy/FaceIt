//
//  EmotionsViewController.swift
//  FaceIt
//
//  Created by Whealy, Chris on 29/06/2016.
//  Copyright © 2016 Whealy, Chris. All rights reserved.
//

import UIKit

class EmotionsViewController: UIViewController {
  fileprivate let emotionalFaces: Dictionary<String, FacialExpression> = [
    "Angry"       : FacialExpression(eyes: .closed, eyeBrows: -1.0,  mouth: -1.0),
    "Happy"       : FacialExpression(eyes: .open,   eyeBrows: 0.0,   mouth: 1.0),
    "Worried"     : FacialExpression(eyes: .open,   eyeBrows: 0.5,   mouth: -0.25),
    "Mischevious" : FacialExpression(eyes: .open,   eyeBrows: -0.25, mouth: 0.4)
  ]

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    var destinationVC = segue.destination

    if let navCntrlr = destinationVC as? UINavigationController {
      destinationVC = navCntrlr.visibleViewController ?? destinationVC
    }

    if let faceVC     = destinationVC as? FaceViewController,
       let identifier = segue.identifier,
       let expression = emotionalFaces[identifier] {
      faceVC.expression = expression

      if let sendingButton = sender as? UIButton {
        faceVC.navigationItem.title = sendingButton.currentTitle
      }
    }
  }
}
