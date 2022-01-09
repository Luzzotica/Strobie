//
//  LocalGameViewViewController.swift
//  Strobe
//
//  Created by Sterling Long on 10/11/14.
//  Copyright (c) 2014 Sterling Long. All rights reserved.
//

import UIKit

class LocalGameView: UIViewController {
    
    final var PLAYERS = 4
    
    @IBOutlet weak var start: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var quit: UIButton!
    @IBOutlet weak var settings: UIButton!
    
    @IBOutlet weak var p1left: UIButton!
    @IBOutlet weak var p1mid: UIButton!
    @IBOutlet weak var p1right: UIButton!
    
    @IBOutlet weak var p2left: UIButton!
    @IBOutlet weak var p2mid: UIButton!
    @IBOutlet weak var p2right: UIButton!
    
    @IBOutlet weak var p3left: UIButton!
    @IBOutlet weak var p3mid: UIButton!
    @IBOutlet weak var p3right: UIButton!
    
    @IBOutlet weak var p4left: UIButton!
    @IBOutlet weak var p4mid: UIButton!
    @IBOutlet weak var p4right: UIButton!
    
    @IBOutlet var p1View: UIView!
    @IBOutlet var p2View: UIView!
    @IBOutlet var p3View: UIView!
    @IBOutlet var p4View: UIView!
    
    @IBOutlet weak var p1Image: UIImageView!
    @IBOutlet weak var p2Image: UIImageView!
    @IBOutlet weak var p3Image: UIImageView!
    @IBOutlet weak var p4Image: UIImageView!
    
    var players: [Player]!
    
    // Game Stuff
    var playerDying = false
    var gameInProgress = false
    var didPass = false
    var passTo: Player!
    var passFrom: Player!
    
    // Timer Stuff
    let potatoChooserTimeMax = 0.5
    let potatoChooserTimeStart = 0.15
    var potatoChooserTime = 0.15
    var target = 0
    var isChoosing = false
    
    var startTime = NSDate.timeIntervalSinceReferenceDate()
    var currentTime: NSTimeInterval = 0
    
    let timeInterval = 6.0
    let reduceFraction = 4.0
    let baseTime = 0.4
    
    var turnTimer : NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        p1left.setImage(UIImage(named: "NArrow P1 Left Dead.png"), forState: UIControlState.Disabled)
        p1mid.setImage(UIImage(named: "NArrow P1 Dead.png"), forState: UIControlState.Disabled)
        p1right.setImage(UIImage(named: "NArrow P1 Right Dead.png"), forState: UIControlState.Disabled)
        
        p2left.setImage(UIImage(named: "NArrow P2 Left Dead.png"), forState: UIControlState.Disabled)
        p2mid.setImage(UIImage(named: "NArrow P2 Dead.png"), forState: UIControlState.Disabled)
        p2right.setImage(UIImage(named: "NArrow P2 Right Dead.png"), forState: UIControlState.Disabled)
        
        p3left.setImage(UIImage(named: "NArrow P3 Left Dead.png"), forState: UIControlState.Disabled)
        p3mid.setImage(UIImage(named: "NArrow P3 Dead.png"), forState: UIControlState.Disabled)
        p3right.setImage(UIImage(named: "NArrow P3 Right Dead.png"), forState: UIControlState.Disabled)
        
        p4left.setImage(UIImage(named: "NArrow P4 Left Dead.png"), forState: UIControlState.Disabled)
        p4mid.setImage(UIImage(named: "NArrow P4 Dead.png"), forState: UIControlState.Disabled)
        p4right.setImage(UIImage(named: "NArrow P4 Right Dead.png"), forState: UIControlState.Disabled)
        
        players = [Player(controller: self, light: p1Image, btnLeft: p1left, btnMid: p1mid, btnRight: p1right, view: p1View),
            Player(controller: self, light: p2Image, btnLeft: p2left, btnMid: p2mid, btnRight: p2right, view: p2View),
            Player(controller: self, light: p3Image, btnLeft: p3left, btnMid: p3mid, btnRight: p3right, view: p3View),
            Player(controller: self, light: p4Image, btnLeft: p4left, btnMid: p4mid, btnRight: p4right, view: p4View)]
        
