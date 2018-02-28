//
//  ViewController.swift
//  PerformanceTest
//
//  Created by Hartwig Hopfenzitz on 26.02.18.
//  Copyright © 2018 Hartwig Hopfenzitz. All rights reserved.
//

import UIKit
import Foundation



// MARK: - Queues
// the queue to synchronze data access, it's a concurrent one
fileprivate let globalDataQueue = DispatchQueue(
    label: "com.ACME.globalDataQueue",
    attributes: .concurrent)


// MARK: - global test variables
// ------------------------------------------------------------------------------------------------
// Base Version: Just a global variable
// this is the global "variable"  we worked with
var globalVariable : Int = 0


// ------------------------------------------------------------------------------------------------
// Alternative 1:  with concurrent queue, helper variable insider getter
// As I used a calculated variable, to overcome the compiler errors, we need a helper variable
// to store the actual value.
var globalVariable1_Value : Int = 0

// this is the global "variable"  we worked with
var globalVariable1 : Int {
    set (newValue) {
        globalDataQueue.async(flags: .barrier) {
            globalVariable1_Value = newValue
        }
    }
    
    get {
        // we need a helper variable to store the result.
        // inside a void closure you are not allow to "return"
        var globalVariable1_Helper : Int = 0
        globalDataQueue.sync{
            globalVariable1_Helper = globalVariable1_Value
        }
        return globalVariable1_Helper
    }
}

// ------------------------------------------------------------------------------------------------
// Alternative 2:  with concurrent queue, helper variable as additional global variable
// As I used a calculated variable, to overcome the compiler errors, we need a helper variable
// to store the actual value.
var globalVariable2_Value : Int = 0
var globalVariable2_Helper : Int = 0

// this is the global "variable"  we worked with
var globalVariable2 : Int {
    
    // the setter
    set (newValue) {
        globalDataQueue.async(flags: .barrier) {
            globalVariable2_Value = newValue
        }
    }
    
    // the getter
    get {
        globalDataQueue.sync{
            globalVariable2_Helper = globalVariable2_Value
        }
        return globalVariable2_Helper
    }
}

// ------------------------------------------------------------------------------------------------
// Alternative 3:  with concurrent queue, no helper variable as Itai Ferber suggested
var globalVariable3_Value : Int = 0
var globalVariable3 : Int {
    set (newValue) { globalDataQueue.async(flags: .barrier) { globalVariable3_Value = newValue } }
    get { return globalDataQueue.sync { globalVariable3_Value } }
}



// MARK: - class
class ViewController: UIViewController {

    // MARK: - class properties
    // Variable to control the test run (false = stop test)
    var testShouldRun : Bool = false
    
    // variable for the iterations
    var iterations : Int = 1
    
    
    // MARK: - IBOutlets
    /**
     -----------------------------------------------------------------------------------------------
     
     Switches between the number of iterations of the test
     
     -----------------------------------------------------------------------------------------------
     */
    @IBOutlet weak var IterationsSwitch: UISegmentedControl!
    @IBAction func IterationSwitchAction(_ sender: Any) {
        
        switch IterationsSwitch.selectedSegmentIndex {
        case 0:
            iterations = 100
            
        case 1:
            iterations = 1_000
            
        case 2:
            iterations = 10_000
            
        case 3:
            iterations = 100_000
            
        default:
            iterations = 1
        }
     }
    
    /**
     -----------------------------------------------------------------------------------------------
     
     Starts the test
     
     -----------------------------------------------------------------------------------------------
     */
    @IBAction func StartButtonAction(_ sender: Any) {
        
        self.StartTest()
    }
    
    /**
     -----------------------------------------------------------------------------------------------
     
     Shows that test ist running
     
     -----------------------------------------------------------------------------------------------
     */
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!

    
    /**
     -----------------------------------------------------------------------------------------------
     
     Stops the test
     
     -----------------------------------------------------------------------------------------------
     */
    @IBAction func StopButtonAction(_ sender: Any) {

        self.StopTest()
    }
    
    
    /**
     -----------------------------------------------------------------------------------------------
     
     outlets for showing results
     
     -----------------------------------------------------------------------------------------------
     */
    @IBOutlet weak var time0: UILabel!
    var time0Value : TimeInterval = 0.0
    
    @IBOutlet weak var factor0: UILabel!
    var factor0Value : Double = 1.0
    
    @IBOutlet weak var timePer0: UILabel!
    
    
    @IBOutlet weak var time1: UILabel!
    var time1Value : TimeInterval = 0.0

    @IBOutlet weak var factor1: UILabel!
    var factor1Value : Double = 1.0
    
