//
//  HostViewController.swift
//  Strobe
//
//  Created by Sterling Long on 10/9/14.
//  Copyright (c) 2014 Sterling Long. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class GameLobby: UIViewController {
    
    var playerNum: Int = 0
    var gTitle: String!
    var lobbyPlayers: [String] = []
    var hostSession: MCSession!
    
    var handler : ClientGameHandler!
    
    var players: [NetworkPlayer] = []
    
    //Player Position Values
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    let middleBuffer = CGFloat(30)
    let sideBuffer = CGFloat(20)
    
    let maxSize = 0.5
    
    // Constants
    let StrobeServiceType = "Strobe-Service"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        handler = ClientGameHandler(session: hostSession,owner: self)
        
        
        newPlayer(lobbyPlayers)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
    }
    
    func handleReceivedData(receivedData: NSData, session: MCSession){
        
        let message = NSString(data: receivedData, encoding: NSUTF8StringEncoding) as String
        println("CLIENT Message received \(message)")
        
        var values = message.componentsSeparatedByString(",")
        
        switch(values[0])
        {
        case "new":
            newPlayer([values[1]])
            break
            
        case "DC":
            removePlayer(values[1])
            break
            
        case "start":
            handler.sendData("ready")
            break
            
        default:
            break
        }
        
    }
    
    func newPlayer(name: [String]) {
        // Player Button Stuff
        
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        var setPos = CGRectMake(0, 0, 0, 0)
        
        var width = (screenWidth - (sideBuffer * CGFloat(2)) - middleBuffer * CGFloat(name.count + players.count - 1))
        width = width / CGFloat(players.count + name.count)
        
        if width > screenWidth * 0.5 {
            width = screenWidth * 0.5
        }
        
        for i in 0 ... name.count - 1 {
            players.append(NetworkPlayer(pName: name[i]))
            self.view.addSubview(players[players.count - 1].view)
            
            self.view.sendSubviewToBack(players[players.count - 1].view)
            
            setPos.origin.x = screenWidth + ((width + self.middleBuffer) * CGFloat(i))
            setPos.origin.y = sideBuffer
            setPos.size.height = screenHeight - (sideBuffer * 2) - 40
            setPos.size.width = width
            
            players[players.count - 1].view.frame = setPos
        }
        
        
        
        for i in 0 ... players.count - 1 {
            resize(width, screenWidth: screenWidth, i: i)
        }
    }
    
    func removePlayer(name: String) {
        var index = 0
        for i in 0 ... players.count - 1 {
            if players[i].name == name {
                index = i
            }
        }
        
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
                
                if self.players.count > 0 {
                    for i in 0 ... self.players.count - 1 {
                        if i == index {
                            
                        }
                        else {
                            self.resize(width, screenWidth: screenWidth, i: i)
                        }
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
    
    func host_disconnects()
    {
        self.performSegueWithIdentifier("Disconnect", sender: self)
    }
    
    @IBAction func disconnectPressed(sender: AnyObject) {
        hostSession!.disconnect()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier=="Disconnect")
        {
            var targetView = segue.destinationViewController as JoinViewController
            println("Disconnecting")
            hostSession!.disconnect()
        }
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
