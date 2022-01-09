//
//  HostViewController.swift
//  Strobe
//
//  Created by Sterling Long on 10/9/14.
//  Copyright (c) 2014 Sterling Long. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class HostViewController: UIViewController {
    
    @IBOutlet var resetButton: UIButton!
    @IBOutlet var start: UIButton!
    @IBOutlet var quit: UIButton!
    @IBOutlet var settings: UIButton!
    
    var hostHandler:HostNetworkHandler!
    var gameHandler: HostGameHandler!
    
    var players: [NetworkPlayer] = []
    
    //Player Position Values
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    let middleBuffer = CGFloat(30)
    let sideBuffer = CGFloat(20)
    
    let maxSize = 0.5
    
    func enableButtons() {
        for i in 0 ... players.count - 1 {
            players[i].sendData.enabled = true
        }
    }
    
    func disableButtons() {
        for i in 0 ... players.count - 1 {
            players[i].sendData.enabled = false
        }
    }
    
    /*
    THIS IS THE GAME SETUP CODE...
    DON'T TOUCH IT, IT WORKS...
    SORTA...
    LOTS OF BUGS WITH MULTIPEER CONNECTIVITY.
    SUPER ANNOYING.
    BUT IT WORKS.
    */
    
    // Notification Functions
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //addPlayer()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if hostHandler == nil {
            hostHandler = HostNetworkHandler(owner: self)
        }
        
        hostHandler.setupPeerDisplayName(UIDevice.currentDevice().name)
        hostHandler.advertiseSelf(true)
        
        super.viewWillAppear(animated)
    }
    
    func addPlayer(name: String) {
        // Player Button Stuff
        
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        players.append(NetworkPlayer(pName: name))
        self.view.addSubview(players[players.count - 1].view)
        
        checkPlayerCount()
        
        self.view.sendSubviewToBack(players[players.count - 1].view)
        
        var setPos = CGRectMake(0, 0, 0, 0)
        
        var width = (screenWidth - (sideBuffer * CGFloat(2)) - middleBuffer * CGFloat(players.count - 1))
        width = width / CGFloat(players.count)
        
        if width > screenWidth * 0.5 {
            width = screenWidth * 0.5
        }
        
        setPos.origin.x = screenWidth
        setPos.origin.y = sideBuffer
        setPos.size.height = screenHeight - (sideBuffer * 2) - 40
        setPos.size.width = width
        
        players[players.count - 1].view.frame = setPos
        
        for i in 0 ... players.count - 1 {
            resize(width, screenWidth: screenWidth, i: i)
        }
    }
    
    func removePlayer(index: Int) {
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        var setPos = CGRectMake(0, 0, 0, 0)
        var width = (screenWidth - (sideBuffer * CGFloat(2)) - middleBuffer * CGFloat(players.count - 1))
        width = width / CGFloat(players.count)
        
        UIView.animateWithDuration(1.2, delay: 0, options: .CurveEaseOut, animations: {
            setPos = self.players[index].view.frame
            
            setPos.origin.y = CGFloat(setPos.height + screenHeight)
            
            self.players[index].view.frame = setPos
            
            }, completion: { finished in
                println("Player Removed")
                
                self.players[index].view.removeFromSuperview()
                self.players.removeAtIndex(index)
                
                self.checkPlayerCount()
                
                println(self.players.count)
                if self.players.count > 0 {
                    
                    for i in 0 ... self.players.count - 1 {
                        
                        self.resize(width, screenWidth: screenWidth, i: i)
                        
                    }
                }
        })
    }
    
    func resize(width: CGFloat, screenWidth: CGFloat, i: Int) {
        
        
        var setPos = self.players[i].view.frame
        
        if self.players.count == 1 {
            players[i].resize(width, x: (screenWidth / 2) - (width / 2))
            setPos.origin.x = (screenWidth / 2) - (width / 2)
        }
        else {
            players[i].resize(width, x: self.sideBuffer + ((width + self.middleBuffer) * CGFloat(i)))
            setPos.origin.x = self.sideBuffer + ((width + self.middleBuffer) * CGFloat(i))
        }
    }
    
    func checkPlayerCount() {
        if players.count > 0 {
            start.enabled = true
        }
        else {
            start.enabled = false
        }
    }
    
    @IBAction func startGame(sender: AnyObject) {
        settings.hidden = true
        
        gameHandler = HostGameHandler(handler: hostHandler, owner: self)
        hostHandler.disconnect()
        hostHandler = nil
        
        for i in 0 ... players.count - 1 {
            players[i].host = gameHandler
        }
        
        gameHandler.startGame()
    }
    
    func peerChangedState(state: Int, peerID: MCPeerID) {
        
        if state == MCSessionState.Connected.rawValue {
            
        }
        else if (state==MCSessionState.NotConnected.rawValue)
        {
            print(peerID.displayName + " ")
            println("disconnected")
        }
    }
    
    func handleReceivedData(receivedData: NSData, peerID: MCPeerID) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier=="HostingToMenu")
        {
            hostHandler = nil
            //hostHandler.disconnect()
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
