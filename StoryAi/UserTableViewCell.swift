//
//  UserTableViewCell.swift
//  StoryAi
//
//  Created by Cesa Salaam on 4/20/19.
//  Copyright © 2019 Cesa Salaam. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var labelContainerView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(with message: Message) {
        
        messageLabel.text = message.text
        messageLabel.textColor = .chatBackgroundStart
        
        let dateFormatterMessage = DateFormatter()
        dateFormatterMessage.setLocalizedDateFormatFromTemplate("hh:mm")
        timeLabel.text = dateFormatterMessage.string(from: message.date)
        timeLabel.textColor = .mainGreen
        
    }

}
