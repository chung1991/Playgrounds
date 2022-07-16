import UIKit

var greeting = "Hello, playground"

class A {
    init () {
        print ("after init a", CFGetRetainCount(self))
    }
    
    lazy var concurrentQueue = DispatchQueue(label: "concurrent queue", attributes: .concurrent)
    func doSomething() {
        concurrentQueue.async { [weak self] in
            Thread.sleep(forTimeInterval: 5.0)
            print ("value of self \(self)")
            self?.doSomething2()
        }
    }
    
    func doSomething2() {
        concurrentQueue.async {
            Thread.sleep(forTimeInterval: 5.0)
            print ("dosomething2")
        }
    }
}

func a() {
    let a = A() // retain Count = 1
    // retain Count = 0
    print ("after run a", CFGetRetainCount(a))
    a.doSomething()
}

a()
