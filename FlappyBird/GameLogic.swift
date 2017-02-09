

//
//  GameLogic.swift
//  FlappyBird
//
//  Created by Halcao on 2017/2/8.
//  Copyright © 2017年 Halcao. All rights reserved.
//

import UIKit

class GameLogic {
    var FPS: Double {
        return 30
//        return 30*GameLogic.SPEED
    }
    static let SPEED = 6.0 // Global Speed
    //let JUMP_DURATION = SPEED*100
    var agent = Agent()
    
    var GRAVITY: Double {
        //return 1.5*0.3*GameLogic.SPEED*30.0/FPS
        // return GameLogic.SPEED*60.0/FPS
        return GameLogic.SPEED*50.0/FPS
    }
//    let JUMP_SPEED = -10.0*SPEED
    var JUMP_SPEED: Double {
        // return -GameLogic.SPEED*550.0/FPS
        return -700.0*6.0/FPS
    }
    let PIPE_INTERVAL = 230.0
    let BIRD_INITIAL_HEIGHT = 230.0
    
    let GROUND_HEIGHT = UIScreen.main.bounds.size.height/5
    
    var bird = Bird(width: 40, height: 40)
    let GROUND_OFFSET = CGFloat(3.5)
    let groundView = UIImageView(image: #imageLiteral(resourceName: "ground"))
    let scoreLabel = UILabel()
    
    var pipe1: Pipe!
    var pipe2: Pipe!
    var displayLink: CADisplayLink!
    
    var time = 0
    var score = 0
    var max = 0
    var gameOver = false
    var isClear = false
    var isCollision = false
    
    var oldState = State()
    var newState = State()
    var up = Set<State>()
    
    var dx = 0.0
    var dy = 0.0
    
    var action = Action.NOTHING
    
    init() {
        displayLink = CADisplayLink(target: self, selector: #selector(run))
        displayLink.preferredFramesPerSecond = Int(FPS)
        displayLink.add(to: .current, forMode: .defaultRunLoopMode)
        
        
        groundView.frame = CGRect(x: 0, y: 4*UIScreen.main.bounds.size.height/5, width: UIScreen.main.bounds.size.width+GROUND_OFFSET, height: UIScreen.main.bounds.size.height/5)

        pipe1 = Pipe(high: 180.0+Double(Int(arc4random())%80), width: 70, space: 150)
        pipe2 = Pipe(high: 220.0+Double(Int(arc4random())%20), width: 70, space: 150)
        gameInit()
    }
    
    func gameInit() {
        pipe1.pos = 300
//        pipe1.pos = 600
        pipe2.pos = pipe1.pos+PIPE_INTERVAL
        pipe1.high = 180.0+Double(Int(arc4random())%80)
        pipe2.high = 220.0+Double(Int(arc4random())%20)
        bird.x = 100
        bird.y = 230
        score = 0
        bird.speedY = 0
        oldState.x = 1000
    }
    
    /**
     the function will run $FPS times per second
     */
    @objc func run() {
        scoreLabel.text = String(score)
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 50)
        scoreLabel.textColor = UIColor.white
        scoreLabel.sizeToFit()
        scoreLabel.frame = CGRect(x: (UIScreen.main.bounds.size.width-scoreLabel.frame.size.width)/2, y: 100, width: scoreLabel.frame.size.width, height: scoreLabel.frame.size.height)
        
        if bird.left > pipe1.right {
            dx = pipe2.pos - bird.right
            dy = Double(UIScreen.main.bounds.size.height) - pipe2.low - bird.top
        } else if bird.left > pipe2.right {
            dx = pipe1.pos - bird.right
            dy = Double(UIScreen.main.bounds.size.height) - pipe1.low - bird.top
        } else if bird.right < pipe1.pos && pipe1.pos < pipe2.pos {
            dx = pipe1.pos - bird.right
            dy = Double(UIScreen.main.bounds.size.height) - pipe1.low - bird.top
        }
        
        if oldState.x == 1000 {
            oldState = State(x: dx, y: dy, isJumping: bird.isJumping, isDead: gameOver, py: Int(bird.y))
            oldState.isCollision = isCollision
            oldState.isCleared = isClear
        } else {
            newState = State(x: dx, y: dy, isJumping: bird.isJumping, isDead: gameOver, py: Int(bird.y))
            newState.isCollision = isCollision
            newState.isCleared = isClear
            if !newState.isEqual(to: oldState) {
                agent.learn(action: action, oldState: oldState, newState: &newState)
                up.insert(oldState)
            }
            oldState = newState
        }

        
        guard gameOver == false else {
            // if game is over
            // TODO: game Over
            //print("over")
            groundView.frame = CGRect(x: 0, y: 4*GROUND_HEIGHT, width: UIScreen.main.bounds.size.width+GROUND_OFFSET, height: GROUND_HEIGHT)
            
            //pipe1 = Pipe(high: 180.0+Double(Int(arc4random())%80), width: 70, space: 150)
            //pipe2 = Pipe(high: 220.0+Double(Int(arc4random())%20), width: 70, space: 150)
//            pipe1.pos = 600
//            pipe2.pos = pipe1.pos+PIPE_INTERVAL
//            bird.x = 100
//            bird.y = BIRD_INITIAL_HEIGHT
//            time = 0
//            bird.speedY = 0
//            score = 0
            gameInit()
            isCollision = false
            isClear = false
            gameOver = false
            oldState = State()
            oldState.x = 1000
            print("unique states: \(agent.Q.history.count) score: \(score) unique: \(up.count) max: \(max)")
            return
        }
        
        
        // jump
        action = agent.decide(state: &oldState , bird: bird)
        // action = .NOTHING
        if action == Action.JUMP {
            self.time = -10
            bird.speedY = -4*GameLogic.SPEED
            self.bird.isJumping = true
            self.bird.frame = CGRect(origin: CGPoint(x: self.bird.x, y: self.bird.y), size: CGSize(width: 40, height: 40))
        }

        bird.speedY += GRAVITY
        
//        if bird.isJumping {
//            // bird.jump()
//            if bird.speedY < 0 {
//                bird.speedY += GRAVITY
//                //bird.y -= SPEED*5*(1-cos(M_PI*Double(time)))*30/FPS
//               // bird.y -= -Double(2*time) + GRAVITY*Double(time*time)
//               // time += 1
//            } else {
//                bird.isJumping = false
//            }
//        } else {
//            time += 1
//            //bird.transform = CGAffineTransform(rotationAngle: CGFloat(-SPEED*GRAVITY*Double(time)/5 - 20.0))
//            //bird.y += SPEED*GRAVITY*Double(time*time)*30/FPS
//            bird.speedY += GRAVITY
//        }
        if bird.speedY < 0 {
            bird.isJumping = true
        } else {
            bird.isJumping = false
        }
        bird.speedY += GRAVITY

        bird.y += bird.speedY

        pipeMove()
        groundMove()
        collisionDetect()
        // birdRotate()
    }
    
    func birdRotate() {
        let distance = Double(4*GROUND_HEIGHT) - bird.y
        let height = Double(4*GROUND_HEIGHT) - BIRD_INITIAL_HEIGHT
        let ratio =  1.0 - distance/height
        bird.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2*ratio))
    }
    
    func pipeMove() {
        pipe1.pos -= 5*1.5*GameLogic.SPEED*30/FPS
        pipe2.pos -= 5*1.5*GameLogic.SPEED*30/FPS
        if pipe1.right < 0 && pipe2.right > 0 {
            pipe1.pos = pipe2.pos + PIPE_INTERVAL
            pipe1.high = 80.0+Double(Int(arc4random())%80)
        } else if pipe2.right < 0 && pipe1.right > 0 {
            pipe2.pos = pipe1.pos + PIPE_INTERVAL
            pipe2.high = 80.0+Double(Int(arc4random())%80)
        }

    }
    
    func groundMove() {
        if groundView.frame.origin.x == 0 {
            groundView.frame = CGRect(x: -GROUND_OFFSET, y: 4*GROUND_HEIGHT, width: UIScreen.main.bounds.size.width+GROUND_OFFSET, height: GROUND_HEIGHT)
        } else {
            groundView.frame = CGRect(x: 0, y: 4*GROUND_HEIGHT, width: UIScreen.main.bounds.size.width+GROUND_OFFSET, height: GROUND_HEIGHT)
        }

    }
    
    func touchesEnd() {
        bird.speedY = JUMP_SPEED
        self.bird.isJumping = true
        self.bird.frame = CGRect(origin: CGPoint(x: self.bird.x, y: self.bird.y), size: CGSize(width: 40, height: 40))
    }
    
    /**
        collision detect
     */
    func collisionDetect() {
        gameOver = false
        if bird.right < pipe1.right && bird.right > pipe1.pos && (bird.top < pipe1.high || bird.bottom > pipe1.low ) {
            gameOver = true
        }
        
        if bird.left < pipe1.right && bird.left > pipe1.pos && (bird.top < pipe1.high || bird.bottom > pipe1.low ) {
            gameOver = true
        }

        
        if bird.right < pipe2.right && bird.right > pipe2.pos && (bird.top < pipe2.high || bird.bottom > pipe2.low ) {
            gameOver = true
        }
        
        if bird.left < pipe2.right && bird.left > pipe2.pos && (bird.top < pipe2.high || bird.bottom > pipe2.low ) {
            gameOver = true
        }

        
        isCollision = true
        
        // fell down on ground
        if bird.bottom > Double(4*GROUND_HEIGHT) {
            bird.y = Double(4*GROUND_HEIGHT) - bird.height
            gameOver = true
            isCollision = false
        }
        
        isClear = false
        
       // if (bird.left > pipe2.right-4 && bird.left < pipe2.right+4) ||
           // (bird.left > pipe1.right-4 && bird.left < pipe1.right+4) {
      //  print("-----------------------------\n\(abs(bird.left-pipe1.right))-----\(abs(bird.left-pipe2.right))\n------------------------------")
            if abs(bird.left-pipe1.right) < 6 || abs(bird.left-pipe2.right) < 6 {
            score += 1
            isClear = true
            if score > max {
                max = score
            }
            print("current score: \(score)")
        }
        

        if gameOver == true {
        
        }

    }
}
