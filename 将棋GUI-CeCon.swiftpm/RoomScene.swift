import SpriteKit
import UIKit

class RoomScene: SKScene {
    var roomID = ""
    var isawait = false
    private var showText: ShowText!
    func displayErrorLog(_ message: String) {showText.addErrorLog(message, in: self)}
    
    //var chatBase = ChatBase()
    func sendChatMessage(message: String) {
        guard let url = URL(string: "\(endpoint)/chat.json") else { return }
        let timestamp = Date().timeIntervalSince1970
        let chatData: [String: Any] = ["name": my_Player_name,"message": message,"timestamp": timestamp]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: chatData)
        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {print("Error sending chat message: \(error.localizedDescription)")
            } else {
                print("Message sent successfully")
            }
        }.resume()
    }
    
    //func displayChatMessage(_ message: String) {showText.addChatLog(message, in: self)}
    
    
    override func didMove(to view: SKView) {
        showText = ShowText(fontcolor: .white, lineHeight: 25, fontName: "Arial", fontSize: 20)
        addChild(showText)
        let MenuBG = SKSpriteNode(imageNamed: "RoomBG")
        MenuBG.position=CGPoint(x: frame.midX, y: frame.midY)
        MenuBG.zPosition = -5
        MenuBG.size = CGSize(width: 1080, height: 810)
        DispatchQueue.main.async {
            self.addChild(MenuBG)
        }
        backgroundColor = .white
        let titleLabel = SKLabelNode(text: "オンラインルーム")
        titleLabel.fontSize = 30
        titleLabel.fontName = "KouzanBrushFontGyousyoOTF"
        titleLabel.fontColor = .black
        titleLabel.position = CGPoint(x: frame.midX, y: frame.height - 100)
        addChild(titleLabel)
        // 部屋作成ボタン
        /*
        createButton(
            text: "マッチング",
            position: CGPoint(x: frame.midX, y: frame.midY + 150),
            size: CGSize(width: 200, height: 50),
            name: "matching"
        )
         */
        createButton(
            text: "部屋を作成・盤面初期化",
            position: CGPoint(x: frame.midX, y: frame.midY + 50),
            size: CGSize(width: 300, height: 50),
            name: "createRoom"
        )
        // 部屋に参加ボタン
        createButton(
            text: "部屋に参加・再加入",
            position: CGPoint(x: frame.midX-200, y: frame.midY - 50),
            size: CGSize(width: 300, height: 50),
            name: "joinRoom"
        )
        createButton(
            text: "前回の部屋\(Crashed_roomID)に入室",
            position: CGPoint(x: frame.midX+200, y: frame.midY - 50),
            size: CGSize(width: 300, height: 50),
            name: "REjoinRoom"
        )
        // 戻るボタン
        createButton(
            text: "戻る",
            position: CGPoint(x: frame.midX, y: frame.midY - 250),
            size: CGSize(width: 200, height: 50),
            name: "back"
        )
        
        if Crashed_roomID != "" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
                self.displayErrorLog("あなたが前回入室した部屋のroomIDはこちらです：\(Crashed_roomID)")
            }
        }
        /*
        roomidtextField = createTextField(
            placeholder: "棋譜情報を貼り付けてください",
            position: CGPoint(x: frame.midX, y: size.height / 2 + 150)
        )
        view.addSubview(self.roomidtextField)*/
    }
    override func willMove(from view: SKView) {
        //roomidtextField.resignFirstResponder() // キーボードを表示
        //roomidtextField.removeFromSuperview()
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
        label.fontSize = 22
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
            if isawait {return}
            if node.name == "matching" {
                print("マッチング")
                //sendChatMessage(message: "rojawew")
                displayErrorLog("作成中")
            }else if node.name == "createRoom" {
                isawait = true
                displayErrorLog("既存の部屋を検索中です。")
                //createNewRoom()
                //checkExistingRoomAndCreateIfNeeded()
                findOrCreateRoom()
            } else if node.name == "joinRoom" {
                isawait = true
                let alert = UIAlertController(title: "部屋番号を入力", message: "", preferredStyle: .alert)
                alert.addTextField { (textField) in
                    textField.placeholder = "部屋番号"
                    textField.clearButtonMode = .whileEditing
                    textField.autocorrectionType = .no
                    textField.keyboardType = .default
                    textField.returnKeyType = .done   
                }
                let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    guard let textField = alert.textFields?.first else { return }
                    let inputText = textField.text ?? ""
                    if inputText == "" {self.isawait=false;return}
                    if inputText.count != 5{self.isawait=false;self.displayErrorLog("roomIDは5桁の半角英数字です。");return}
                    self.displayErrorLog("入力された部屋番号: \(inputText)")
                    self.checkRoomAvailability(roomID: inputText)
                    //self.joinRoom(my_Player_name: my_Player_name, roomID: inputText)
                }
                alert.addAction(okAction)
                self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
                //transitionToGameScene(gameMode: "JoinRoom")
            }else if node.name == "REjoinRoom" {
                if Crashed_roomID == "" {return}
                isawait = true
                displayErrorLog("部屋を検索中です。")
                self.checkRoomAvailability(roomID: Crashed_roomID)
            }else if node.name == "back" {
                isawait = true
                print("メニューに戻ります")
                transitionToMenuScene()
            }
        }
    }
    
    func transitionToGameScene(opposeName:String,gameMode: String) {
        Crashed_roomID = roomID
        if gameMode == "Online_host" || gameMode == "Online_guest"{sendChatMessage(message: "!log!\(my_Player_name)さんがルーム \(roomID) に入室しました。")}
        let gameScene = GameScene(size: self.size)
        gameScene.gameMode = gameMode
        gameScene.NETopposeNAME = opposeName
        gameScene.roomID = roomID
        let transition = SKTransition.fade(withDuration: 1.0)
        self.view?.presentScene(gameScene, transition: transition)
    }
    
    func transitionToMenuScene() {
        let menuScene = MenuScene(size: self.size)
        let transition = SKTransition.fade(withDuration: 1.0)
        self.view?.presentScene(menuScene, transition: transition)
    }
    
    func createRoom(myPlayerName: String,roomID:String) {
        let firebaseURL = "\(endpoint)/room/\(roomID).json"
        let roomData: [String: Any] = [
            "sente": myPlayerName,
            "gote": "NoneName_Player",
            "board": initboard,
            "sHave": [""],
            "gHave": [""],
            "move": "",
            "timestamp": Date().timeIntervalSince1970,
            "countTEBAN": 0
        ]
        // データをJSONに変換
        guard let jsonData = try? JSONSerialization.data(withJSONObject: roomData, options: []) else {
            displayErrorLog("データのJSON変換に失敗しました")
            isawait = false
            return
        }
        // HTTPリクエストを作成
        var request = URLRequest(url: URL(string: firebaseURL)!)
        request.httpMethod = "PUT" // Firebaseに新しいデータを作成
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        // リクエストを送信
        let task = URLSession.shared.dataTask(with: request) { [self] data, response, error in
            if let error = error {
                displayErrorLog("エラーが発生しました: \(error.localizedDescription)")
                print("エラーが発生しました: \(error.localizedDescription)")
                isawait = false
                return
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                displayErrorLog("部屋を作成しました: \(self.roomID)")
                DispatchQueue.main.sync {
                    self.sendChatMessage(message:"!privatelog!\(my_Player_name)さんがルームを作成しました。下の文字をタップしてroomIDをコピーしてください")
                    self.sendChatMessage(message: "!room!\(roomID)")
                }
            } else {
                displayErrorLog("部屋の作成に失敗しました")
            }
        }
        task.resume()
    }
    /*
    func joinRoom(myPlayerName: String, roomID: String) {
        let firebaseURL = "\(endpoint)/room/\(roomID).json"
        var request = URLRequest(url: URL(string: firebaseURL)!)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("エラーが発生しました: \(error.localizedDescription)")
                self.displayErrorLog("エラーが発生しました: \(error.localizedDescription)")
                return
            }
            guard let data = data, 
                    let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                print("部屋データの取得に失敗しました")
                self.displayErrorLog("部屋が存在しません: \(roomID)")
                self.isawait = false
                return
            } 
            if json.isEmpty {
                self.displayErrorLog("部屋が存在しません: \(roomID)")
                self.isawait = false
                return
            }
            self.displayErrorLog("部屋に参加します")
            self.roomID = roomID
            // 部屋が存在する場合、goteキーにデータを保存
            var updateRequest = URLRequest(url: URL(string: firebaseURL)!)
            updateRequest.httpMethod = "PATCH" // 部分的にデータを更新
            updateRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let updateData: [String: Any] = [
                "gote": myPlayerName
            ]
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: updateData, options: []) else {
                print("データのJSON変換に失敗しました")
                return
            }
            
            updateRequest.httpBody = jsonData
            
            let updateTask = URLSession.shared.dataTask(with: updateRequest) { _, updateResponse, updateError in
                if let updateError = updateError {
                    print("エラーが発生しました: \(updateError.localizedDescription)")
                    return
                }
                
                if let httpResponse = updateResponse as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("部屋に参加しました: \(roomID)")
                    self.transitionToGameScene(gameMode: "Online_guest")
                } else {
                    print("部屋への参加に失敗しました")
                }
            }
            updateTask.resume()
        }
        task.resume()
    }
     */
    func findOrCreateRoom() {
        let urlString = "\(endpoint)/room.json"
        guard let url = URL(string: urlString) else {print("Invalid URL.");return}
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                //print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                
                return
            }
            do {
                // JSONの解析
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // JSONが辞書の場合
                    var foundRoomID: String? = nil
                    for (roomID, roomData) in json {
                        if let roomInfo = roomData as? [String: Any],
                           let sente = roomInfo["sente"] as? String,
                           sente == my_Player_name {
                            foundRoomID = roomID
                            break
                        }
                    }
                    if let roomID = foundRoomID {
                        //print("既存のルームID: \(roomID)")
                        self.roomID = roomID
                        self.displayErrorLog("既存のルームIDで入室します\(roomID)")
                        self.createRoom(myPlayerName: my_Player_name, roomID: roomID)
                        self.transitionToGameScene(opposeName: "not found", gameMode: "Online_host")
                    } else {
                        print("新規ルーム作成")
                        self.createNewRoom()
                    }
                } else if let jsonString = String(data: data, encoding: .utf8), jsonString == "null" {
                    self.displayErrorLog("作成済みの部屋がありませんでした")
                    self.createNewRoom()
                } else {
                    self.displayErrorLog("予期しないデータ形式です。")
                    self.isawait = false
                }
            } catch {
                if let responseString = String(data: data, encoding: .utf8) {
                    //print("Response: \(responseString)")
                    if responseString == "null" {
                        self.createNewRoom()
                        return
                    }else{
                        self.displayErrorLog("エラーが発生しました。")
                        print("\(error)")
                        self.isawait = false
                    }
                }else{
                    print("Error decoding JSON: \(error)")
                }
            }
        }
        task.resume()
    }
    /*
    func checkExistingRoomAndCreateIfNeeded() {
        let urlString = "\(endpoint)/room.json" // /roomディレクトリ全体を取得
        displayErrorLog("既存の部屋を検索中です　しばらくお待ち下さい")
        guard let url = URL(string: urlString) else {
            print("Invalid URL.")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [self] data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
                if responseString == "null" {createNewRoom();return}
            }
            do {
                if let rooms = try JSONSerialization.jsonObject(with: data, options: []) as? [String: [String: Any]] {
                    // 各部屋を確認
                    for (existingRoomID, roomData) in rooms {
                        if let sente = roomData["sente"] as? String, sente == my_Player_name {
                            // 一致する部屋があればそのroomIDを使用
                            roomID = existingRoomID
                            displayErrorLog("既存の部屋 \(roomID) を使用します。")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                self.transitionToGameScene(opposeName: "not found",gameMode: "Online_host")
                            }
                            return
                        }
                    }
                }
                // 一致する部屋がなかった場合、新たに部屋を作成
                self.createNewRoom()
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
        
        task.resume()
    }
    */
    // 新しい部屋を作成する処理
    func createNewRoom() {
        roomID = String((0..<5).map { _ in "ABCDEFGHJKLMNPRSTUVWXYZ2345678".randomElement()! })
        displayErrorLog("部屋を作成しました")
        UIPasteboard.general.string = roomID
        displayErrorLog("\(roomID)で、クリップボードに多分保存されています。")
        createRoom(myPlayerName: my_Player_name, roomID: roomID)
        
        // 部屋作成後にゲームシーンに遷移
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.transitionToGameScene(opposeName: "not found",gameMode: "Online_host")
        }
    }
    
    func checkRoomAvailability(roomID: String) {
        let urlString = "\(endpoint)/room/\(roomID).json"
        guard let url = URL(string: urlString) else {print("Invalid URL.");return}
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                //print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                self.displayErrorLog("部屋が見つかりません")
                self.isawait = false
                return
            }
            do {
                // JSONの解析
                self.roomID = roomID
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // JSONが辞書の場合
                    if let sente = json["sente"] as? String, let gote = json["gote"] as? String {
                        print("sente: \(sente)")
                        print("gote: \(gote)")
                        if sente == my_Player_name {
                            self.displayErrorLog("ルームホストが再入場します。\(roomID)")
                            self.transitionToGameScene(opposeName: "\(gote)",gameMode: "Online_host_RE")
                        }else if gote == my_Player_name || gote == "NoneName_Player"{
                            self.displayErrorLog("部屋に参加しました\(roomID)")
                            self.transitionToGameScene(opposeName: "\(sente)",gameMode: "Online_guest")
                        }else{
                            self.displayErrorLog("先：\(sente)対後：\(gote)の試合を観戦します")
                            self.transitionToGameScene(opposeName: "\(sente)対\(gote)",gameMode: "Online_viewer")
                        }
                    } else {//新規
                        print("部屋に参加しました: \(roomID)")
                        self.transitionToGameScene(opposeName: "not found", gameMode: "Online_guest")
                    }
                } else if let jsonString = String(data: data, encoding: .utf8), jsonString == "null" {
                    // JSONがnullの場合
                    self.displayErrorLog("部屋がありません")
                    self.isawait = false
                } else {
                    self.displayErrorLog("予期しないデータ形式です。")
                    self.isawait = false
                }
            } catch {
                self.displayErrorLog("部屋が見つかりません")
                self.isawait = false
                //print("Error decoding JSON: \(error)")
            }
        }
        
        task.resume()
    }
}


/*

// UITextFieldDelegateの拡張
extension RoomScene: UITextFieldDelegate {
    func textFieldShouldReturn(_ roomidtextField: UITextField) -> Bool {
        roomidtextField.resignFirstResponder()
        //print("入力されたテキスト: \(roomidtextField.text ?? "")")
        joinRoom(myPlayerName: my_Player_name, roomID: roomidtextField.text ?? "")
        return true
    }
}
*/
