import SpriteKit

class MenuScene: SKScene {
    private var showText: ShowText!
    func displayErrorLog(_ message: String) {showText.addErrorLog(message, in: self)}
    
    override func didMove(to view: SKView) {
        showText = ShowText(fontcolor: .black, lineHeight: 25, fontName: "Arial", fontSize: 20)
        addChild(showText)
        let MenuBG = SKSpriteNode(imageNamed: "MenuBG")
        MenuBG.position=CGPoint(x: frame.midX, y: frame.midY)
        MenuBG.zPosition = -5
        DispatchQueue.main.async {
            self.addChild(MenuBG)
        }
        backgroundColor = .white
        
        // ボタンのサイズとスペーシング
        let buttonSize = CGSize(width: 200, height: 50)
        let verticalSpacing: CGFloat = 20
        let horizontalSpacing: CGFloat = 10
        
        // 一人で研究ボタン
        createButton(
            text: "一人で研究",
            position: CGPoint(x: frame.midX, y: frame.midY + buttonSize.height + verticalSpacing),
            size: buttonSize,
            name: "soloButton"
        )
        // オンラインで戦うボタン
        createButton(
            text: "オンラインで戦う",
            position: CGPoint(x: frame.midX, y: frame.midY),
            size: buttonSize,
            name: "onlineButton"
        )
        // プロフィールボタン（横並び）
        createButton(
            text: "プロフィール",
            position: CGPoint(
                x: frame.midX - 100 / 2 - horizontalSpacing / 2,
                y: frame.midY - buttonSize.height - verticalSpacing
            ),
            size: CGSize(width: 95, height: 50),
            name: "profileButton"
        )
        createButton(
            text: "チャット",
            position: CGPoint(
                x: frame.midX + 100 / 2 + horizontalSpacing / 2,
                y: frame.midY - buttonSize.height - verticalSpacing
            ),
            size: CGSize(width: 95, height: 50),
            name: "chatsButton"
        )
        createButton(
            text: "詳細説明",
            position: CGPoint(x: frame.midX,y: frame.midY - buttonSize.height * 2 - verticalSpacing * 2),
            size: buttonSize,
            name: "explain"
        )
        DispatchQueue.main.async{
            self.admin_announce()
        }
        
        // ラベルの初期化
        messageLabel = SKLabelNode(fontNamed: "Helvetica")
        messageLabel.fontSize = 32
        messageLabel.fontColor = .cyan
        messageLabel.zPosition = 10
        messageLabel.position = CGPoint(x: frame.maxX, y: frame.maxY - 50)
        messageLabel.horizontalAlignmentMode = .left
        addChild(messageLabel)
        let label = SKLabelNode(text: version_txt)
        label.fontSize = 30
        label.fontColor = .white
        label.horizontalAlignmentMode = .left
        label.position = CGPoint(x:frame.minX + 10,y:frame.minY + 10)
        addChild(label)
    }
    
    func createButton(text: String, position: CGPoint, size: CGSize, name: String) {
        let background = SKShapeNode(rectOf: size, cornerRadius: 10)
        background.fillColor = .lightGray
        background.position = position
        background.name = name
        addChild(background)
        let label = SKLabelNode(text: text)
        label.fontSize = 18
        label.fontColor = .black
        label.fontName = "KouzanBrushFontGyousyoOTF"
        label.verticalAlignmentMode = .center
        label.position = position
        label.name = name
        addChild(label)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let node = atPoint(location)
            if node.name == "soloButton" {
                print("一人で研究が選択されました")
                let gameScene = GameScene(size: self.size)
                gameScene.gameMode = "Solo" // GameSceneのプロパティにモードを設定
                let transition = SKTransition.fade(withDuration: 1.0)
                self.view?.presentScene(gameScene, transition: transition)
            } else if node.name == "onlineButton" { //Online
                print("オンラインで戦うが選択されました")
                if my_Player_name == "NoneName_Player" {displayErrorLog("プロフィールから名前を登録してください");return}
                let roomScene = RoomScene(size: self.size)
                let transition = SKTransition.fade(withDuration: 1.0)
                self.view?.presentScene(roomScene, transition: transition)
            } else if node.name == "profileButton" {
                let profileScene = ProfileScene(size: self.size)
                self.view?.presentScene(profileScene, transition: SKTransition.fade(withDuration: 1.0))
            } else if node.name == "chatsButton" {
                let chatScene = ChatScene(size: self.size)
                self.view?.presentScene(chatScene, transition: SKTransition.fade(withDuration: 1.0))
            } else if node.name == "explain" {
                if let view = self.view{
                    let infoVC = InfoViewController()
                    infoVC.modalPresentationStyle = .overFullScreen
                    view.window?.rootViewController?.present(infoVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    var admin_messages: [String] = []
    func admin_announce() {
        guard let url = URL(string: "\(endpoint)/admin.json") else {print("Invalid URL");return}
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {print("Error: \(error)");return}
            guard let data = data else {print("No data received");return}
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: [String: Any]] {
                    let sortedMessages = json.values.sorted { (first, second) -> Bool in
                        guard let timestamp1 = first["timestamp"] as? Double,
                              let timestamp2 = second["timestamp"] as? Double else { return false }
                        return timestamp1 < timestamp2
                    }.compactMap { $0["message"] as? String }
                    for message in sortedMessages {
                        self.admin_messages.append(message)
                        print(message)
                    }
                    self.startScrollingMessages()
                }
            } catch {print("Error parsing JSON: \(error)")}
        }
        
        task.resume()
    }
    private var currentMessageIndex = 0 // 現在のメッセージインデックス
    private var messageLabel: SKLabelNode!
    
    
    private func startScrollingMessages() {
        guard !admin_messages.isEmpty else { return }
        
        // 現在のメッセージを取得
        let message = admin_messages[currentMessageIndex]
        messageLabel.text = message
        
        // ラベルの初期位置（画面右端）
        messageLabel.position = CGPoint(x: frame.maxX, y: frame.maxY - 50)
        // メッセージの幅を計算
        let messageWidth = messageLabel.frame.width
        let moveLeft = SKAction.moveTo(x: -messageWidth, duration: 10.0) // 左端へ移動
        let resetPosition = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.currentMessageIndex = (self.currentMessageIndex + 1) % self.admin_messages.count // 次のメッセージへ
            self.startScrollingMessages()
        }
        
        // アニメーションの実行
        let sequence = SKAction.sequence([moveLeft, resetPosition])
        messageLabel.run(sequence)
    }

    
}
