//
//  IndicatorUIView.swift
//  
//
//  Created by Juan Salcedo on 3/11/17.
//  Copyright © 2017 Juan Salcedo. All rights reserved.
//

import UIKit

class IndicatorUIView: UIView {
    
    var actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.3)
        
        actInd.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        actInd.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        
        self.addSubview(actInd)
        self.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadingView(_ isloading: Bool) {
        if isloading {
            self.isHidden = false
            self.actInd.startAnimating()
        } else {
            self.actInd.stopAnimating()
            self.isHidden = true
            
        }
    }
}
