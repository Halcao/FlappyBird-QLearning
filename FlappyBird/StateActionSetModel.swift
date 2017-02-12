//
//  StateActionSetModel.swift
//  FlappyBird
//
//  Created by Halcao on 2017/2/12.
//  Copyright © 2017年 Halcao. All rights reserved.
//

import UIKit

class StateActionSetModel: NSObject, NSCoding {
    var x = 0
    var y = 0
    var isJumping = false
    var isCollision = false
    var isDead = false
    var isCleared = false
    var py = 0
    
    var jump = 1.0
    var j_cnt = 0.0
    var n_cnt = 0.0
    var nothing = 1.0
    
    init(with state: State, actionSet: ActionSet) {
        x = state.x
        y = state.y
        isJumping = state.isJumping
        isCollision  = state.isCollision
        isDead = state.isDead
        isCleared = state.isCleared
        
        jump = actionSet.jump
        j_cnt = actionSet.j_cnt
        n_cnt = actionSet.n_cnt
        nothing = actionSet.nothing
    }
    
    required init(coder aDecoder: NSCoder) {
        self.x = aDecoder.decodeInteger(forKey: "x")
        self.y = aDecoder.decodeInteger(forKey: "y")
        self.isJumping =  aDecoder.decodeBool(forKey: "isJumping")
        self.isCollision = aDecoder.decodeBool(forKey: "isCollision")
        self.isDead = aDecoder.decodeBool(forKey: "isDead")
        self.isCleared = aDecoder.decodeBool(forKey: "isCleared")
        self.py = aDecoder.decodeInteger(forKey: "py")
        
        self.jump = aDecoder.decodeDouble(forKey: "jump")
        self.j_cnt = aDecoder.decodeDouble(forKey: "j_cnt")
        self.n_cnt = aDecoder.decodeDouble(forKey: "n_cnt")
        self.nothing = aDecoder.decodeDouble(forKey: "nothing")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.x, forKey: "x")
        aCoder.encode(self.y, forKey: "y")
        aCoder.encode(self.isJumping, forKey: "isJumping")
        aCoder.encode(self.isCollision, forKey: "isCollision")
        aCoder.encode(self.isDead, forKey: "isDead")
        aCoder.encode(self.isCleared, forKey: "isCleared")
        aCoder.encode(self.py, forKey: "py")
        
        aCoder.encode(self.jump, forKey: "jump")
        aCoder.encode(self.j_cnt, forKey: "j_cnt")
        aCoder.encode(self.n_cnt, forKey: "n_cnt")
        aCoder.encode(self.nothing, forKey: "nothing")
    }
    
    func getState() -> State {
        return State(x: self.x, y: self.y, isJumping: isJumping, isDead: isDead, py: py, isCleared: isCleared, isCollision: isCollision)
    }
    
    func getActionSet() -> ActionSet {
        let set = ActionSet()
        set.jump = self.jump
        set.nothing = self.nothing
        set.j_cnt = self.j_cnt
        set.n_cnt = self.n_cnt
        return set
    }
}
