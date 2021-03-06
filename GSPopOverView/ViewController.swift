//
//  ViewController.swift
//  GSPopOverView
//
//  Created by Gurdeep Singh on 15/12/15.
//  Copyright © 2015 Gurdeep Singh. All rights reserved.
//

import UIKit


class ViewController: UIViewController, GSPopOverViewDelegate {
    
    @IBOutlet weak var whitePopup: GSPopOverView!
    
    @IBOutlet weak var yellowPopup: GSPopOverView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        whitePopup.delegate = self
        yellowPopup.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func lowerBtnTapped(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        yellowPopup.toggle()
    }
    
    @IBAction func upperBtnTapped(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        whitePopup.toggle()
    }
    
    //MARK: GSPopOverViewDelegate
    
    func popupMinimized(_ popup : GSPopOverView) {
    
        if popup === yellowPopup {
    
            print("Yellow Popup Minimized")
        
        } else if popup === whitePopup {
        
            print("White Popup Minimized")
        }
    }
    
    func popupMaximized(_ popup : GSPopOverView) {
    
        if popup === yellowPopup {
            
            print("Yellow Popup Maximized")
            
        } else if popup === whitePopup {
            
            print("White Popup Maximized")
        }
    }

    func popupTapped(_ popup: GSPopOverView) {

        if popup === yellowPopup {
            
            print("Yellow Popup Tapped")
            
        } else if popup === whitePopup {
            
            print("White Popup Tapped")
        }
    }
    
}
