//
//  HostViewCell.swift
//  Strobe
//
//  Created by Sterling Long on 10/25/14.
//  Copyright (c) 2014 Sterling Long. All rights reserved.
//

import UIKit

class HostViewCell: UITableViewCell {

    @IBOutlet weak var playerName: UILabel!
    
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
    
    func setCellInfo(pName: NSString) {
        playerName.text = pName
    }
    
}
