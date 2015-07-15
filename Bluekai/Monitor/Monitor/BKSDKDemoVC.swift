//
//  BKSDKDemoVC.swift
//  Monitor
//
//  Created by Anping Wang on 7/4/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit
import Bluekai

class BKSDKDemoVC: UIViewController {

    @IBOutlet var siteId: UITextField!
    @IBOutlet var idfaLabel: UILabel!
    
    @IBOutlet var enableAdfa: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableAdfa.enabled = true
        let idfa : String = ""
        //[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]
        idfaLabel.text = "IDFA:\(idfa)";
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func clearCookies(sender: AnyObject) {
        let storage : NSHTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage();
        
        for cookie in storage.cookies!  {
            storage.deleteCookie(cookie as! NSHTTPCookie);
        }
        
        NSUserDefaults.standardUserDefaults().synchronize();
       
    }
    
    @IBOutlet var categories: UISegmentedControl!
    
    @IBAction func tagUser(sender: AnyObject) {
        siteId.resignFirstResponder();
        
        var bkuuid:String;
        
        let storage : NSHTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage();
        
        for value in storage.cookies!  {
           // storage.deleteCookie(cookie as! NSHTTPCookie);
            let cookie = value as! NSHTTPCookie
            
            println("Cookie in the jar \(cookie.name) \(cookie.value)")
            
            if cookie.name == "bku"
            {
                bkuuid = cookie.value!;
            }
        }
        
        let selected = categories.selectedSegmentIndex;
        let cat = selected == 0 ? "Auto" : selected == 1 ? "Travel" : selected == 2 ? "Computer" : "Food";
       

        let pixelServer : PixelServer = PixelServer.forSite(siteId.text)
            .enableIdfa(enableAdfa.enabled)
            
        pixelServer.tagUser(["in-market":cat],
            onSuccess: { (NSData) -> Void in
                
                
            },
            onProgress: {(AnyObject) -> Void in
                
                
            },
            onFailure: { (AnyObject) -> Void in
                
                
            }
        )
        
        
        
        /*
        [[[PixelServer forSite:siteId.text] enableIdfa:enableAdfa.enabled]
        tagUser:@{@"in-market":cat}
        onSuccess:^(NSData *data) {
        NSString *bkuuid = nil;
        for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
        {
        NSLog(@"Cookie received %@ %@", cookie.name, cookie.value);
        if ([cookie.name isEqual:@"bku"])
        {
        bkuuid = cookie.value;
        }
        }
        [[[UIAlertView alloc]initWithTitle:@"Success" message: [NSString stringWithFormat:@"BKUUID - %@", bkuuid] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        } onProgress:^(id data) {
        //
        } onFailure:^(id data) {
        //
        }
        ];
        */
    }
    

}
