import SpriteKit

class ShowText: SKNode {
    private var errorMessages: [SKLabelNode] = []
    private var chatMessages: [SKLabelNode] = []
    private let maxLines = 5
    private let lineHeight: CGFloat
    private let fontName: String
    let fontcolor: UIColor
    private let fontSize: CGFloat
    private let animationDuration: TimeInterval
    
    init(fontcolor: UIColor, lineHeight: CGFloat = 25, fontName: String = "Helvetica", fontSize: CGFloat = 15, animationDuration: TimeInterval = 0.5) {
        self.lineHeight = lineHeight
        self.fontName = fontName
        self.fontSize = fontSize
        self.fontcolor = fontcolor
        self.animationDuration = animationDuration
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addErrorLog(_ message: String, in scene: SKScene) {
        let startPosition = CGPoint(x: scene.frame.maxX - 20, y: scene.frame.minY + lineHeight - 20)
        addMessage(message,fontcolor: fontcolor, at: startPosition, to: &errorMessages, parentScene: scene,mode:"error",maxLine: 4)
    }
    
    func addChatLog(_ message: String, in scene: SKScene) {
        let startPosition = CGPoint(x: scene.frame.minX + 20, y: scene.frame.minY + lineHeight - 20)
        addMessage(message,fontcolor: fontcolor, at: startPosition, to: &chatMessages, parentScene: scene, mode:"chat",maxLine: 5)
    }
    
    private func addMessage
    (_ message: String,
     fontcolor: UIColor,
     at position: CGPoint,
     to messageList:
     inout [SKLabelNode],
     parentScene: SKScene,
     mode:String,
     maxLine: Int
    ) {
        if messageList.count >= maxLine {
            let oldestMessage = messageList.removeFirst()
            oldestMessage.run(.fadeOut(withDuration: animationDuration)) {
                oldestMessage.removeFromParent()
            }
        }
        let label = SKLabelNode(fontNamed: fontName)
        label.text = message
        label.fontSize = fontSize
        label.fontColor = fontcolor
        label.position = position
        label.horizontalAlignmentMode = mode == "error" ? .right : .left
        label.alpha = 0 // 透明からスタート
        label.zPosition = -5
        if mode == "chat" {label.fontSize = 15}
        parentScene.addChild(label)
        messageList.append(label)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.1)
        let moveUp = SKAction.moveBy(x: 0, y: lineHeight / 2, duration: animationDuration)
        let appearAction = SKAction.group([fadeIn, moveUp])
        label.run(appearAction)
        for (index, existingLabel) in messageList.enumerated() {
            if existingLabel != label {
                let targetY = position.y + CGFloat(messageList.count - index) * lineHeight
                let moveToTarget = SKAction.moveTo(y: targetY, duration: animationDuration)
                moveToTarget.timingMode = .easeInEaseOut // イージング効果
                existingLabel.run(moveToTarget)
            }
        }
    }
}
