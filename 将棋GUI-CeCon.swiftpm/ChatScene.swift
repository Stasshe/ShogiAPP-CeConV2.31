import SpriteKit
import Foundation
import UIKit

class ChatScene: SKScene {
    var SendButton: SKLabelNode!
    var isinit = true
    private var showText: ShowText!
    func displayErrorLog(_ message: String) {showText.addErrorLog(message, in: self)}
    
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: frame)
        scrollView.contentSize = CGSize(width: frame.width, height: 200)//CGFloat.greatestFiniteMagnitude)
        return scrollView
    }()
    var previousChat: [ChatBase.ChatMessage] = []
    var init_index = 0
    var init_c_private = 0
    var countPrivate = 0
    func updateChat() {
        if previousChat == chatMessages {return}
        previousChat = chatMessages
        //print("update chat")
        // UIScrollView に UILabel を追加
        
        //init_index = 0
        for (index, message) in chatMessages.enumerated() {
            if !(init_index <= index) {continue}
            let isMe = message.name == my_Player_name
            let x:CGFloat = isMe ? 0 : frame.minX
            let nx:CGFloat = isMe ? -50 : 50
            let nameLabel = UILabel(frame: CGRect(x: nx, y: 70 + CGFloat(index - countPrivate) * 70, width: scrollView.frame.width, height: 18))
            nameLabel.textColor = .white
            let date = Date(timeIntervalSince1970: message.timestamp)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM月dd日 EEEE HH時mm分ss秒" // 曜日も表示
            let formattedDate = dateFormatter.string(from: date)
            //print(formattedDate) // 例: 2023年11月22日 水曜日 15時30分00秒
            nameLabel.text = "\(message.name): \(formattedDate)"
            nameLabel.font = UIFont.systemFont(ofSize: 16)
            nameLabel.textAlignment = isMe ? .right : .left
            let txt = "\(message.message)"
            if String(txt.prefix(6)) == "!room!" {
                nameLabel.text = "--roomID--\(formattedDate)"
                nameLabel.layer.position.x = frame.midX
                nameLabel.textColor = .lightGray
                let roomID = String(message.message.dropFirst(6)) // !room!を除いた部分を取得
                let label = UILabel(frame: CGRect(x: x, y: 70 + CGFloat(Double(index - countPrivate) + 0.3) * 70 - 40, width: scrollView.frame.width, height: 30))
                label.text = "Room ID: \(roomID)"
                label.textColor = .yellow
                label.textAlignment = isMe ? .right : .left
                label.font = UIFont.boldSystemFont(ofSize: 17)
                label.isUserInteractionEnabled = true // ユーザーインタラクションを有効化
                // タップジェスチャーを追加
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(copyRoomID(_:)))
                label.addGestureRecognizer(tapGesture)
                label.tag = index // ラベルにインデックスをタグとして設定（複数ラベルを区別）
                nameLabel.text = ""
                scrollView.addSubview(nameLabel)
                scrollView.addSubview(label)
            }else{
                let textView = UITextView(frame: CGRect(x: x, y: 70 + CGFloat(Double(index - countPrivate) + 0.2) * 70, width: scrollView.frame.width, height: 35))
                textView.text = "-> \(message.message)"
                textView.textColor = .white
                textView.isEditable = false
                textView.isSelectable = true
                textView.backgroundColor = .clear
                textView.textAlignment = isMe ? .right : .left
                textView.font = UIFont.boldSystemFont(ofSize: 18)
                textView.isScrollEnabled = false
                if message.message.dropFirst().contains("@"){
                    let (name, sentence) = chatBase.extractStrings(from: message.message)
                    if name == my_Player_name {
                        textView.text = "@@-> \(sentence ?? "NONE")"
                    } else if name != "" {
                        init_index += 1
                        countPrivate += 1
                        continue
                    }
                }
                if String(message.message.prefix(5)) == "!log!" {
                    nameLabel.text = "--LOG--\(formattedDate)"
                    nameLabel.textAlignment = .center
                    nameLabel.layer.position.x = frame.midX
                    nameLabel.textColor = .lightGray
                    textView.text = String(message.message.dropFirst(5))
                    textView.textAlignment = .center
                    textView.textColor = .lightGray
                } else if String(message.message.prefix(7)) == "!admin!" {
                    nameLabel.text = "--運営より--\(formattedDate)"
                    nameLabel.textAlignment = .center
                    nameLabel.textColor = .cyan
                    nameLabel.layer.position.x = frame.midX
                    textView.text = String(message.message.dropFirst(7))
                    textView.textAlignment = .center
                    textView.textColor = .cyan
                } else if String(message.message.prefix(12)) == "!privatelog!" {
                    nameLabel.layer.position.x = frame.midX
                    nameLabel.font = UIFont.systemFont(ofSize: 14)
                    nameLabel.textColor = .lightGray
                    textView.text = String(message.message.dropFirst(12))
                    textView.font = UIFont.systemFont(ofSize: 16)
                    textView.textColor = .lightGray
                }
                scrollView.addSubview(nameLabel)
                scrollView.addSubview(textView)
            }
            if index >= 10 {scrollView.contentSize.height += 70}
            let bottom = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.frame.size.height)
            scrollView.setContentOffset(bottom, animated: true)
            init_index += 1
        }
        /*
        let n = countPrivate - init_c_private - 3
        if init_c_private != countPrivate && n > 0{
            for _ in 1...( n ) {
                scrollView.contentSize.height -= 70
            }
            init_c_private = countPrivate
        }
        */
    }
    
    @objc private func copyRoomID(_ sender: UITapGestureRecognizer) {
        if let label = sender.view as? UILabel {
            let roomIDText = label.text?.replacingOccurrences(of: "Room ID: ", with: "")
            UIPasteboard.general.string = roomIDText
            let alert = UIAlertController(title: "roomIDコピー完了", message: "Room ID: \(roomIDText ?? "") がコピーされました", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            if let vc = view?.window?.rootViewController {
                vc.present(alert, animated: true, completion: nil)
            }
        }
    }
    func showMessageInputAlert() {
        let alertController = UIAlertController(title: "Send Message", message: "Enter your message", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Enter message"
            textField.clearButtonMode = .whileEditing
            textField.autocorrectionType = .no
            textField.keyboardType = .default
            textField.returnKeyType = .done
            textField.becomeFirstResponder()
        }
        let sendAction = UIAlertAction(title: "Send", style: .default) { [weak alertController] _ in
            if let message = alertController?.textFields?.first?.text, !message.isEmpty {
                if String(message.prefix(5)) != "!log!" && String(message.prefix(6)) != "!room!" && self.isValidName(message){
                    self.sendMessage(message)
                }else{
                    self.displayErrorLog("このメッセージは送信できません。")
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(sendAction)
        alertController.addAction(cancelAction)
        if let viewController = self.view?.window?.rootViewController {
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    func isValidName(_ name: String) -> Bool {
        return true
        /*
        let pattern = "^[\\p{Hiragana}\\p{Katakana}\\p{Han}a-zA-Z0-9_-]+$"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {return false}
        let range = NSRange(location: 0, length: name.utf16.count)
        return regex.firstMatch(in: name, options: [], range: range) != nil
         */
    }
    // メッセージの送信
    func sendMessage(_ message: String) {
        SendButton.text = "++++send chat メッセージ送信中++++"
        chatBase.sendChatMessage(message: message)
    }
    
    let scrollViewHeight: CGFloat = 750 // 希望の高さ
    let topanchor: CGFloat = 10
    override func didMove(to view: SKView) {
        showText = ShowText(fontcolor: .white, lineHeight: 20, fontName: "Arial", fontSize: 15)
        addChild(showText)
        
        chatBase.deleteOldChats(admin: false)
        super.didMove(to: view)
        DispatchQueue.main.async{ [self] in
            view.addSubview(scrollView)
            // Auto Layout を有効にする
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: view.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                scrollView.heightAnchor.constraint(equalToConstant: scrollViewHeight)
            ])
            scrollView.contentInset.top = 20
            scrollView.contentSize.height = 770
        }
        SendButton = SKLabelNode(text: "++++send chat++++")
        SendButton.fontName = "Arial-BoldMT"
        SendButton.fontSize = 36
        SendButton.name = "SendMessageButton"
        SendButton.fontColor = .white
        SendButton.position = CGPoint(x: frame.midX, y: frame.minY + 10)
        addChild(SendButton)
        
        let BackMenu = SKLabelNode(text: "メニューに戻る")
        BackMenu.fontSize = 20
        BackMenu.fontColor = .white
        BackMenu.name = "BackMenu"
        BackMenu.horizontalAlignmentMode = .left
        BackMenu.position = CGPoint(x: frame.minX + 20, y: frame.minY + 10)
        addChild(BackMenu)
        
    }
    override func willMove(from view: SKView) {
        scrollView.removeFromSuperview()
    }
    private let chatBase = ChatBase() // ChatBaseのインスタンス
    private var chatMessages: [ChatBase.ChatMessage] = [] // ローカルで保持するチャットメッセージ
    var updateInterval: TimeInterval = 3.0
    var lastUpdateTime: TimeInterval = 0
    override func update(_ currentTime: TimeInterval) {
        if currentTime - lastUpdateTime > updateInterval {
            lastUpdateTime = currentTime
            SendButton.text = "++++send chat++++"
            fetchAndUpdateChatMessages()
        }
    }
    private func fetchAndUpdateChatMessages() {
        chatBase.fetchNewChatMessages { [weak self] newMessages in
            guard let self = self else { return }
            self.chatMessages.append(contentsOf: newMessages)
            self.updateChat()
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let node = atPoint(location)
            if node.name == "SendMessageButton" {
                showMessageInputAlert()
            }else if node.name == "BackMenu" {
                let menuScene = MenuScene(size: self.size)
                let transition = SKTransition.fade(withDuration: 1.0)
                self.view?.presentScene(menuScene, transition: transition)
            }
        }
    }
}
