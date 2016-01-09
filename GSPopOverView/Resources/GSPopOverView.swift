//
//  GSPopOverView.swift
//  GSPopOverView
//
//  Created by Gurdeep Singh on 15/12/15.
//  Copyright © 2015 Gurdeep Singh. All rights reserved.
//

import UIKit

@objc protocol GSPopOverViewDelegate {

    optional func popupMinimized(popup : GSPopOverView)
    optional func popupMaximized(popup : GSPopOverView)
    optional func popupTapped(popup : GSPopOverView)
}

@IBDesignable
class GSPopOverView: UIView {
    
    @IBInspectable var pointerHeight : CGFloat = 20.0 {
    
        didSet {
            if pointerHeight.isSignMinus {
                pointerLocation = 0
            }
        }
    }
    
    @IBInspectable var pointerWidth : CGFloat = 30.0 {
    
        didSet {
            if pointerWidth.isSignMinus {
                pointerWidth = 0
            }
            
            if pointerEdge == .Bottom || pointerEdge == .Top {
                if pointerWidth > bounds.width - cornerRadius*2 {
                    pointerWidth = bounds.width - cornerRadius*2
                }
            } else if pointerEdge == .Left || pointerEdge == .Right {
                if pointerWidth > bounds.height - cornerRadius*2 {
                    pointerWidth = bounds.height - cornerRadius*2
                }
            }
        }
    }

    @IBInspectable var pointerLocation : CGFloat = 0.5 {
        
        didSet {
            
            if pointerLocation > 1 {
                pointerLocation = 1
            } else if pointerLocation.isSignMinus {
                pointerLocation = 0
            }
            
            var sideSize : CGFloat!

            if pointerEdge == .Bottom || pointerEdge == .Top {
                sideSize = bounds.width
            } else if pointerEdge == .Left || pointerEdge == .Right {
                sideSize = bounds.height
            }

            if (sideSize*pointerLocation)+pointerWidth/2 > sideSize {
                
                pointerLocation = (sideSize - pointerWidth/2)/sideSize
            
            } else if (sideSize*pointerLocation)-pointerWidth/2 < 0 {
                
                pointerLocation = pointerWidth/(2*sideSize)
            }
        }
    }
    
    @IBInspectable var pointerEdgeSide : UInt = 0 {
    
        didSet {
        
            pointerEdgeSide = pointerEdgeSide%4
        }
    }
    
    private var pointerEdge : UIRectEdge {
        
        return UIRectEdge(rawValue: (2 << pointerEdgeSide)/2)
    }
    
    @IBInspectable var cornerRadius : CGFloat = 15.0 {
        
        didSet {
            
            if cornerRadius.isSignMinus {
                cornerRadius = 0
            }
            
            cornerRadius = min(cornerRadius, min((bounds.width)/2, (bounds.height-pointerHeight)/2))
        }
    }

    @IBInspectable var borderWidth : CGFloat = 0.0
    
    @IBInspectable var borderColor : UIColor = UIColor.darkGrayColor()
    
    @IBInspectable var shadowEnabled : Bool = true {
        
        didSet {
            
            if !shadowEnabled {
                
                layer.shadowColor = UIColor.clearColor().CGColor
                layer.shadowRadius = 0.0

            } else {
                
                layer.shadowColor = shadowColor.CGColor
                layer.shadowRadius = shadowRadius
            }
            
            layer.shadowOffset = shadowOffset
            layer.shadowPath = borderPath
            layer.shadowOpacity = shadowOpacity

            layer.masksToBounds = false
            
            layoutIfNeeded()
        }
    }
    
    @IBInspectable var shadowOffset : CGSize = CGSizeZero {
    
        didSet {
            
            if shadowEnabled {
                layer.shadowOffset = shadowOffset
                layer.shadowPath = borderPath
                layer.masksToBounds = false
                layoutIfNeeded()
            }
        }
    }
    
    
    @IBInspectable var shadowRadius : CGFloat = 3.0 {
        
        didSet {

            if shadowEnabled {
                layer.shadowRadius = shadowRadius
                layer.shadowPath = borderPath
                layer.masksToBounds = false
                layoutIfNeeded()
            }
        }
    }
    
