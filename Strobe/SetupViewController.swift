//
//  SetupViewController.swift
//  Strobe
//
//  Created by Sterling Long on 10/9/14.
//  Copyright (c) 2014 Sterling Long. All rights reserved.
//

import UIKit

class SetupViewController: UIViewController{

    @IBOutlet weak var maxPlayer: UITextField!
    @IBOutlet weak var maxPlayerCounter: UIStepper!
    
    @IBOutlet weak var hostButton: UIButton!
    
    @IBOutlet weak var gameTitleField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //hostButton.enabled=false
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func stepTextField(sender: UIStepper) {
        maxPlayer.text = String(Int(sender.value))
    }
    
    @IBAction func changedText(sender: UITextField) {
        if (gameTitleField.text.isEmpty){
            //hostButton.enabled=false
        }
        else{
            hostButton.enabled=true
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if(segue.identifier == "SetupToMenu")
        {
            
        }
        else if(segue.identifier == "SetupToHostGame") {
            var targetView = segue.destinationViewController as HostViewController
            
        }
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
