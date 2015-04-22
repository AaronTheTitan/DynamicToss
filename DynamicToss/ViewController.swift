//
//  ViewController.swift
//  DynamicToss
//
//  Created by Aaron Bradley on 4/22/15.
//  Copyright (c) 2015 Aaron Bradley. All rights reserved.
//

import UIKit

let ThrowingThreshold: CGFloat = 1000
let ThrowingVelocityPadding: CGFloat = 35

class ViewController: UIViewController {


  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var redSquare: UIView!
  @IBOutlet weak var blueSquare: UIView!

  private var originalBounds = CGRect.zeroRect
  private var originalCenter = CGPoint.zeroPoint

  private var animator: UIDynamicAnimator!
  private var attachmentBehavior: UIAttachmentBehavior!
  private var pushBehavior: UIPushBehavior!
  private var itemBehavior: UIDynamicItemBehavior!


  override func viewDidLoad() {
    super.viewDidLoad()

    animator = UIDynamicAnimator(referenceView: view)
    originalBounds = imageView.bounds
    originalCenter = imageView.center
  }


  @IBAction func handleAttachmentGesture(sender: UIPanGestureRecognizer) {
    let location = sender.locationInView(view)
    let boxLocation = sender.locationInView(imageView)

    switch sender.state {
    case .Began:
      println("Your touch start position is \(location)")
      println("Start location in image is \(boxLocation)")

      animator.removeAllBehaviors()

      let centerOffset = UIOffset(horizontal: boxLocation.x - imageView.bounds.midX, vertical: boxLocation.y - imageView.bounds.midY)
      attachmentBehavior = UIAttachmentBehavior(item: imageView, offsetFromCenter: centerOffset, attachedToAnchor: location)

      redSquare.center = attachmentBehavior.anchorPoint
      blueSquare.center = location

      animator.addBehavior(attachmentBehavior)

    case .Ended:
      println("Your touch end position is \(location)")
      println("End location in image is \(boxLocation)")

      animator.removeAllBehaviors()

      let velocity = sender.velocityInView(view)
      let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))

      if magnitude > ThrowingThreshold {
        let pushBehavior = UIPushBehavior(items: [imageView], mode: .Instantaneous)
        pushBehavior.pushDirection = CGVector(dx: velocity.x / 10, dy: velocity.y / 10)
        pushBehavior.magnitude = magnitude / ThrowingVelocityPadding

        self.pushBehavior = pushBehavior
        animator.addBehavior(pushBehavior)

        let angle = Int(arc4random_uniform(20)) - 10

        itemBehavior = UIDynamicItemBehavior(items: [imageView])
        itemBehavior.friction = 0.2
        itemBehavior.allowsRotation = true
        itemBehavior.addAngularVelocity(CGFloat(angle), forItem: imageView)
        animator.addBehavior(itemBehavior)

        let timeOffset = Int64(0.4 * Double(NSEC_PER_SEC))
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, timeOffset), dispatch_get_main_queue()) {
          self.resetDemo()
        }
      } else {
        resetDemo()
      }

    default:
      attachmentBehavior.anchorPoint = sender.locationInView(view)
      redSquare.center = attachmentBehavior.anchorPoint
    }
  }

  func resetDemo() {
    animator.removeAllBehaviors()

    UIView.animateWithDuration(0.45) {
      self.imageView.bounds = self.originalBounds
      self.imageView.center = self.originalCenter
      self.imageView.transform = CGAffineTransformIdentity
    }
  }

}











