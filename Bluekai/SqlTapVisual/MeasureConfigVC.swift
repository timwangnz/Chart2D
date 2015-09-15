//
//  MeasureConfigVC.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 9/12/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit

class MeasureConfigVC: PopoverGenericVC {
    var measure : Measure? {
        didSet {
            updateUI();
        }
    }
    
    @IBOutlet var measureSC: UISegmentedControl!
    @IBAction func changeMeasure(sender :UISegmentedControl)
    {
        let selectIdx = measureSC.selectedSegmentIndex
        if (selectIdx == 0)
        {
            measure!.valueType = .Sum
            
        } else if (selectIdx == 1)
        {
            measure!.valueType = .Average
        } else if (selectIdx == 2)
        {
            measure!.valueType = .Count
        }
        
        self.parentVC?.tableChanged()
        self.didFinish()
    }
    
    @IBAction func removeField(sender : UIButton)
    {
        self.parentVC?.model?.deleteMeasure(measure!)
        self.didFinish();
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI();
    }
    
    func updateUI()
    {
        if (measureSC == nil || measure == nil)
        {
            return
        }
        measureSC.selectedSegmentIndex = measure?.valueType == .Sum ? 0 :
            measure?.valueType == .Average ? 1 : 2;

    }
}
