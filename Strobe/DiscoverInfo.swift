//
//  DiscoverInfo.swift
//  Strobe
//
//  Created by Sterling Long on 10/17/14.
//  Copyright (c) 2014 Sterling Long. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class DiscoverInfo: NSObject {
    
    var HostName: NSString!
    var GameName: NSString!
    var PlayerCount: Int!
    var MaxPlayers: Int!
    var targetID: MCSession!
    
    init(hName: String, gName: String, pCount: Int, mPlayers: Int, targetID: MCSession) {
        HostName = hName
        GameName = gName
        PlayerCount = pCount
        MaxPlayers = mPlayers
        self.targetID = targetID
    }
    
}
