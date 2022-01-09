//
//  TableViewCellController.swift
//  Strobe
//
//  Created by Sterling Long on 10/10/14.
//  Copyright (c) 2014 Sterling Long. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class JoinViewCellController: UITableViewCell {

    @IBOutlet weak var gameName: UILabel!
    @IBOutlet weak var hostName: UILabel!
    @IBOutlet weak var joinGame: UIButton!
    
    var host: String!
    var game: String!
    
    var owner: JoinViewController!
    
    var targetPeer: MCSession!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setCellInfo(info: DiscoverInfo, owner: JoinViewController) {
        hostName.text = "Host Name: \(info.HostName)"
        gameName.text = "Game Name: \(info.GameName)"
        targetPeer = info.targetID
        self.owner = owner
    }
    
    @IBAction func joinGame(sender: UIButton) {
        joinGame.enabled = false
        owner.clientHandler.joinGame(targetPeer)
        //segue to the gamelobby
        
    }
    
    

}
