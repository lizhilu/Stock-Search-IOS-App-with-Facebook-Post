//
//  CustomerCell.swift
//  hw9
//
//  Created by Lizhi Lu on 4/21/16.
//  Copyright © 2016 Lizhi Lu. All rights reserved.
//

import UIKit

class CustomerCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var upordown: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
