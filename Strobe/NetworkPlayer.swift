//
//  NetworkPlayer.swift
//  Strobe
//
//  Created by Sterling Long on 12/2/14.
//  Copyright (c) 2014 Sterling Long. All rights reserved.
//

import UIKit

class NetworkPlayer: UIViewController {

    @IBOutlet var light: UIImageView!
    @IBOutlet var playerName: UILabel!
    @IBOutlet var sendData: UIButton!
    
    var client: ClientGameHandler!
    var host: HostGameHandler!
    
    var name: String!
    var ID: String!
    
    var hasPerson = false
    var isNew = true
    
    var potatoTimer: NSTimer!
    
    let wonCounterMax = 10
    let wonTimerValue = 0.1
    
    let lightAnimTime = 0.2
    let lightBigger = CGFloat(64)
    let lightSmaller = CGFloat(20)
    
    var flashCounter = 0
    
    var playing = true
    var hasPotato = false
    var lightOn = false
    
    func lost() {
        disablePlayer()
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
            if client != nil {
                
            }
            else if host != nil {
                host.reset()
            }
        }
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
    }
    
    init(pName: String) {
        super.init(nibName: "NetworkPlayer", bundle: nil)
        
        name = pName
    }

    required init(coder aDecoder: NSCoder) {
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        playerName.text = name
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendToPlayer(sender: AnyObject) {
        if client != nil {
            client.sendData("client,\(name)")
        }
        else if host != nil {
            host.sendData("host,\(name)", from: "self")
        }
    }
    
    
    
    func resize(width: CGFloat, x: CGFloat) {
        let options = UIViewKeyframeAnimationOptions.CalculationModeCubic
        
        UIView.animateKeyframesWithDuration(0.5, delay: 0, options: options, animations: {
            
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 1, animations: {
                self.view.bounds.size.width = width
                self.view.frame.origin.x = x
            })
            
            }, completion: {finished in
                // any code entered here will be applied
                // once the animation has completed
                
        })
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
