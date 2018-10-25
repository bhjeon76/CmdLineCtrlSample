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
    var excuteTask:Process!
    
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
            let excuteFileName = "./CommandLineSope"
            
            var arguments:[String] = []
            //arguments.append(excutePath)
            //arguments.append(excuteFileName)
            arguments.append(controlArgumentOption.stringValue)
            
            print("arguments = \(arguments)")
             
            excuteButton.isEnabled = false
            spinner.startAnimation(self)
            
            runScript(arguments)
            
        }
    }
    
    
    @IBAction func cancelButton(_ sender: Any) {
        
        if isRunning {
            spinner.stopAnimation(self)
            isRunning = false
        }
    }
    
    func runScript(_ arguments:[String]) {
        
        isRunning = true
        let taskQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)

        taskQueue.async {
            
//            guard let path = Bundle.main.path(forResource: "ExcuteScript",ofType:"command") else {
//
//                print("Unable to locate ExcuteScript.command")
//                let path = Bundle.main.path(forResource: "ExcuteScript",ofType:"command")
//                print("path = \(path)")
//
//                return
//            }
            
            self.excuteTask = Process()
            self.excuteTask.launchPath = "/Users/bhjeon/CmdLineCtrlSample/CommandLineScope" //  /bin/ls" //path
            self.excuteTask.arguments = [] //arguments
            
            self.excuteTask.terminationHandler = {
                
                task in
                DispatchQueue.main.async(execute: {
                    self.excuteButton.isEnabled = true
                    self.spinner.stopAnimation(self)
                    self.isRunning = false
                })
                
            }
            
            self.captureStandardOutputAndRouteToTextView(self.excuteTask)
            self.excuteTask.launch()
            self.excuteTask.waitUntilExit()
            
        }
    }
    
    func captureStandardOutputAndRouteToTextView(_ task:Process) {
        
        outputPipe = Pipe()
        task.standardOutput = outputPipe
        
        outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outputPipe.fileHandleForReading , queue: nil) {
            notification in

            let output = self.outputPipe.fileHandleForReading.availableData
            let outputString = String(data: output, encoding: String.Encoding.utf8) ?? ""

            DispatchQueue.main.async(execute: {
                let previousOutput = self.outputText.string ?? ""
                let nextOutput = previousOutput + "\n" + outputString
                self.outputText.string = nextOutput
                
                let range = NSRange(location:nextOutput.characters.count,length:0)
                self.outputText.scrollRangeToVisible(range)
                
            })
            
            self.outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
            
        }
    }
}

