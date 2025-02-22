import SpriteKit
import Foundation

class ProfileScene: SKScene {
    private var titleLabel: SKLabelNode!
    private var nameLabel: SKLabelNode!
    private var changeNameButton: SKSpriteNode!
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
        
        // タイトルラベル
        titleLabel = SKLabelNode(text: "プロフィール")
        titleLabel.fontSize = 36
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 200)
        addChild(titleLabel)
        
        // 名前ラベル
        nameLabel = SKLabelNode(text: "名前: \(my_Player_name)")
        nameLabel.fontSize = 40
        nameLabel.fontName = "Helvetica"
        nameLabel.fontColor = .white
        nameLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 100)
        addChild(nameLabel)
        
        // 名前変更ボタン
        changeNameButton = SKSpriteNode(color: .lightGray, size: CGSize(width: 150, height: 50))
        changeNameButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 100)
        changeNameButton.name = "changeNameButton"
        addChild(changeNameButton)
        
        // ボタンラベル
        let buttonLabel = SKLabelNode(text: "名前変更")
        buttonLabel.fontSize = 36
        buttonLabel.fontColor = .black
        buttonLabel.fontName = "KouzanBrushFontGyousyoOTF"
        buttonLabel.position = .zero
        buttonLabel.verticalAlignmentMode = .center
        buttonLabel.name = "changeNameButton"
        changeNameButton.addChild(buttonLabel)
        
        
        let BackToMenu = SKLabelNode(text: "メニューへ戻る")
        BackToMenu.fontName = "KouzanBrushFontGyousyoOTF"
        BackToMenu.name = "Menu"
        BackToMenu.fontSize = 36
        BackToMenu.fontColor = .white
        BackToMenu.position = CGPoint(x: size.width / 2, y: size.height / 2 - 300)
        addChild(BackToMenu)
        
    }
    
    override func willMove(from view: SKView) {
        titleLabel.removeFromParent()
        nameLabel.removeFromParent()
        changeNameButton.removeFromParent()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        // 名前変更ボタンが押された場合
        if touchedNode.name == "changeNameButton" {
            showChangeNameAlert()
        }else if touchedNode.name == "Menu" {
            let menuScene = MenuScene(size: self.size)
            self.view?.presentScene(menuScene, transition: SKTransition.fade(withDuration: 1.0))
        }
    }
    
    private func showChangeNameAlert() {
        guard let view = view else { return }
        let alertController = UIAlertController(title: "名前変更", message: "新しい名前を入力してください。", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.clearButtonMode = .whileEditing
            textField.autocorrectionType = .no
            textField.keyboardType = .default
            textField.returnKeyType = .done
            textField.placeholder = "新しい名前"
            textField.text = my_Player_name
            //DispatchQueue.main.async {textField.becomeFirstResponder()}
        }
        
        let confirmAction = UIAlertAction(title: "名前を変更", style: .default) { _ in
            if let newName = alertController.textFields?.first?.text, !newName.isEmpty {
                if newName.count >= 15 {self.displayErrorLog("名前が長すぎます。15文字以内としてください。");return}
                if newName.range(of: "[/\\\\:*?\"<>|]", options: .regularExpression) != nil {self.displayErrorLog("特殊文字は使えません")}
                if newName == "Roughfts" {self.displayErrorLog("管理者を名乗ることはできません。");return}
                if !self.isValidName(newName) {self.displayErrorLog("特殊記号・バグ文字は使えません。");return}
                if my_Player_name == "NoneName_Player" {
                    self.savePlayerToCloud(playerName: newName, score: 0)
                    self.displayErrorLog("名前がクラウドに保存されました。\(newName)")
                    my_Player_name = newName
                }else{
                    self.changePlayerName(currentName: my_Player_name, newName: newName)
                }
                self.nameLabel.text = "名前: \(my_Player_name)"
            }
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        DispatchQueue.main.async {
            view.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        }   
    }
    
    
    
    func isValidName(_ name: String) -> Bool {
        let pattern = "^[\\p{Hiragana}\\p{Katakana}\\p{Han}a-zA-Z0-9_-]+$"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {return false}
        let range = NSRange(location: 0, length: name.utf16.count)
        return regex.firstMatch(in: name, options: [], range: range) != nil
    }
    
    
    
    func savePlayerToCloud(playerName: String, score: Int) {
        // playersフォルダ内の自分の名前をキーにしたURLを作成
        let urlString = "\(endpoint)/players/\(playerName).json"
        guard let url = URL(string: urlString) else {
            print("Invalid URL.")
            return
        }
        let playerData: [String: Any] = ["score": score]
        do {
            // JSONデータに変換
            let jsonData = try JSONSerialization.data(withJSONObject: playerData, options: [])
            
            // URLリクエストを作成
            var request = URLRequest(url: url)
            request.httpMethod = "PUT" // 名前をキーにしてデータを上書き保存
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            // HTTPリクエストを送信
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error saving player data: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Unexpected response.")
                    return
                }
                if httpResponse.statusCode == 200 {
                    print("Player \(playerName)'s data saved successfully.")
                } else {
                    print("Failed to save data. HTTP status code: \(httpResponse.statusCode)")
                }
            }
            task.resume()
        } catch {
            print("Error creating JSON data: \(error.localizedDescription)")
        }
    }
    
    
    
    func changePlayerName(currentName: String, newName: String) {
        // playersフォルダのURLを作成
        let playersURLString = "\(endpoint)/players.json"
        guard let playersURL = URL(string: playersURLString) else {
            print("Invalid URL.")
            return
        }
        
        // playersフォルダを取得
        let task = URLSession.shared.dataTask(with: playersURL) { data, response, error in
            if let error = error {
                print("Error fetching players: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data returned from server.")
                return
            }
            
            do {
                // playersのデータをデコード
                let players = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
                
                // 新しい名前が既に存在する場合
                if players.keys.contains(newName) {
                    print("The name '\(newName)' is already taken.")
                    self.displayErrorLog("名前は既に使用されています")
                    return
                }
                
                // 現在の名前のデータを取得
                guard let currentData = players[currentName] as? [String: Any] else {
                    self.displayErrorLog("\(currentName)はクラウドに存在しません")
                    return
                }
                // スコアを保持
                let score = currentData["score"] ?? 0
                
                // 新しい名前にデータをコピー
                let newPlayerURLString = "\(endpoint)/players/\(newName).json"
                guard let newPlayerURL = URL(string: newPlayerURLString) else { return }
                
                var newRequest = URLRequest(url: newPlayerURL)
                newRequest.httpMethod = "PUT"
                newRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let newData: [String: Any] = ["score": score]
                newRequest.httpBody = try JSONSerialization.data(withJSONObject: newData, options: [])
                
                URLSession.shared.dataTask(with: newRequest) { _, _, newError in
                    if let newError = newError {
                        print("Error saving new name: \(newError.localizedDescription)")
                        return
                    }
                    // 古い名前のデータを削除
                    let oldPlayerURLString = "\(endpoint)/players/\(currentName).json"
                    guard let oldPlayerURL = URL(string: oldPlayerURLString) else { return }
                    
                    var deleteRequest = URLRequest(url: oldPlayerURL)
                    deleteRequest.httpMethod = "DELETE"
                    
                    URLSession.shared.dataTask(with: deleteRequest) { _, _, deleteError in
                        if let deleteError = deleteError {
                            print("Error deleting old name: \(deleteError.localizedDescription)")
                            return
                        }
                        
                        print("Name changed from '\(currentName)' to '\(newName)' successfully.")
                        self.displayErrorLog("名前は適切に\(newName)へ変更されました。")
                        my_Player_name = newName
                        self.nameLabel.text = "名前: \(my_Player_name)"
                    }.resume()
                }.resume()
            } catch {
                print("Error decoding players data: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    

    
}
