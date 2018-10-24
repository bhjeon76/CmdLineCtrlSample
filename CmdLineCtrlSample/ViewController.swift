//
//  ViewController.swift
//  CmdLineCtrlSample
//
//  Created by 전병학 on 24/10/2018.
//  Copyright © 2018 전병학. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var outputText: NSTextView!
    @IBOutlet weak var commandLineScopePath: NSPathControl!
    @IBOutlet weak var controlArgumentOption: NSTextField!
    @IBOutlet weak var spinner: NSProgressIndicator!
    @IBOutlet weak var excuteButton: NSButton!
    
    @objc dynamic var isRunning = false
    var outputPipe:Pipe!
    var buildTask:Process!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func excuteButton(_ sender: Any) {
        
        outputText.string = ""
        
        if let commandLineScopeURL = commandLineScopePath.url {
            
            let commandLineScopeLocation = commandLineScopeURL.path
            let excutePath = commandLineScopeLocation
            let excuteFileName = "commandLineSope"
            
            var arguments:[String] = []
            arguments.append(excutePath)
            arguments.append(excuteFileName)
            arguments.append(controlArgumentOption.stringValue)
            
            print("arguments = \(arguments)")
             
            excuteButton.isEnabled = false
            spinner.startAnimation(self)
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        
        if isRunning {
            
        }
    }
    
}

