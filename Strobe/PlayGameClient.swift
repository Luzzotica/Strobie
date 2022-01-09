//
//  PlayGame.swift
//  Strobe
//
//  Created by Sterling Long on 11/8/14.
//  Copyright (c) 2014 Sterling Long. All rights reserved.
//



/*
import UIKit
import MultipeerConnectivity

public struct player {
    var session : MCSession!
    var number : String!
    
    init(session: MCSession, number: String)
    {
        self.session = session
        self.number = number
    }
    
    init(number: String)
    {
        self.number = number
    }
}

class PlayGame: UIViewController {
    
    //bluetooth variables
    var isHost : Bool!
    var playerNumber : String!
    
    var handler : NetworkHandler!
    var connectedPeers: [MCSession] = []
    
    var players : [player] = [] //the list of players in the game, not the actual connected players
	
	var totalPlayers : Int!
		
	var gotInfo = false
    var havePotato = false
	
	//host stuff
	var globalClock : NSTimer?
    
    override init()
    {
        handler = NetworkHandler()
        
        havePotato = false
        super.init()
        
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peerChangedState:", name: "DidChangeState", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedData:", name: "DidReceiveData", object: nil)
        
        //need to set up host timer
		var potatoChooserTime = 0.15
		
        //assign numbers to the connected players
        if (isHost==true)
        {
			globalClock = NSTimer.scheduledTimerWithTimeInterval(potatoChooserTime, target: self, selector: Selector("tick:"), userInfo: nil, repeats: true)
			
            for x in 0...connectedPeers.count
            {
                players.append(player(session: connectedPeers[x],number: toString(x+2)))
				let data = "assignNumber " + toString(x+2)
				handler.sendData(data, peerID: connectedPeers[x].connectedPeers[0] as MCPeerID)
            }
			totalPlayers = connectedPeers.count
        }
		else
		{
			while(gotInfo != true) {}
		}
		
		
		//COMMENT THIS STUFF OUT IF YOU WANT TO RUN THIS FILE <<---------------------------------------
		//now set up the display according to total number of players, definately need to revise, this is just a template
		var y_anchor = 20//how far down the buttons are
		var padding = 15//to automatically center the prefabs, we need to programmatically set this
		var prefab_width : Int?
		
		/*for x in 0...totalPlayers
		{
			if (String(x+1) != playerNumber)
			{
				let button  = UIButton.buttonWithType(UIButtonType.System) as UIButton
				button.frame = CGRectMake(((x+1)*padding+prefab_width*x), y_anchor, 100, 50)
				button.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
				//set image

				self.view.addSubview(button)
			}
		}*/



		
    }
		
	func tick()
	{
		for x in 0...players.count
		{
			handler.sendData("tick",players[x].session)
		}
	}
    
    func peerChangedState(notification:NSNotification)
    {
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        //need to work on this
    }
    
    
    func receivedData(notification:NSNotification)
    {
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        
        //PULL OUT THE COMMAND AND THE (possibly not there) DATA MEMBERS:
        let info = userInfo.objectForKey("data") as String
        
        var command = ""
        var data1 = ""
        var data2 = ""
        
        var components = info.componentsSeparatedByString(" ")
        
        command = components[0]
        if (components.count>1)
        {
            data1 = components[1]
            if (components.count>2)
            {
                data2=components[2]
            }
        }
        
        //FIND THE COMMAND THEY SENT:
        
        let sentFrom = userInfo.objectForKey("peerID") as MCSession
        var playerSentFrom : player!
        for x in 0...players.count
        {
            if (players[x].getID()==sentFrom){
                playerSentFrom = players[x]
            }
        }
		
        
        if (isHost==true)//only hosts need these commands
        {
            if (command=="disconnecting")
            {
                //this guy's trying to disconnect
            }
            else if (command=="givePotatoTo")
            {
                let from = playerSentFrom.getNumber()
                let to = data1
                
                let data = "potatoPassedFrom " + from + " " + to
                for x in 0...players.count
                {
					if (players[x] != playerSentFrom) {
                    	handler.sendData(data, peerID: players[x].getID())
					}
                }
                if (to=="1")
                {
                    //they passed it to you
                }
            }
        }
        else//only clients need these commands
        {
			if (command=="tick")
			{
				//host global timer just ticked, use this to flash the lights and stuff
			}
            else if (command=="potatoPassedFrom")
            {
                if (data2==playerNumber)
                {
                    //you have the potato now
                }
                //it was passed from data1 to data2. now update it on your screen.
            }
            else if (command=="assignNumber")//create peer list
            {
				gotInfo=true
                playerNumber = data1;
                players.append(player(id:connectedPeers[0].connectedPeers[0] as MCPeerID,num:"1"))
				
				totalPlayers = sentFrom.connectedPeers.count
                //assign numbers to the rest of the players
                for x in 2...totalPlayers
                {
                    if String(x) != playerNumber
                    {
                        players.append(player(num:toString(x)))
                    }
                }
            }
			else if (command=="endingGame")
			{
				//the host is ending the game for some reason
			}
        }
        //Now take care of the commands that everybody needs
        
        if (command=="playerOut")
        {
            if (isHost==true)//if you're the host,sent out the info to everybody else
            {
                for x in 0...players.count
                {
                    var play = players[x]
                    if (play.getID() != sentFrom)//player 1 is host
                    {
                        var data = "playerOut " + playerSentFrom.getNumber() as String
                        handler.sendData(data, peerID: play.getID())
                    }
                }
            }
            
            for x in 0...players.count
            {
                if (players[x].getNumber()==data1)
                {
                    players.removeAtIndex(x)
                }
                //next update their status on the screen
            }
        }
    }
	
	
	//THESE ARE ALL FUNCTIONS FOR THE DISPLAY AND INTERFACE, NOT NETWORKING:
	
	//personal variables
	var hasPotato : player!//which player has the potato
	
	func buttonPressed(sender: UIButton!)
	{
		//pressed button, see if it is a valid press
	}
	
	func givePotatoTo(target: player)
	{
		//change display to give that person the potato
		hasPotato = target
	}
	 
	func playerOut()
	{
		//button disable
		
		//send to the host that your out
		var data = "playerOut " + playerNumber
		//sendData(data, peerID: players[0].getID())
	}
	
	
	

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
*/