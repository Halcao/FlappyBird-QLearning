//
//  ViewController.swift
//  FlappyBird
//
//  Created by Halcao on 2017/2/7.
//  Copyright © 2017年 Halcao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let gl = GameLogic()
    override func viewDidLoad() {
        super.viewDidLoad()
            let bgd = UIImageView(frame: self.view.bounds)
        
            bgd.image = #imageLiteral(resourceName: "background")
            self.view.addSubview(bgd)
        
            self.view.addSubview(gl.pipe1)
            self.view.addSubview(gl.pipe2)
        
            self.view.addSubview(gl.bird)
            self.view.addSubview(gl.groundView)
            self.view.addSubview(gl.scoreLabel)
            self.view.addSubview(gl.slider)
        
            self.view.addSubview(gl.resetBtn)
            self.view.addSubview(gl.saveBtn)
            self.view.addSubview(gl.loadBtn)
        
    // Do any additional setup after loading the view, typically from a nib.
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        gl.touchesEnd()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

