//
//  PopoverGenericVC.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 9/12/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit

class PopoverGenericVC: UIViewController {
    
    var parentVC : VisualViewVC? = nil
    var object : AnyObject? = nil

    
    func didFinish(){
        dismissViewControllerAnimated(true, completion: nil)
    }
    

}
