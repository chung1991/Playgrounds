import UIKit
import Foundation

var greeting = "Hello, playground"

class A {
    var operationQueue = OperationQueue()

    func main() {
        self.operationQueue.addOperation { [unowned self] in
            self.operationQueue.isSuspended = true
            DispatchQueue.main.async { [unowned self] in
                print ("action")
                self.operationQueue.isSuspended = false
            }
        }
    }
}

let a = A()
a.main()