    @IBInspectable var shadowColor : UIColor = UIColor.darkGrayColor() {
        
        didSet {
            
            if shadowEnabled {
                layer.shadowColor = shadowColor.CGColor
                layer.shadowPath = borderPath
                layer.masksToBounds = false
                layoutIfNeeded()
            }
        }
    }
    
    @IBInspectable var shadowOpacity : Float = 0.9 {
        
        didSet {
            
            if shadowEnabled {
                layer.shadowOpacity = shadowOpacity
                layer.shadowPath = borderPath
                layer.masksToBounds = false
                layoutIfNeeded()
            }
        }
    }

    override var alpha : CGFloat {
        
        didSet {
            
            popupAlpha = alpha
            super.alpha = 1.0
        }
    }
    
    override var backgroundColor : UIColor? {
        
        didSet {
            
            popupBackgroungColor = backgroundColor ?? UIColor.whiteColor()
            super.backgroundColor = UIColor.clearColor()
        }
    }
    
    var minimized : Bool {
        
        return !CGAffineTransformIsIdentity(self.transform)
    }
    
    var effectiveBounds : CGRect {
    
        var _bounds = bounds
        
        if pointerEdge == .Bottom || pointerEdge == .Top {
        
            _bounds.size.height -= pointerHeight
            
        } else if pointerEdge == .Left || pointerEdge == .Right {
            
            _bounds.size.width -= pointerHeight
        }
        
        return _bounds
    }
    
    
    var effectiveFrame : CGRect {
    
        var _frame = effectiveBounds
        
        if pointerEdge == .Top {
            
            _frame.origin.y = frame.origin.y + pointerHeight
            
        } else if pointerEdge == .Right {
            
            _frame.origin.x = frame.origin.x + pointerHeight
        }
        
        return _frame
    }
    
    var effectiveCenter : CGPoint {
    
        switch pointerEdge {
            
        case UIRectEdge.Top :
            return CGPointMake(center.x, center.y+pointerHeight)
            
        case UIRectEdge.Bottom :
            return CGPointMake(center.x, center.y-pointerHeight)
            
        case UIRectEdge.Left :
            return CGPointMake(center.x-pointerHeight, center.y)
            
        case UIRectEdge.Right :
            return CGPointMake(center.x+pointerHeight, center.y)
            
        default : return CGPointZero
            
        }
        
    }
    
    private var pointerHead : CGPoint {
        
        switch pointerEdge {
        
            case UIRectEdge.Top :
                return CGPointMake(bounds.width*pointerLocation, 0)

            case UIRectEdge.Bottom :
                return CGPointMake(bounds.width*pointerLocation, bounds.height)

            case UIRectEdge.Left :
                return CGPointMake(bounds.width, bounds.height*pointerLocation)

            case UIRectEdge.Right :
                return CGPointMake(0, bounds.height*pointerLocation)

            default : return CGPointZero

        }

    }
    
    var delegate : GSPopOverViewDelegate?
    
    private var borderPath : CGMutablePathRef!
    
    private var popupAlpha : CGFloat = 1.0
    private var popupBackgroungColor : UIColor = UIColor.whiteColor()
    
