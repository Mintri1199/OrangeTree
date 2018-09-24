import SpriteKit

class GameScene: SKScene {
    var orangeTree: SKSpriteNode!
    var orange: Orange?
    var touchstart: CGPoint = .zero
    var shapeNode = SKShapeNode()
    
    
    override func didMove(to view: SKView) {
        // Connect Game Objects
        orangeTree = childNode(withName: "tree") as! SKSpriteNode
        
        // Configure shapeNode
        shapeNode.lineWidth = 20
        shapeNode.lineCap = .round
        shapeNode.strokeColor = UIColor(white: 1, alpha: 0.3)
        addChild(shapeNode)
        
        // Set the contact delegate
        physicsWorld.contactDelegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Get the location of the touch on the screen
        let touch = touches.first!
        let location = touch.location(in: self)
        
        // Check if the touch was on the Orange Tree
        if atPoint(location).name ==  "tree"{
            // Create the orange and add it to the scene at the touhc location
            orange = Orange()
            orange?.position =  location
            addChild(orange!)
            
            // Store the location of the touch
            touchstart = location
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Get the location of the touch
        let touch = touches.first!
        let location = touch.location(in: self)
        
        // Draw the firing vector
        let path = UIBezierPath()
        path.move(to: touchstart)
        path.addLine(to: location)
        shapeNode.path = path.cgPath
        
        // Update the position of the Orange to the current location
        orange?.position = location
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Get the location of where the touch ended
        let touch = touches.first!
        let location = touch.location(in: self)
        
        
        // Get the difference between the start and end point as a vector
        let dx = touchstart.x - location.x
        let dy = touchstart.y - location.y
        let vector = CGVector(dx: dx, dy: dy)
        
        // Set the Orange dynamic again and apply the vector as an impulse
        orange?.physicsBody?.isDynamic = true
        orange?.physicsBody?.applyImpulse(vector)
        
        // Remove the path from shapeNode
        shapeNode.path = nil
    }
    
}

extension GameScene: SKPhysicsContactDelegate {
    // Called when the physicWorld dtects two nodes colliding
    func didBegin(_ contact: SKPhysicsContact) {
        let nodeA = contact.bodyA.node
        let nodeB = contact.bodyB.node
        
        // Chekc that the bodies collided hard enough
        if contact.collisionImpulse > 15 {
            if nodeA?.name == "skull"{
                removeSkull(node: nodeA!)
            }else if nodeB?.name == "skull"{
                removeSkull(node: nodeB!)
            }
        }
    }
    
    // Function used to remove the skull node from the scene
    func removeSkull(node: SKNode) {
        node.removeFromParent()
    }
}
