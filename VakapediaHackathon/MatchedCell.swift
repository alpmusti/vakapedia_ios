//
//  MatchedCell.swift
//  VakapediaHackathon
//
//  Created by Mustafa ALP on 26/03/2017.
//  Copyright © 2017 Mustafa ALP. All rights reserved.
//

import UIKit

class MatchedCell: UITableViewCell {

    @IBOutlet weak var matchedLocation: UILabel!
    @IBOutlet weak var matchedHours: UILabel!
    @IBOutlet weak var matchedName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
