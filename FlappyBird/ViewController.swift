//
//  ViewController.swift
//  FlappyBird
//
//  Created by Halcao on 2017/2/7.
//  Copyright © 2017年 Halcao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let alertController = UIAlertController(title: "Flappy", message: "", preferredStyle: .actionSheet)
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
        
            self.view.addSubview(gl.maxLabel)
            self.view.addSubview(gl.tipLabel)
            self.view.addSubview(gl.sw)
        
        let saveAction = UIAlertAction(title: "save", style: .default) { _ in
            self.gl.saveData()
            self.gl.isPaused = false
        }
        let loadAction = UIAlertAction(title: "load", style: .default) { _ in
            self.gl.loadData()
            self.gl.isPaused = false
        }
        let resetAction = UIAlertAction(title: "reset", style: .default) { _ in
            self.gl.resetBtnTapped()
            self.gl.isPaused = false
        }
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: { _ in
            self.gl.isPaused = false
        })
        
        alertController.addAction(saveAction)
        alertController.addAction(loadAction)
        alertController.addAction(resetAction)
        alertController.addAction(cancelAction)
        

        //self.present(alertController, animated: true, completion: nil)
        
    // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gl.sw.isOn {
            gl.isPaused = true
            self.present(self.alertController, animated: true, completion: nil)
        } else {
            gl.bird.jump(at: gl.JUMP_SPEED)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

