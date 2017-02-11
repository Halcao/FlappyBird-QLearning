

//
//  GameLogic.swift
//  FlappyBird
//
//  Created by Halcao on 2017/2/8.
//  Copyright © 2017年 Halcao. All rights reserved.
//

import UIKit

class GameLogic {
    // constants
    var FPS: Double {
        return 60
    }
    
    var dt: Double {
        return 1.0/FPS
    }
    static var SPEED = 4.0 // Global Speed
    
    var GRAVITY: Double {
        return 1200.0*GameLogic.SPEED*GameLogic.SPEED
    }

    var JUMP_SPEED: Double {
        return -400.0*GameLogic.SPEED
    }
    
    var PIPE_SPEED: Double {
        return 150.0*GameLogic.SPEED
    }
    
    let PIPE_INTERVAL = 230.0
    let BIRD_INITIAL_HEIGHT = 230.0
    
    var GAP_MIDDLE_HEIGHT: CGFloat {
        return (UIScreen.main.bounds.size.height - GROUND_HEIGHT)/2 - CGFloat(80)
    }
    
    let GROUND_HEIGHT = UIScreen.main.bounds.size.height/5
    let GROUND_OFFSET = CGFloat(3.5)

    // views
    let groundView = UIImageView(image: #imageLiteral(resourceName: "ground"))
    let scoreLabel = UILabel()
    let slider = UISlider()
    let resetBtn = UIButton(type: .system)
    let saveBtn = UIButton(type: .system)
    let loadBtn = UIButton(type: .system)
    let maxLabel = UILabel()

    // objects
    var bird = Bird(width: 40, height: 40)
    var pipe1: Pipe!
    var pipe2: Pipe!
    var displayLink: CADisplayLink!
    
    var agent = Agent()

    
    // status values
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
    
    var distance = 0.0
    
    var action = Action.NOTHING
    
    init() {
        displayLink = CADisplayLink(target: self, selector: #selector(run))
        displayLink.preferredFramesPerSecond = Int(FPS)
        displayLink.add(to: .current, forMode: .defaultRunLoopMode)
        
        
        groundView.frame = CGRect(x: 0, y: 4*UIScreen.main.bounds.size.height/5, width: UIScreen.main.bounds.size.width+GROUND_OFFSET, height: UIScreen.main.bounds.size.height/5)

        slider.frame = CGRect(x: 20, y: UIScreen.main.bounds.size.height - GROUND_HEIGHT, width: 300, height: 30)
        slider.minimumValue = 1.0
        slider.maximumValue = 8.0
        
        pipe1 = Pipe(high: Double(GAP_MIDDLE_HEIGHT)+Double(arc4random_uniform(80)), width: 70, space: 150)
        pipe2 = Pipe(high: Double(GAP_MIDDLE_HEIGHT)+Double(arc4random_uniform(80)), width: 70, space: 150)
        
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 50)
        scoreLabel.textColor = UIColor.white
        maxLabel.frame = CGRect(x: 20, y: UIScreen.main.bounds.size.height - GROUND_HEIGHT+70, width: 20, height: 30)
        
        gameInit()
        initViews()
    }
    
    func initViews() {
        
        //resetBtn.titleLabel?.text = "reset"
        let base = UIScreen.main.bounds.size.height - GROUND_HEIGHT
        resetBtn.setTitle("reset", for: .normal)
        resetBtn.sizeToFit()
        resetBtn.center = CGPoint(x: 20, y: base+70)
        resetBtn.addTarget(self, action: #selector(GameLogic.resetBtnTapped), for: .touchUpInside)
        saveBtn.setTitle("save", for: .normal)
        saveBtn.sizeToFit()
        saveBtn.center = CGPoint(x: 20+120, y: base+70)
        saveBtn.addTarget(self, action: #selector(GameLogic.saveBtnTapped), for: .touchUpInside)
        loadBtn.setTitle("load", for: .normal)
        loadBtn.sizeToFit()
        loadBtn.center = CGPoint(x: 20+240, y: base+70)
        loadBtn.addTarget(self, action: #selector(GameLogic.loadBtnTapped), for: .touchUpInside)

    }
    
    @objc func resetBtnTapped() {
        gameInit()
        agent = Agent()
        isCollision = false
        isClear = false
        gameOver = false
        oldState = State()
        oldState.x = 1000
        up.removeAll()
    }
    
    @objc func saveBtnTapped() {
        UserDefaults.standard.setValue(agent.Q.history, forKeyPath: "FIXED_GREAT_AGENT")
    }
    
    @objc func loadBtnTapped() {
        gameInit()
        let Qhistory = UserDefaults.standard.object(forKey: "FIXED_GREAT_AGENT") as! Dictionary<State, ActionSet>
        agent.Q.history = Qhistory
        isCollision = false
        isClear = false
        gameOver = false
        oldState = State()
        oldState.x = 1000
        up.removeAll()
    }
    
    func gameInit() {
        pipe1.pos = 300
        pipe2.pos = pipe1.pos+PIPE_INTERVAL
        pipe1.high = Double(GAP_MIDDLE_HEIGHT)+Double(arc4random_uniform(80))
        pipe2.high = Double(GAP_MIDDLE_HEIGHT)+Double(arc4random_uniform(80))
        bird.x = 100
        bird.y = 230
        score = 0
        distance = 0
        bird.speedY = 0
        oldState.x = 1000
        isClear = false
    }
    
    /**
     the function will run $FPS times per second
     */
    @objc func run() {
        GameLogic.SPEED = Double(slider.value)
        
        scoreLabel.text = String(score)
        scoreLabel.sizeToFit()
        scoreLabel.frame = CGRect(x: (UIScreen.main.bounds.size.width-scoreLabel.frame.size.width)/2, y: 100, width: scoreLabel.frame.size.width, height: scoreLabel.frame.size.height)
        
        maxLabel.text = "max: \(score)"
        maxLabel.sizeToFit()
        
        if bird.left < pipe1.right && pipe1.pos < pipe2.pos {
            dx = pipe1.pos - bird.right
            dy = pipe1.low - bird.bottom
        } else if bird.left < pipe2.right && pipe2.pos < pipe1.pos {
            dx = pipe2.pos - bird.right
            dy = pipe2.low - bird.bottom
        } else if bird.left > pipe1.right && bird.left < pipe2.right {
            dx = pipe2.pos - bird.right
            dy = pipe2.low - bird.bottom
        } else if bird.left > pipe2.right && bird.left < pipe1.right {
            dx = pipe1.pos - bird.right
            dy = pipe1.low - bird.bottom
        }
    
        isClear = false
        if Int((distance - 300+100-pipe1.width+PIPE_INTERVAL)/PIPE_INTERVAL) - score == 1 {
            score += 1
            isClear = true
            if score > max {
                max = score
            }
            print("current score: \(score)")
        }

        // in the first case
        if oldState.x == 1000 {
            oldState = State(x: dx, y: dy, isJumping: bird.isJumping, isDead: gameOver, py: Int(bird.y), isCleared: isClear, isCollision: isCollision)
        } else {
            newState = State(x: dx, y: dy, isJumping: bird.isJumping, isDead: gameOver, py: Int(bird.y), isCleared: isClear, isCollision: isCollision)
            if !newState.isEqual(to: oldState) {
                agent.learn(action: action, oldState: oldState, newState: &newState)
                up.insert(oldState)
            }
            oldState = newState
        }

        
        guard gameOver == false else {
            // if game is over
            // TODO: game Over
            groundView.frame = CGRect(x: 0, y: 4*GROUND_HEIGHT, width: UIScreen.main.bounds.size.width+GROUND_OFFSET, height: GROUND_HEIGHT)
            
            gameInit()
            isCollision = false
            isClear = false
            gameOver = false
            oldState = State()
            oldState.x = 1000
            print("unique states: \(agent.Q.history.count) score: \(score) unique: \(up.count) max: \(max)")
            return
        }
        
        
        // if the agent decides to jump
        action = agent.decide(state: &oldState , bird: bird)
        if action == Action.JUMP {
            bird.speedY = JUMP_SPEED
            self.bird.isJumping = true
            self.bird.frame = CGRect(origin: CGPoint(x: self.bird.x, y: self.bird.y), size: CGSize(width: 40, height: 40))
        }
        
        // detect the jumping state
        if bird.speedY < 0 {
            bird.isJumping = true
        } else {
            bird.isJumping = false
        }
        
        bird.speedY += GRAVITY*dt
        bird.y += bird.speedY*dt

        pipeMove()
        groundMove()
        collisionDetect()
        // birdRotate()
    }
    
    
    // TODO: finish the rotating action
    func birdRotate() {
        let distance = Double(4*GROUND_HEIGHT) - bird.y
        let height = Double(4*GROUND_HEIGHT) - BIRD_INITIAL_HEIGHT
        let ratio =  1.0 - distance/height
        bird.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2*ratio))
    }
    
    func pipeMove() {
        pipe1.pos -= PIPE_SPEED*dt
        pipe2.pos -= PIPE_SPEED*dt
        distance += PIPE_SPEED*dt
        if pipe1.right < 0 && pipe2.right > 0 {
            pipe1.pos = pipe2.pos + PIPE_INTERVAL
            pipe1.high = 180.0+Double(arc4random_uniform(80))
        } else if pipe2.right < 0 && pipe1.right > 0 {
            pipe2.pos = pipe1.pos + PIPE_INTERVAL
            pipe2.high = 180.0+Double(arc4random_uniform(80))
        }

    }
    
    func groundMove() {
        if groundView.frame.origin.x == 0 {
            groundView.frame = CGRect(x: -GROUND_OFFSET, y: 4*GROUND_HEIGHT, width: UIScreen.main.bounds.size.width+GROUND_OFFSET, height: GROUND_HEIGHT)
        } else {
            groundView.frame = CGRect(x: 0, y: 4*GROUND_HEIGHT, width: UIScreen.main.bounds.size.width+GROUND_OFFSET, height: GROUND_HEIGHT)
        }

    }
    
    
    // the jump action
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
        
        // fell down on the ground
        if bird.bottom > Double(4*GROUND_HEIGHT) {
            bird.y = Double(4*GROUND_HEIGHT) - bird.height
            gameOver = true
            isCollision = false
        }
        
        
    }
}
