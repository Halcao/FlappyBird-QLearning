

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
    let maxLabel = UILabel()
    let sw = UISwitch() // AI Switch
    let tipLabel = UILabel()


    // objects
    var displayLink: CADisplayLink!
    var bird = Bird(width: 40, height: 40)
    var pipe1: Pipe!
    var pipe2: Pipe!
    var agent = Agent()

    
    // status values
    var score = 0
    var max = 0
    var gameOver = false
    var isClear = false
    var isCollision = false

    var isPaused = false
    var enableAI = false
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

        initViews()
        gameInit()
    }
    
    func initViews() {
        groundView.frame = CGRect(x: 0, y: 4*UIScreen.main.bounds.size.height/5, width: UIScreen.main.bounds.size.width+GROUND_OFFSET, height: UIScreen.main.bounds.size.height/5)
        
        slider.frame = CGRect(x: 20, y: UIScreen.main.bounds.size.height - GROUND_HEIGHT, width: 300, height: 30)
        slider.minimumValue = 1.0
        slider.maximumValue = 8.0
        
        pipe1 = Pipe(high: Double(GAP_MIDDLE_HEIGHT)+Double(arc4random_uniform(80)), width: 70, space: 150)
        pipe2 = Pipe(high: Double(GAP_MIDDLE_HEIGHT)+Double(arc4random_uniform(80)), width: 70, space: 150)
        
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 50)
        scoreLabel.textColor = UIColor.white
        maxLabel.frame = CGRect(x: 220, y: UIScreen.main.bounds.size.height - GROUND_HEIGHT+60, width: 40, height: 30)
        
        let base = UIScreen.main.bounds.size.height*4.0/5.0 + 70
        tipLabel.text = "Enable AI"
        tipLabel.sizeToFit()
        tipLabel.center = CGPoint(x: tipLabel.bounds.size.width/2+20 , y: base)
        sw.center = CGPoint(x: tipLabel.bounds.size.width + 60, y: base)
    }
    
    func resetBtnTapped() {
        gameInit()
        agent = Agent()
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
        isClear = false
        groundView.frame = CGRect(x: 0, y: 4*GROUND_HEIGHT, width: UIScreen.main.bounds.size.width+GROUND_OFFSET, height: GROUND_HEIGHT)
        isCollision = false
        isClear = false
        gameOver = false
        //action = .NOTHING
        dx = pipe1.pos - bird.right
        dy = pipe1.low - bird.bottom
        
       // oldState = State()
        //newState = State()
    }
    
    /**
     the function will run $FPS times per second
     */
    
    @objc func run() {
        guard isPaused == false else {
            return
        }
        
        GameLogic.SPEED = Double(slider.value)
        enableAI = sw.isOn
        
        updateUI()
        
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
        // if get score
        if Int((distance - 300+100-pipe1.width+PIPE_INTERVAL)/PIPE_INTERVAL) - score == 1 {
            score += 1
            isClear = true
            if score > max {
                max = score
            }
            print("current score: \(score)")
        }

        
        // Q learning state updating core logic
        if enableAI {
            if agent.Q.history.keys.count == 0 {
                oldState = State(x: Int(dx), y: Int(dy), isJumping: bird.isJumping, isDead: gameOver, py: Int(bird.y), isCleared: isClear, isCollision: isCollision)
                 agent.Q.add(state: &oldState)
            }
            
            for s in agent.Q.history.keys {
                if s.isEqual1(to: oldState) {
                    oldState = s
                    break
                }
            }

            newState = State(x: Int(dx), y: Int(dy), isJumping: bird.isJumping, isDead: gameOver, py: Int(bird.y), isCleared: isClear, isCollision: isCollision)
            
            // new case, learn it
            if !newState.isEqual1(to: oldState) {
                 agent.learn(action: action, oldState: oldState, newState: &newState)
                up.insert(oldState)
            }
            oldState = newState
            
            // if the agent decides to jump
            action = agent.decide(state: &oldState , bird: bird)
            if action == Action.JUMP {
                bird.jump(at: JUMP_SPEED)
            }

        }

        
        if gameOver {
            print("gameOver")
            if enableAI {
                print("states: \(agent.Q.history.count) score: \(score) unique: \(up.count) max: \(max)")
            }
            // TODO: gameOverScene()
            gameInit()
            return
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
    
    func updateUI() {
        scoreLabel.text = String(score)
        scoreLabel.sizeToFit()
        scoreLabel.frame = CGRect(x: (UIScreen.main.bounds.size.width-scoreLabel.frame.size.width)/2, y: 100, width: scoreLabel.frame.size.width, height: scoreLabel.frame.size.height)
        
        maxLabel.text = "max: \(max)"
        maxLabel.sizeToFit()
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
            pipe1.high = Double(GAP_MIDDLE_HEIGHT)+Double(arc4random_uniform(80))
        } else if pipe2.right < 0 && pipe1.right > 0 {
            pipe2.pos = pipe1.pos + PIPE_INTERVAL
            pipe2.high = Double(GAP_MIDDLE_HEIGHT)+Double(arc4random_uniform(80))
        }

    }
    
    func groundMove() {
        if groundView.frame.origin.x == 0 {
            groundView.frame = CGRect(x: -GROUND_OFFSET, y: 4*GROUND_HEIGHT, width: UIScreen.main.bounds.size.width+GROUND_OFFSET, height: GROUND_HEIGHT)
        } else {
            groundView.frame = CGRect(x: 0, y: 4*GROUND_HEIGHT, width: UIScreen.main.bounds.size.width+GROUND_OFFSET, height: GROUND_HEIGHT)
        }

    }
    
    // collision detect
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

// extension: Save and Load
extension GameLogic {
    func saveData() {
        let data = NSMutableData()
        //申明一个归档处理对象
        let archiver = NSKeyedArchiver(forWritingWith: data)
        //将lists以对应Checklist关键字进行编码
        
        var array = [StateActionSetModel]()
        for key in agent.Q.history.keys {
            let model = StateActionSetModel(with: key, actionSet: agent.Q.history[key]!)
            array.append(model)
        }
        archiver.encode(array, forKey: "model_array")
        //编码结束
        archiver.finishEncoding()
        //数据写入
        data.write(toFile: dataFilePath(), atomically: true)
    }
    
    //读取数据
    func loadData() {
        displayLink.invalidate()
        //获取本地数据文件地址
        let path = self.dataFilePath()
        //声明文件管理器
        let defaultManager = FileManager()
        //通过文件地址判断数据文件是否存在
        if defaultManager.fileExists(atPath: path) {
            //读取文件数据
            let url = URL(fileURLWithPath: path)
            let data = try! Data(contentsOf: url)
            //解码器
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            //通过归档时设置的关键字Checklist还原lists
            let array = unarchiver.decodeObject(forKey: "model_array") as! Array<StateActionSetModel>
            resetBtnTapped()
            
            for model in array {
                agent.Q.history[model.getState()] = model.getActionSet()
            }
            //结束解码
            unarchiver.finishDecoding()
            //self.agent.Q.add(state: &oldState)
            //oldState = State()
            //agent.Q.add(state: &oldState)
            displayLink = CADisplayLink(target: self, selector: #selector(run))
            displayLink.preferredFramesPerSecond = Int(FPS)
            displayLink.add(to: .current, forMode: .defaultRunLoopMode)
        }
    }
    
    //获取沙盒文件夹路径
    func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                        .userDomainMask, true)
        let documentsDirectory = paths.first!
        return documentsDirectory
    }
    
    //获取数据文件地址
    func dataFilePath() -> String{
        return self.documentsDirectory().appendingFormat("/userList.plist")
    }

}
