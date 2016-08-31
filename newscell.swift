//
//  newscell.swift
//  hw9
//
//  Created by Lizhi Lu on 4/21/16.
//  Copyright © 2016 Lizhi Lu. All rights reserved.
//

import UIKit

class newscell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var des: UILabel!
    @IBOutlet weak var publish: UILabel!
    @IBOutlet weak var date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //textLabel.numberOfLines = 0;
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
