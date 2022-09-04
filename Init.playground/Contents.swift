import UIKit

var greeting = "Hello, playground"

class Person {
    let name: String
    init(_ name: String) {
        self.name = name
    }
}

class Superman: Person {
//    override init(_ name: String) {
//        super.init(name)
//    }
//
    convenience init() {
        self.init("chung")
    }
    
    convenience init(_ age: Int) {
        self.init("chung")
    }
//    let strength: Int
//    let hp: Int
//    let vit: Int
//    init(_ strength: Int, _ hp: Int) {
//        self.strength = strength
//        self.hp = hp
//        super.init("superman")
//
//    }
////    init() {
////        super.init("man")
////    }
////
//    convenience init(_ strength: Int) {
//        self.init(strength, 100)
//        //self.strength = strength
//    }
}

let man = Superman()
print (man.name)

class Orange {
    convenience init(_ name: String) {
        self.init()
    }
}

// 1 class must have 1 designated init
// - if not implement designated init
//      - if this is child class => infer base class's designated init
//      - if this is base class => infer empty parameter init
// - if implement designated init
//      - must call base designated init
// => designated init always call VERTICAL or not if this is parent
//
// 1 class can have 0-n convenience init
// - must call designed init of current class
// => convenience init always call HORIZONTAL
