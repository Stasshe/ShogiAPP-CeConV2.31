import SpriteKit
import Foundation
import SpriteKit
import UIKit

class ChatScene: SKScene {
    var updateInterval: TimeInterval = 3
    var lastUpdateTime: TimeInterval = 0
    
    // テキストデータを配列で保持
    var chatMessages: [ChatMessage] = [
        ChatMessage(message: "hello", name: "A", timestamp: 0),
        ChatMessage(message: "hello", name: "B", timestamp: 0)
    ]
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: frame)
        scrollView.contentSize = CGSize(width: frame.width, height: CGFloat.greatestFiniteMagnitude)
        return scrollView
    }()
    
    
    func updateChat(){
        // UIScrollView に UILabel を追加
        for (index, message) in chatMessages.enumerated() {
            let label = UILabel(frame: CGRect(x: 0, y: CGFloat(index) * 20, width: scrollView.frame.width, height: 20))
            label.text = message.message
            scrollView.addSubview(label)
        }
    }
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        // UIView を SKView に追加
        view.addSubview(scrollView)
        // Auto Layout を有効にする
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        // 制約を設定
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    override func update(_ currentTime: TimeInterval) {
        if currentTime - lastUpdateTime > updateInterval {
            lastUpdateTime = currentTime
            fetchNewChatMessages { newMessages in
                // newMessages には新しいメッセージのみが入っているので、好きなように処理できます。
                for message in newMessages {
                    let N: [ChatMessage] = [ChatMessage(message: message.message, name: message.name, timestamp: 0)]
                    self.chatMessages.append(contentsOf: N)
                    self.updateChat()
                    print("新しいメッセージ: \(message.message) - \(message.name)")
                }
            }
        }
    }
    
    
    struct ChatMessage: Codable, Hashable {
        let message: String
        let name: String
        let timestamp: Double
    }
    
    var previousChatMessages: Set<ChatMessage> = []
    func fetchNewChatMessages(completion: @escaping ([ChatMessage]) -> Void) {
        let urlString = "\(endpoint)/chat.json"
        guard let url = URL(string: urlString) else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { [self] data, response, error in
            guard let data = data, error == nil else {
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                var newChatMessages: [ChatMessage] = []
                for (_, value) in jsonDictionary ?? [:] {
                    if let chatMessageData = try? JSONSerialization.data(withJSONObject: value, options: []),
                       let chatMessage = try? decoder.decode(ChatMessage.self, from: chatMessageData) {
                        newChatMessages.append(chatMessage)
                    }
                }
                // 新しいメッセージを抽出
                let newMessages = newChatMessages.filter { newMessage in
                    !previousChatMessages.contains(where: { $0.message == newMessage.message && $0.timestamp == newMessage.timestamp })
                }
                previousChatMessages.formUnion(newMessages)
                DispatchQueue.main.async {
                    let sortedNewMessages = newMessages.sorted { $0.timestamp < $1.timestamp }
                    completion(sortedNewMessages)
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }
        task.resume()
    }

}


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
