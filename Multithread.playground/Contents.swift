import UIKit

let dispatchGroup = DispatchGroup()
let concurrentQueue = DispatchQueue(label: "concurrent_queue", attributes: .concurrent)
var semaphore = DispatchSemaphore(value: 3) // suppose to run 4 thread at a time
let operationQueue = OperationQueue()

func customDelay(_ from: TimeInterval=1.0, _ to: TimeInterval=5.0) {
    let randomDelay = TimeInterval.random(in: from...to)
    Thread.sleep(forTimeInterval: randomDelay)
}

func task(number: Int, completion: @escaping () -> Void) {
    concurrentQueue.async {
        let randomInterval = TimeInterval.random(in: 2...5)
        Thread.sleep(forTimeInterval: randomInterval)
        print("Task \(number), time \(randomInterval)")
        completion()
    }
}

func heavyAction(_ msg: String) {
    let delayTime = TimeInterval.random(in: 5.0...6.0)
    Thread.sleep(forTimeInterval: delayTime)
    print (msg)
}


// MARK: Dispatch Group
/// Enter and leave
func dispatchGroup1() {
    dispatchGroup.enter()
    task(number: 1, completion: {
        dispatchGroup.leave()
    })

    dispatchGroup.enter()
    task(number: 2, completion: {
        dispatchGroup.leave()
    })

    dispatchGroup.enter()
    task(number: 3, completion: {
        dispatchGroup.leave()
    })

    dispatchGroup.notify(queue: DispatchQueue.global()) {
        task(number: 10) {}
    }
}

/// Wait
func dispatchGroup2() {
    dispatchGroup.enter()
    task(number: 1, completion: {
        dispatchGroup.leave()
    })

    dispatchGroup.enter()
    task(number: 2, completion: {
        dispatchGroup.leave()
    })

    dispatchGroup.enter()
    task(number: 3, completion: {
        dispatchGroup.leave()
    })
    dispatchGroup.wait()
    print ("end")
}

/// Wait timeout
func dispatchGroup3() {
    
}

/// Wait wall time out
func dispatchGroup4() {
    
}

// MARK: Global Queue

/// auto select main queue/background queue
func globalQueue1() {
    DispatchQueue.global().sync {
        print ("1. It suppose to select main thread. Actual: Main thread is", Thread.isMainThread, Thread.current, Thread.current.qualityOfService.rawValue)
    }
    
    DispatchQueue.global().async {
        print ("2. It suppose to select background thread. Actual: Main thread is", Thread.isMainThread, Thread.current, Thread.current.qualityOfService.rawValue)
    }
}

// MARK: Safe thread - Barrier
// - .barrier for SETTERs so all GETTERs will wait for any SETTERs finish first
// - must use .barrier on custom Concurrent Queue only.
// - do not use .barrier on Global Queue because it will auto select different queue
// - do not use .barrier on Serial Queue because it no affect

class SafeThreadBarrier1 {
    var macbookCount = 0

    func buy(_ person: Int) {
        // Require barrier because of setters
        let randomTime = TimeInterval.random(in: 0.0...0.2)
        concurrentQueue.asyncAfter(deadline: .now() + randomTime, flags: .barrier) {
            if self.macbookCount > 0 {
                let before = self.macbookCount
                self.macbookCount -= 1
                let mistake = before - 1 == self.macbookCount ? "good" : "bad"
                print ("Person \(person) bought has \(mistake). Before: \(before). After: \(self.macbookCount)")
            } else {
                print ("Person \(person) buy but out of stock")
            }
        }
    }

    func stock(_ person: Int) {
        // Require barrier because of setters
        let randomTime = TimeInterval.random(in: 0.0...0.2)
        concurrentQueue.asyncAfter(deadline: .now() + randomTime, flags: .barrier) {
            let before = self.macbookCount
            self.macbookCount += 1
            let mistake = before + 1 == self.macbookCount ? "good" : "bad"
            print ("Person \(person) stocked has \(mistake). Before: \(before). After: \(self.macbookCount)")
        }

    }

    func viewRemainStock() {
        // Not need to barrier because of it is getter
        let randomTime = TimeInterval.random(in: 0.0...0.2)
        concurrentQueue.asyncAfter(deadline: .now() + randomTime) {
            print ("Still has \(self.macbookCount) units")
        }
    }

