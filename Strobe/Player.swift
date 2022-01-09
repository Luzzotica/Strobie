//
//  Player.swift
//  Strobe
//
//  Created by Sterling Long on 10/11/14.
//  Copyright (c) 2014 Sterling Long. All rights reserved.
//

import UIKit

class Player: NSObject {
    
    // Losing Timer and Values
    // lostCounterMax Must be XXXX
    
    var potatoTimer: NSTimer!
    
    let wonCounterMax = 10
    let wonTimerValue = 0.1
    
    let lightAnimTime = 0.2
    let lightEating = CGFloat(500)
    let lightBigger = CGFloat(120)
    let lightSmaller = CGFloat(60)
    
    var flashCounter = 0
    
    var controller: LocalGameView!
    
    var container: UIView!
    var light: UIImageView!
    var btnLeft: UIButton!
    var btnMid: UIButton!
    var btnRight: UIButton!
    
    var playing = true
    var hasPotato = false
    var lightOn = false
    
    init(controller: LocalGameView, light: UIImageView, btnLeft: UIButton, btnMid: UIButton, btnRight: UIButton, view: UIView) {
        self.controller = controller
        self.light = light
        self.btnLeft = btnLeft
        self.btnMid = btnMid
        self.btnRight = btnRight
        self.container = view
        
        btnLeft.enabled=false
        btnMid.enabled=false
        btnRight.enabled=false
        
        playing = true
        hasPotato = false
        
        potatoTimer = NSTimer()
    }
    
    func lost() {
        disablePlayer()
        container.hidden = true
    }
    
    func givePotato(time: Double) {
        hasPotato = true
        setLight("On")
        
        //potatoTimer = NSTimer.scheduledTimerWithTimeInterval(time / flashIntervalFraction, target: self, selector: Selector("hasPotatoFlashView"), userInfo: nil, repeats: true)
        
        potatoTimer = NSTimer.scheduledTimerWithTimeInterval(time, target: self, selector: Selector("hasPotatoFlashView"), userInfo: nil, repeats: true)
    }
    
    func takePotato() {
        hasPotato = false
        potatoTimer?.invalidate()
        //setLight("Off")
        flashCounter = 0
        
        stopHasPotatoFlashing()
    }
    
    func hasPotatoFlashView() {
        if lightOn == true {
            setLight("Off")
        }
        else {
            setLight("On")
        }
        
        flashCounter++
        if flashCounter == 1 {
            flashCounter = 0
            potatoTimer.invalidate()
        }
        
    }
    
    func stopHasPotatoFlashing() {
        if potatoTimer != nil {
            potatoTimer.invalidate()
        }
        if playing {
            setLight("Off")
        }
        flashCounter = 0
    }
    
    func won() {
        potatoTimer = NSTimer.scheduledTimerWithTimeInterval(wonTimerValue, target: self, selector: Selector("wonFlashView"), userInfo: nil, repeats: true)
        setLight("On")
    }
    
    func wonFlashView() {
        if lightOn == true {
            setLight("Off")
        }
        else {
            setLight("On")
        }
        
        flashCounter++
        if flashCounter == wonCounterMax {
            flashCounter = 0
            potatoTimer.invalidate()
            controller.reset2()
        }
    }
    
    func animateEat(moveX: CGFloat, moveY: CGFloat) {
        light.bounds.size.width = lightEating
        light.bounds.size.height = lightEating
        
        light.frame.origin.x = light.frame.origin.x + moveX
        light.frame.origin.y = light.frame.origin.y + moveY
    }
    
    func animateBack(moveX: CGFloat, moveY: CGFloat) {
        light.bounds.size.width = lightSmaller
        light.bounds.size.height = lightSmaller
        
        light.frame.origin.x = light.frame.origin.x + moveX
        light.frame.origin.y = light.frame.origin.y + moveY
    }
    
    func setLight(string: NSString) {
        if string == "On" {
            lightOn = true
            light.image = UIImage(named: "LightOn")
            
            UIView.animateWithDuration(lightAnimTime, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                
                self.light.bounds.size.width = self.lightBigger
                self.light.bounds.size.height = self.lightBigger
                
                }, completion: { finished in
                    
            })
        }
        else if string == "Off" {
            lightOn = false
            light.image = UIImage(named: "LightOff")
            
            UIView.animateWithDuration(lightAnimTime, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                
                self.light.bounds.size.width = self.lightSmaller
                self.light.bounds.size.height = self.lightSmaller
                
                }, completion: { finished in
                    
            })
        }
    }
    
    func enableButtons()
    {
        btnLeft.enabled=true
        btnMid.enabled=true
        btnRight.enabled=true
    }
    
    func disableButtons()
    {
        btnLeft.enabled=false
        btnMid.enabled=false
        btnRight.enabled=false
    }
    
    func clicked(num : Int) -> Bool
    {
        if (!hasPotato){
            return false
        }
        return true
    }
    
    func reset()
    {
        
        playing=true
        hasPotato=false
        if potatoTimer != nil {
            potatoTimer.invalidate()
        }
        light.image = UIImage(named: "LightOff")
    }
    
    func disablePlayer() {
        playing = false
        hasPotato = false
        flashCounter = 0
        disableButtons()
    }
}
