import UIKit

var greeting = "Hello, playground"

// #1: tradition way
//class Player {
//    var isBitten = false
//    var isProtected = false
//    var isDead = false
//}
//
//let player = Player()
//
//func bite(_ player: Player) {
//    player.isBitten = true
//}
//
//func protect(_ player: Player) {
//    player.isProtected = true
//}
//
//func nextNight(_ player: Player) {
//    if !player.isDead {
//        player.isDead = player.isBitten && !player.isProtected
//    }
//}

// 1 bytes = 8 bits
// 8 bytes = 64 bits
// 0 or 1
// ...0000000000000
// bit 64 is bitten
// bit 63 is protected
//

// status           ...0000000 = 0
// isBitten         ...0000001 = 1
// isProtected      ...0000010 = 2
//
// wolf1 bite
//          0000000|  0000001    -> 0000001
// status = status | isBitten
// wolf2 bite
//          0000001| 0000001      -> 0000001
// status = status | isBitten
// bodyguard protect
//          0000001| 0000010      -> 0000011
// status = status | isBitten

// status: 0000011      = 3
// isBitten:    00001   = 1
// isProtect:   00010   = 2
// isSilence:   00100   = 4
//
// isDead = status | isBitten = 0000011 | 00001 = 0000011
// isDead = status | isBitten = 0000010 | 00001 = 0000011
//
// status:      00011
// isBitten:    00001
// isProtect:   00000

// 00011 & 00001 = 00001
// 00011 & 00010 = 00010

// 00011 & (00001) = 00001

// 00111 & 00001 = 00001
// 00111 & (00001) = 00001

// bitten    dead contion
// 00001 &  (00001 | 0000)  =    00001      => positive

// bitten but protect       dead contion
// 00011 &  (00001 | 0000)  =    00000      => negative




// not die          die
// 011              101     =>  not die ->             110 -> ko chet ->  010
// nd and silence   die
// 111              101     =>  not die ->             010 -> ko chet ->  110
//
// die              die
// 001              101     =   die     ->             100 -> chet ->     000
//
// die and silence  die
// 101              101     =   die     ->             000 -> chet ->     100

// status & 00001 & ~1101 = 0000

// 111 &  001  = 001
// 111 &  010  = 010

// assign:      OR
// check condition
// - build condition = condtion2 OR condtion2
// - (status & built condtion) & built condtion = built condtion => positive else negative

// AND  = 0 & 0 = 0
//      = 1 & 0 = 0
//      = 0 & 1 = 0
//      = 1 & 1 = 1
// OR   = 0 | 0 = 0
//      = 1 | 0 = 1
//      = 0 | 1 = 1
//      = 1 | 1 = 1
// XOR  = 0 ^ 0 = 0
//      = 1 ^ 0 = 1
//      = 0 ^ 1 = 1
//      = 1 ^ 1 = 0
// NOT  = 0~    = 1
//      = 1~    = 0
//      = 0101~ = 1010
// <<   = 0101 << 1 = 1010
// >>   = 0101 >> 1 = 0010

// #2

enum Action: Int {
    case bitten = 1//1 << 0     // 000001
    case protected = 2//1 << 1  // 000010
    case silenced = 4//1 << 2   // 000100
}

class BitPlayer {
    var status: Int = 0
    var dead = false
    
    func apply(action: Action) {
        status |= action.rawValue
        //print("status:", status)
        // 1
        // 3
    }
    
    func nextNight() {
        // which bit is related to contion, mask as 1. Other mask as 0
        let mask = Action.bitten.rawValue | Action.protected.rawValue
        
        // dead condition
        let deadCondition = Action.bitten.rawValue | 0
//        print ("deadCondition: ", deadCondition)
//        print ("status before calc", status & deadCondition)
//
        // remove all bit not related
        let result = status & mask
        
//        print ("result", result) // 011 & 001 = 101 & 001 = 011
        
        self.dead = result == deadCondition
        
        status = 0
    }
}

// 011
// 010
// 011 ^ 010 = 001
// 011 ^ 001 = 010

// 011 & 010 = 010
// 011 & 001 = 001

// 011 | 010 = 011
// 011 | 001 = 011

// 011 | 011 =
// 101011 & 000011 = 000011 = true
//
//
//let player = BitPlayer()
//player.apply(action: .bitten)
//player.apply(action: .protected)
//player.nextNight()
//print ("player is dead", player.dead)

var choice = 0
let option1 = 1
let option2 = 2
let option3 = 4


//BITMASK


switch choice {
case option1:
    print ("selected option 1")
case option2:
    print ("selected option 2")
case option1 | option2: // DIE CONTION
    print ("selected option 1 and 2")
default:
    print ("not reach")
}

// 111 & 001 = 001


//
// mask = 011
//
// 111 & 011 = 011
// 011 & 011 = 011
// 001 & 011 = 001


// 000000 11

// 010110 01 -> 000000 01
// 011111 01 -> 000000 01
//
// 010110 01  &  000000 11 = 000000 01
// 011111 01  &  000000 11 = 000000 01

//

// 0001 & 0011 -> 0001
// 0101 & 0011 -> 0001
// 1101 & 0011 -> 0001
