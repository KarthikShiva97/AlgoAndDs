
import Foundation

public protocol ValueLimitProvider {
    static var min: Self { get }
    static var max: Self { get }
}

public class BinarySearchTree<T: Comparable & ValueLimitProvider> {
    private var root: Node?
    public init() {}
}

extension BinarySearchTree {
    public func insert(_ value: T) {
        // If root is nil, assign the value as root
        guard let root = root else {
            return root = Node(data: value)
        }
        insert(value, below: root)
    }
    
    private func insert(_ value: T, below node: Node) {
        // If value is less than or equal to current node's value,
        // 1) Check if left node is nil.
        // 2) If nil, insert as left child
        // 3) If not nil, ask the left child to insert the value under it
        if value <= node.data {
            guard let leftNode = node.left else {
                return node.left = Node(data: value)
            }
            return insert(value, below: leftNode)
        }
        
        // If value is greater than current node's value,
        // 1) Check if right node is nil.
        // 2) If nil, insert as right child
        // 3) If not nil, ask the right child to insert the value under it
        guard let rightNode = node.right else {
            return node.right = Node(data: value)
        }
        return insert(value, below: rightNode)
    }
}

extension BinarySearchTree {
    public func delete(_ value: T) {
        guard isEmpty == false else {
            return print("Nothing to delete.")
        }
        
        // We create a dummy node here with max possible value and assign the root as the left child (Satisfies BST property even if root node has max possible value)
        // Why: Our delete code is designed to work with the parent of the 'node to be deleted' and it works well for every case except when the node to be deleted is the
        // root node of the tree itself. In this case, there is no parent. So, to counter this edge case, we assign a dummy parent.
        let proxyRoot = Node(data: T.max)
        proxyRoot.left = root
        deleteValue(value, under: proxyRoot)
        
        assert(proxyRoot.left != nil)
        root = proxyRoot.left
    }
    
    private func deleteValue(_ value: T, under node: Node?) {
        // Case 1: Node to be deleted is a leaf node
        // What: Just remove reference from parent
        // Why: Since the node to be deleted has no children, there is no need to maintain the BST property for its children
        
        // Case 2: Node to be deleted is an internal node
        
        // Case 2.1: Node to be deleted has only one child
        // What: Connect child with grand parent
        // Why: Since node has only one child, there is no other child that can become the child of the grand parent
        
        // Case 2.2: Node to be deleted has both left and right child
        // What: Determine the which node from the left or the right subtree of the, node to be deleted, should replace the node which is to be deleted.
        // 1) Max from left subtree: All nodes in left would be smaller and since its from left subtreee, all nodes in right would be larger (OR) [will have NO RIGHT CHILD]
        // 2) Min from right subtree: All nodes in left would be automatically smaller and all nodes in right would be larger since this is the min value. [will have NO LEFT CHILD]
        // Why: To maintain the BST property, the new child(root to be) must ensure that all the nodes in its left are less than or equal and all nodes on the right are greater
        
        guard let node = node else { return }
        var nodeToBeDeleted: Node?
        var directionToDelete: Node.Direction?
        
        if value <= node.data {
            guard let leftNode = node.left, leftNode.data == value else {
                return deleteValue(value, under: node.left)
            }
            nodeToBeDeleted = leftNode
            directionToDelete = .left
        } else {
            guard let rightNode = node.right, rightNode.data == value else {
                return deleteValue(value, under: node.right)
            }
            nodeToBeDeleted = rightNode
            directionToDelete = .right
        }
        
        guard let nodeToBeDeleted = nodeToBeDeleted, let directionToDelete = directionToDelete else {
            return assertionFailure("Should have been non nil.")
        }
        
        // Case 1
        if nodeToBeDeleted.isLeaf {
            return node.setChild(nil, in: directionToDelete)
            // Case 2.1
        } else if nodeToBeDeleted.hasOnlySingleChild, let theOnlyGrandChild = nodeToBeDeleted.left ?? nodeToBeDeleted.right {
            node.setChild(theOnlyGrandChild, in: directionToDelete)
        } else {
            // Case 2.2
            assert(nodeToBeDeleted.hasTwoChildren)
            guard let leftChild = nodeToBeDeleted.left else { return assertionFailure("Left child should have existed.") }
            // This child will not have right subtree since this is the max value child
            let maxChildInLeftSubTree = getMaxValueNode(under: leftChild)
            // This delete will encounter Case 2.1
            deleteValue(maxChildInLeftSubTree.data, under: leftChild)
            
            // Setting the left and right subtrees of the new child
            maxChildInLeftSubTree.left = nodeToBeDeleted.left
            maxChildInLeftSubTree.right = nodeToBeDeleted.right
            
            // Finally Insert the descendant in the direction, that the 'nodeToBeDeleted' node existed.
            node.setChild(maxChildInLeftSubTree, in: directionToDelete)
        }
    }
    
    private func getMaxValueNode(under node: Node) -> Node {
        var maxValueNode = node
        while let rightNode = maxValueNode.right {
            maxValueNode = rightNode
        }
        return maxValueNode
    }
}

extension BinarySearchTree {
    public func _print() {
        guard let root = root else {
            return print("Empty Tree.")
        }
        _printNode(root)
    }
    
    private func _printNode(_ node: Node?) {
        guard let node = node else { return }
        print("\nRoot ->", node.data)
        print("Left ->", node.left?.data ?? "Nil")
        print("Right ->", node.right?.data ?? "Nil")
        _printNode(node.left)
        _printNode(node.right)
    }
    
    public var isEmpty: Bool {
        return root == nil
    }
    
    public var max: T? {
        guard let root = root else { return nil }
        return getMaxValueNode(under: root).data
    }
}

extension BinarySearchTree {
    class Node {
        var data: T
        var left: Node?
        var right: Node?
        
        init(data: T, left: Node? = nil, right: Node? = nil) {
            self.data = data
            self.left = left
            self.right = right
        }
        
        var isLeaf: Bool {
            return left == nil && right == nil
        }
        
        var hasOnlySingleChild: Bool {
            return (left == nil || right == nil) && (left != nil || right != nil)
        }
        
        var hasTwoChildren: Bool {
            return left != nil && right != nil
        }
        
        func getChild(in direction: Direction) -> Node? {
            switch direction {
            case .left:
                return left
            case .right:
                return right
            }
        }
        
        func setChild(_ child: Node?, in direction: Direction) {
            switch direction {
            case .left:
                left = child
            case .right:
                right = child
            }
        }
    }
}

extension BinarySearchTree.Node {
    enum Direction {
        /// Left child
        case left
        /// Right child
        case right
    }
}