    func main() {
        // init 100 buyers concurrently
        for i in 0..<100 {
            DispatchQueue.global().async {
                self.buy(i)
            }
        }

        // init 100 stockers concurrently
        for i in 0..<100 {
            DispatchQueue.global().async {
                self.stock(i)
            }
        }

        // init 100 query concurrently
        for _ in 0..<100 {
            DispatchQueue.global().async {
                self.viewRemainStock()
            }
        }
    }
}

// MARK: Semaphore
/// Do 4 actions at a time because semaphore initially at 3
func semaphore1() {
    for i in 0..<20 {
        DispatchQueue.global().async {
            heavyAction("msg\(i)")
            semaphore.signal()
        }
        semaphore.wait()
    }
    print ("end")
}

// MARK: Serial Queue
// - always safe thread
func serialQueue1() {
}

// MARK: Operation Queue
// - It is ok for operation depends another operation in another OperationQueue
// - OperationQueue is concurrent
// - If we cancel upstream dependency operation, so the downstream operation can start()
// - Executing order
//    - Priority: higher first
//    - Ready: is ready to start (any dependent need run first)
//        - Add order
// - waitUntilAllOperationsAreFinished: Allow operation queue to wait, if queue 1 depends queue2 so wait = queue1 + queue2’s execution time
// - BlockOperation is only able to check cancel if it is not run yet, because addOperation will trigger run immediately
// - Cancel operation not means it will be removed, but as soon as it’s turn, it should be handled to be marked as Done
// - Operation can done with DONE or CANCELED
// - Can not add same instance of operation is two OperationQueue, otherwise it crashes
// - addBarrierBlock: to allow all executing to finishing first, the other want to run must wait.
//- An operation queue executes its operations either directly, by running them on secondary threads, or indirectly using the libdispatch library (also known as Grand Central Dispatch).


/// #1: Add to queue, sync Operation object
/// - write in main, so it will run synced object, but they are added in operation queue, so they will run concurrently
class FirstOperation: Operation {
    let title: String
    init(_ title: String) {
        self.title = title
    }

    override func main() {
        customDelay(1,1)
        print ("\(title) done")
    }
}

class FirstOperationRunner {
    func main() {
        let operation1 = FirstOperation("operation1")
        let operation2 = FirstOperation("operation2")
        let operation3 = FirstOperation("operation3")
        let operation4 = FirstOperation("operation4")
        operationQueue.addOperation(operation1)
        operationQueue.addOperation(operation2)
        operationQueue.addOperation(operation3)
        operationQueue.addOperation(operation4)
    }
}

// #2 Add to queue, async Operation object
// SecondOperation was not demo-ed because of it no value
// Similar to example 1: Both run concurrently
// Different: This operation run asynced, example 1 run synced


// #3 No add to queue, sync Operation object
//class ThirdOperation: Operation {
//    let title: String
//    init(_ title: String) {
//        self.title = title
//    }
//
//    override func main() {
//        print ("Main thread", Thread.isMainThread)
//        customDelay()
//        print ("\(title) done")
//        print ("END", Date().timeIntervalSince1970)
//    }
//}
//
//class ThirdOperationRunner {
//    func main() {
//        print ("START", Date().timeIntervalSince1970)
//        for i in 0..<9 {
//            let operation = ThirdOperation("operation\(i)")
//            operation.start()
//        }
//    }
//}


// #4 No add to queue, async Operation object
// - No need to create a custom Operation unless default OperationQueue do not serve your purpose.
// This example to demo how to extend operation asynced (override start function), and added it to operation queue.
class ForthOperation: Operation {
    lazy var concurrentQueue = DispatchQueue(label: "\(title) concurrent queue", attributes: .concurrent)
    let title: String
    init(_ title: String) {
        self.title = title
    }

    private var _isExecuting: Bool = false {
        willSet {
            willChangeValue(for: \ForthOperation.isExecuting)
        }
        didSet {
            didChangeValue(for: \ForthOperation.isExecuting)
        }
    }
    
    override var isExecuting: Bool {
        return _isExecuting
    }

    private var _isFinished: Bool = false {
        willSet {
            willChangeValue(for: \ForthOperation.isFinished)
        }
        didSet {
            didChangeValue(for: \ForthOperation.isFinished)
        }
    }
    override var isFinished: Bool {
        return _isFinished
    }

    private var _isCustomLogic: Bool = true
    override var isReady: Bool {
        return super.isReady && _isCustomLogic
    }
    
