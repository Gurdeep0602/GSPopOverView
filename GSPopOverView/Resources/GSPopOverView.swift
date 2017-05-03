//
//  GSPopOverView.swift
//  GSPopOverView
//
//  Created by Gurdeep Singh on 15/12/15.
//  Copyright © 2015 Gurdeep Singh. All rights reserved.
//

import UIKit


@objc protocol GSPopOverViewDelegate {

    @objc optional func popupMinimized(_ popup : GSPopOverView)
    @objc optional func popupMaximized(_ popup : GSPopOverView)
    @objc optional func popupTapped(_ popup : GSPopOverView)
}

@IBDesignable
class GSPopOverView: UIView {
    
    @IBInspectable var pointerHeight : CGFloat = 20.0 {
    
        didSet {
            if pointerHeight.sign == .minus {
                pointerLocation = 0
            }
        }
    }
    
    @IBInspectable var pointerWidth : CGFloat = 30.0 {
    
        didSet {
            if pointerWidth.sign == .minus {
                pointerWidth = 0
            }
            
            if pointerEdge == .bottom || pointerEdge == .top {
                if pointerWidth > bounds.width - cornerRadius*2 {
                    pointerWidth = bounds.width - cornerRadius*2
                }
            } else if pointerEdge == .left || pointerEdge == .right {
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
            } else if pointerLocation.sign == .minus {
                pointerLocation = 0
            }
            
            var sideSize : CGFloat!

            if pointerEdge == .bottom || pointerEdge == .top {
                sideSize = bounds.width
            } else if pointerEdge == .left || pointerEdge == .right {
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
    
    fileprivate var pointerEdge : UIRectEdge {
        
        return UIRectEdge(rawValue: (2 << pointerEdgeSide)/2)
    }
    
    @IBInspectable var cornerRadius : CGFloat = 15.0 {
        
        didSet {
            
            if cornerRadius.sign == .minus {
                cornerRadius = 0
            }
            
            cornerRadius = min(cornerRadius, min((bounds.width)/2, (bounds.height-pointerHeight)/2))
        }
    }

    @IBInspectable var borderWidth : CGFloat = 0.0
    
    @IBInspectable var borderColor : UIColor = UIColor.darkGray
    
    @IBInspectable var shadowEnabled : Bool = true {
        
        didSet {
            
            if !shadowEnabled {
                
                layer.shadowColor = UIColor.clear.cgColor
                layer.shadowRadius = 0.0

            } else {
                
                layer.shadowColor = shadowColor.cgColor
                layer.shadowRadius = shadowRadius
            }
            
            layer.shadowOffset = shadowOffset
            layer.shadowPath = borderPath
            layer.shadowOpacity = shadowOpacity

            layer.masksToBounds = false
            
            layoutIfNeeded()
        }
    }
    
    @IBInspectable var shadowOffset : CGSize = CGSize.zero {
    
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
    
    @IBInspectable var shadowColor : UIColor = UIColor.darkGray {
        
        didSet {
            
            if shadowEnabled {
                layer.shadowColor = shadowColor.cgColor
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
            
            popupBackgroungColor = backgroundColor ?? UIColor.white
            super.backgroundColor = UIColor.clear
        }
    }
    
    var minimized : Bool {
        
        return !self.transform.isIdentity
    }
    
    var effectiveBounds : CGRect {
    
        var _bounds = bounds
        
        if pointerEdge == .bottom || pointerEdge == .top {
        
            _bounds.size.height -= pointerHeight
            
        } else if pointerEdge == .left || pointerEdge == .right {
            
            _bounds.size.width -= pointerHeight
        }
        
        return _bounds
    }
    
    
    var effectiveFrame : CGRect {
    
        var _frame = effectiveBounds
        
        if pointerEdge == .top {
            
            _frame.origin.y = frame.origin.y + pointerHeight
            
        } else if pointerEdge == .right {
            
            _frame.origin.x = frame.origin.x + pointerHeight
        }
        
        return _frame
    }
    
    var effectiveCenter : CGPoint {
    
        switch pointerEdge {
            
        case UIRectEdge.top :
            return CGPoint(x: center.x, y: center.y+pointerHeight)
            
        case UIRectEdge.bottom :
            return CGPoint(x: center.x, y: center.y-pointerHeight)
            
        case UIRectEdge.left :
            return CGPoint(x: center.x-pointerHeight, y: center.y)
            
        case UIRectEdge.right :
            return CGPoint(x: center.x+pointerHeight, y: center.y)
            
        default : return CGPoint.zero
            
        }
        
    }
    
    fileprivate var pointerHead : CGPoint {
        
        switch pointerEdge {
        
            case UIRectEdge.top :
                return CGPoint(x: bounds.width*pointerLocation, y: 0)

            case UIRectEdge.bottom :
                return CGPoint(x: bounds.width*pointerLocation, y: bounds.height)

            case UIRectEdge.left :
                return CGPoint(x: bounds.width, y: bounds.height*pointerLocation)

            case UIRectEdge.right :
                return CGPoint(x: 0, y: bounds.height*pointerLocation)

            default : return CGPoint.zero

        }

    }
    
    var delegate : GSPopOverViewDelegate?
    
    fileprivate var borderPath : CGMutablePath!
    
    fileprivate var popupAlpha : CGFloat = 1.0
    fileprivate var popupBackgroungColor : UIColor = UIColor.white
    
    func present(animated:Bool = true) {
        
        let animation : ()->Void = {
            unowned let weakSelf = self
            weakSelf.transform = CGAffineTransform.identity
        }
        
        let animationCompleted : (Bool)->Void = {   _ in
        
            unowned let weakSelf = self
            weakSelf.delegate?.popupMaximized?(weakSelf)
        }
        
        self.isHidden = false

        
        if animated {
        
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.curveEaseOut, animations: animation, completion: animationCompleted)
            
        } else {
        
            animation()
            animationCompleted(true)
        }
        
        guard let superview = self.superview else { return }

        let view = BackgroudView(frame: CGRect.zero)
        view.delegate = self
        superview.addSubview(view)
        superview.bringSubview(toFront: self)
        
    }
    
    func dismiss(animated:Bool = true) {
        
        let animation : () -> Void = {
            
            unowned let weakSelf = self

            let scale_t = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
            
            let translate_t = CGAffineTransform(
                translationX: weakSelf.pointerHead.x - weakSelf.frame.width/2,
                y: weakSelf.pointerHead.y - weakSelf.frame.height/2
            )
            
            weakSelf.transform = scale_t.concatenating(translate_t)
        }
        
        let animationCompleted : (Bool) -> Void = {
            
            unowned let weakSelf = self

            weakSelf.isHidden = $0
            weakSelf.delegate?.popupMinimized?(weakSelf)
        }
    
        if animated {
            
            UIView.animate(withDuration: 0.2, animations: animation, completion: animationCompleted)
            
        } else {
            
            animation()
            animationCompleted(true)
        }
        
    }
    
    func toggle(animated:Bool = true) {
    
        minimized ? present(animated: animated) : dismiss(animated: animated)
    }
    
    fileprivate var halfBorderWidth : CGFloat {
        return borderWidth/2
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    
    override func draw(_ rect: CGRect) {
        
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        
        context.setLineWidth(borderWidth)
        context.setLineCap(CGLineCap.round)
        context.setStrokeColor(borderColor.cgColor)
        context.setAlpha(popupAlpha)
        
        context.setFillColor(popupBackgroungColor.cgColor)
        context.fillPath()

        if self.pointerEdge == .top {
        
            self.drawWithTopEdge(rect, context: context)
            
        } else if self.pointerEdge == .bottom {
            
            self.drawWithBottomEdge(rect, context: context)
        
        } else if self.pointerEdge == .left {
            
            self.drawWithLeftEdge(rect, context: context)
        
        } else if self.pointerEdge == .right {
            
            self.drawWithRightEdge(rect, context: context)
        }

        self.layer.contentsScale = UIScreen.main.scale
    }
    
    fileprivate func drawWithTopEdge(_ rect: CGRect, context: CGContext) {
        
        
        borderPath = CGMutablePath()
        
        let arcLength : CGFloat = halfBorderWidth+cornerRadius
        
        borderPath.move(to: CGPoint(x: halfBorderWidth, y: rect.height - arcLength))
        
        borderPath.addArc(center: CGPoint(x: arcLength, y: cornerRadius + pointerHeight), radius: cornerRadius,
                    startAngle: CGFloat.pi, endAngle: -CGFloat.pi_2, clockwise: false)
        
        borderPath.addLine(to: CGPoint(x: (rect.width*pointerLocation)-pointerWidth/2, y: pointerHeight))
        borderPath.addLine(to: CGPoint(x: (rect.width*pointerLocation), y: halfBorderWidth))
        borderPath.addLine(to: CGPoint(x: (rect.width*pointerLocation)+pointerWidth/2, y: pointerHeight))
        
        borderPath.addArc(center: CGPoint(x: rect.width - arcLength, y: cornerRadius + pointerHeight), radius: cornerRadius,
                          startAngle: -CGFloat.pi_2, endAngle: 0, clockwise: false)
        
        borderPath.addArc(center: CGPoint(x: rect.width - arcLength, y: rect.height - arcLength), radius: cornerRadius,
                          startAngle: 0, endAngle: CGFloat.pi_2, clockwise: false)
        
        borderPath.addArc(center: CGPoint(x: arcLength, y: rect.height - arcLength), radius: cornerRadius,
                          startAngle: CGFloat.pi_2, endAngle: CGFloat.pi, clockwise: false)
        
        
//        CGPathMoveToPoint(borderPath, nil, halfBorderWidth, rect.height - arcLength)
//        CGPathAddArc(borderPath, nil, arcLength, cornerRadius + pointerHeight, cornerRadius, CGFloat.pi, -CGFloat.pi_2, false)
        
//        CGPathAddLineToPoint(borderPath, nil, (rect.width*pointerLocation)-pointerWidth/2, pointerHeight)
//        CGPathAddLineToPoint(borderPath, nil, (rect.width*pointerLocation), halfBorderWidth)
//        CGPathAddLineToPoint(borderPath, nil, (rect.width*pointerLocation)+pointerWidth/2, pointerHeight)
//        
//        CGPathAddArc(borderPath, nil, rect.width - arcLength, cornerRadius + pointerHeight, cornerRadius, -CGFloat.pi_2, 0, false)
//        CGPathAddArc(borderPath, nil, rect.width - arcLength, rect.height - arcLength, cornerRadius, 0, CGFloat.pi_2, false)
//        CGPathAddArc(borderPath, nil, arcLength, rect.height - arcLength, cornerRadius , CGFloat.pi_2, CGFloat.pi, false)
//        CGContextClosePath(context)

        context.addPath(borderPath)
        context.drawPath(using: CGPathDrawingMode.fillStroke)
        
    }

    fileprivate func drawWithBottomEdge(_ rect: CGRect, context: CGContext) {
        
        borderPath = CGMutablePath()
        
        let arcLength : CGFloat = halfBorderWidth+cornerRadius

        borderPath.move(to: CGPoint(x: halfBorderWidth, y: rect.height - pointerHeight - cornerRadius))
        
        borderPath.addArc(center: CGPoint(x: arcLength, y: arcLength), radius: cornerRadius,
                          startAngle: CGFloat(Double.pi), endAngle: -CGFloat.pi_2, clockwise: false)

        borderPath.addArc(center: CGPoint(x: rect.width - arcLength, y: arcLength), radius: cornerRadius,
                          startAngle: -CGFloat.pi_2, endAngle: 0, clockwise: false)

        borderPath.addArc(center: CGPoint(x: rect.width - arcLength, y: rect.height - pointerHeight - cornerRadius), radius: cornerRadius,
                          startAngle: 0, endAngle: CGFloat.pi_2, clockwise: false)
        
        
        borderPath.addLine(to: CGPoint(x: (rect.width*pointerLocation)+pointerWidth/2, y: rect.height - pointerHeight))
        borderPath.addLine(to: CGPoint(x: (rect.width*pointerLocation), y: rect.height - halfBorderWidth))
        borderPath.addLine(to: CGPoint(x: (rect.width*pointerLocation)-pointerWidth/2, y: rect.height - pointerHeight))

        borderPath.addArc(center: CGPoint(x: arcLength, y: rect.height - pointerHeight - cornerRadius), radius: cornerRadius,
                          startAngle: CGFloat.pi_2, endAngle: CGFloat.pi, clockwise: false)

        
        
//        CGPathMoveToPoint(borderPath, nil, halfBorderWidth, rect.height - pointerHeight - cornerRadius)
//        CGPathAddArc(borderPath, nil, arcLength, arcLength, cornerRadius, CGFloat.pi, -CGFloat.pi_2, false)
//        CGPathAddArc(borderPath, nil, rect.width - arcLength, arcLength, cornerRadius, -CGFloat.pi_2, 0, false)
//        CGPathAddArc(borderPath, nil, rect.width - arcLength, rect.height - pointerHeight - cornerRadius, cornerRadius, 0, CGFloat.pi_2, false)
//        
//        CGPathAddLineToPoint(borderPath, nil, (rect.width*pointerLocation)+pointerWidth/2, rect.height - pointerHeight)
//        CGPathAddLineToPoint(borderPath, nil, (rect.width*pointerLocation), rect.height-halfBorderWidth)
//        CGPathAddLineToPoint(borderPath, nil, (rect.width*pointerLocation)-pointerWidth/2, rect.height - pointerHeight)
//        
//        CGPathAddArc(borderPath, nil, arcLength, rect.height - pointerHeight - cornerRadius , cornerRadius , CGFloat.pi_2, CGFloat.pi, false)
//        CGContextClosePath(context)

        context.addPath(borderPath)
        context.drawPath(using: CGPathDrawingMode.fillStroke)

    }

    fileprivate func drawWithLeftEdge(_ rect: CGRect, context: CGContext) {

        borderPath = CGMutablePath()
        
        let arcLength : CGFloat = halfBorderWidth+cornerRadius

        borderPath.move(to: CGPoint(x: halfBorderWidth, y: rect.height - cornerRadius))
        
        borderPath.addArc(center: CGPoint(x: arcLength, y: arcLength), radius: cornerRadius,
                          startAngle: CGFloat.pi, endAngle: -CGFloat.pi_2, clockwise: false)

        borderPath.addArc(center: CGPoint(x: rect.width - pointerHeight - cornerRadius, y: arcLength), radius: cornerRadius,
                          startAngle: -CGFloat.pi_2, endAngle: 0, clockwise: false)
        
        borderPath.addLine(to: CGPoint(x: rect.width - pointerHeight, y: (rect.height*pointerLocation) - pointerWidth/2))
        borderPath.addLine(to: CGPoint(x: rect.width - halfBorderWidth, y: rect.height*pointerLocation))
        borderPath.addLine(to: CGPoint(x: rect.width - pointerHeight, y: (rect.height*pointerLocation) + pointerWidth/2))

        borderPath.addArc(center: CGPoint(x: rect.width - pointerHeight - cornerRadius, y: rect.height - arcLength), radius: cornerRadius,
                          startAngle: 0, endAngle: CGFloat.pi_2, clockwise: false)

        borderPath.addArc(center: CGPoint(x: arcLength, y: rect.height - arcLength), radius: cornerRadius,
                          startAngle: CGFloat.pi_2, endAngle: CGFloat.pi, clockwise: false)

        
//        CGPathMoveToPoint(borderPath, nil, halfBorderWidth, rect.height - cornerRadius)
//
//        CGPathAddArc(borderPath, nil, arcLength, arcLength, cornerRadius, CGFloat.pi, -CGFloat.pi_2, false)
//        CGPathAddArc(borderPath, nil, rect.width - pointerHeight - cornerRadius, arcLength, cornerRadius, -CGFloat.pi_2, 0, false)
//        
//        CGPathAddLineToPoint(borderPath, nil, rect.width - pointerHeight, (rect.height*pointerLocation) - pointerWidth/2)
//        CGPathAddLineToPoint(borderPath, nil, rect.width - halfBorderWidth, rect.height*pointerLocation)
//        CGPathAddLineToPoint(borderPath, nil, rect.width - pointerHeight, (rect.height*pointerLocation) + pointerWidth/2)
//        
//        CGPathAddArc(borderPath, nil, rect.width - pointerHeight - cornerRadius, rect.height - arcLength, cornerRadius, 0, CGFloat.pi_2, false)
//        CGPathAddArc(borderPath, nil, arcLength, rect.height - arcLength , cornerRadius , CGFloat.pi_2, CGFloat.pi, false)
//        CGContextClosePath(context)

        context.addPath(borderPath)
        context.drawPath(using: CGPathDrawingMode.fillStroke)
        
    }
    
    fileprivate func drawWithRightEdge(_ rect: CGRect, context: CGContext) {

        borderPath = CGMutablePath()
        
        let arcLength : CGFloat = halfBorderWidth+cornerRadius

        borderPath.move(to: CGPoint(x: pointerHeight, y: rect.height - arcLength))

        borderPath.addLine(to: CGPoint(x: pointerHeight, y: (rect.height*pointerLocation) + pointerWidth/2))
        borderPath.addLine(to: CGPoint(x: halfBorderWidth, y: rect.height*pointerLocation))
        borderPath.addLine(to: CGPoint(x: pointerHeight, y: (rect.height*pointerLocation) - pointerWidth/2))

        borderPath.addArc(center: CGPoint(x: cornerRadius + pointerHeight, y: arcLength), radius: cornerRadius,
                          startAngle: CGFloat.pi, endAngle: -CGFloat.pi_2, clockwise: false)

        borderPath.addArc(center: CGPoint(x: rect.width - arcLength, y: arcLength), radius: cornerRadius,
                          startAngle: -CGFloat.pi_2, endAngle: 0, clockwise: false)

        borderPath.addArc(center: CGPoint(x: rect.width - arcLength, y: rect.height - arcLength), radius: cornerRadius,
                          startAngle: 0, endAngle: CGFloat.pi_2, clockwise: false)

        borderPath.addArc(center: CGPoint(x: cornerRadius + pointerHeight, y: rect.height - arcLength), radius: cornerRadius,
                          startAngle: CGFloat.pi_2, endAngle: CGFloat.pi, clockwise: false)

        
//        CGPathMoveToPoint(borderPath, nil, pointerHeight, rect.height - arcLength)
//        
//        CGPathAddLineToPoint(borderPath, nil, pointerHeight, (rect.height*pointerLocation)+pointerWidth/2)
//        CGPathAddLineToPoint(borderPath, nil, halfBorderWidth, rect.height*pointerLocation)
//        CGPathAddLineToPoint(borderPath, nil, pointerHeight, (rect.height*pointerLocation)-pointerWidth/2)
//        
//        CGPathAddArc(borderPath, nil, cornerRadius + pointerHeight, arcLength, cornerRadius, CGFloat.pi, -CGFloat.pi_2, false)
//        CGPathAddArc(borderPath, nil, rect.width - arcLength, arcLength, cornerRadius, -CGFloat.pi_2, 0, false)
        
//        CGPathAddArc(borderPath, nil, rect.width - arcLength, rect.height - arcLength, cornerRadius, 0, CGFloat.pi_2, false)
//        CGPathAddArc(borderPath, nil, cornerRadius + pointerHeight, rect.height - arcLength , cornerRadius , CGFloat.pi_2, CGFloat.pi, false)
//        CGContextClosePath(context)

        context.addPath(borderPath)
        context.drawPath(using: CGPathDrawingMode.fillStroke)

    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
        return borderPath.contains(point) //  CGPathContainsPoint(borderPath, nil, point, true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesBegan(touches, with: event)
        delegate?.popupTapped?(self)
    }
    
}


protocol BackgroundViewDelegate {
    func backgroudViewTapped(_ view: BackgroudView)
}

class BackgroudView : UIView {
    
    var delegate : BackgroundViewDelegate?
    
    override init(frame: CGRect) {

        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 1.0, alpha: 0)
        self.frame = UIScreen.main.bounds
    }

    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
        self.backgroundColor = UIColor(white: 1.0, alpha: 0)
        self.frame = UIScreen.main.bounds
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.delegate?.backgroudViewTapped(self)
    }
}

extension GSPopOverView : BackgroundViewDelegate {

    func backgroudViewTapped(_ view: BackgroudView) {
    
        view.removeFromSuperview()
        
        self.dismiss()
    }
}

private extension CGFloat {

    static var pi : CGFloat {
        return CGFloat(Double.pi)
    }

    static var pi_2 : CGFloat {
        return CGFloat(Double.pi) / 2.0
    }
}
