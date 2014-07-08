//
//  ViewController.swift
//  SwiftSegmentView
//
//  Created by Bhambhwani, Jaikumar (US - Mumbai) on 7/7/14.
//  Copyright (c) 2014 Jaikumar. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SegmentViewDelegate, SegmentViewDataSource {
                            
    @IBOutlet var segmentView: SegmentView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.segmentView.delegate = self
        self.segmentView.datasource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSegments(segmentView: SegmentView) -> Int {
        return 4
    }
    
    func contentForSegment(segmentIndex: Int) -> AnyObject? {
        if segmentIndex == 0 {
            return UIImage(named:"team-member")
        }
        return "test\(segmentIndex)"
    }
    
    func didSelectSegment(segementView: SegmentView,segment: Int) {
        println("clicked \(segment)")
    }


}