    override func main() {
        concurrentQueue.async(flags: .barrier) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            guard !strongSelf.isFinished && strongSelf.isReady && !strongSelf.isCancelled && !strongSelf.isExecuting else { return }
            strongSelf._isExecuting = true
            strongSelf.doMain()
        }
    }
    
    func doMain() {
        concurrentQueue.async(flags: .barrier) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            customDelay()
            print ("\(strongSelf.title) done")
            strongSelf._isExecuting = false
            strongSelf._isFinished = true
        }
    }
}

class ForthOperationRunner: NSObject {
    var prevOperation: ForthOperation?
    let operationQueue = OperationQueue()
    
    func main() {
        let actions = ["downloadJDM", "unzip", "install"]
        for i in 0..<actions.count {
            let action = actions[i]
            let operation = ForthOperation(action)
            if let prevOperation = prevOperation {
                operation.addDependency(prevOperation)
            }
            prevOperation = operation
            operationQueue.addOperation(operation)
        }
    }
}

// MARK: Deadlock

// 4 case
// sync -> async
// sync -> sync -> deadlock
// async -> async
// async - sync -> deadlock
// - sync: block all, it must excecute first
// - async: not block, execute later
// - concurrent: tasks run same time
// - serial: tasks run sequentially

// MARK: Lock

class Lock1 {
    let lock = NSLock()
    var counter = 1
    func doSthSafely() {
        lock.lock()
        let expected = counter + 1
        counter += 1
        let status = counter == expected ? "good" : "bad"
        print ("Counter by 1, now \(counter). Safethread is", status)
        lock.unlock()
    }
    
    func doSthUnSafely() {
        let expected = counter + 1
        counter += 1
        let status = counter == expected ? "good" : "bad"
        print ("Counter by 1, now \(counter). Safethread is", status)
    }
    
    func main() {
        for _ in 0..<1000 {
            DispatchQueue.global().async {
                self.doSthUnSafely()
            }
        }
    }
}

// MARK: NSConditionLock
// Basic
class NSConditionLock1 {
    let lock = NSConditionLock(condition: 0)
    func testCase1() {
        // if lock init with 0
        // so you can't lock with condition 1, so it hang there
        lock.lock(whenCondition: 1)
        print ("abc")
    }
    
    func testCase2() {
        // if lock init with 0
        // so you can't lock with condition 1, if tryLock so it NOT hang there
        print (lock.tryLock(whenCondition: 1))
        print ("abc")
    }
}

// Advance
class NSConditionLock2 {
    let lock = NSConditionLock(condition: 0)
    func tc1() {
        // safe thread
        // 1: lock --------------------------------------> abc -> unlock
        // 2: ---------can't get lock - hang and wait--------------------locked--> abc -> unlock
        lock.lock(whenCondition: 0)
        print("abc")
        lock.unlock(withCondition: 0)
    }
    
    func tc2() {
        // safe thread using try lock
        // 1: lock --------------------------------------> abc -> unlock
        // 2: ---------can't get lock - hang and wait using while--------locked--> abc -> unlock
        while !lock.tryLock(whenCondition: 0) { }
        print("abc")
        lock.unlock(withCondition: 0)
    }
    
    func main() {
        for _ in 1...2 {
            DispatchQueue.global().async {
                self.tc2()
            }
        }
    }
}

// Real scenario
class NSConditionLock3 {
    var inStock = 100
    var inDisplay = 0
    let LESS_ITEM = 0        // in stock < 10
    let ENOUGH_ITEM = 1      // in stock >= 10
    let lock = NSConditionLock(condition: 0) // LESS_ITEM

    func stock() {
        while true {
            lock.lock(whenCondition: LESS_ITEM)
            if inStock > 0 {
                inStock -= 20
                inDisplay += 20
                print ("Supply 20 unit, now inDislay", inDisplay, "inStock", inStock)
            }
            lock.unlock(withCondition: ENOUGH_ITEM) // release lock when items > 10 for allow buying
        }
    }

    func buy() {
        lock.tryLock(whenCondition: ENOUGH_ITEM)
        if inDisplay > 0 {
            inDisplay -= 1
            print ("customer bought, remain", inDisplay)
        }
        // if > 10, unlock Lock1.ENOUGH_ITEM
        // otherwise, unlock the stock
        let condition = inDisplay > 10 ? ENOUGH_ITEM : LESS_ITEM
        lock.unlock(withCondition: condition)
    }
    
    func main() {
        // stock while supply lasts
        DispatchQueue.global().async {
            self.stock()
        }

        // 100 ccu walk to store
        DispatchQueue.global().async {
            for _ in 0..<100 {
                self.buy()
            }
        }
    }
}