        for i in 0 ... players.count - 1 {
            players[i].container.hidden = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func startGame() {
        gameInProgress = true
        
        UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            
            for i in 0 ... self.players.count - 1 {
                self.players[i].container.hidden = false
                self.players[i].enableButtons()
            }
            
            let moveDist = CGFloat(-130)
            
            for i in 0 ... self.players.count - 1 {
                switch i {
                case 0:
                    self.players[i].animateBack(0, moveY: moveDist)
                    break
                case 1:
                    self.players[i].animateBack(-moveDist, moveY: 0)
                    break
                case 2:
                    self.players[i].animateBack(0, moveY: -moveDist)
                    break
                case 3:
                    self.players[i].animateBack(moveDist, moveY: 0)
                    break
                default:
                    break
                }
                
            }
            
            }, completion: { finished in
                self.resetButton.enabled = true
                self.startPotatoChooser()
        })
        
    }
    
    func startPotatoChooser() {
        if checkForWinner() {
            return
        }
        
        isChoosing = true
        
        /*for i in 0 ... players.count - 1 {
            if players[i].playing {
                players[i].setLight("On")
            }
        }*/
        
        turnTimer = NSTimer.scheduledTimerWithTimeInterval(potatoChooserTime, target: self, selector: Selector("findPlayer"), userInfo: nil, repeats: true)
    }
    
    // Round about green flashing, slows down with random amounts until it reaches potatoChooserTimeMax then it stops at that player and gives him the potato. Pretty good at choosing a random player to start.
    func findPlayer() {
        potatoChooserTime += (Double(arc4random()) / Double(UINT32_MAX)) / 15.0
        turnTimer.fireDate = turnTimer.fireDate.dateByAddingTimeInterval(potatoChooserTime)
        
        if potatoChooserTime >= potatoChooserTimeMax {
            turnTimer.invalidate()
            
            playerDying = false
            isChoosing = false
            
            startTime = NSDate.timeIntervalSinceReferenceDate()
            currentTime = NSDate.timeIntervalSinceReferenceDate()
            
            var elapsedTime = currentTime - startTime
            
            var time = (timeInterval / (elapsedTime + reduceFraction)) + baseTime
            println(time)
            
            turnTimer.invalidate()
            turnTimer = NSTimer.scheduledTimerWithTimeInterval(time, target: self, selector: Selector("update"), userInfo: nil, repeats: false)
            
            //players[target].setLight("Off")
            players[target].givePotato(timeInterval)
            passFrom = players[target]
            
            potatoChooserTime = potatoChooserTimeStart
            return
        }
        
        target++
        target %= players.count
        while(players[target].playing == false) {
            target++
            target %= players.count
        }
        
        for i in 0 ... players.count - 1 {
            if i == target {
                players[i].setLight("On")
            }
            else {
                if players[i].playing {
                    players[i].setLight("Off")
                }
            }
        }
    }
    
    func passPotato(fromPlayer: Player, toPlayer: Player) {
        if toPlayer.playing {
            didPass = true
            passTo = toPlayer
            passFrom = fromPlayer
            pass()
        }
        else {
            playerLoses(fromPlayer)
        }
    }
    
    // Timer was amassing time if you moved through the passes quickly, caused strangely long wait times at the end. Fixed by creating a new oneShot timer (Non-repeating) everytime and calling turnTimer.fire() to skip to the next turn
    func pass()
    {
        
        passFrom.takePotato()
        passFrom = passTo
        passTo.givePotato(timeInterval)
        passFrom.setLight("Off")
        passTo.setLight("On")
        turnTimer.fire()
    }
    
    func checkForWinner() -> Bool {
        var winner = -1
        var countPlaying = 0
        
        for i in 0 ... players.count - 1 {
            if players[i].playing {
                countPlaying++
                winner = i
            }
        }
        
        if countPlaying == 1 {
            players[winner].won()
            return true
        }
        else {
            return false
        }
    }
    
    func playerLoses(player: Player) {
        turnTimer.invalidate()
        playerDying = true
        
        var index = 0
        
        for i in 0 ... players.count - 1 {
            //players[i].stopHasPotatoFlashing()
            if players[i] == player {
                index = i
                players[i].playing = false
                player.light.image = UIImage(named: "LightOn")
            }
            players[i].takePotato()
        }
        
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            
            let moveDist = CGFloat(130)
            
            switch index {
            case 0:
                player.animateEat(0, moveY: moveDist)
                break
            case 1:
                player.animateEat(-moveDist, moveY: 0)
                break
            case 2:
                player.animateEat(0, moveY: -moveDist)
                break
            case 3:
                player.animateEat(moveDist, moveY: 0)
                break
            default:
                break
            }
            
            }, completion: { finished in
                if self.gameInProgress {
                    player.lost()
                    player.light.image = UIImage(named: "LightOff")
                }
                UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                    
                    let moveDist = CGFloat(-130)
                    
                    switch index {
                    case 0:
                        player.animateBack(0, moveY: moveDist)
                        break
                    case 1:
                        player.animateBack(-moveDist, moveY: 0)
                        break
                    case 2:
                        player.animateBack(0, moveY: -moveDist)
                        break
                    case 3:
                        player.animateBack(moveDist, moveY: 0)
                        break
                    default:
                        break
                    }
                    
                    }, completion: { finished in
                        if self.gameInProgress {
                            self.startPotatoChooser()
                        }
                })
        })
        
    }
    
    @IBAction func buttonTouched(sender: UIButton) {
        // So Players can't die while another one is dying. Basically a pause game
        if playerDying || isChoosing {
            return
        }
        
        if ((sender===p1left || sender===p1mid || sender===p1right) && players[0].playing)
        {
            if (players[0].hasPotato)
            {
                if (sender===p1left){
                    passPotato(players[0], toPlayer: players[1])
                }
                else if (sender===p1mid){
                    passPotato(players[0], toPlayer: players[2])
                }
                else if (sender===p1right){
                    passPotato(players[0], toPlayer: players[3])
                }
            }
            else
            {
                playerLoses(players[0])
            }
        }
        else if ((sender===p2left || sender===p2mid || sender===p2right) && players[1].playing)
        {
            if (players[1].hasPotato)
            {
                if (sender===p2left){
                    passPotato(players[1], toPlayer: players[2])
                }
                else if (sender===p2mid){
                    passPotato(players[1], toPlayer: players[3])
                }
                else if (sender===p2right){
                    passPotato(players[1], toPlayer: players[0])
                }
            }
            else
            {
                playerLoses(players[1])
            }
        }
        else if ((sender===p3left || sender===p3mid || sender===p3right) && players[2].playing)
        {
            if (players[2].hasPotato)
            {
                if (sender===p3left){
                    passPotato(players[2], toPlayer: players[3])
                }
                else if (sender===p3mid){
                    passPotato(players[2], toPlayer: players[0])
                }
                else if (sender===p3right){
                    passPotato(players[2], toPlayer: players[1])
                }
            }
            else
            {
                playerLoses(players[2])
            }
        }
        else if ((sender===p4left || sender===p4mid || sender===p4right) && players[3].playing)
        {
            if (players[3].hasPotato)
            {
                if (sender===p4left){
                    passPotato(players[3], toPlayer: players[0])
                }
                else if (sender===p4mid){
                    passPotato(players[3], toPlayer: players[1])
                }
                else if (sender===p4right){
                    passPotato(players[3], toPlayer: players[2])
                }
            }
            else
            {
                playerLoses(players[3])
            }
        }
    }
    
    @IBAction func start(sender: AnyObject) {
        start.hidden = true
        resetButton.hidden = false
        resetButton.enabled = false
        settings.hidden = true
        self.startGame()
        
        if gameInProgress {
            
        }
        else {
            
        }
    }
    
    @IBAction func reset(sender: AnyObject) {
        reset2()
    }
    
    func reset2() {
        start.hidden = false
        start.enabled = false
        resetButton.hidden = true
        settings.hidden = false
        
        playerDying = false
        gameInProgress = false
        if turnTimer != nil {
            turnTimer.invalidate()
        }
        
        UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            
            let moveDist = CGFloat(130)
            
            for i in 0 ... self.players.count - 1 {
                switch i {
                case 0:
                    self.players[i].animateEat(0, moveY: moveDist)
                    break
                case 1:
                    self.players[i].animateEat(-moveDist, moveY: 0)
                    break
                case 2:
                    self.players[i].animateEat(0, moveY: -moveDist)
                    break
                case 3:
                    self.players[i].animateEat(moveDist, moveY: 0)
                    break
                default:
                    break
                }
                
                self.players[i].reset()
            }
            }, completion: { finished in
                self.start.enabled = true
                for i in 0 ... self.players.count - 1 {
                    self.players[i].container.hidden = true
                    self.players[i].disableButtons()
                }
        })
    }
    
    @IBAction func settings(sender: AnyObject) {
        
    }
    
    
    // Game timer stuff
    func update() {
        
        if didPass {
            currentTime = NSDate.timeIntervalSinceReferenceDate()
            
            var elapsedTime = currentTime - startTime
            
            var time = (timeInterval / (elapsedTime + reduceFraction)) + baseTime
            println(time)
            
            turnTimer = NSTimer.scheduledTimerWithTimeInterval(time, target: self, selector: Selector("update"), userInfo: nil, repeats: false)
            
            didPass=false
        }
        else {
            playerLoses(passFrom)
            didPass = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
