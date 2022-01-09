//
//  ClientNetworkHandler.swift
//  Strobe
//
//  Created by Sterling Long on 11/4/14.
//  Copyright (c) 2014 Sterling Long. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ClientNetworkHandler: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate {
    
    var peerID:MCPeerID!
    var session: MCSession!
    
    var browser:MCNearbyServiceBrowser!
    
    let strobeServiceType = "Strobe-Service"
    
    var possiblePeers: [MCSession] = []
    
    let maxPlayers = 70
    
    var owner: JoinViewController!
    
    init(owner: JoinViewController) {
        self.owner = owner
    }
    
    func sendData(toSend: String, peerID: MCSession) {
        let data = toSend.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        var error: NSError? = nil
        
        if (!peerID.sendData(data, toPeers: peerID.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)){
            println("ERROR \(error)")
        }
    }
    
    func joinGame(peerID: MCSession) {
        let data = "JOIN".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        var error: NSError? = nil
        //var value: Int!
        /*if connectedPeers.count > 0 {
        for i in 0 ... connectedPeers.count {
        if connectedPeers[i].connectedPeers[0] as MCPeerID == peerID {
        value = i
        break
        }
        }
        }*/
        
        //session = connectedPeers[value]
        if (!peerID.sendData(data, toPeers: peerID.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)){
            println("ERROR \(error)")
        }
    }
    
    // MCNearbyServiceBrowserDelegate
    
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
        println("Found Peer! \(peerID.displayName)")
        
        var session = MCSession(peer: self.peerID)
        session.delegate = self
        
        browser.invitePeer(peerID, toSession: session, withContext: nil, timeout: 5)
        
        //var discovered = info!.objectForKey("discoverInfo") as String
        //var discovered = info["discoverInfo"] as String
        //println("Test String: \(discovered)")
        
        //var values = discovered.componentsSeparatedByString(", ")
        
        
        //possiblePeers.append(DiscoverInfo(hName: values[1], gName: values[0], pCount: values[2].toInt()!, mPlayers: values[3].toInt()!, targetID: peerID!))
        //updateTable()
        
        //availableGames.reloadData()
        
        //        if (localSession == nil) {
        //          browser.invitePeer(peerID, toSession: localSession, withContext: nil, timeout: 5)
        //          enableServices(false)
        //        }
        
    }
    
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {
        println("Lost a peer")
    }
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        
        println("CLIENT CHANGED STATE: \(state.rawValue)")
        
        let userInfo = ["session":session,"peerID": peerID, "state":state.rawValue]
        
        if possiblePeers.count > 0 && state == MCSessionState.NotConnected {
            session.disconnect()
            removeSession(session)
        }
        
        if state == MCSessionState.Connecting
        {
            print(peerID.displayName + " ")
            println("connecting")
            possiblePeers.append(session)
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.owner.peerChangedState(state.rawValue, session: session, ID: peerID)
        })
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        
        let message = NSString(data: data, encoding: NSUTF8StringEncoding) as String
        var values = message.componentsSeparatedByString(",")
        
        if values[0] == "true" {
            removeSession(session)
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.owner.handleReceivedData(data, session: session)
        })
        
    }
    
    func disconnect()
    {
        if possiblePeers.count > 0 {
            for i in 0 ... possiblePeers.count - 1 {
                possiblePeers[i].disconnect()
            }
        }
        possiblePeers = []
        browser = nil
    }

    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        
    }
    
    func setupPeerDisplayName (displayName:String){
        peerID = MCPeerID(displayName: displayName)
    }
    
    func browseOthers(browse:Bool){
        if browse {
            browser = MCNearbyServiceBrowser(peer: peerID!, serviceType: strobeServiceType)
            browser!.delegate = self
            browser!.startBrowsingForPeers()
        }
        else {
            browser = nil
        }
    }
    
    func updateTable() {
        let tableData = ["data": possiblePeers]
        
        owner.updateTableView()
        
        /*dispatch_async(dispatch_get_main_queue(), { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("CLIENT_UpdateTableView", object: nil, userInfo: tableData)
        })*/
    }
    
    func removeSession(session: MCSession) {
        if possiblePeers.count > 0 {
            for i in 0 ... possiblePeers.count - 1 {
                if possiblePeers[i] == session {
                    //println("CLIENT \(session.connectedPeers[0].displayName) disconnected from Possibles")
                    //possiblePeers[i].disconnect()
                    possiblePeers.removeAtIndex(i)
                    
                    break
                }
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
}