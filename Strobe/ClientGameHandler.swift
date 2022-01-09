//
//  ClientNetworkHandler.swift
//  Strobe
//
//  Created by Sterling Long on 11/4/14.
//  Copyright (c) 2014 Sterling Long. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ClientGameHandler: NSObject, MCSessionDelegate {
    
    var peerID:MCPeerID!
    var session:MCSession!
    
    var lobby : GameLobby!
    
    let maxPlayers = 70
    
    init(session: MCSession, owner: GameLobby)
    {
        super.init()
        
        self.session = session
        self.lobby = owner
        
        self.session.delegate = self
    }
    
    func sendData(toSend: String) {
        let data = toSend.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        var error: NSError? = nil
        
        if (!session.sendData(data, toPeers: session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)){
            println("ERROR \(error)")
        }
    }
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if (state == MCSessionState.NotConnected)
            {
                self.lobby.host_disconnects()
            }
        })
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        let userInfo = ["data":data, "peerID":peerID]
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.lobby.handleReceivedData(data, session: session)
        })
        
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        
    }
}