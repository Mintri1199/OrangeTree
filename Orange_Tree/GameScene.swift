import SpriteKit

class GameScene: SKScene {
    var orangeTree: SKSpriteNode!
    var orange: Orange?
    var touchstart: CGPoint = .zero
    var shapeNode = SKShapeNode()
    var boundary = SKNode()
    
    // Class method to load .sks files
    static func Load (level: Int) -> GameScene?{
        return GameScene(fileNamed: "Level-\(level)")
    }
    
    
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
        
        // Setup the boundaries
        boundary.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(origin: .zero, size: size))
        boundary.position = .zero
        addChild(boundary)
        
        // Add the Sun to the scene
        let sun = SKSpriteNode(imageNamed: "Sun")
        sun.name = "sun"
        sun.position.x = size.width - (sun.size.width * 0.75)
        sun.position.y = size.height - (sun.size.height * 0.75)
        addChild(sun)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Get the location of the touch on the screen
        let touch = touches.first!
        let location = touch.location(in: self)
        
        // Check if the touch was on the Orange Tree
        if atPoint(location).name ==  "tree"{
            // Create the orange and add it to the scene at the touch location
            orange = Orange()
            orange?.position =  location
            addChild(orange!)
            
            // Store the location of the touch
            touchstart = location
        }
        // Check whether the sun was tapped and change the level
        for node in nodes(at: location) {
            if node.name == "sun" {
                let n = Int.random(in: 1 ... 2)
                if let scene = GameScene.Load(level: n) {
                    scene.scaleMode = .aspectFill
                    if let view = view {
                        view.presentScene(scene)
                    }
                }
            }
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
        let dx = (touchstart.x - location.x) * 0.5
        let dy = (touchstart.y - location.y) * 0.5
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