    func present(animated animated:Bool = true) {
        
        let animation : ()->Void = {
            unowned let weakSelf = self
            weakSelf.transform = CGAffineTransformIdentity
        }
        
        let animationCompleted : (Bool)->Void = {   _ in
        
            unowned let weakSelf = self
            weakSelf.delegate?.popupMaximized?(weakSelf)
        }
        
        self.hidden = false

        if animated {
        
            UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.CurveEaseOut, animations: animation, completion: animationCompleted)
            
        } else {
        
            animation()
            animationCompleted(true)
        }
        
    }
    
    func dismiss(animated animated:Bool = true) {
        
        let animation : () -> Void = {
            
            unowned let weakSelf = self

            let scale_t = CGAffineTransformMakeScale(0.0001, 0.0001)
            
            let translate_t = CGAffineTransformMakeTranslation(
                weakSelf.pointerHead.x - weakSelf.frame.width/2,
                weakSelf.pointerHead.y - weakSelf.frame.height/2
            )
            
            weakSelf.transform = CGAffineTransformConcat(scale_t, translate_t)
        }
        
        let animationCompleted : (Bool) -> Void = {
            
            unowned let weakSelf = self

            weakSelf.hidden = $0
            weakSelf.delegate?.popupMinimized?(weakSelf)
        }
    
        if animated {
            
            UIView.animateWithDuration(0.2, animations: animation, completion: animationCompleted)
            
        } else {
            
            animation()
            animationCompleted(true)
        }
        
    }
    
    func toggle(animated animated:Bool = true) {
    
        minimized ? present(animated: animated) : dismiss(animated: animated)
    }
    
    private var halfBorderWidth : CGFloat {
        return borderWidth/2
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    
    override func drawRect(rect: CGRect) {
        
        super.drawRect(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        
        CGContextSetLineWidth(context, borderWidth)
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetStrokeColorWithColor(context, borderColor.CGColor)
        CGContextSetAlpha(context, popupAlpha)
        
        CGContextSetFillColorWithColor(context, popupBackgroungColor.CGColor)
        CGContextFillPath(context)

        if self.pointerEdge == .Top {
        
            self.drawWithTopEdge(rect, context: context)
            
        } else if self.pointerEdge == .Bottom {
            
            self.drawWithBottomEdge(rect, context: context)
        
        } else if self.pointerEdge == .Left {
            
            self.drawWithLeftEdge(rect, context: context)
        
        } else if self.pointerEdge == .Right {
            
            self.drawWithRightEdge(rect, context: context)
        }

        self.layer.contentsScale = UIScreen.mainScreen().scale
    }
    
    private func drawWithTopEdge(rect: CGRect, context: CGContextRef) {
        
        borderPath = CGPathCreateMutable()
        
        let arcLength : CGFloat = halfBorderWidth+cornerRadius
        
        CGPathMoveToPoint(borderPath, nil, halfBorderWidth, rect.height - arcLength)
        CGPathAddArc(borderPath, nil, arcLength, cornerRadius + pointerHeight, cornerRadius, CGFloat(M_PI), CGFloat(-M_PI_2), false)
        
        CGPathAddLineToPoint(borderPath, nil, (rect.width*pointerLocation)-pointerWidth/2, pointerHeight)
        CGPathAddLineToPoint(borderPath, nil, (rect.width*pointerLocation), halfBorderWidth)
        CGPathAddLineToPoint(borderPath, nil, (rect.width*pointerLocation)+pointerWidth/2, pointerHeight)
        
        CGPathAddArc(borderPath, nil, rect.width - arcLength, cornerRadius + pointerHeight, cornerRadius, CGFloat(-M_PI_2), 0, false)
        CGPathAddArc(borderPath, nil, rect.width - arcLength, rect.height - arcLength, cornerRadius, 0, CGFloat(M_PI_2), false)
        CGPathAddArc(borderPath, nil, arcLength, rect.height - arcLength, cornerRadius , CGFloat(M_PI_2), CGFloat(M_PI), false)
        
        CGContextAddPath(context, borderPath)
        CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
        
    }

    private func drawWithBottomEdge(rect: CGRect, context: CGContextRef) {
        
        borderPath = CGPathCreateMutable()
        
        let arcLength : CGFloat = halfBorderWidth+cornerRadius

        CGPathMoveToPoint(borderPath, nil, halfBorderWidth, rect.height - pointerHeight - cornerRadius)
        CGPathAddArc(borderPath, nil, arcLength, arcLength, cornerRadius, CGFloat(M_PI), CGFloat(-M_PI_2), false)
        CGPathAddArc(borderPath, nil, rect.width - arcLength, arcLength, cornerRadius, CGFloat(-M_PI_2), 0, false)
        CGPathAddArc(borderPath, nil, rect.width - arcLength, rect.height - pointerHeight - cornerRadius, cornerRadius, 0, CGFloat(M_PI_2), false)
        
        CGPathAddLineToPoint(borderPath, nil, (rect.width*pointerLocation)+pointerWidth/2, rect.height - pointerHeight)
        CGPathAddLineToPoint(borderPath, nil, (rect.width*pointerLocation), rect.height-halfBorderWidth)
        CGPathAddLineToPoint(borderPath, nil, (rect.width*pointerLocation)-pointerWidth/2, rect.height - pointerHeight)
        
        CGPathAddArc(borderPath, nil, arcLength, rect.height - pointerHeight - cornerRadius , cornerRadius , CGFloat(M_PI_2), CGFloat(M_PI), false)
        
        CGContextAddPath(context, borderPath)
        CGContextDrawPath(context, CGPathDrawingMode.FillStroke)

    }

    private func drawWithLeftEdge(rect: CGRect, context: CGContextRef) {

        borderPath = CGPathCreateMutable()
        
        let arcLength : CGFloat = halfBorderWidth+cornerRadius

        CGPathMoveToPoint(borderPath, nil, halfBorderWidth, rect.height - cornerRadius)

        CGPathAddArc(borderPath, nil, arcLength, arcLength, cornerRadius, CGFloat(M_PI), CGFloat(-M_PI_2), false)
        CGPathAddArc(borderPath, nil, rect.width - pointerHeight - cornerRadius, arcLength, cornerRadius, CGFloat(-M_PI_2), 0, false)
        
        CGPathAddLineToPoint(borderPath, nil, rect.width - pointerHeight, (rect.height*pointerLocation) - pointerWidth/2)
        CGPathAddLineToPoint(borderPath, nil, rect.width - halfBorderWidth, rect.height*pointerLocation)
        CGPathAddLineToPoint(borderPath, nil, rect.width - pointerHeight, (rect.height*pointerLocation) + pointerWidth/2)
        
        CGPathAddArc(borderPath, nil, rect.width - pointerHeight - cornerRadius, rect.height - arcLength, cornerRadius, 0, CGFloat(M_PI_2), false)
        CGPathAddArc(borderPath, nil, arcLength, rect.height - arcLength , cornerRadius , CGFloat(M_PI_2), CGFloat(M_PI), false)
        
        CGContextAddPath(context, borderPath)
        CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
        
    }
    
    private func drawWithRightEdge(rect: CGRect, context: CGContextRef) {

        borderPath = CGPathCreateMutable()
        
        let arcLength : CGFloat = halfBorderWidth+cornerRadius

        CGPathMoveToPoint(borderPath, nil, pointerHeight, rect.height - arcLength)
        
        CGPathAddLineToPoint(borderPath, nil, pointerHeight, (rect.height*pointerLocation)+pointerWidth/2)
        CGPathAddLineToPoint(borderPath, nil, halfBorderWidth, rect.height*pointerLocation)
        CGPathAddLineToPoint(borderPath, nil, pointerHeight, (rect.height*pointerLocation)-pointerWidth/2)
        
        CGPathAddArc(borderPath, nil, cornerRadius + pointerHeight, arcLength, cornerRadius, CGFloat(M_PI), CGFloat(-M_PI_2), false)
        CGPathAddArc(borderPath, nil, rect.width - arcLength, arcLength, cornerRadius, CGFloat(-M_PI_2), 0, false)
        CGPathAddArc(borderPath, nil, rect.width - arcLength, rect.height - arcLength, cornerRadius, 0, CGFloat(M_PI_2), false)
        CGPathAddArc(borderPath, nil, cornerRadius + pointerHeight, rect.height - arcLength , cornerRadius , CGFloat(M_PI_2), CGFloat(M_PI), false)
        
        CGContextAddPath(context, borderPath)
        CGContextDrawPath(context, CGPathDrawingMode.FillStroke)

    }

    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        
        return CGPathContainsPoint(borderPath, nil, point, true)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        super.touchesBegan(touches, withEvent: event)
        delegate?.popupTapped?(self)
    }
    
}