    @IBOutlet weak var timePer1: UILabel!
    
    
    @IBOutlet weak var time2: UILabel!
    var time2Value : TimeInterval = 0.0
    
    @IBOutlet weak var factor2: UILabel!
    var factor2Value : Double = 1.0
    
    @IBOutlet weak var timePer2: UILabel!
    
    
    @IBOutlet weak var time3: UILabel!
    var time3Value : TimeInterval = 0.0
    
    @IBOutlet weak var factor3: UILabel!
    var factor3Value : Double = 1.0
    
    @IBOutlet weak var timePer3: UILabel!
    
    // MARK: - Helper methods
    /**
     -----------------------------------------------------------------------------------------------
     
     clears all results to neutral values
     
     -----------------------------------------------------------------------------------------------
     */
    func clearResults() {
        
        // reset all results
        
        time0Value = 0.0
        factor0Value = 1.0
        
        time1Value = 0.0
        factor1Value = 1.0
        
        time2Value = 0.0
        factor2Value = 1.0
        
        time3Value = 0.0
        factor3Value = 1.0
        
        // show them on screen
        self.showResults()
    }
    
    /**
     -----------------------------------------------------------------------------------------------
     
     shows all current values formatted on screen
     
     -----------------------------------------------------------------------------------------------
     */
    func showResults() {
        
        let formatter4 = NumberFormatter()
        formatter4.numberStyle = .decimal
        formatter4.minimumFractionDigits = 4
        formatter4.maximumFractionDigits = 4
        
        let formatter10 = NumberFormatter()
        formatter10.numberStyle = .decimal
        formatter10.minimumFractionDigits = 10
        formatter10.maximumFractionDigits = 10
        
        let formatter1 = NumberFormatter()
        formatter1.numberStyle = .decimal
        formatter1.minimumFractionDigits = 1
        formatter1.maximumFractionDigits = 1

        // show all current results
        DispatchQueue.main.async(execute: {
            
            self.time0.text = formatter4.string(from: NSNumber(value: self.time0Value))
            self.factor0.text = formatter1.string(from: NSNumber(value: self.factor0Value))
            self.timePer0.text = formatter10.string(from: NSNumber(
                value: (self.time0Value / Double(self.iterations * 3))))

            self.time1.text = formatter4.string(from: NSNumber(value: self.time1Value))
            self.factor1.text = formatter1.string(from: NSNumber(value: self.factor1Value))
            self.timePer1.text = formatter10.string(from: NSNumber(
                value: (self.time1Value / Double(self.iterations * 3))))

            self.time2.text = formatter4.string(from: NSNumber(value: self.time2Value))
            self.factor2.text = formatter1.string(from: NSNumber(value: self.factor2Value))
            self.timePer2.text = formatter10.string(from: NSNumber(
                value: (self.time2Value / Double(self.iterations * 3))))

            self.time3.text = formatter4.string(from: NSNumber(value: self.time3Value))
            self.factor3.text = formatter1.string(from: NSNumber(value: self.factor3Value))
            self.timePer3.text = formatter10.string(from: NSNumber(
                value: (self.time3Value / Double(self.iterations * 3))))
            
        })
    }
    
    /**
     -----------------------------------------------------------------------------------------------
     
     stop the spinning wheel
     
     -----------------------------------------------------------------------------------------------
     */
    func stopIndicator () {
        
        // stop the indicator
        DispatchQueue.main.async(execute: {
            self.ActivityIndicator.isHidden = true
            self.ActivityIndicator.stopAnimating()
        })
    }
    
    // MARK: - Core methode

