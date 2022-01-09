//
//  HostGameHandler.swift
//  Strobe
//
//  Created by Sterling Long on 12/9/14.
//  Copyright (c) 2014 Sterling Long. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class HostGameHandler: NSObject, MCSessionDelegate {
    
    var peerID:MCPeerID!
    var players: [String] = []
    var sessions: [MCSession] = []
    
    var owner: HostViewController!
    
    let maxPlayers = 70
    
    // Game Stuff
    var playerDying = false
    var gameInProgress = false
    var didPass = false
    var passTo: NetworkPlayer!
    var passFrom: NetworkPlayer!
    
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
    
    func startGame() {
        gameInProgress = true
        
        sendData("start", from: "self")
        
        owner.enableButtons()
        
        owner.resetButton.enabled = true
        startPotatoChooser()
    }
    
    func startPotatoChooser() {
        if checkForWinner() {
            return
        }
        
        isChoosing = true
        
        turnTimer = NSTimer.scheduledTimerWithTimeInterval(potatoChooserTime, target: self, selector: Selector("findPlayer"), userInfo: nil, repeats: true)
    }
    
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
            owner.players[target].givePotato(timeInterval)
            passFrom = owner.players[target]
            
            potatoChooserTime = potatoChooserTimeStart
            return
        }
        
        target++
        target %= players.count
        while(owner.players[target].playing == false) {
            target++
            target %= owner.players.count
        }
        
        for i in 0 ... players.count - 1 {
            if i == target {
                owner.players[i].setLight("On")
            }
            else {
                if owner.players[i].playing {
                    owner.players[i].setLight("Off")
                }
            }
        }
    }
    
    func passPotato(fromPlayer: NetworkPlayer, toPlayer: NetworkPlayer) {
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
    
    func reset() {
        owner.start.hidden = false
        owner.start.enabled = false
        owner.resetButton.hidden = true
        owner.settings.hidden = false
        
        playerDying = false
        gameInProgress = false
        if turnTimer != nil {
            turnTimer.invalidate()
        }
        
        UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            
            for i in 0 ... self.players.count - 1 {
                
                self.owner.players[i].reset()
            }
            }, completion: { finished in
                self.owner.start.enabled = true
                for i in 0 ... self.players.count - 1 {
                    self.owner.disableButtons()
                }
        })
    }

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
            if owner.players[i].playing {
                countPlaying++
                winner = i
            }
        }
        
        if countPlaying == 1 {
            owner.players[winner].won()
            return true
        }
        else {
            return false
        }
    }
    
    func playerLoses(player: NetworkPlayer) {
        turnTimer.invalidate()
        playerDying = true
        
        var index = 0
        
        for i in 0 ... players.count - 1 {
            //players[i].stopHasPotatoFlashing()
            if players[i] == player {
                index = i
                owner.players[i].playing = false
                player.light.image = UIImage(named: "LightOn")
            }
            owner.players[i].takePotato()
        }
        
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            
            }, completion: { finished in
                if self.gameInProgress {
                    player.lost()
                    player.light.image = UIImage(named: "LightOff")
                }
                UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                    
                    
                    }, completion: { finished in
                        if self.gameInProgress {
                            self.startPotatoChooser()
                        }
                })
        })
        
    }
    
    /*
        THIS IS THE STUFF THAT RUNS THE NETWORKING.
        DON'T TOUCH IT, IT WORKS.
    */
    
    init(handler: HostNetworkHandler, owner: HostViewController)
    {
        super.init()
        
        peerID = handler.peerID
        players = handler.players
        sessions = handler.sessions
        
        self.owner = owner
        
        for i in 0 ... sessions.count - 1 {
            sessions[i].delegate = self
        }
    }
    
    func sendData(toSend: String, from: String) {
        let data = toSend.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        var error: NSError? = nil
        
        for i in 0 ... sessions.count - 1 {
            if (!sessions[i].sendData(data, toPeers: sessions[i].connectedPeers, withMode: MCSessionSendDataMode.Unreliable, error: &error)){
                println("ERROR \(error)")
            }
        }
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        
        let message = NSString(data: receivedData, encoding: NSUTF8StringEncoding) as String
        println("HOST Message received \(message)")
        
        var values = message.componentsSeparatedByString(",")
        
        switch(values[0])
        {
        case "ready":
            
            break
            
        default:
            break
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.owner.handleReceivedData(data, peerID: peerID)
        })
        
    }
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        
    }
}
