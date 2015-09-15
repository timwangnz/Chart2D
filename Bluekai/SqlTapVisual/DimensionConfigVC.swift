//
//  DimensionConfigVC.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 9/12/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit

class DimensionConfigVC: PopoverGenericVC {
    
    
    @IBOutlet var sortbySg: UISegmentedControl!
    @IBOutlet var nameField: UILabel!
    var dimension : Dimension?

    var measure : Measure? {
        didSet {
            updateUI();
        }
    }
    
    @IBAction func removeField(sender : UIButton)
    {
        self.parentVC?.model?.deleteDimension(dimension!)
        self.didFinish();
    }
    
    @IBAction func sortbyChanged(sender : UISegmentedControl)
    {
        if (sortbySg.selectedSegmentIndex == 1)
        {
            dimension?.sortBy = .Value
        }
        else
        {
            dimension?.sortBy = .Name
        }
        self.parentVC?.model!.dimensionChanged()
        self.parentVC?.dimensionsChanged()
        self.didFinish();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI();
    }
    
    func updateUI()
    {
        if (nameField == nil || dimension == nil)
        {
            return
        }
        nameField.text = dimension?.fieldName
        sortbySg.selectedSegmentIndex = dimension!.sortBy == .Name ? 0 : 1
    }
}
