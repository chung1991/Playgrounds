import UIKit

var greeting = "Hello, playground"

// base classess
protocol MotorVehicle {
    func drive()
}

protocol Aircraft {
    func pilot()
}

class Car: MotorVehicle, Aircraft {
    func drive() {
        
    }
    func pilot() {
        
    }
}

class MotorCycle: MotorVehicle {
    func drive() {
        
    }
}

class Plane: Aircraft {
    func pilot() {
        
    }
}

protocol Bird: CustomStringConvertible {
    var isFlyable: Bool { get }
}

extension CustomStringConvertible where Self : Bird {
    var description: String {
        return isFlyable ? "Flyable" : "Not Flyable"
    }
}

enum CustomBird: Bird {
    case Penguin
    case Eagle
    
    var isFlyable: Bool {
        return self == .Eagle
    }
}

print (CustomBird.Eagle)
print (CustomBird.Penguin)
