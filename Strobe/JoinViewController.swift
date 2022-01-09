//
//  JoinViewController2.swift
//  Strobe
//
//  Created by Sterling Long on 10/20/14.
//  Copyright (c) 2014 Sterling Long. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class JoinViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var availableGames: UITableView!
    
    // Constants
    let HotColdServiceType = "Strobe-Service"
    
    var clientHandler: ClientNetworkHandler!
    
    // Set properties
    var possiblePeers: [DiscoverInfo] = []
    
    var stringsToPass: [String] = []
    var sessionToPass: MCSession!
    
    override func viewDidLoad() {
        
        var nib = UINib(nibName: "JoinGameCell", bundle: nil)
        
        self.availableGames.registerNib(nib, forCellReuseIdentifier: "MyCell")
        self.availableGames.delegate = self
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if clientHandler == nil {
            clientHandler = ClientNetworkHandler(owner: self)
        }
        
        clientHandler.setupPeerDisplayName(UIDevice.currentDevice().name)
        clientHandler.browseOthers(true)
        
        super.viewWillAppear(animated)
    }
    
    // Notification Functions
    func updateTableView() {
        availableGames.reloadData()
    }
    
    func peerChangedState(state: Int, session: MCSession, ID: MCPeerID){
        
        if possiblePeers.count > 0 && state == MCSessionState.NotConnected.rawValue {
            removeSession(session)
        }
        
        if state == MCSessionState.Connecting.rawValue {}
        
    }
    
    func handleReceivedData(receivedData: NSData, session: MCSession){
        
        let message = NSString(data: receivedData, encoding: NSUTF8StringEncoding) as String
        println("CLIENT Message received \(message)")

        var values = message.componentsSeparatedByString(",")
        
        switch(values[0])
        {
        case "true":
            values.removeAtIndex(0)
            clientHandler.removeSession(session)
            performSegue(values, session: session)
            //values.removeAtIndex(0)
            //lobbyPlayers = values
            break
            
        case "false":
            
            break
            
        case "addedToTemp":
            //just got added to the temporary list, so add the host to the table view
            var toAdd = DiscoverInfo(hName: values[2], gName: values[1], pCount: values[4].toInt()!, mPlayers: values[3].toInt()!, targetID: session)
            
            possiblePeers.append(toAdd)
            availableGames.reloadData()
            break
            
        default:
            break
        }
        
    }
    
    // Table View Stuff
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return possiblePeers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:JoinViewCellController = self.availableGames.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) as JoinViewCellController
        
        cell.setCellInfo(possiblePeers[indexPath.row], owner: self)
        
        return cell
    }
    
    /*
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 70;
    }
    */
    
    func removeSession(session: MCSession) {
        if possiblePeers.count > 0 {
            for i in 0 ... possiblePeers.count - 1 {
                if possiblePeers[i].targetID == session {
                    //println("CLIENT \(session.connectedPeers[0].displayName) removed from List")
                    possiblePeers.removeAtIndex(i)
                    break
                }
            }
        }
        availableGames.reloadData()
    }
    
    func performSegue(playersAndTitle: [String], session: MCSession) {
        stringsToPass = playersAndTitle
        sessionToPass = session
        
        self.performSegueWithIdentifier("JoinToLobby", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        clientHandler.browseOthers(false)
        if(segue.identifier == "JoinToMenu") {

            println("leaving")
            clientHandler = nil
            //clientHandler.disconnect()
            
        }
        else if (segue.identifier=="JoinToLobby")
        {
            var targetView = segue.destinationViewController as GameLobby
            
            targetView.playerNum = stringsToPass[0].toInt()!
            stringsToPass.removeAtIndex(0)
            targetView.lobbyPlayers = stringsToPass
            targetView.hostSession = sessionToPass
            
            clientHandler = nil
            //clientHandler.disconnect()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
