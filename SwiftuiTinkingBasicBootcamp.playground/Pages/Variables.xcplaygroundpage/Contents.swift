import Foundation

// Constant
let someConstant: Bool = true

// Variable
var someVariable: Bool = true

//Cannot assign to value: 'someConstant' is a 'let' constant
//someConstant = false


someVariable = false

var myNumber: Double = 1.1123
print(myNumber)
myNumber = 2
print(myNumber)
myNumber = 234234234
print(myNumber)
myNumber =  24
print(myNumber)
myNumber = 2344
print(myNumber)


// if statements
var userIsPremium: Bool = false

if userIsPremium == true {
    print("1 - You have access to premium features.")
} else {
    print("1.1 - You do not have access to premium features.")
}

if userIsPremium {
    print("2 - You have access to premium features.")
}

if userIsPremium == false {
    print("3 - You do not have access to premium features.")
}

if !userIsPremium {
    print("4 - You do not have access to premium features.")
}
