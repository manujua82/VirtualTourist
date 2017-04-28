//
//  PhotoAlbumCollectionViewCell.swift
//  VirtualTouristPortfolio
//
//  Created by Juan Salcedo on 4/25/17.
//  Copyright © 2017 Juan Salcedo. All rights reserved.
//

import UIKit

class PhotoAlbumCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override var isSelected: Bool {
        didSet {
            imageView.layer.borderWidth = isSelected ? 100 : 0
        }
    }
    
    // MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
       
        let themeColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.4)
        imageView.layer.borderColor = themeColor.cgColor
        isSelected = false
    }


    
    
}



