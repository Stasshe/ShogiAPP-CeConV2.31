import SpriteKit

class MenuScene: SKScene {
    private var showText: ShowText!
    func displayErrorLog(_ message: String) {showText.addErrorLog(message, in: self)}
    
    override func didMove(to view: SKView) {
        showText = ShowText(fontcolor: .black,maxLines: 5, lineHeight: 25, fontName: "Arial", fontSize: 20)
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
        
        // 設定ボタン（横並び）
        createButton(
            text: "チャット",
            position: CGPoint(
                x: frame.midX + 100 / 2 + horizontalSpacing / 2,
                y: frame.midY - buttonSize.height - verticalSpacing
            ),
            size: CGSize(width: 95, height: 50),
            name: "chatsButton"
        )
        
        
    }
    
    func createButton(text: String, position: CGPoint, size: CGSize, name: String) {
        // 背景の四角
        let background = SKShapeNode(rectOf: size, cornerRadius: 10)
        background.fillColor = .lightGray
        background.position = position
        background.name = name
        addChild(background)
        
        // テキスト
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
                self.displayErrorLog("グローバルチャットは作成検討中")
                
                //let chatScene = ChatScene(size: self.size)
                //self.view?.presentScene(chatScene, transition: SKTransition.fade(withDuration: 1.0))
            }
        }
    }
}