    /**
     -----------------------------------------------------------------------------------------------
     
     starts the tests tests async
     
     -----------------------------------------------------------------------------------------------
     */
    func StartTest() {
        
        // dispatch it to be sure we are off the main thread
        DispatchQueue.global(qos: .userInitiated).async(execute: {
            
            // set flag to "run"
            self.testShouldRun = true
            
            // clear the result
            self.clearResults()
            
            // start the indicator
            DispatchQueue.main.async(execute: {
                self.ActivityIndicator.isHidden = false
                self.ActivityIndicator.startAnimating()
            })
            
            // start test
            self.RunTest()
        })
    }

    
    /**
     -----------------------------------------------------------------------------------------------
     
     Runs the four tests
     
     -----------------------------------------------------------------------------------------------
     */
    func RunTest() {
    
        // ------------------------------------------------------------------------------------------------
        // -- Testing
        // variable for read test
        var testVar = 0
        let waitForOneTestCompleted : DispatchGroup = DispatchGroup()

        // -----------------------------------------------------------------------------------------
        // Test 0: simple global variable, not thread safe
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // each test will be done in three parallel async calls with different qos classes
        
        // one enter() per async call
        waitForOneTestCompleted.enter()
        
        // call the test async
        DispatchQueue.global(qos: .userInitiated).async(execute: {
            for _ in 0 ..< self.iterations {
                
                // this stops the test, if button STOP was hit
                if self.testShouldRun == false { break }
                
                // just a simple test with read and write, no threading
                testVar = globalVariable
                globalVariable += 1
            }
            waitForOneTestCompleted.leave()
        })
        
        // one enter() per async call
        waitForOneTestCompleted.enter()
        
        // call the test async
        DispatchQueue.global(qos: .default).async(execute: {
            for _ in 0 ..< self.iterations {
                
                // this stops the test, if button STOP was hit
                if self.testShouldRun == false { break }
                
                // just a simple test with read and write, no threading
                testVar = globalVariable
                globalVariable += 1
            }
            waitForOneTestCompleted.leave()
        })
        
        // one enter() per async call
        waitForOneTestCompleted.enter()
        
        // call the test async
        DispatchQueue.global(qos: .background).async(execute: {
            for _ in 0 ..< self.iterations {
                
                // this stops the test, if button STOP was hit
                if self.testShouldRun == false { break }
                
                // just a simple test with read and write, no threading
                testVar = globalVariable
                globalVariable += 1
            }
            waitForOneTestCompleted.leave()
        })
        
        // wait until the three tests are done
        waitForOneTestCompleted.wait()
        
        // get the end time
        let endTime = CFAbsoluteTimeGetCurrent()
        
        // print the testvar just to avoid that the optimizer eliminates unused variables
        print ("Test0: testVar == \(testVar)")
        
        // calculates the time
        self.time0Value = endTime - startTime
        
        // set the variables for the screen
        self.factor0Value = self.time0Value / self.time0Value
        self.showResults()
        
        
        
        // -----------------------------------------------------------------------------------------
        // Test 1: concurrent queue, helper variable inside getter
        let startTime1 = CFAbsoluteTimeGetCurrent()
        
        // each test will be done in three parallel async calls with different qos classes
        
        // one enter() per async call
        waitForOneTestCompleted.enter()
        
        // call the test async
        DispatchQueue.global(qos: .userInitiated).async(execute: {
            for _ in 0 ..< self.iterations {
                
                // this stops the test, if button STOP was hit
                if self.testShouldRun == false { break }
                
                // just a simple test with read and write, no threading
                testVar = globalVariable1
                globalVariable1 += 1
            }
            waitForOneTestCompleted.leave()
        })
        
        // one enter() per async call
        waitForOneTestCompleted.enter()
        
        // call the test async
        DispatchQueue.global(qos: .default).async(execute: {
            for _ in 0 ..< self.iterations {
                
                // this stops the test, if button STOP was hit
                if self.testShouldRun == false { break }
                
                // just a simple test with read and write, no threading
                testVar = globalVariable1
                globalVariable1 += 1
            }
            waitForOneTestCompleted.leave()
        })
        
        // one enter() per async call
        waitForOneTestCompleted.enter()
        
        // call the test async
        DispatchQueue.global(qos: .background).async(execute: {
            for _ in 0 ..< self.iterations {
                
                // this stops the test, if button STOP was hit
                if self.testShouldRun == false { break }
                
                // just a simple test with read and write, no threading
                testVar = globalVariable1
                globalVariable1 += 1
            }
            waitForOneTestCompleted.leave()
        })
        
        // wait until the three tests are done
        waitForOneTestCompleted.wait()
        
        // get the end time
        let endTime1 = CFAbsoluteTimeGetCurrent()
        
        // print the testvar just to avoid that the optimizer eliminates unused variables
        print ("Test1: testVar == \(testVar)")

        // calculates the time
        self.time1Value = endTime1 - startTime1
        
        // set the variables for the screen
        self.factor1Value = self.time1Value / self.time0Value
        self.showResults()
        
        
        // -----------------------------------------------------------------------------------------
        // Test 2: with concurrent queue, helper variable as an additional global variable
        let startTime2 = CFAbsoluteTimeGetCurrent()
        
        // each test will be done in three parallel async calls with different qos classes
        
        // one enter() per async call
        waitForOneTestCompleted.enter()
        
        // call the test async
        DispatchQueue.global(qos: .userInitiated).async(execute: {
            for _ in 0 ..< self.iterations {
                
                // this stops the test, if button STOP was hit
                if self.testShouldRun == false { break }
                
                // just a simple test with read and write, no threading
                testVar = globalVariable2
                globalVariable2 += 1
            }
            waitForOneTestCompleted.leave()
        })
        
        // one enter() per async call
        waitForOneTestCompleted.enter()
        
        // call the test async
        DispatchQueue.global(qos: .default).async(execute: {
            for _ in 0 ..< self.iterations {
                
                // this stops the test, if button STOP was hit
                if self.testShouldRun == false { break }
                
                // just a simple test with read and write, no threading
                testVar = globalVariable2
                globalVariable2 += 1
            }
            waitForOneTestCompleted.leave()
        })
        
        // one enter() per async call
        waitForOneTestCompleted.enter()
        
        // call the test async
        DispatchQueue.global(qos: .background).async(execute: {
            for _ in 0 ..< self.iterations {
                
                // this stops the test, if button STOP was hit
                if self.testShouldRun == false { break }
                
                // just a simple test with read and write, no threading
                testVar = globalVariable2
                globalVariable2 += 1
            }
            
            // leave this test
            waitForOneTestCompleted.leave()
        })
        
        // wait until the three tests are done
        waitForOneTestCompleted.wait()
        
        // get the end time
        let endTime2 = CFAbsoluteTimeGetCurrent()
        
        // print the testvar just to avoid that the optimizer eliminates unused variables
        print ("Test2: testVar == \(testVar)")

        // calculates the time
        self.time2Value = endTime2 - startTime2
        
        // set the variables for the screen
        self.factor2Value = self.time2Value / self.time0Value
        self.showResults()
        
        
        // -----------------------------------------------------------------------------------------
        // Test 3: with concurrent queue, no helper variable as Itai Ferber suggested
        let startTime3 = CFAbsoluteTimeGetCurrent()
        
        // each test will be done in three parallel async calls with different qos classes
        
        // one enter() per async call
        waitForOneTestCompleted.enter()
        
        // call the test async
        DispatchQueue.global(qos: .userInitiated).async(execute: {
            for _ in 0 ..< self.iterations {
                
                // this stops the test, if button STOP was hit
                if self.testShouldRun == false { break }
                
                // just a simple test with read and write, no threading
                testVar = globalVariable3
                globalVariable3 += 1
            }
            waitForOneTestCompleted.leave()
        })
        
        // one enter() per async call
        waitForOneTestCompleted.enter()
        
        // call the test async
        DispatchQueue.global(qos: .default).async(execute: {
            for _ in 0 ..< self.iterations {
                
                // this stops the test, if button STOP was hit
                if self.testShouldRun == false { break }
                
                // just a simple test with read and write, no threading
                testVar = globalVariable3
                globalVariable3 += 1
            }
            waitForOneTestCompleted.leave()
        })
        
        // one enter() per async call
        waitForOneTestCompleted.enter()
        
        // call the test async
        DispatchQueue.global(qos: .background).async(execute: {
            for _ in 0 ..< self.iterations {
                
                // this stops the test, if button STOP was hit
                if self.testShouldRun == false { break }
                
                // just a simple test with read and write, no threading
                testVar = globalVariable3
                globalVariable3 += 1
            }
            
            // leave this test
            waitForOneTestCompleted.leave()
        })
        
        // wait until the three tests are done
        waitForOneTestCompleted.wait()
        
        // get the end time
        let endTime3 = CFAbsoluteTimeGetCurrent()
        
        // print the testvar just to avoid that the optimizer eliminates unused variables
        print ("Test3: testVar == \(testVar)")

        // calculates the time
        self.time3Value = endTime3 - startTime3
        
        // set the variables for the screen
        self.factor3Value = self.time3Value / self.time0Value
        self.showResults()
        
        
        // -----------------------------------------------------------------------------------------
        // cleanup
        // stop the spinner
        self.stopIndicator()
    }
  
    /**
     -----------------------------------------------------------------------------------------------
     
     Stops the four tests
     
     -----------------------------------------------------------------------------------------------
     */
    func StopTest() {
        
        // set flag to "run"
        self.testShouldRun = false
    }


    // MARK: - VC Life cylce
    /**
     -----------------------------------------------------------------------------------------------
     
     viewDidLoad()
     
     -----------------------------------------------------------------------------------------------
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // stop the activity indicator
        self.stopIndicator()
        
        // clear all variable
        self.clearResults()
        
        // show all variables
        self.showResults()
        
        // sets the iterations and the switch
        iterations = 100
        DispatchQueue.main.async { self.IterationsSwitch.selectedSegmentIndex = 0 }
   }

    /**
     -----------------------------------------------------------------------------------------------
     
     didReceiveMemoryWarning()
     
     -----------------------------------------------------------------------------------------------
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

