//
//  MPCHandler.swift
//  TicTacToe
//
//  Created by Training on 12/09/14.
//  Copyright (c) 2014 Training. All rights reserved.
//

import UIKit
import MultipeerConnectivity


class HostNetworkHandler: NSObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate {
    
    var peerID:MCPeerID!
    var players: [String] = []
    var sessions: [MCSession] = []
    var possibleSessions: [MCSession] = []
    
    var advertiser: MCNearbyServiceAdvertiser?
    
    // Constants
    let StrobeServiceType = "Strobe-Service"
    
    // Session
    var maxPlayers = 6
    var title: String!
    
    var owner: HostViewController!
    
    init(owner: HostViewController)
    {
        self.owner = owner
    }
    
    func handlePlayerRequest(peerID: MCSession) {
        if sessions.count < maxPlayers {
            println("HOST Handling Player Request")
            
            for i in 0 ... possibleSessions.count - 1 {
                if possibleSessions[i] as MCSession == peerID {
                    
                    var toSend = ""
                    if sessions.count > 0 {
                        toSend = "new,\(peerID.connectedPeers[0].displayName)"
                        for i in 0 ... sessions.count - 1 {
                            sendData(toSend, session: sessions[i])
                        }
                    }
                    
                    toSend = "true,\(sessions.count),\(self.peerID.displayName)"
                    if sessions.count > 0 {
                        toSend += ","
                        for x in 0 ... sessions.count - 1 {
                            toSend += sessions[x].connectedPeers[0].displayName
                            if x != sessions.count - 1 {
                                toSend += ","
                            }
                        }
                    }
                    
                    players.append(possibleSessions[i].connectedPeers[0].displayName)
                    sessions.append(possibleSessions[i])
                    possibleSessions.removeAtIndex(i)
                    
                    sendData(toSend, session: peerID)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.owner.addPlayer(peerID.connectedPeers[0].displayName)
                    })
                    break
                }
            }
            
            checkPlayerCount()
        }
        else {
            for i in 0 ... possibleSessions.count {
                if possibleSessions[i].connectedPeers[0] as NSObject == peerID {
                    sendData("false", session: possibleSessions[possibleSessions.count - 1])
                    break
                }
            }
        }
    }
    
    func sendData(toSend: String, session: MCSession) {
        let data = toSend.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        var error: NSError? = nil
        
        if (!session.sendData(data, toPeers: session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)){
            println("ERROR \(error)")
        }
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {
        println("Received invitation from \(peerID.displayName)")
        
        var session = MCSession(peer: self.peerID)
        session.delegate = self
        
        possibleSessions.append(session)
        
        invitationHandler(true, session)
        
    }
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        
        println("HOST CHANGED STATE: \(state.rawValue)")
        
        if state == MCSessionState.NotConnected {
            removeSession(session)
        }
        
        if state == MCSessionState.Connected {
            print(peerID.displayName + " ")
            println("connected")
            sendData("addedToTemp,\(title),\(self.peerID.displayName),\(maxPlayers),\(sessions.count)", session: session)
        }
        
        let userInfo = ["peerID":peerID,"state":state.rawValue]
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.owner.peerChangedState(state.rawValue, peerID: peerID)
        })
        
        
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        let message = NSString(data: data, encoding: NSUTF8StringEncoding) as String
        println("HOST Message received \(message)")
        
        if message == "JOIN" {
            handlePlayerRequest(session)
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.owner.handleReceivedData(data, peerID: peerID)
        })
        
        
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        
    }
    
    func advertiseSelf(advertise: Bool){
        if advertise{
            var info = ["discoverInfo": ", \(peerID.displayName), 0, 4"]
            advertiser = MCNearbyServiceAdvertiser(peer: peerID!, discoveryInfo: info, serviceType: "Strobe-Service")
            advertiser!.delegate = self
            advertiser!.startAdvertisingPeer()
        }else{
            //advertiser!.stop()
            advertiser = nil
        }
    }
    
    func disconnect()
    {
        if possibleSessions.count > 0 {
            for i in 0 ... possibleSessions.count - 1 {
                possibleSessions[i].disconnect()
            }
        }
        possibleSessions = []
        
        if sessions.count > 0 {
            for i in 0 ... sessions.count - 1 {
                sessions[i].disconnect()
            }
        }
        sessions = []
        advertiser!.stopAdvertisingPeer()
        advertiser = nil
        peerID = nil
    }
    
    func setupPeerDisplayName (displayName:String){
        peerID = MCPeerID(displayName: displayName)
    }
    
    func checkPlayerCount() {
        if possibleSessions.count >= maxPlayers {
            advertiseSelf(false)
            for i in 0 ... possibleSessions.count {
                possibleSessions[1].disconnect()
            }
        }
    }
    
    func removeSession(session: MCSession) {
        if possibleSessions.count > 0 {
            for i in 0 ... possibleSessions.count - 1 {
                if possibleSessions[i] == session {
                    
                    println("HOST disconnected someone from Possibles")
                    possibleSessions[i].disconnect()
                    possibleSessions.removeAtIndex(i)
                    
                    break
                }
            }
        }
        
        if sessions.count > 0 {
            for i in 0 ... sessions.count - 1 {
                if sessions[i] == session {
                    println("HOST disconnected someone from Players")
                    
                    var toSend = "DC,\(findLeaver())"
                    
                    sessions[i].disconnect()
                    sessions.removeAtIndex(i)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.owner.removePlayer(i)
                    })
                    
                    if sessions.count > 0 {
                        
                        for i2 in 0 ... sessions.count - 1 {
                            sendData(toSend, session: sessions[i2])
                        }
                    }
                    
                    break
                }
            }
        }
    }
    
    func findLeaver() -> String {
        for i in 0 ... sessions.count - 1 {
            if sessions[i].connectedPeers.count == 0 {
                return players.removeAtIndex(i)
            }
        }
        
        return ""
    }
    
    
}
