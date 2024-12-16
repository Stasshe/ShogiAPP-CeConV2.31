import SpriteKit

class ShowText: SKNode {
    private var errorMessages: [SKLabelNode] = []
    private var chatMessages: [SKLabelNode] = []
    private let maxLines: Int
    private let lineHeight: CGFloat
    private let fontName: String
    private let fontcolor: UIColor
    private let fontSize: CGFloat
    private let animationDuration: TimeInterval
    
    init(fontcolor: UIColor,maxLines: Int = 5, lineHeight: CGFloat = 35, fontName: String = "Helvetica", fontSize: CGFloat = 18, animationDuration: TimeInterval = 0.5) {
        self.maxLines = maxLines
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
        addMessage(message,fontcolor: fontcolor, at: startPosition, to: &errorMessages, parentScene: scene,mode:"error")
    }
    
    func addChatLog(_ message: String, in scene: SKScene) {
        let startPosition = CGPoint(x: scene.frame.minX + 20, y: scene.frame.minY + lineHeight - 20)
        addMessage(message,fontcolor: fontcolor, at: startPosition, to: &chatMessages, parentScene: scene, mode:"chat")
    }
    
    private func addMessage(_ message: String,fontcolor: UIColor, at position: CGPoint, to messageList: inout [SKLabelNode], parentScene: SKScene,mode:String) {
        // 古いメッセージが最大数を超えた場合は削除
        if messageList.count >= maxLines {
            let oldestMessage = messageList.removeFirst()
            oldestMessage.run(.fadeOut(withDuration: animationDuration)) {
                oldestMessage.removeFromParent()
            }
        }
        
        // 新しいメッセージを作成
        let label = SKLabelNode(fontNamed: fontName)
        label.text = message
        label.fontSize = fontSize
        label.fontColor = fontcolor
        label.position = position
        label.horizontalAlignmentMode = mode == "error" ? .right : .left
        label.alpha = 0 // 透明からスタート
        parentScene.addChild(label)
        messageList.append(label)
        
        // 表示アニメーション（ふわっと登場）
        let fadeIn = SKAction.fadeIn(withDuration: 0.1)
        let moveUp = SKAction.moveBy(x: 0, y: lineHeight / 2, duration: animationDuration)
        let appearAction = SKAction.group([fadeIn, moveUp])
        label.run(appearAction)
        
        // 既存のメッセージを上に押し上げるアニメーション
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
