//
//  SegmentView.swift
//  SwiftSegmentView
//
//  Created by Bhambhwani, Jaikumar (US - Mumbai) on 7/7/14.
//  Copyright (c) 2014 Jaikumar. All rights reserved.
//

import UIKit
import QuartzCore

@objc protocol SegmentViewDataSource: NSObjectProtocol {
    func numberOfSegments(segmentView: SegmentView) -> Int
    func contentForSegment(segmentIndex: Int) -> AnyObject?
}

@objc protocol SegmentViewDelegate: NSObjectProtocol {
    @optional func didSelectSegment(segementView: SegmentView,segment: Int)
    @optional func imageInsetForSegment(segementView: SegmentView,segment: Int) -> UIEdgeInsets
}

class SegmentViewBackgroundLayer: CAShapeLayer {

    init(containerFrame: CGRect) {
        super.init()
        self.container = containerFrame
    }
    
    var selectSegment: Int = 0 {
        didSet {
            self.currentPath = self.paths[selectSegment] as? UIBezierPath
        }
    }

    var paths: NSMutableArray = NSMutableArray()
    
    var container: CGRect = CGRectZero
    
    var numberOfSegments: Int = 0 {
        didSet {
            if(numberOfSegments > 1 && numberOfSegments < 5) {
                for i in 0..numberOfSegments {
                    paths.addObject(self.pathForBackground(self.container, position: CGFloat(2 * i + 1) * (1.0/CGFloat(numberOfSegments * 2))))
                }
            }
        }
    }
    
    var currentPath: UIBezierPath?
    {
        didSet {
            var animation: CABasicAnimation = CABasicAnimation(keyPath:"path")
            animation.fromValue = oldValue?.CGPath
            animation.toValue = paths[selectSegment].CGPath
            animation.duration = 0.3
            animation.removedOnCompletion = false
            animation.fillMode = kCAFillModeForwards
            self.addAnimation(animation, forKey: "animation")
            self.path = currentPath!.CGPath
        }
    }
    
    
    func pathForBackground(container: CGRect, position: CGFloat) -> UIBezierPath {
        
        //// Subframes
        let chevronFrame: CGRect = CGRectMake(container.minX + CGFloat(floor(Double(container.width * position - 7.8 + 0.5))), container.minY + CGFloat(floor(Double(container.height * 0.74138 + 0.5))), CGFloat(floor(Double(container.width * 0.78982 + 0.5))) - CGFloat(floor(Double(container.width * 0.75000 + 0.5))), CGFloat(floor(Double(container.height * 0.96552 + 0.5))) - CGFloat(floor(Double(container.height * 0.74138 + 0.5))))
        
        //// Bezier Drawing
        var bezierPath: UIBezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPointMake(container.minX + 1.00000 * container.width, container.minY + 0.01211 * container.height))
        bezierPath.addLineToPoint(CGPointMake(container.minX + 1.00000 * container.width, container.minY + 0.92276 * container.height))
        bezierPath.addLineToPoint(CGPointMake(chevronFrame.minX + 0.95168 * chevronFrame.width, chevronFrame.minY + 0.78840 * chevronFrame.height))
        bezierPath.addLineToPoint(CGPointMake(chevronFrame.minX + 0.53790 * chevronFrame.width, chevronFrame.minY + 0.13838 * chevronFrame.height))
        bezierPath.addLineToPoint(CGPointMake(chevronFrame.minX + 0.01335 * chevronFrame.width, chevronFrame.minY + 0.78840 * chevronFrame.height))
        bezierPath.addLineToPoint(CGPointMake(container.minX + 0.00000 * container.width, container.minY + 0.92276 * container.height))
        bezierPath.addLineToPoint(CGPointMake(container.minX + 0.00000 * container.width, container.minY + 0.01211 * container.height))
        bezierPath.addLineToPoint(CGPointMake(container.minX + 1.00000 * container.width, container.minY + 0.01211 * container.height))
        bezierPath.closePath()
        bezierPath.miterLimit = 4;
        
        return bezierPath
    }
}

class SegmentView: UIView {
    
    var delegate: SegmentViewDelegate?
    var datasource: SegmentViewDataSource? {
        didSet {
            self.initialize()
        }
    }
    var selectedSegment: Int = 0 {
        didSet {
            self.segmentBackgroundLayer!.selectSegment = self.selectedSegment
        }
    }
    var numberOfSegments: Int?
    var segmentContentDictionary: Dictionary<Int,AnyObject?> = Dictionary<Int,AnyObject?>()
    var segmentBackgroundLayer: SegmentViewBackgroundLayer?
    var segmentButtons: Array<UIButton> = Array<UIButton>()
    var fillColor: UIColor = UIColor.blackColor() {
        didSet {
            if let bkglayer = self.segmentBackgroundLayer {
                bkglayer.fillColor = fillColor.CGColor
            }
        }
    }
    
    init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(coder aDecoder: NSCoder!)  {
        super.init(coder: aDecoder)
    }
    
    func initialize() {
        numberOfSegments = datasource?.numberOfSegments(self)
        
        if numberOfSegments? > 1 && numberOfSegments? < 5{
            for segmentNo in 0..numberOfSegments! {
                self.segmentContentDictionary[segmentNo] = datasource?.contentForSegment(segmentNo)
            }
            self.addBackgroundLayer()
            self.addContentSubviews()
        } else {
            println("The number of segments should be from 2 to 4")
        }
    }

    func addBackgroundLayer() {
        self.segmentBackgroundLayer = SegmentViewBackgroundLayer(containerFrame: self.bounds)
        self.segmentBackgroundLayer!.numberOfSegments = self.numberOfSegments!
        self.segmentBackgroundLayer!.selectSegment = 0
        self.layer.addSublayer(self.segmentBackgroundLayer!)
    }
    
    func addContentSubviews() {
        var segmentWidth: CGFloat = self.bounds.size.width/CGFloat(self.numberOfSegments!)
        var remainderRect: CGRect = self.bounds
        for segmentNo in 0..self.numberOfSegments! {
            
            var viewRect: CGRect = CGRectZero
            CGRectDivide(remainderRect, &viewRect, &remainderRect, segmentWidth, CGRectEdge.MinXEdge)
            var segmtbtn: UIButton = UIButton(frame: viewRect)
            
            if self.segmentContentDictionary[segmentNo] as? UIImage {
                segmtbtn.setImage(self.segmentContentDictionary[segmentNo]! as UIImage, forState: .Normal)
                var insetForSegment: UIEdgeInsets? = delegate?.imageInsetForSegment?(self, segment: segmentNo)
                if insetForSegment {
                    segmtbtn.imageEdgeInsets = insetForSegment!
                }
            } else if self.segmentContentDictionary[segmentNo] as? NSString {
                segmtbtn.setTitle(self.segmentContentDictionary[segmentNo]! as NSString, forState: .Normal)
            } else if self.segmentContentDictionary[segmentNo] as? NSAttributedString {
                segmtbtn.setAttributedTitle(self.segmentContentDictionary[segmentNo]! as NSAttributedString, forState: .Normal)
            }
            
            segmtbtn.addTarget(self, action: Selector("segmentClicked:"), forControlEvents: UIControlEvents.TouchUpInside)
            segmtbtn.tag = segmentNo
            self.segmentButtons.append(segmtbtn)
            self.addSubview(segmtbtn)
        }
    }
    
    func segmentClicked(sender: UIButton) {
        self.selectedSegment = sender.tag
        delegate?.didSelectSegment?(self, segment: sender.tag)
    }
}
