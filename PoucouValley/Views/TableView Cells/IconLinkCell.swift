//
//  IconLinkCell.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-07-07.
//

import UIKit

class IconLinkCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var linkButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configWebsite(url: String?) {
        iconImageView.image = UIImage(named: "Icon-web")!
        linkButton.setTitle(url, for: .normal)
    }
    
    func configFacebook(facebookName: String?) {
        iconImageView.image = UIImage(named: "Icon-facebook")!
        linkButton.setTitle("@" + (facebookName ?? ""), for: .normal)
    }
    
    func configTwitter(twitterName: String?) {
        iconImageView.image = UIImage(named: "Icon-twitter")!
        linkButton.setTitle("@" + (twitterName ?? ""), for: .normal)
    }
    
    func configInstagram(igName: String?) {
        iconImageView.image = UIImage(named: "Icon-instagram")!
        linkButton.setTitle("@" + (igName ?? ""), for: .normal)
    }
}
