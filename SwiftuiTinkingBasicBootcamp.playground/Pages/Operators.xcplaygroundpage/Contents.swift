import Foundation

//var likeCount: Double = 5
//var commentCount: Double = 0
//var viewCount: Double = 100


//likeCount = 5 + 1
//likeCount = likeCount + 1
//likeCount += 1


//likeCount = 5 - 1
//likeCount = likeCount - 1
//likeCount -= 1


//likeCount = likeCount * 1.5
//likeCount *= 1.5

//likeCount = likeCount / 2
//likeCount /= 2


//likeCount = likeCount - 1 * 1.5 / 2


var likeCount: Double = 5
var commentCount: Double = 1
var viewCount: Double = 100

likeCount += 1

if likeCount == 5 {
    print("likeCount is 5")
}

if likeCount != 5 {
    print("likeCount is NOT 5")
}

if likeCount > 5 {
    print("likeCount is greater than 5")
}

if likeCount < 5{
    print("likeCount is less than 5")
}

if likeCount >= 5 {
    print("likeCount greater than equal to 5 ")
}
    
if likeCount <= 5 {
    print("likeCount less than equal to 5 ")
}

if likeCount >= 5 && commentCount > 0 {
    print("Post has greater than 5 likes and greater than 0 comments.")
} else {
    print("Post has 5 or less likes or post has 0 or less comments.")
}

if likeCount > 5 || commentCount > 0 {
    print("Post has greater than 5 likes OR greater than 0 comments.")
} else {
    print("Post has 5 or less likes and 0 or less comments.")
}

var userIsPremium: Bool = true
var userIsNew: Bool = false

if userIsPremium && userIsNew {
    print("EXECUTE")
}

if likeCount > 100 && commentCount > 0 ||  viewCount > 50 {
    print("Execute")
}
