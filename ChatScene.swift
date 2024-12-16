/*
import SpriteKit

class ChatScene: SKScene {
    
    var messageNodes: [SKLabelNode] = []  // メッセージを保持する配列
    var yOffset: CGFloat = 0  // メッセージ間の縦の間隔
    var updateInterval: TimeInterval = 5.0
    var lastUpdateTime: TimeInterval = 0
    
    override func didMove(to view: SKView) {
        // 初期設定（例えば背景やフォントなど）
        self.backgroundColor = .white
    }
    
    func addMessage(message: Message, userID: String) {
        // 新しいメッセージを追加
        
        let labelNode = SKLabelNode(text: message.message)
        labelNode.fontName = "Arial"
        labelNode.fontColor = .black
        labelNode.fontSize = 18
        labelNode.horizontalAlignmentMode = userID == my_Player_name ? .right : .left
        
        // メッセージの配置（新しいメッセージが下に表示されるように）
        labelNode.position = CGPoint(x: userID == my_Player_name ? self.size.width - 20 : 20, y: 100 - 50 - yOffset)
        // メッセージをシーンに追加
        self.addChild(labelNode)
        // メッセージ位置調整
        yOffset -= labelNode.frame.height + 5
        // 配列に保存
        messageNodes.append(labelNode)
        
        // メッセージが画面外に出たらスクロールする
        if labelNode.position.y < 0 {
            self.scrollMessages()
        }
    }
    
    func scrollMessages() {
        // メッセージが画面外に出た場合、スクロールして古いメッセージを上に移動させる
        for node in messageNodes {
            node.position.y += node.frame.height + 5
        }
        yOffset = messageNodes.last?.position.y ?? 0
    }
    
    // チャットデータを取得し、メッセージを表示
    func fetchAndDisplayMessages() {
        fetchAndSortMessages { messages in
            for message in messages {
                self.addMessage(message: message, userID: message.name)
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if currentTime - lastUpdateTime > updateInterval {
            lastUpdateTime = currentTime
            fetchAndDisplayMessages()
        }
    }
    
    
    // メッセージの構造体を定義
    struct Message: Decodable {
        let message: String
        let name: String
        let timestamp: Double
    }
    func fetchAndSortMessages(completion: @escaping ([Message]) -> Void) {
        let urlString = "https://shogi-gui-cecon-default-rtdb.firebaseio.com/chat.json"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                // JSONを辞書型として解析
                let messages = try JSONDecoder().decode([String: Message].self, from: data)
                
                // timestampでソート（降順）
                let sortedMessages = messages.values.sorted { $0.timestamp > $1.timestamp }
                
                // メインスレッドでUI更新
                DispatchQueue.main.async {
                    completion(sortedMessages)
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
        
        task.resume()
    }
}
 
*/
