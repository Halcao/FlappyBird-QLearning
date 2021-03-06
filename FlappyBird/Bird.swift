//
//  Bird.swift
//  FlappyBird
//
//  Created by Halcao on 2017/2/7.
//  Copyright © 2017年 Halcao. All rights reserved.
//

import UIKit

class Bird: UIView {
    var x = 0.0 {
        didSet {
            update()
        }
    }
    var y = 0.0 {
        didSet {
            update()
        }
    }

    var width = 40.0
    var height = 40.0

    var top: Double {
        return y
    }
    var bottom: Double {
        return y + height
    }
    var left: Double {
        return x
    }
    var right: Double {
        return x + width
    }
    
    var speedY = 0.0
    var isJumping = false
    var imgView: UIImageView!
    convenience init(width: Double, height: Double) {
        self.init()
        self.width = width
        self.height = height
        self.frame = CGRect(x: x, y: y, width: width, height: height)
        self.imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        self.imgView.image = UIImage(named: "bird_wing_up")
        self.addSubview(imgView)
        self.imgView.tag = 1
        
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            if self.imgView.tag == 0 {
                self.imgView.image = #imageLiteral(resourceName: "bird_wing_up")
                self.imgView.tag = 1
            } else {
                self.imgView.image = #imageLiteral(resourceName: "bird_wing_down")
                self.imgView.tag = 0
            }
        }
    }
    
    func jump(at speed: Double) {
        speedY = speed
        isJumping = true
        frame = CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: 40, height: 40))
    }
    
    func update() {
        self.frame = CGRect(x: x, y: y, width: width, height: height)
    }
    
}
