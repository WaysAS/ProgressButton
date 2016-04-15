//
//  ProgressButton.swift
//  ButtonExperiment
//
//  Created by Oscar Apeland on 13.04.2016.
//  Copyright © 2016 Ways AS. All rights reserved.
//

import UIKit
@IBDesignable
class ProgressButton: UIButton {
    //IBInspecables
    @IBInspectable
    var normalColor:UIColor = UIColor() {
        didSet {
            layer.borderColor = normalColor.CGColor
            self.tintColor = normalColor
            self.progressBarView.backgroundColor = normalColor
        }
    }
    
    @IBInspectable
    var failColor:UIColor = UIColor.redColor()
    
    @IBInspectable
    var successColor:UIColor?
    
    @IBInspectable
    var defaultTitle:String = "Upload"
    
    @IBInspectable
    var loadingTitle:String = "Uploading"
    
    //Private
    private lazy var progressBarView:UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 0, height: self.frame.height)
        return view
    }()
    
    private lazy var invertedLabel:UILabel = {
        let label = UILabel()
        label.frame = self.titleLabel!.frame
        label.text = self.titleLabel?.text
        label.font = self.titleLabel!.font
        label.textColor = UIColor.whiteColor()
        return label
    }()
    
    //Inits
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    //Functions to update appearance
    func loading(progress:Double) {
        self.userInteractionEnabled = false
        //Set standard label to loading text
        self.setTitle(self.loadingTitle, forState: .Normal)

        //Change inverted label to new title
        invertedLabel.frame = self.titleLabel!.frame
        invertedLabel.text = self.titleLabel?.text
        invertedLabel.font = self.titleLabel!.font
        
        if progressBarView.superview == nil {
            self.addSubview(progressBarView)
            self.addSubview(invertedLabel)
            self.bringSubviewToFront(self.titleLabel!)
        }
        
        //Progress bar animation
        let maskFrame = CGRect(x: self.frame.width * CGFloat(progress) - (self.titleLabel?.frame.minX)!,
                               y: 0,
                               width: self.frame.width,
                               height: self.frame.height)
        let maskView = UIView(frame: maskFrame)
        maskView.backgroundColor = UIColor.blackColor() //Mask works with alpha (made for image masks), so a background color is required.
        
        let newFrame = CGRect(x: 0.0,
                              y: 0.0,
                              width: self.frame.width * CGFloat(progress),
                              height: self.frame.height)
        
        UIView.animateWithDuration(0.1) {
            self.progressBarView.frame = newFrame
            self.titleLabel?.maskView = maskView
        }
    }

    
    func loadingFailed(error:NSError?) {
        //Make icon animation block
        let animateIcon = {
            
            //Make a line from center and outwards in four directions
            let pathToTopLeft = UIBezierPath()
            let pathToBotLeft = UIBezierPath()
            let pathToTopRight = UIBezierPath()
            let pathToBotRight = UIBezierPath()
            let mid = CGPoint(x: self.frame.midX, y: self.frame.midX)
            let height = self.frame.height/2 - self.frame.height/6
            for path in [pathToTopLeft, pathToBotLeft, pathToBotRight, pathToTopRight] {
                path.moveToPoint(mid)
            }
            
            pathToTopLeft.addLineToPoint( CGPoint(x: mid.x - height, y: mid.y - height))
            pathToBotLeft.addLineToPoint( CGPoint(x: mid.x - height, y: mid.y + height))
            pathToTopRight.addLineToPoint(CGPoint(x: mid.x + height, y: mid.y - height))
            pathToBotRight.addLineToPoint( CGPoint(x: mid.x + height, y: mid.y + height))
            
            //Make a layer for each one
            var layers:Array<CAShapeLayer> = Array()
            for path in [pathToTopLeft, pathToBotLeft, pathToBotRight, pathToTopRight] {
                let shapeLayer = CAShapeLayer()
                shapeLayer.frame = self.layer.bounds
                shapeLayer.path = path.CGPath
                shapeLayer.bounds = CGRect(x: mid.x - height, y: mid.y - height, width: height*2, height: height*2)
                shapeLayer.strokeColor = UIColor.whiteColor().CGColor
                shapeLayer.fillColor = nil
                shapeLayer.lineWidth = 2.0
                shapeLayer.lineCap = kCALineCapRound
                shapeLayer.lineJoin = kCALineJoinBevel
                layers.append(shapeLayer)
                self.progressBarView.layer.addSublayer(shapeLayer)
            }
            
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = 0.1
            animation.fromValue = NSNumber(double: 0.0)
            animation.toValue = NSNumber(double: 1.0)
            
            for shapeLayer in layers {
                shapeLayer.addAnimation(animation, forKey: "strokeEnd")
            }
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                for shapeLayer in layers {
                    shapeLayer.removeFromSuperlayer()
                }
                self.resetToDefault()
            }
        }

        
        //Background animation block
        let animateBackground = {
            let borderAnimation = CABasicAnimation(keyPath: "borderColor")
            borderAnimation.fromValue = self.normalColor.CGColor
            borderAnimation.toValue = self.failColor.CGColor
            borderAnimation.duration = 0.3
            self.layer.addAnimation(borderAnimation, forKey: "BorderColorChange2")
            self.layer.borderColor = self.failColor.CGColor

            UIView.animateWithDuration(0.3, animations: {
                self.progressBarView.backgroundColor = self.failColor
            }, completion:  { (success:Bool) in
                animateIcon()
            })
        }
        
        //Clean away text and call animate background block
        UIView.animateWithDuration(0.3, animations: {
            self.titleLabel?.alpha = 0.0
            self.invertedLabel.alpha = 0.0
        }, completion: { (success:Bool) in
            animateBackground()
        })

    }
    
    func loadingDone() {
        //Make icon animation block
        let animateIcon = {
            let path = UIBezierPath()
            let height = self.frame.height
            path.moveToPoint(CGPoint(x: 0.0, y: height/2))
            path.addLineToPoint(CGPoint(x: height/2, y: (height/6)*5))
            path.addLineToPoint(CGPoint(x: height, y: (height/6)*1))
            
            let checkLayer = CAShapeLayer()
            checkLayer.frame = self.layer.bounds
            checkLayer.path = path.CGPath
            checkLayer.bounds = CGPathGetPathBoundingBox(CGPathCreateCopyByStrokingPath(checkLayer.path, nil, 2, .Round, .Miter, 2))
            checkLayer.strokeColor = UIColor.whiteColor().CGColor
            checkLayer.fillColor = nil
            checkLayer.lineWidth = 2.0
            checkLayer.lineCap = kCALineCapRound
            checkLayer.lineJoin = kCALineJoinBevel
            self.progressBarView.layer.addSublayer(checkLayer)

            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = 0.1
            animation.fromValue = NSNumber(double: 0.0)
            animation.toValue = NSNumber(double: 1.0)
            checkLayer.addAnimation(animation, forKey: "strokeEnd")
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                checkLayer.removeFromSuperlayer()
                self.resetToDefault()
            }
        }
        
        
        //Background Animation
        let animateBackground = {
            let borderAnimation = CABasicAnimation(keyPath: "borderColor")
            borderAnimation.fromValue = self.normalColor.CGColor
            let toColor = self.successColor ?? self.normalColor
            borderAnimation.toValue = toColor.CGColor
            borderAnimation.duration = 0.3
            self.layer.addAnimation(borderAnimation, forKey: "BorderColorChange")
            self.layer.borderColor = toColor.CGColor
            
            UIView.animateWithDuration(0.3, animations: {
                self.progressBarView.backgroundColor = self.successColor ?? self.normalColor
            }, completion:  { (success:Bool) in
                animateIcon()
            })
        }
        
        //Clean away text
        UIView.animateWithDuration(0.5, animations: {
            self.titleLabel?.alpha = 0.0
            self.invertedLabel.alpha = 0.0
        }, completion: { (success:Bool) in
            animateBackground()
        })
    }
    
    
    private func resetToDefault() {
        //Prepare for animation
        self.titleLabel?.alpha = 0.0
        self.titleLabel?.maskView = nil
        self.setTitle(self.defaultTitle, forState: .Normal)
        
        let borderAnimation = CABasicAnimation(keyPath: "borderColor")
        borderAnimation.fromValue = self.layer.borderColor!
        borderAnimation.toValue = self.normalColor.CGColor
        borderAnimation.duration = 0.5
        self.layer.addAnimation(borderAnimation, forKey: "BorderColorChange")
        self.layer.borderColor = self.normalColor.CGColor
        
        UIView.animateWithDuration(0.5, animations: {
            //Animate back to original values
            self.progressBarView.alpha = 0.0
            self.invertedLabel.alpha = 0.0
            self.titleLabel?.alpha = 1.0
        }, completion:  { (success:Bool) in
            //Reset and prepare for next animation
            self.progressBarView.removeFromSuperview()
            self.invertedLabel.removeFromSuperview()
            self.progressBarView.alpha = 1.0
            self.invertedLabel.alpha = 1.0
            self.progressBarView.backgroundColor = self.normalColor
            self.progressBarView.frame = CGRect(x: 0, y: 0, width: 0, height: self.frame.height)
            self.userInteractionEnabled = true
        })
    }


}

//Extension to make border
extension ProgressButton {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
}