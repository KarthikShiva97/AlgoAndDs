import UIKit


extension Float: ValueLimitProvider {
    public static var min: Float {
        Float.leastNonzeroMagnitude
    }
    
    public static var max: Float {
        Float.greatestFiniteMagnitude
    }
}

let bst = BinarySearchTree<Float>()
bst.insert(3)
bst.insert(2)
bst.insert(11)

bst.insert(13)
bst.insert(12)

bst.insert(8)
bst.insert(9)

bst.insert(8.5)

bst.insert(2.5)
bst._print()

if true {
    // Deleting root node
    bst.delete(3)
}

if false {
    // Deleting leaf node
    bst.delete(12)
}

if false {
    // Deleting internal node with single child
    bst.delete(2)
}

if false {
    // Deleting internal node with two children
    bst.delete(11)
}

print("\n After delete")
bst._print()
