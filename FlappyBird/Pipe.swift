//
//  Pipe.swift
//  FlappyBird
//
//  Created by Halcao on 2017/2/7.
//  Copyright © 2017年 Halcao. All rights reserved.
//

import UIKit

class Pipe: UIView {
    let HEIGHT = UIScreen.main.bounds.size.height
    let endHeight = 30.0
    var pos = 0.0 {
        didSet {
            update()
        }
    }
    
    var width = 0.0

    var right:Double {
        return pos + width
    }
    
    var high = 0.0 {
        didSet {
            generateRandomPipe()
        }
    }
    var space = 0.0
    var low: Double {
        return high + space
    }
    
    var upper: UIImageView!
    var up_end: UIImageView!
    var lower: UIImageView!
    var low_end: UIImageView!
    
    convenience init(high: Double, width: Double, space: Double) {
        self.init()
        self.backgroundColor = UIColor.clear
        self.width = width
        self.space = space
        self.high = high
        upper = UIImageView()
        lower = UIImageView()
        low_end = UIImageView()
        up_end  = UIImageView()
        upper.image = #imageLiteral(resourceName: "pipe_body")
        lower.image = #imageLiteral(resourceName: "pipe_body")
        up_end.image = #imageLiteral(resourceName: "pipe_end")
        low_end.image = #imageLiteral(resourceName: "pipe_end")
    }
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        generateRandomPipe()
    }
    
    
    func generateRandomPipe() {
        upper.frame = CGRect(x: 0, y: 0, width: width, height: high-endHeight)
        lower.frame = CGRect(x: 0, y: low+endHeight, width: width, height: Double(self.frame.size.height)-low-endHeight)
        up_end.frame = CGRect(x: 0, y: high-endHeight, width: width, height: endHeight)
        low_end.frame = CGRect(x: 0, y: low, width: width, height: endHeight)
        self.addSubview(upper)
        self.addSubview(lower)
        self.addSubview(up_end)
        self.addSubview(low_end)
    }
    
    func update() {
        self.frame = CGRect(x: Int(pos), y: 0, width: Int(width), height: Int(HEIGHT))
    }

    
}
