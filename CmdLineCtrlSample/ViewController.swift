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
        
        if ((commandLineScopePath?.url) != nil) {
            
            var arguments:[String] = []
            
            var cmdString = controlArgumentOption.stringValue
            if (cmdString == "") {
                cmdString = "-h"
            }
            arguments.append(cmdString)
            
            excuteButton.isEnabled = false
            spinner.startAnimation(self)
            
            runScript(arguments)
            //print("arguments = \(arguments)")
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        
        if isRunning {
            
            self.excuteButton.isEnabled = true
            spinner.stopAnimation(self)
            isRunning = false
            
            excuteTask.terminate()
        }
    }
    
    func runScript(_ arguments:[String]) {
        
        let fileMgr = FileManager()
        let path = "/Applications/CommandLineScope"
        
        let result = fileMgr.fileExists(atPath: path)
        if result == false {
            print("Unable to locate \(path)")
            
            self.excuteButton.isEnabled = true
            self.spinner.stopAnimation(self)
            return
        }
        
        isRunning = true
        let taskQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)

        taskQueue.async {

            self.excuteTask = Process()
            self.excuteTask.launchPath = path
            self.excuteTask.arguments = arguments
            
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

