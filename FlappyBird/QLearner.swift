//
//  QLearner.swift
//  FlappyBird
//
//  Created by Halcao on 2017/2/8.
//  Copyright © 2017年 Halcao. All rights reserved.
//

import UIKit

enum Action {
    case JUMP
    case NOTHING
}

class ActionSet {
    var jump = 1.0
    var j_cnt = 0.0
    var n_cnt = 0.0
    var nothing = 1.0
    func maxReward() -> Double {
        
        let jump_r = self.jump + 5.0/(self.j_cnt+1)
        let noth_r = self.nothing + 5.0/(self.n_cnt+1)
        return max(jump_r, noth_r)
    }
    
    func chooseAction(x: Double, y:Double) -> Action {
        var action: Action = .NOTHING
        if (self.jump+5.0/(self.j_cnt+1)) == (self.nothing+5.0/(self.n_cnt+1)) {
            if x > 30 && y < -10 {
                action = .JUMP
            } else {
                action = .NOTHING
            }
        } else if (self.jump+5.0/(self.j_cnt+1)) > (self.nothing+5.0/(self.n_cnt+1)) {
            action = .JUMP
        } else {
            action = .NOTHING
        }
        return action
    }
    
    func getReward(action: Action) -> Double {
        if action == .JUMP {
            return self.jump
        } else {
            return self.nothing
        }
    }
    
    func updateReward(action: Action, value: Double) {
        if action == .JUMP {
            self.jump = value
            self.j_cnt += 1
        } else {
            self.nothing = value
            self.n_cnt += 1
        }
    }
    
    static func getAlpha() -> Double {
        return 0.9
    }
    
}


class State: NSObject {

    var x = 0.0
    var y = 0.0
    var isJumping = false
    var isCollision = false
    var isDead = false
    var isCleared = false
    var py = 0
    // py??? three segments
    convenience init(x: Double, y: Double, isJumping: Bool, isDead: Bool, py: Int) {
        self.init()
        self.x = x
        self.y = y
        self.isJumping = isJumping
        self.isDead = isDead
        if py < 512/3 {
            self.py = 0
        } else if py < 512/2 {
            self.py = 1
        } else if py < 512 {
            self.py = 2
        }
    }
    
    func isEqual(to other: State) -> Bool {
        if self.x == other.x &&
            self.y == other.y &&
            self.isJumping == other.isJumping &&
            self.isDead == other.isDead &&
            self.py == other.py {
                return true
        }
        return false
    }
    public static func ==(lhs: State, rhs: State) -> Bool {
        if lhs.x == rhs.x &&
            lhs.y == rhs.y &&
            lhs.isJumping == rhs.isJumping &&
            lhs.isDead == rhs.isDead &&
            lhs.py == rhs.py {
            return true
        }
        return false

    }
}

class QArray {
    var history = Dictionary<State, ActionSet>()
    func add(state: inout State) {
        for s in history.keys {
            if s.isEqual(to: state) {
                state = s
                return
            }
        }
//        if history[state] == nil {
//            history[state] = ActionSet()
//        }
        history[state] = ActionSet()
    }
}

class Agent {
    var Q = QArray()
    
    func decide(state: inout State, bird: Bird) -> Action {
        Q.add(state: &state)
        let actions = Q.history[state]!
        // x, y distance from bird to pipe
        let action = actions.chooseAction(x: bird.x, y: bird.y)
        return action
    }
    
    func immediateReward(newState: State) -> Int {
        let dist = sqrt(newState.x*newState.x+newState.y*newState.y)
        
        if newState.isDead {
            Q.history[newState]?.updateReward(action: .JUMP, value: -1000)
            Q.history[newState]?.updateReward(action: .NOTHING, value: -1000)
            var r = -(1000+dist) // base punishment
            if newState.isCollision {
                r -= 2000
            } else {
                r -= 10000
            }
            print("Died, punishing " + String(r))
            return Int(r)
        } else {
            var r = 1.0
            r += 15.0/dist
            if r.isEqual(to: .infinity) {
                r = 999999
            }
            if newState.isCleared {
                r += 8000
            }
            return Int(r)
        }
    }
    
    func learn(action: Action, oldState: State, newState: inout State) {
        let oldActions = Q.history[oldState]!
        Q.add(state: &newState)
        let newActions = Q.history[newState]!
        let r = self.immediateReward(newState: newState)
        var Q_old = oldActions.getReward(action: action)
        let Q_new_max = newActions.maxReward()
        Q_old = Q_old + ActionSet.getAlpha()*(Double(r) + 0.8*Q_new_max - Q_old)
        oldActions.updateReward(action: action, value: Q_old)
    }
}

