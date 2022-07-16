import UIKit

var greeting = "Hello, playground"

var serialQueue = DispatchQueue(label: "serial queue")

func doSomething() {
    serialQueue.async {
        print ("a")
    }
}

let date = Date()
serialQueue.sync {
    print (Date().timeIntervalSince(date))
    doSomething()
    print ("end")
}

//1/60
//
//0.00011111
