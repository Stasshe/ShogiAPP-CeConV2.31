//2.30.d
import SpriteKit
import UIKit
import Foundation

class GameScene: SKScene {
    private var showText: ShowText!
    func displayErrorLog(_ message: String) {showText.addErrorLog(message, in: self)}
    func displayChat(_ message: String) {showText.addChatLog(message, in: self)}
    var NET_IAM = "G"
    var isonline = false
    var OpposeNameL: SKLabelNode!
    var roomID: String = ""
    var NETopposeNAME = ""
    var Move_to = ""
    var sente = ""
    var gote = ""
    var NETismy_turn = true
    var gameMode: String = ""
    var ended = false
    var ended_max_teban = 10000
    var board: [[String]] = initboard
    var previous_board: [[String]] = initboard
    var AIbattle = false
    var isCheck_moveAble = true
    var AIerror = false
    var aiCheckbox: UISwitch!
    var movementCheckCheckbox: UISwitch!
    var saveHistory: UISwitch!
    var inputTextField: UITextField!
    var AIbestmove = ""
    var AI_playerselect_S_or_G = "S"
    //var AIscore_cp = 0
    var AIthinking_time = 5000
    var selectedPiece: Piece?
    var countTEBAN: Int = 0 {
        didSet {
            teban_label.text = String(countTEBAN + Online_not_enough_data_teban)
        }
    }
    var teban_label: SKLabelNode!
    var pieceControlManager = PieceControlManager()
    var ableMove:[String] = [""]
    var captured_validCells: [String] = []
    var pieces: [Piece] = []  // 盤面上の駒を管理する配列
    var pieceNodes: [SKNode] = []  // 駒のスプライトノードを管理する配列
    let boardSize: CGFloat = 585  // 盤面のサイズ (正方形)
    let cellSize: CGFloat = 65   // 1マスのサイズ (正方形)
    let number_font_size:CGFloat = 20
    let board_offsetY:CGFloat = -30
    let d_board_numlabel:CGFloat = 25
    var highlightNode: SKShapeNode?
    var move_ableNode: [SKShapeNode] = [] 
    var thinkingLabel: SKLabelNode!
    var is_selecting_piece = false
    var selecting_captured = ""
    var selected_pos_piece = ""
    var selected_name_piece = ""
    var promote_to_pos = ""
    var shouldawait = false
    var AIisthinking = false
    var flipped = false
    let promotablePieces = ["歩","銀", "桂", "香", "飛", "角"]
    var promotionCompletion: ((Bool) -> Void)?
    var pre_teban = "S"
    var now_Player = "S" { // 初期プレイヤー（先手）
        didSet {
            S_or_G.text = now_Player == "S" ? "先手の番です" : "後手の番です"
            if pre_teban != (now_Player == "S" ? "G" : "S") {
                if pieceControlManager.isOute(board: board, nowPlayer: now_Player == "S" ? "G" : "S") {oute()}
                pre_teban = now_Player == "S" ? "G" : "S"
            }
            if AIbattle {
                DispatchQueue.main.async {
                    self.updateBoard_for_AI()
                }
            }
        } 
    }
    var shogiMoveParser: ShogiMoveParser!
    var S_or_G: SKLabelNode!
    var flip_board: SKLabelNode!
    var sHaveNodes: [SKNode] = []
    var gHaveNodes: [SKNode] = []
    var history_board:[[[String]]] = [initboard]
    var H_Shave:[[String]] = [[""]]
    var H_Ghave:[[String]] = [[""]]
    var H_P:[String] = ["S"]
    var issaveHistory = true
    var sHave: [String] = []
    var gHave: [String] = []
    var currentPlayer: String = "S"
    let komaSpriteMapping: [String: [Int]] = [
        "金-S":[0,0,60,64],"と-S":[60,0,60,64],"歩-S":[120,0,60,64],"王-G":[180,0,60,64],"角-G":[240,0,60,64],"龍-G":[300,0,60,64],"金-G":[360,0,60,64],"飛-S":[420,0,60,64],"全-G":[480,0,60,64],"圭-G":[540,0,60,64],"銀-G":[600,0,60,64],"歩-G":[660,0,60,64],"香-S":[720,0,60,64],"馬-G":[780,0,60,64],"角-S":[840,0,60,64],"圭-S":[900,0,60,64],"桂-G":[960,0,60,64],"桂-S":[1020,0,60,64],"杏-G":[1080,0,60,64],"香-G":[1140,0,60,64],"龍-S":[1200,0,60,64],"全-S":[1260,0,60,64],"馬-S":[1320,0,60,64],"と-G":[1380,0,60,64],"飛-G":[1440,0,60,64],"銀-S":[1500,0,60,64],"王-S":[1560,0,60,64],"杏-S":[1620,0,60,64]
    ]
    let spriteSheetName = "koma.png"
    
    
    func drawBoard() {
        let board = SKSpriteNode(imageNamed: "wooden_texture")  // wooden_textureという名前の画像を使用
        board.size = CGSize(width: boardSize, height: boardSize)  // 盤面のサイズに合わせる
        board.position = CGPoint(x: frame.midX, y: frame.midY+board_offsetY)  // 画面の中央に配置
        self.addChild(board)
        for row in 0..<9 {
            for col in 0..<9 {
                let cell = SKShapeNode(rectOf: CGSize(width: cellSize, height: cellSize))
                cell.position = CGPoint(x: board.position.x + CGFloat(col - 4) * cellSize,
                                        y: board.position.y + CGFloat(4 - row) * cellSize)
                cell.strokeColor = .black //line color
                cell.lineWidth = 2  // pen-width
                cell.fillColor = .clear//(row + col) % 2 == 0 ? .lightGray : .darkGray// 交互に色を変える
                self.addChild(cell)
            }
        }
        addLabels()
    }
    
    
    func updateBoard_for_AI(){
        if sHave.contains("王") || gHave.contains("王") {thinkingLabel.isHidden = true;return}
        if now_Player != AI_playerselect_S_or_G && !AIisthinking {
            AIisthinking = true
            movementCheckCheckbox.isEnabled = false
            AIerror = false
            shouldawait = true
            board = flipped ? flipBoard(board: board) : board
            let ai = ConnectAI()
            let sfen = ai.convertToSFEN(board: board,shave: sHave,ghave: gHave,countTEBAN: String(countTEBAN+1),player: now_Player == "G" ? "w" : "b")
            print("airequest\(sfen)")
            //↑SとGが入れ替わったあとだから逆にする? b=gote w=sente  sfenの手番は、さっき指した人の方を書く
            if countTEBAN > 15 {AIthinking_time = 10000}
            RequestAI(byoyomi: AIthinking_time, position: sfen)
        }
    }
    
    func RequestAI(byoyomi: Int,position: String) {
        aiCheckbox.isEnabled = false
        movementCheckCheckbox.isEnabled = false
        saveHistory.isEnabled = false
        repeatDotsUpdate(dotCount: 0)
        let urlString = "https://17xn1ovxga.execute-api.ap-northeast-1.amazonaws.com/production/gikou?byoyomi=\(byoyomi)&position=sfen \(position)"
        if !AIbattle {movementCheckCheckbox.isEnabled = true;saveHistory.isEnabled = true;return}
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                if let data = data {
                    let result = self.extractBestMoveAndScore(from: data)
                    self.AIbestmove = result.bestMove!
                    self.AImove()
                    /*
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Response: \(responseString)")
                    }
                    print("result:",self.AIbestmove,0)
                     */
                }
            }
            task.resume()
        }
    }
    
    
    func extractBestMoveAndScore(from jsonResponse: Data) -> (bestMove: String?, scoreCP: Int?) {
        do {
            let response = try JSONSerialization.jsonObject(with: jsonResponse, options: []) as? [String: Any]
            // 必要なデータがレスポンスに含まれているか確認
            guard let response = response else {print("Invalid JSON response");return (nil, nil)}
            guard let bestMove = response["bestmove"] as? String else {
                print("bestmove not found")
                aiCheckbox.isOn = false
                AIbattle = false
                AIerror = true
                return ("", 0)
            } 
            return(bestMove,0)
        } catch {
            print("Error parsing JSON: \(error.localizedDescription)")
            AIerror = true
            return ("", 0)
        }
    }
    
    
    func reversePiece(pieceCode: String) -> String {
        switch pieceCode {
        case "l": return "香-G"
        case "n": return "桂-G"
        case "s": return "銀-G"
        case "g": return "金-G"
        case "k": return "王-G"
        case "r": return "飛-G"
        case "b": return "角-G"
        case "p": return "歩-G"
            
        case "L": return "香-S"
        case "N": return "桂-S"
        case "S": return "銀-S"
        case "G": return "金-S"
        case "K": return "王-S"
        case "R": return "飛-S"
        case "B": return "角-S"
        case "P": return "歩-S"
        default: return ""
        }
    }
    
    func AImove(){
        if AIerror {thinkingLabel.text = "AIエラー";now_Player = now_Player == "S" ? "G" : "S";countTEBAN += 1;return}
        if let result = convertMove(AIbestmove: AIbestmove) {
            print("from: \(result.from), to: \(result.to), qualifier: \(result.qualifier)") // 出力: from: 23, to: 24
            shogiMoveParser.movePiece(board: &board, from:result.from, to: result.to, currentPlayer: now_Player, sHave: &sHave, gHave: &gHave, qualifier: result.qualifier,save_kif: issaveHistory,moveable: isCheck_moveAble)
            checkended()
            //print("AI board_lists ended")
            let firstDigit = result.to.first.flatMap({ Int(String($0)) }) ?? 1
            let secondDigit = result.to.last.flatMap({ Int(String($0)) }) ?? 1
            let ai_move_position = CGPoint(
                x: frame.midX + CGFloat(5 - firstDigit) * cellSize,
                y: frame.midY + CGFloat(5 - secondDigit) * cellSize + board_offsetY
            )
            let aihighlightNode = SKShapeNode(rectOf: CGSize(width: cellSize, height: cellSize))
            aihighlightNode.position = ai_move_position
            aihighlightNode.fillColor = .red
            aihighlightNode.alpha = 0.3
            aihighlightNode.strokeColor = .clear
            aihighlightNode.zPosition = 10
            override_kif()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if self.issaveHistory {
                    self.history_board.append(self.board)
                    self.H_Shave.append(self.sHave)
                    self.H_Ghave.append(self.gHave)
                    self.H_P.append(self.now_Player == "S" ? "G" : "S")
                }
                self.board = self.flipped ? self.flipBoard(board: self.board) : self.board
                self.placePieces()
                self.drawCapturedPieces()
                self.now_Player = self.now_Player == "S" ? "G" : "S"
                self.countTEBAN += 1
                self.shouldawait = false
                self.AIisthinking = false
                self.thinkingLabel.text = "待機中"
                self.addChild(aihighlightNode)
                let fadeOut = SKAction.fadeOut(withDuration: 0.8) // フェードアウトに1秒
                let remove = SKAction.removeFromParent()         // ノードを削除
                let sequence = SKAction.sequence([fadeOut, remove]) // フェードアウト後に削除
                aihighlightNode.run(sequence)
            }
        }
    }
    
    //var aithinked: TimeInterval = 0
    func convertMove(AIbestmove: String) -> (from: String, to: String, qualifier: String)? {
        let coordinateMap: [Character: String] = ["a": "1", "b": "2", "c": "3", "d": "4", "e": "5", "f": "6", "g": "7", "h": "8", "i": "9"]
        if AIbestmove.contains("*") {
            let chars = Array(AIbestmove)
            let from = String(reversePiece(pieceCode: String(chars[0])).prefix(1))
            guard let toRow = coordinateMap[chars[3]] else { return nil } // 列(a~i)
            let to = "\(chars[2])\(toRow)" // 列+行
            print(from,"convert move ******",to)
            return (from, to, "打")
        }
        // 4文字の通常の指し手の場合
        if AIbestmove.count == 4 || (AIbestmove.count == 5 && AIbestmove.hasSuffix("+")) {
            let chars = Array(AIbestmove)   
            // 末尾が"+"の場合
            let isPromotion = AIbestmove.hasSuffix("+")
            let length = isPromotion ? 5 : 4
            guard chars.count == length else { return nil } // 必要条件チェック
            let fromColumn = chars[0] // 例: 8
            let fromRow = chars[1] // 例: c
            let toColumn = chars[2] // 例: 7
            let toRow = chars[3] // 例: d
            guard let fromRowNumber = coordinateMap[fromRow], let toRowNumber = coordinateMap[toRow] else { return nil }
            let from = "\(fromColumn)\(fromRowNumber)"
            let to = "\(toColumn)\(toRowNumber)"
            let qualifier = isPromotion ? "成" : ""
            return (from, to, qualifier)
        }
        return nil
    }    
    
    override func didMove(to view: SKView) {
        showText = ShowText(fontcolor: .black, lineHeight: 20, fontName: "Arial", fontSize: 20)
        addChild(showText)
        //super.didMove(to: view)
        shogiMoveParser = ShogiMoveParser(board: board, sHave: sHave, gHave: gHave)
        drawBoard()
        placePieces()
        let yoffset_left_announcer: CGFloat = 50
        S_or_G = SKLabelNode(text: "先手の番です")
        S_or_G.fontSize = 40
        S_or_G.fontName = "KouzanBrushFontGyousyoOTF"
        S_or_G.fontColor = .red
        S_or_G.position = CGPoint(x: frame.minX+130, y: frame.midY + yoffset_left_announcer)
        flip_board = SKLabelNode(text: "盤面を反転")
        flip_board.fontSize = 40
        flip_board.fontName = "KouzanBrushFontGyousyoOTF"
        flip_board.fontColor = .black
        flip_board.name = "flip"
        flip_board.position = CGPoint(x: frame.minX + 130, y: frame.midY - 100 + yoffset_left_announcer)
        // 思考中のラベルを作成
        thinkingLabel = SKLabelNode(text: "待機中")
        thinkingLabel.fontName = "KouzanBrushFontGyousyoOTF"
        thinkingLabel.fontColor = .magenta
        thinkingLabel.fontSize = 36
        thinkingLabel.position = CGPoint(x: 20, y: size.height - 100)  // 左上に配置
        thinkingLabel.horizontalAlignmentMode = .left
        thinkingLabel.verticalAlignmentMode = .top
        if !AIbattle {thinkingLabel.isHidden = true}
        teban_label = SKLabelNode(text: String(countTEBAN))
        teban_label.fontName = "KouzanBrushFontGyousyoOTF"
        teban_label.fontSize = 24
        teban_label.position = CGPoint(x: size.width - 120+15, y: size.height / 2 - 180)
        let RoomIDlabel = SKLabelNode(text: String(roomID))
        RoomIDlabel.fontName = "Arial-BoldMT"
        RoomIDlabel.fontSize = 36
        RoomIDlabel.fontColor = .black
        RoomIDlabel.horizontalAlignmentMode = .right
        RoomIDlabel.position = CGPoint(x: frame.maxX - 50, y: frame.midY)
        addChild(RoomIDlabel)
        let resetButton = SKLabelNode(text: "初期状態に戻す")
        resetButton.fontName = "KouzanBrushFontGyousyoOTF"
        resetButton.fontSize = 30
        resetButton.name = "reset"
        resetButton.horizontalAlignmentMode = .left
        resetButton.fontColor = .black
        resetButton.position = CGPoint(x: frame.minX+30,y:frame.maxY-50)
        let BackMenu = SKLabelNode(text: "メニューに戻る")
        BackMenu.fontName = "KouzanBrushFontGyousyoOTF"
        BackMenu.fontSize = 30
        BackMenu.name = "BackMenu"
        BackMenu.horizontalAlignmentMode = .left
        BackMenu.fontColor = .black
        BackMenu.position = CGPoint(x: frame.minX+30,y:frame.midY-170 + yoffset_left_announcer)
        addChild(BackMenu)
        if String(gameMode.prefix(6)) == "Online"{
            let sendMessage = SKLabelNode(text: "メッセージを送る")
            sendMessage.fontName = "KouzanBrushFontGyousyoOTF"
            sendMessage.fontSize = 30
            sendMessage.name = "sendMessage"
            sendMessage.horizontalAlignmentMode = .center
            sendMessage.fontColor = .black
            sendMessage.position = CGPoint(x: frame.minX+120,y:frame.midY-190)
            addChild(sendMessage)
        }
        let CopyBoard_to_clipboard = SKLabelNode(text: "棋譜情報コピー")
        CopyBoard_to_clipboard.fontName = "KouzanBrushFontGyousyoOTF"
        CopyBoard_to_clipboard.fontSize = 25
        CopyBoard_to_clipboard.name = "CopyBoard_to_clipboard"
        CopyBoard_to_clipboard.horizontalAlignmentMode = .right
        CopyBoard_to_clipboard.zPosition = 20
        CopyBoard_to_clipboard.fontColor = .black
        CopyBoard_to_clipboard.position = CGPoint(x: frame.maxX-10,y:frame.maxY-180)
        
        let kifinputL = SKLabelNode(text: "棋譜情報を貼り付け")
        kifinputL.fontName = "KouzanBrushFontGyousyoOTF"
        kifinputL.fontSize = 25
        kifinputL.name = "kifinputL"
        kifinputL.fontColor = .black
        kifinputL.horizontalAlignmentMode = .right
        kifinputL.position = CGPoint(x: frame.maxX-10,y:frame.maxY-250)
        let backButton = SKLabelNode(text: "◀︎")
        backButton.position = CGPoint(x: size.width - 120 - 30, y: size.height / 2 - 180)
        backButton.name = "back"
        let forButton = SKLabelNode(text: "▶︎")
        forButton.position = CGPoint(x: size.width - 80 + 30, y: size.height / 2 - 180)
        forButton.name = "for"
        aiCheckbox = createCheckbox(labelText: "AI", position: CGPoint(x: size.width - 60, y: size.height / 2 + 30), action: #selector(aiCheckboxChanged(_:)))
        if AIbattle{aiCheckbox.isOn = true}
        movementCheckCheckbox = createCheckbox(labelText: "駒の動きチェック", position: CGPoint(x: size.width - 60, y: size.height / 2 - 30), action: #selector(movementCheckCheckboxChanged(_:)))
        movementCheckCheckbox.isOn = true
        saveHistory = createCheckbox(labelText: "棋譜履歴を保存", position: CGPoint(x: size.width - 60, y: size.height / 2 + 90), action: #selector(saveHistoryChanged(_ :)))
        saveHistory.isOn = true
        /*
         inputTextField = createTextField(
         placeholder: "棋譜情報を貼り付けてください",
         position: CGPoint(x: frame.maxX - 140, y: frame.midY - 320)
         )*/
        isonline = String(gameMode.prefix(6)) == "Online" ? true : false
        if isonline{
            shouldawait = true
            print("gameMode: \(gameMode)")
            if gameMode == "Online_guest" {
                updateGote()
                NETismy_turn = false
                //now_Player = "G"
                flipped = true
                NET_IAM = "G"
                //ResponseNET()
            }else if gameMode == "Online_host_RE" {//ホスト新規・再入場
                NET_IAM = "S"
                NETismy_turn = false
                ResponseNET()
            }else if gameMode == "Online_viewer"{
                NET_IAM = "V"
                NETismy_turn = false
                //ResponseNET()
            }else{
                initNET = 1
                NET_IAM = "S"
            }
            
            Online()
            OpposeNameL = SKLabelNode(text: NETopposeNAME)
            OpposeNameL.fontName = "Arial-BoldMT"
            OpposeNameL.fontSize = 20
            OpposeNameL.fontColor = .black
            OpposeNameL.horizontalAlignmentMode = .right
            OpposeNameL.position = CGPoint(x: frame.maxX - 20,y: frame.midY - 100)
            addChild(OpposeNameL)
        }
        self.setupTatamiBackground()
        // シーンに追加
        DispatchQueue.main.async {
            self.addChild(self.S_or_G)
            self.addChild(self.teban_label)
            self.addChild(CopyBoard_to_clipboard)
            if self.gameMode == "Online_viewer" {self.addChild(self.flip_board)}
            if self.gameMode == "Solo" {
                self.addChild(self.flip_board)
                self.addChild(self.thinkingLabel)
                self.addChild(resetButton)
                self.addChild(backButton)
                self.addChild(forButton)
                self.addChild(kifinputL)
                //view.addSubview(self.inputTextField)
                view.addSubview(self.aiCheckbox)
                view.addSubview(self.movementCheckCheckbox)
                view.addSubview(self.saveHistory)
            }
        }
    }
    
    
    func repeatDotsUpdate(dotCount: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.AIisthinking {
                let newDotCount = (dotCount + 1) % 4
                self.thinkingLabel.text = "思考中" + String(repeating: ".", count: newDotCount)           
                self.repeatDotsUpdate(dotCount: newDotCount)
            }else{
                self.aiCheckbox.isEnabled = true
                self.saveHistory.isEnabled = true
                self.movementCheckCheckbox.isEnabled = true
            }
        }
    }
    
    
    
    override func willMove(from view: SKView) {
        for label in switchlabel {label.removeFromSuperview()}
        switchlabel.removeAll()
        aiCheckbox.removeFromSuperview()
        movementCheckCheckbox.removeFromSuperview()
        saveHistory.removeFromSuperview()
        aiCheckbox = nil
        movementCheckCheckbox = nil
        saveHistory = nil
    }
    var switchlabel: [UILabel] = []
    private func createCheckbox(labelText: String, position: CGPoint, action: Selector) -> UISwitch {
        let switchControl = UISwitch()
        switchControl.addTarget(self, action: action, for: .valueChanged)
        switchControl.frame.origin = CGPoint(x: position.x, y: position.y)
        let label = UILabel()
        label.text = labelText
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .black
        label.sizeToFit()
        label.frame.origin = CGPoint(x: position.x - label.frame.width - 10, y: position.y + 5)
        switchlabel.append(label)
        // ラベルをビューに追加
        if gameMode == "Solo" {self.view?.addSubview(label)}
        return switchControl
    }
    @objc private func aiCheckboxChanged(_ sender: UISwitch) {
        print("change: AI")
        AIerror = false
        AIbattle.toggle()
        if !AIbattle {
            aiCheckbox.isOn = false
            thinkingLabel.isHidden = true
        }else{
            thinkingLabel.isHidden = false
            updateBoard_for_AI()
        }
    }
    var previous_teban = 1
    @objc private func movementCheckCheckboxChanged(_ sender: UISwitch) {
        if shouldawait{
            movementCheckCheckbox.isOn = true
        }else{
            isCheck_moveAble.toggle()
            if !isCheck_moveAble {//checkしていない
                movementCheckCheckbox.isOn = false
                aiCheckbox.isOn = false
                thinkingLabel.isHidden = true
                AIbattle = false
                previous_teban = countTEBAN
                teban_label.isHidden = true
                countTEBAN += 1
                //sente gote 調整
                issaveHistory = false
                saveHistory.isOn = false
            }else{
                countTEBAN = previous_teban
                teban_label.isHidden = false
                issaveHistory = true
                saveHistory.isOn = true
            }
        }
    }
    //var previousPLAYER = ""
    @objc private func saveHistoryChanged(_ sender: UISwitch) {
        print("change: save history")
        issaveHistory.toggle()
        if issaveHistory {isCheck_moveAble = true;movementCheckCheckbox.isOn = true}
        /*
         if !issaveHistory {
         previousPLAYER = now_Player
         }else{//2.26.d    
         if previousPLAYER != now_Player{
         history_board.append(board)
         H_Shave.append(sHave)
         H_Ghave.append(gHave)
         H_P.append(now_Player == "S" ? "G" : "S")
         }
         }*/
    }
    func setupTatamiBackground() {
        let tatamiImage = "tatami"
        let tatamiSize = CGSize(width: 720, height: 360)
        let numRows = Int(ceil(frame.height / tatamiSize.height))
        let numCols = Int(ceil(frame.width / tatamiSize.width))
        for row in 0..<numRows {
            for col in 0..<numCols {
                let tatamiNode = SKSpriteNode(imageNamed: tatamiImage)
                tatamiNode.size = tatamiSize
                let offsetX = CGFloat(row) * (tatamiSize.width / 5) // 1/4 ずつずらす
                let positionX = CGFloat(col) * tatamiSize.width - frame.width / 2 + offsetX + 600
                let positionY = CGFloat(row) * tatamiSize.height - frame.height / 2 + 400
                tatamiNode.position = CGPoint(x: positionX, y: positionY)
                tatamiNode.zPosition = -10 // 背景に配置する
                self.addChild(tatamiNode)
            }
        }
    }
    
    
    func flipBoard(board: [[String]]) -> [[String]] {
        removeMoveAbleHighlightCells()
        highlightNode?.removeFromParent()
        highlightNode = nil
        reset_after_movePiece(will_place: false)
        var rotatedBoard: [[String]] = []
        let rowCount = board.count
        let colCount = board[0].count
        for row in (0..<rowCount).reversed() {
            var newRow: [String] = []
            for col in (0..<colCount).reversed() {newRow.append(board[row][col])}
            rotatedBoard.append(newRow)
        }
        return rotatedBoard
    }
    
    func addLabels() {
        for i in 0..<9 {
            let label = SKLabelNode(text: "\(9-i)")
            label.fontSize = number_font_size
            label.fontName = "Arial-BoldMT"
            label.position = CGPoint(x: frame.midX + CGFloat(i - 4) * cellSize, y: frame.midY + boardSize / 2 + d_board_numlabel + board_offsetY)
            self.addChild(label)
        }
        let rawLabels = ["一", "二", "三", "四", "五", "六", "七", "八", "九"]
        for i in 0..<9 {
            let kanjilabel = SKLabelNode(text: rawLabels[i])
            kanjilabel.fontSize = number_font_size
            kanjilabel.fontName = "Arial-BoldMT"
            kanjilabel.position = CGPoint(x: frame.midX + boardSize / 2 + d_board_numlabel, y: frame.midY + CGFloat(4 - i) * cellSize + board_offsetY)  // 上から1,2,...9
            self.addChild(kanjilabel)
        }
    }
    var textureCache: [String: SKTexture] = [:]
    func createPieceSprite(pieceType: String, position: CGPoint, spriteSheet: SKTexture) -> SKSpriteNode? {
        if let cachedTexture = textureCache[pieceType] {
            let pieceNode = SKSpriteNode(texture: cachedTexture)
            pieceNode.position = position
            pieceNode.name = pieceType
            return pieceNode
        }
        // キャッシュにない場合、新しいテクスチャを作成
        guard let spriteData = komaSpriteMapping[pieceType] else { return nil }
        let x = CGFloat(spriteData[0])
        let y: CGFloat = 0 // CGFloat(spriteData[1])
        let width = CGFloat(spriteData[2])
        let height = CGFloat(spriteData[3])
        let textureRect = CGRect(x: x / spriteSheet.size().width,
                                 y: y / spriteSheet.size().height,
                                 width: width / spriteSheet.size().width,
                                 height: height / spriteSheet.size().height)
        let pieceTexture = SKTexture(rect: textureRect, in: spriteSheet)
        textureCache[pieceType] = pieceTexture
        let pieceNode = SKSpriteNode(texture: pieceTexture)
        pieceNode.position = position
        pieceNode.name = pieceType
        return pieceNode
    }
    func placePieces() {
        for node in pieceNodes {node.removeFromParent()}
        pieceNodes.removeAll()
        pieces.removeAll()
        let spriteSheet = SKTexture(imageNamed: spriteSheetName)
        for row in 0..<9 { // y
            for col in 0..<9 { // x            
                let pieceType = board[row][col]
                if pieceType != "" {
                    let position = CGPoint(x: frame.midX + CGFloat(col - 4) * cellSize,y: frame.midY + CGFloat(4 - row) * cellSize + board_offsetY)
                    let piecePosition = CGPoint(x: 9 - col, y: row + 1)
                    let uniqueID = "\(pieceType)-\(9 - col)\(row + 1)"
                    let piece = Piece(id: uniqueID, type: pieceType, position: position, shogiposition: piecePosition, owner: String(pieceType.suffix(1)))
                    pieces.append(piece)
                    if let pieceNode = createPieceSprite(pieceType: pieceType, position: position, spriteSheet: spriteSheet) {
                        self.addChild(pieceNode)
                        pieceNode.name = uniqueID
                        if flipped {pieceNode.zRotation = .pi}
                        pieceNodes.append(pieceNode)
                    }
                }
            }
        }
    }
    
    
    func drawCapturedPieces() {
        removeCapturedPieces()
        sHave.sort(by: shogiPieceOrder)
        gHave.sort(by: shogiPieceOrder)
        let spriteSheet = SKTexture(imageNamed: spriteSheetName)
        let sBaseY = frame.minY + 20
        let gBaseY = frame.maxY - 50
        for (index, pieceType) in sHave.enumerated() {
            let position = CGPoint(x: frame.midX - CGFloat(sHave.count / 2) * 50 + CGFloat(index) * 50,y: flipped ? gBaseY : sBaseY)
            if let pieceNode = createPieceSprite(pieceType: pieceType+"-S", position: position, spriteSheet: spriteSheet) {
                adjustPieceOrientation(node: pieceNode, owner: "S")
                sHaveNodes.append(pieceNode)
                pieceNode.name = "captured_" + pieceType + "-S"
                self.addChild(pieceNode)
            }
        }
        for (index, pieceType) in gHave.enumerated() {
            let position = CGPoint(x: frame.midX - CGFloat(gHave.count / 2) * 50 + CGFloat(index) * 50,y: flipped ? sBaseY : gBaseY)
            if let pieceNode = createPieceSprite(pieceType: pieceType+"-G", position: position, spriteSheet: spriteSheet) {
                adjustPieceOrientation(node: pieceNode, owner: "G")
                gHaveNodes.append(pieceNode)
                pieceNode.name = "captured_" + pieceType + "-G"
                self.addChild(pieceNode)
            }
        }
    }
    
    func removeCapturedPieces() {
        for node in sHaveNodes { node.removeFromParent() }
        sHaveNodes.removeAll()
        for node in gHaveNodes { node.removeFromParent() }
        gHaveNodes.removeAll()
    }
    
    // 駒の向きを調整
    func adjustPieceOrientation(node: SKSpriteNode, owner: String) {
        if owner == "G" {if flipped {node.zRotation = .pi;node.position.y += 20} else {node.position.y -= 20}
        } else {if flipped {node.zRotation = .pi;node.position.y -= 20} else {node.position.y += 20}}
    }
    
    // 駒の並び順を定義
    func shogiPieceOrder(_ piece1: String, _ piece2: String) -> Bool {
        let pieceOrder: [String: Int] = ["歩": 1, "桂": 2, "香": 3, "銀": 4, "金": 5, "角": 6, "飛": 7, "王": 8]
        let p1 = piece1.prefix(1) // 駒の種類（先頭の1文字）
        let p2 = piece2.prefix(1) // 駒の種類（先頭の1文字）
        return (pieceOrder[String(p1)] ?? 0) < (pieceOrder[String(p2)] ?? 0)
    }
    
    func highlightSquareBehindPiece(selectedPiece: Piece) {
        highlightNode?.removeFromParent()
        highlightNode = nil
        let piecePosition = selectedPiece.position
        let targetPosition = CGPoint(x: piecePosition.x,y: piecePosition.y)
        let highlight = SKShapeNode(rectOf: CGSize(width: cellSize, height: cellSize))
        highlight.position = targetPosition
        highlight.fillColor = UIColor.blue.withAlphaComponent(0.3)  // 透明な青色
        highlight.strokeColor = .clear 
        addChild(highlight) 
        highlightNode = highlight
    }
    
    // すべての駒を削除するメソッド
    func removeAllPieces() {
        for pieceNode in pieceNodes {pieceNode.removeFromParent()}
        pieceNodes.removeAll()
        pieces.removeAll()
    }
    
    func reset_after_movePiece(will_place: Bool){
        is_selecting_piece = false
        highlightNode?.removeFromParent();highlightNode = nil
        if will_place {
            removeAllPieces()
            placePieces()
            drawCapturedPieces()
        }
        selected_name_piece = ""
        selected_pos_piece = ""
        //selecting_captured = "" 書いたらダメ
    }
    
    
    func back(){
        //print(history_board)
        countTEBAN -= 1
        aiCheckbox.isOn = false
        thinkingLabel.isHidden = true
        AIbattle = false
        if history_board.count  < countTEBAN + 1 {countTEBAN = history_board.count - 1}
        let t = history_board[countTEBAN]
        board = flipped ? flipBoard(board: t) : t
        sHave = H_Shave[countTEBAN]
        gHave = H_Ghave[countTEBAN]
        now_Player = H_P[countTEBAN]
        placePieces()
        drawCapturedPieces()
    }
    func copy2DListToClipboard() -> String {
        // 二次元リストをJSON形式に変換
        let jsonData = try! JSONSerialization.data(withJSONObject: flipped ? flipBoard(board: board) : board, options: [])
        let jsonString = String(data: jsonData, encoding: .utf8)!
        let shavedata = try! JSONSerialization.data(withJSONObject: sHave, options: [])
        let shaveString = String(data: shavedata, encoding: .utf8)
        let ghavedata = try! JSONSerialization.data(withJSONObject: gHave, options: [])
        let ghaveString = String(data: ghavedata, encoding: .utf8)
        let hbd = try! JSONSerialization.data(withJSONObject: history_board, options: [])
        let hbdS = String(data: hbd, encoding: .utf8)
        let hsh = try! JSONSerialization.data(withJSONObject: H_Shave, options: [])
        let hshS = String(data:hsh,encoding: .utf8)
        let hgh = try! JSONSerialization.data(withJSONObject: H_Ghave, options: [])
        let hghS = String(data:hgh,encoding :.utf8)
        let hp = try! JSONSerialization.data(withJSONObject: H_P, options: [])
        let hph = String(data:hp,encoding :.utf8)
        let clipString = "\(countTEBAN)$\(shaveString ?? "[]")$\(ghaveString ?? "[]")$\(jsonString)$\(hbdS ?? "[]")$\(hshS ?? "[]")$\(hghS ?? "[]")$\(hph ?? "[]")"
        return clipString
    }
    func unclipString(clipString: String) -> (
        teban: Int,
        sHave: [String], 
        gHave: [String], 
        board: [[String]],
        iserror:Bool,
        hboard:[[[String]]],
        hshave:[[String]],
        hghave:[[String]],
        hp:[String]
    ) {
        var iserror = false
        if clipString.contains("$"){
            let components = clipString.components(separatedBy: "$")
            let teban:Int = Int(components[0]) ?? 0
            let shaveString = components[1]
            let ghaveString = components[2]
            let jsonString = components[3]
            let h_board = components[4]
            let h_shave = components[5]
            let h_ghave = components[6]
            let h_p = components[7]
            guard let shaveData = shaveString.data(using: .utf8),
                  let sHave = try? JSONSerialization.jsonObject(with: shaveData, options: []) as? [String],
                  let ghaveData = ghaveString.data(using: .utf8),
                  let gHave = try? JSONSerialization.jsonObject(with: ghaveData, options: []) as? [String],
                  let jsonData = jsonString.data(using: .utf8),
                  let board = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String]],
                  let hidat_shave = h_board.data(using: .utf8),
                  let hidat_board = try? JSONSerialization.jsonObject(with: hidat_shave, options: []) as? [[[String]]],
                  let hs = h_shave.data(using: .utf8),
                  let hshave = try? JSONSerialization.jsonObject(with: hs, options: []) as? [[String]],
                  let hg = h_ghave.data(using: .utf8),
                  let hghave = try? JSONSerialization.jsonObject(with: hg, options: []) as? [[String]],
                  let hp = h_p.data(using: .utf8),
                  let hph = try? JSONSerialization.jsonObject(with: hp, options: []) as? [String]
            else {
                print("Error: JSON deserialization failed")
                iserror = true
                return (teban:0,sHave: [],gHave:[],board:[],iserror:iserror,hboard:[],hshave:[],hghave:[],hp:[])
            }
            return (teban:teban,sHave: sHave, gHave: gHave, board: board,iserror:iserror,hboard:hidat_board,hshave:hshave,hghave:hghave,hp:hph)
        } else {
            iserror = true
            print("Error: Invalid clip string format")
            return (teban:0,sHave: [],gHave:[],board:[],iserror:iserror,hboard:[],hshave:[],hghave:[],hp:[])
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //displayErrorLog("\(H_P)")
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        shogiMoveParser.is_ok_p_select = true
        let nodesAtPoint = nodes(at: touchLocation)
        for node in nodesAtPoint {
            if node.name == "promote" || node.name == "promoteL" {
                shogiMoveParser.movePiece(board: &board, from: "", to: promote_to_pos, currentPlayer: now_Player, sHave: &sHave, gHave: &gHave, qualifier: "to_be_promote",save_kif: issaveHistory,moveable: isCheck_moveAble)
                if !shogiMoveParser.is_ok_p_select {reset_after_movePiece(will_place: true);cleanupPromotionUI();return}
                reset_after_movePiece(will_place: true)
                cleanupPromotionUI()
                if issaveHistory && isCheck_moveAble{
                    history_board[countTEBAN] = flipped ? flipBoard(board: board) : board
                    H_Shave[countTEBAN] = sHave
                    H_Ghave[countTEBAN] = gHave
                }
                return
            }
            if node.name == "notpromote" || node.name == "notpromoteL" {
                cleanupPromotionUI()
                //if pieceControlManager.isOute(board: board, nowPlayer: now_Player){oute()}
                return
            }
            if (node.name == "flip" && !shouldawait ) || (node.name == "flip" && gameMode == "Online_viewer" && !NETviewerFlipp_should_await)  && !is_showing_promotion_options{
                flipped.toggle()
                board = flipBoard(board: board)
                reset_after_movePiece(will_place: true)
                return
            }
            if node.name == "back" && !shouldawait && countTEBAN >= 1  && !is_showing_promotion_options && !AIisthinking{
                back()
            }
            if node.name == "for" && !shouldawait && countTEBAN < H_P.count - 1 && countTEBAN <= ended_max_teban  && !is_showing_promotion_options && !AIisthinking{
                countTEBAN += 1
                now_Player = countTEBAN % 2 == 0 ? "S" : "G"//countTEBAN引いたから
                let f = history_board[countTEBAN]
                board = flipped ? flipBoard(board: f) : f
                sHave = H_Shave[countTEBAN]
                gHave = H_Ghave[countTEBAN]
                now_Player = H_P[countTEBAN]
                placePieces()
                drawCapturedPieces()
            }
            if node.name == "CopyBoard_to_clipboard" && !is_showing_promotion_options{
                UIPasteboard.general.string = copy2DListToClipboard()
                // コピー完了のメッセージを表示（例）
                let alert = UIAlertController(title: "コピー完了", message: "現在の盤面情報がコピーされました。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
            }
            if node.name == "reset" && !shouldawait && !is_showing_promotion_options {
                board = initboard
                ended_max_teban = 10000
                ended = false
                history_board = [initboard]
                flipped = false
                now_Player = "S"
                countTEBAN=0
                sHave = [];gHave = []
                H_Shave=[[""]];H_Ghave=[[""]]
                H_P=["S"]
                removeAllPieces()
                removeMoveAbleHighlightCells()
                Online_not_enough_data_teban = 0
                reset_after_movePiece(will_place: true)
                /*
                 let menuScene = RoomScene(size: self.size)
                 let transition = SKTransition.fade(withDuration: 1.0)
                 self.view?.presentScene(menuScene, transition: transition)*/
            }
            if node.name == "ended_saveL" && !shouldawait {
                saveStringToKifuFolder(content:copy2DListToClipboard(),sente : sente, gote : gote, win:win)
            }
            if node.name == "kifinputL" && !shouldawait{
                showLoadBoardAlert()
            }
            if node.name == "BackMenu" {
                let menuScene = MenuScene(size: self.size)
                let transition = SKTransition.fade(withDuration: 1.0)
                self.view?.presentScene(menuScene, transition: transition)
            }
            if node.name == "sendMessage" && !is_showing_promotion_options {
                if isonline {
                    if NETopposeNAME != "not found" {showMessageInputAlert()}else{displayErrorLog("対戦相手が入室してからしかメッセージは送信できません")}
                }else{showMessageInputAlert()}
            }
            if gameMode == "Online_viewer" {displayErrorLog("観戦モードです");return}
            if let pieceNode = node as? SKSpriteNode, let uniqueID = pieceNode.name {
                if String(uniqueID.prefix(7)) == "capture" {
                    if String(uniqueID.suffix(1)) == now_Player || !isCheck_moveAble{
                        print("持ち駒が選択されました: \(uniqueID)")
                        is_selecting_piece = false
                        selecting_captured = uniqueID
                        selected_pos_piece = ""
                        selected_name_piece = ""
                        highlightNode?.removeFromParent()
                        removeMoveAbleHighlightCells()
                        getValidDropCells(forCapturedPiece: uniqueID)
                        addGreenHighlightCells(cells: captured_validCells)
                    } else {
                        print("相手の持ち駒です。")
                    }
                    return
                }
            }
            
        }
        let row = Int((frame.midY + board_offsetY - touchLocation.y + boardSize / 2) / cellSize)
        let col = Int((touchLocation.x - frame.midX + boardSize / 2) / cellSize)
        if sHave.contains("王") {
            S_or_G.text = "先手の勝ち";return
        }
        if gHave.contains("王") {
            S_or_G.text = "後手の勝ち";return
        }
        if row >= 0 && row < 9 && col >= 0 && col < 9 && !shouldawait{
            let nodesAtPoint = nodes(at: touchLocation)
            var pieceFound = false
            for node in nodesAtPoint {
                if let pieceNode = node as? SKSpriteNode, let uniqueID = pieceNode.name {
                    if let piece = pieces.first(where: { $0.id == uniqueID }) {
                        pieceFound = true
                        let thirdCharacter = String(piece.id[piece.id.index(piece.id.startIndex, offsetBy: 2)])
                        if gHave.contains("王") || sHave.contains("王") {return}
                        if is_selecting_piece {//自分の駒
                            if thirdCharacter == now_Player {
                                captured_validCells=[]
                                removeMoveAbleHighlightCells()
                                ableMove = pieceControlManager.calculateMovablePositions(for: piece, on: board,flipped: flipped)
                                selected_pos_piece = String(piece.id.suffix(2))
                                selected_name_piece = piece.id
                                is_selecting_piece = true
                                highlightSquareBehindPiece(selectedPiece: piece)
                                addGreenHighlightCells(cells: ableMove)
                            }else{//相手の駒を取る
                                Move_to = String(9-col) + String(row+1)
                                if ableMove.contains(Move_to) || !isCheck_moveAble {
                                    let qualifier = havetoPromote(to: Move_to, pieceName_promote: String(selected_name_piece.prefix(1))) ? "成" : ""
                                    if qualifier == "" {checkPromotion(to: Move_to, pieceName_promote: String(selected_name_piece.prefix(1)))}
                                    shogiMoveParser.movePiece(board: &board, from: selected_pos_piece, to: Move_to, currentPlayer: now_Player, sHave: &sHave, gHave: &gHave, qualifier: qualifier,save_kif: issaveHistory,moveable:isCheck_moveAble)
                                    //if pieceControlManager.isOute(board: board, nowPlayer: now_Player){displayErrorLog("王手")}
                                    if issaveHistory {
                                        override_kif()
                                        history_board.append(flipped ? flipBoard(board: board) : board)
                                        H_Shave.append(sHave)
                                        H_Ghave.append(gHave)
                                        H_P.append(now_Player == "S" ? "G" : "S")
                                    }
                                    reset_after_movePiece(will_place: true)
                                    if !isonline {checkended()}
                                    if !shouldawait && ableMove.contains(Move_to) {now_Player = now_Player == "S" ? "G" : "S";countTEBAN += 1;removeMoveAbleHighlightCells()}else{reset_after_movePiece(will_place: false)}
                                    if isonline {shouldawait = true}
                                }
                                
                            }
                        }else{
                            if thirdCharacter == now_Player || !isCheck_moveAble {//自分の駒
                                if !isCheck_moveAble {now_Player = thirdCharacter}
                                ableMove = pieceControlManager.calculateMovablePositions(for: piece, on: board, flipped: flipped)
                                selected_pos_piece = String(9-col) + String(row+1)
                                selected_name_piece = piece.id
                                is_selecting_piece = true
                                highlightSquareBehindPiece(selectedPiece: piece)
                                addGreenHighlightCells(cells: ableMove)
                            }else {
                                print("相手の駒のため、動かせません。")
                            }
                        }
                        break
                    }else{print("not found pieceNode.name")}
                }
            }
            if !pieceFound && !shouldawait{
                Move_to = String(9-col) + String(row+1)
                if is_selecting_piece && Move_to != selected_pos_piece{// normal 指し手
                    removeMoveAbleHighlightCells()
                    if ableMove.contains(Move_to) || !isCheck_moveAble {
                        //print(String(selected_name_piece.prefix(1)))
                        let qualifier = havetoPromote(to: Move_to, pieceName_promote: String(selected_name_piece.prefix(1))) ? "成" : ""
                        print(qualifier)
                        if qualifier == "" {checkPromotion(to: Move_to, pieceName_promote: String(selected_name_piece.prefix(1)))}
                        shogiMoveParser.movePiece(board: &board, from: selected_pos_piece, to: Move_to, currentPlayer: now_Player, sHave: &sHave, gHave: &gHave, qualifier: qualifier,save_kif: issaveHistory,moveable: isCheck_moveAble)
                        //if pieceControlManager.isOute(board: board, nowPlayer: now_Player){displayErrorLog("王手")}
                        if issaveHistory {
                            override_kif()
                            history_board.append(flipped ? flipBoard(board: board) : board)
                            H_Shave.append(sHave)
                            H_Ghave.append(gHave)
                            H_P.append(now_Player == "S" ? "G" : "S")
                        }
                        reset_after_movePiece(will_place: true)
                    }
                    if shogiMoveParser.is_ok_p_select && !shouldawait && ableMove.contains(Move_to){now_Player = now_Player == "S" ? "G" : "S";countTEBAN += 1;removeMoveAbleHighlightCells()}
                    if isonline {shouldawait = true}
                }else if selecting_captured != "" && captured_validCells.contains(Move_to){//持ち駒から
                    removeMoveAbleHighlightCells()
                    let index = selecting_captured.index(selecting_captured.startIndex, offsetBy: 9) // 2は0始まりで3番目captured_
                    let captured_piece_name = String(selecting_captured[index])
                    print("\(captured_piece_name)captured_piece_name")
                    shogiMoveParser.movePiece(board: &board, from: captured_piece_name, to: Move_to, currentPlayer: now_Player, sHave: &sHave, gHave: &gHave, qualifier: "打",save_kif: issaveHistory,moveable: isCheck_moveAble)
                    //if pieceControlManager.isOute(board: board, nowPlayer: now_Player){displayErrorLog("王手")}
                    if isonline {shouldawait = true}
                    if issaveHistory {
                        override_kif()
                        history_board.append(flipped ? flipBoard(board: board) : board)
                        H_Shave.append(sHave)
                        H_Ghave.append(gHave)
                        H_P.append(now_Player == "S" ? "G" : "S")
                    }
                    reset_after_movePiece(will_place: true)
                    now_Player = now_Player == "S" ? "G" : "S"
                    countTEBAN += 1
                    captured_validCells = []
                }
            }
        } else {
            print("盤面外の位置がタップされました")
            highlightNode?.removeFromParent()
            highlightNode = nil
            is_selecting_piece = false
            captured_validCells = []
            selecting_captured = ""
            selected_pos_piece = ""
            selected_name_piece = ""
            removeMoveAbleHighlightCells()
        }
    }
    func finish(sente:String,gote:String){
        is_showing_promotion_options = true
        show_saveEndedLabel()
        let SenteFinish = SKLabelNode(text: "先手の" + sente)
        SenteFinish.fontName = "KouzanBrushFontGyousyoOTF"
        SenteFinish.fontSize = 120
        SenteFinish.zPosition = 11
        SenteFinish.fontColor = sente == "勝利" ? .red : .blue
        if flipped {SenteFinish.zRotation = .pi}
        SenteFinish.position = CGPoint(x: size.width / 2, y: frame.midY - 220)
        addChild(SenteFinish)
        let GoteFinish = SKLabelNode(text: "後手の"+gote)
        GoteFinish.fontName = "KouzanBrushFontGyousyoOTF"
        GoteFinish.fontSize = 120
        GoteFinish.zPosition = 11
        GoteFinish.fontColor = gote == "勝利" ? .red : .blue
        if !flipped {GoteFinish.zRotation = .pi}
        GoteFinish.position = CGPoint(x: size.width / 2, y: frame.midY + 220)
        addChild(GoteFinish)
        let squareSize = CGSize(width: 1080, height: 810) // 文字に合わせたサイズに変更
        let squareNode = SKSpriteNode(color: .white, size: squareSize)
        squareNode.position = CGPoint(x: frame.midX,y:frame.midY)
        squareNode.zPosition = 10
        squareNode.alpha = 0.7
        addChild(squareNode) // 四角形をシーンに追加
        let nodesToFade = [SenteFinish, GoteFinish, squareNode]
        ended_max_teban = countTEBAN - 1
        print(ended_max_teban,"asgawrgayw")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [self] in
            //if self.gameMode == "Solo" {self.back()}
            if gameMode == "Solo" {
                back()
                override_kif()
            }else{
                if NET_IAM == "S" {back();PostNET()}
            }
            UIPasteboard.general.string = self.copy2DListToClipboard()
            let fadeOutAction = SKAction.fadeOut(withDuration: 1.0)
            let remove = SKAction.removeFromParent()
            let end = SKAction.sequence([fadeOutAction,remove])
            nodesToFade.forEach { node in
                node.run(end)
            }
            is_showing_promotion_options = false
        }
    }
    
    //var oute_animation = false
    func oute(){
        if isCheck_moveAble {pieceControlManager.oute(in: self)}
        //if !oute_animation {return}
        //oute_animation = true
        //displayErrorLog("王手")
    }
    
    func override_kif(){
        if countTEBAN < history_board.count - 1 {
            let t = countTEBAN + 1
            history_board.removeSubrange(t...history_board.count - 1)
            H_Shave.removeSubrange(t...H_Shave.count - 1)
            H_Ghave.removeSubrange(t...H_Ghave.count - 1)
            H_P.removeSubrange(t...H_P.count - 1)
        }
    }
    
    func havetoPromote(to toPos: String, pieceName_promote: String) -> Bool {
        var toRow = Int(toPos.suffix(1))!
        if flipped {toRow = 10 - toRow}
        if pieceName_promote == "歩" || pieceName_promote == "香" {
            if now_Player == "S" && toRow == 1 {
                //if pieceControlManager.isOute(board: board, nowPlayer: now_Player){oute()}
                return true
            } else if now_Player == "G" && toRow == 9{
                //if pieceControlManager.isOute(board: board, nowPlayer: now_Player){oute()}
                return true
            }
        } else if pieceName_promote == "桂" {
            if now_Player == "S" && toRow <= 2 {
                //if pieceControlManager.isOute(board: board, nowPlayer: now_Player){oute()}
                return true
            }else if now_Player == "G" && toRow >= 8 {
                //if pieceControlManager.isOute(board: board, nowPlayer: now_Player){oute()}
                return true
            }
        }
        return false
    }
    
    /*
     func getAbleMove(for piece: Piece) -> [String] {
     return pieceControlManager.calculateMovablePositions(for: piece, on: board,flipped: flipped)
     }*/
    
    func checkPromotion(to toPos: String, pieceName_promote: String) {
        if promotablePieces.contains(pieceName_promote){
            let toRow = Int(toPos.suffix(1))!
            var isEnemyTerritory = false
            if flipped{
                isEnemyTerritory = (now_Player == "S" && toRow >= 7) || (now_Player == "G" && toRow <= 3) || (now_Player == "S" && Int(selected_pos_piece.suffix(1))! >= 7) || (now_Player == "G" && Int(selected_pos_piece.suffix(1))! <= 3)
            }else{
                isEnemyTerritory = (now_Player == "S" && toRow <= 3) || (now_Player == "G" && toRow >= 7) || (now_Player == "S" && Int(selected_pos_piece.suffix(1))! <= 3) || (now_Player == "G" && Int(selected_pos_piece.suffix(1))! >= 7)
            }
            //print(isEnemyTerritory)
            if isEnemyTerritory {
                promote_to_pos = toPos
                shouldawait = true
                showPromotionOptions()
            }else{
                //if pieceControlManager.isOute(board: board, nowPlayer: now_Player){oute()}
            }
        }
    }
    
    func checkended(){
        if sHave.contains("王") && !ended{
            ended = true
            finish(sente: "勝利", gote: "敗北")
            print("先手の勝利")
        }else if gHave.contains("王") && !ended{
            ended = true
            print("後手の勝利")
            finish(sente: "敗北", gote: "勝利")
        }
    }
    var is_showing_promotion_options = false
    func showPromotionOptions() {
        is_showing_promotion_options = true
        // 背景を半透明で表示
        let backgroundNode = SKShapeNode(rectOf: CGSize(width: frame.width, height: frame.height))
        backgroundNode.fillColor = .black.withAlphaComponent(0.5)
        backgroundNode.position = CGPoint(x:frame.midX, y:frame.midY)
        backgroundNode.zPosition = 100
        backgroundNode.name = "promotionBackground"
        self.addChild(backgroundNode)
        // ダイアログの枠
        let dialogSize = CGSize(width: 300, height: 150)
        let dialogNode = SKShapeNode(rectOf: dialogSize, cornerRadius: 10)
        dialogNode.fillColor = .white
        dialogNode.zPosition = 101
        dialogNode.position = CGPoint(x: frame.midX, y: frame.midY)
        dialogNode.name = "promotionDialog"
        self.addChild(dialogNode)
        // 「成る」ボタン
        let promoteButton = SKShapeNode(rectOf: CGSize(width: 120, height: 50), cornerRadius: 10)
        promoteButton.fillColor = .green
        promoteButton.zPosition = 102
        promoteButton.position = CGPoint(x: frame.midX - 70, y: frame.midY - 20)
        promoteButton.name = "promote"
        self.addChild(promoteButton)
        let promoteLabel = SKLabelNode(text: "成る")
        promoteLabel.fontSize = 20
        promoteLabel.fontColor = .white
        promoteLabel.position = CGPoint(x: promoteButton.position.x, y: promoteButton.position.y - 10)
        promoteLabel.zPosition = 103
        promoteLabel.name = "promoteL"
        self.addChild(promoteLabel)
        // 「成らない」ボタン
        let declineButton = SKShapeNode(rectOf: CGSize(width: 120, height: 50), cornerRadius: 10)
        declineButton.fillColor = .red
        declineButton.zPosition = 102
        declineButton.position = CGPoint(x: frame.midX + 70, y: frame.midY - 20)
        declineButton.name = "notpromote"
        self.addChild(declineButton)
        let declineLabel = SKLabelNode(text: "成らない")
        declineLabel.fontSize = 20
        declineLabel.fontColor = .white
        declineLabel.position = CGPoint(x: declineButton.position.x, y: declineButton.position.y - 10)
        declineLabel.zPosition = 103
        declineLabel.name = "notpromoteL"
        self.addChild(declineLabel)
    }
    
    func cleanupPromotionUI() {
        is_showing_promotion_options = false
        self.shouldawait = false
        promote_to_pos = ""
        now_Player = now_Player == "S" ? "G" : "S"
        if isCheck_moveAble{countTEBAN += 1} 
        removeMoveAbleHighlightCells()
        self.childNode(withName: "promotionBackground")?.removeFromParent()
        self.childNode(withName: "promotionDialog")?.removeFromParent()
        self.childNode(withName: "promote")?.removeFromParent()
        self.childNode(withName: "promoteL")?.removeFromParent()
        self.childNode(withName: "notpromote")?.removeFromParent()
        self.childNode(withName: "notpromoteL")?.removeFromParent()
    }
    
    func addGreenHighlightCells(cells: [String]) {
        removeMoveAbleHighlightCells()
        for cell in cells {
            if let col = Int(String(cell.prefix(1))), let row = Int(String(cell.suffix(1))) {
                let position = getCellPosition(row: row, col: col, cellSize: cellSize, boardOffsetY: board_offsetY)
                let highlightNode = SKShapeNode(rectOf: CGSize(width: cellSize, height: cellSize))
                highlightNode.position = position
                highlightNode.fillColor = .green
                highlightNode.alpha = 0.3
                highlightNode.strokeColor = .clear
                highlightNode.zPosition = 10
                self.addChild(highlightNode)
                move_ableNode.append(highlightNode)
            }
        }
    }
    
    func removeMoveAbleHighlightCells() {
        for node in move_ableNode {node.removeFromParent()}
        move_ableNode.removeAll()
    }
    func getCellPosition(row: Int, col: Int, cellSize: CGFloat, boardOffsetY: CGFloat) -> CGPoint {
        let x = frame.midX + CGFloat(5 - col) * cellSize
        let y = frame.midY + CGFloat(5 - row) * cellSize + boardOffsetY
        return CGPoint(x: x, y: y)
    }
    
    
    
    
    func getValidDropCells(forCapturedPiece capturedPieceID: String) {
        captured_validCells = []
        reset_after_movePiece(will_place: false)
        let pieceType = String(capturedPieceID.dropFirst(9).prefix(1))
        let currentPlayer = String(capturedPieceID.suffix(1)) // "S" または "G"
        for row in 0...8 {
            for col in 0...8 {
                if board[row][col] == "" {
                    if isValidDrop(for: pieceType, row: row, col: col, currentPlayer: currentPlayer) {
                        captured_validCells.append("\(9 - col)\(row + 1)")
                    }
                }
            }
        }
    }
    
    
    
    func isValidDrop(for pieceType: String, row: Int, col: Int, currentPlayer: String) -> Bool {
        if pieceType == "歩" {//2歩
            for r in 0...8 {if board[r][col] == "歩-\(currentPlayer)" {return false}}
        }
        let replacedPlayer_config = flipped ? (currentPlayer == "S" ? "G" : "S" ) : currentPlayer
        if pieceType == "歩" || pieceType == "香" {
            if replacedPlayer_config == "S" && row == 0 {return false}
            if replacedPlayer_config == "G" && row == board.count - 1 {return false}
        }
        if pieceType == "桂" {
            if replacedPlayer_config == "S" && row <= 1 {return false}
            if replacedPlayer_config == "G" && row >= 7 {return false}
        }
        return true
    }/*
      private func createTextField(placeholder: String, position: CGPoint) -> UITextField {
      let textField = UITextField()
      textField.placeholder = placeholder
      textField.borderStyle = .roundedRect
      textField.textAlignment = .center
      textField.font = UIFont.systemFont(ofSize: 14)
      textField.backgroundColor = UIColor(white: 0.1, alpha: 0.8)
      // サイズを調整
      textField.frame.size = CGSize(width: 200, height: 30)
      textField.center = position
      // キーボードのリターンキーを監視
      textField.delegate = self
      textField.becomeFirstResponder() // キーボードを表示
      return textField
      }*/
    var NETviewerFlipp_should_await = true
    func ResponseNET(){
        NETviewerFlipp_should_await = true
        fetchShogiRoomData(roomID: self.roomID) { [self] ShogiRoomData in
            if let gameData = ShogiRoomData {
                // 例えばsenteのプレイヤー名を表示
                print("Sente Player: \(gameData.sente)")
                print("Gote Player: \(gameData.gote)")
                print("Board: \(board)")
                print("Sente Have: \(gameData.sHave ?? [""])")
                print("Gote Have: \(gameData.gHave ?? [""])")
                print("countTEBAN: \(gameData.countTEBAN)")
                print("move: \(gameData.move ?? "not found move_to")")
                self.NETviewerFlipp_should_await = false
                if hitted {return}
                if (flipped ? flipBoard(board: board) : board) != gameData.board {//更新されたかチェック
                    initNET+=1
                    displayErrorLog("自分の盤面を更新中")
                    board = flipped ? flipBoard(board: gameData.board) : gameData.board
                    //print("board--------:\(board)")
                    sHave = gameData.sHave ?? []
                    gHave = gameData.gHave ?? []
                    history_board.append(gameData.board)
                    H_Shave.append(sHave)
                    H_Ghave.append(gHave)
                    if initNET == 1 {
                        H_P.append(gameData.countTEBAN % 2 == 0 ? "S" : "G")
                    }else{
                        H_P.append(now_Player == "S" ? "G" : "S")
                    }
                    sente=gameData.sente
                    gote=gameData.gote
                    if initNET != 1 {NETismy_turn = true}
                    Move_to = gameData.move ?? ""
                    NETopposeNAME = NET_IAM == "S" ? gameData.gote : gameData.sente
                    if gameMode != "Online_viewer" {OpposeNameL.text = NETopposeNAME}
                    //shouldawait = false
                    countTEBAN = gameData.countTEBAN
                    self.selecting_captured = ""
                    self.captured_validCells = []
                    reset_after_movePiece(will_place: false)
                    previous_board = board
                    DispatchQueue.main.async(){
                        self.placePieces()
                        self.drawCapturedPieces()
                        
                    }
                    //now_Player = countTEBAN % 2 == 0 ? "S" : "G" NO WRITE!
                }
            } else {
                print("Failed to fetch game data")
                displayErrorLog("Failed to fetch game data")
            }
        }
    }
    
    var initNET = 0
    func PostNET() {
        let endpoint = "\(endpoint)/room/\(self.roomID).json"
        guard let url = URL(string: endpoint) else {print("Invalid URL");return}
        let NETboard = flipped ? self.flipBoard(board: board) : self.board
        let data: [String: Any] = [
            "board": NETboard,
            "sHave": self.sHave,
            "gHave": self.gHave,
            //"\(NET_IAM == "S" ? "sente" : "gote")": ", 
            "move": self.Move_to,
            "timestamp": Date().timeIntervalSince1970,
            "countTEBAN": self.countTEBAN
        ]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            var request = URLRequest(url: url)
            request.httpMethod = "PATCH"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error saving game data: \(error)")
                    self.displayErrorLog("Error saving game data: \(error)")
                    return
                }
                if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    print("Game data saved successfully.")
                    self.displayErrorLog("クラウド更新済")
                    self.hitted = false
                } else {
                    print("Failed to save game data.")
                    self.displayErrorLog("更新失敗")
                }
            }
            task.resume()
        } catch {
            print("Error serializing JSON: \(error)")
        }
    }
    
    var update_time:TimeInterval = 1.0
    var win = ""
    var hitted = false
    func Online(){
        DispatchQueue.main.asyncAfter(deadline: .now() + update_time) {
            if self.NETismy_turn {
                //print("NETturn is me? \(self.NETismy_turn)")
                if self.Move_to != "" {self.move_to_highlight_online()}
                self.shouldawait = false
                if self.previous_board != self.board {
                    self.hitted = true
                    self.shouldawait = true
                    print(self.previous_board,self.board)
                    print("post before")
                    self.PostNET()
                    print("post after")
                    self.NETismy_turn = false
                    //self.reset_after_movePiece(will_place: false)
                    self.selecting_captured = ""
                    self.captured_validCells = []
                    //self.previous_board = self.flipped ? self.flipBoard(board: self.board) : self.board
                    self.shouldawait = true
                    if self.countTEBAN > 15 {self.update_time = 1.5}
                }
            }else{
                self.shouldawait = true
                self.ResponseNET()
            }
            self.now_Player = self.countTEBAN % 2 == 0 ? "S" : "G"
            self.NETismy_turn = self.NET_IAM == self.now_Player ? true : false
            if self.sHave.contains("王") && !self.ended {
                self.ended = true
                self.win = "先手"
                self.finish(sente: "勝利", gote: "敗北")
            }else if self.gHave.contains("王") && !self.ended {
                self.ended = true
                self.win = "後手"
                self.finish(sente: "敗北", gote: "勝利")
            }
            if !self.ended{self.Online()}
            //self.move_to_highlight_online()
        }
    }
    
    func show_saveEndedLabel(){
        let ended_saveL = SKLabelNode(text: "棋譜をファイルに保存")
        ended_saveL.fontName = "KouzanBrushFontGyousyoOTF"
        ended_saveL.fontSize = 20
        ended_saveL.name = "ended_saveL"
        ended_saveL.fontColor = .black
        ended_saveL.horizontalAlignmentMode = .right
        ended_saveL.position = CGPoint(x: frame.maxX - 10,y: frame.midY + 80)
        addChild(ended_saveL)
    }
    
    
    func move_to_highlight_online(){
        let firstDigit = Move_to.first.flatMap({ Int(String($0)) }) ?? 0
        let secondDigit = Move_to.last.flatMap({ Int(String($0)) }) ?? 0
        let flippedX = flipped ? 10 - firstDigit : firstDigit
        let flippedY = flipped ? 10 - secondDigit : secondDigit
        let ai_move_position = CGPoint(
            x: frame.midX + CGFloat(5 - flippedX) * cellSize,
            y: frame.midY + CGFloat(5 - flippedY) * cellSize + board_offsetY
        )
        let aihighlightNode = SKShapeNode(rectOf: CGSize(width: cellSize, height: cellSize))
        aihighlightNode.position = ai_move_position
        aihighlightNode.fillColor = .cyan
        aihighlightNode.alpha = 0.5
        aihighlightNode.strokeColor = .clear
        aihighlightNode.zPosition = 10
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.addChild(aihighlightNode)
            let fadeOut = SKAction.fadeOut(withDuration: 0.8) // フェードアウトに1秒
            let remove = SKAction.removeFromParent()         // ノードを削除
            let sequence = SKAction.sequence([fadeOut, remove]) // フェードアウト後に削除
            aihighlightNode.run(sequence)
        }
    }
    // データ構造の定義
    struct ShogiRoomData: Codable {
        let board: [[String]]
        let gote: String
        let sente: String
        let timestamp: TimeInterval
        var move: String?
        var sHave: [String]?
        var gHave: [String]?
        var countTEBAN: Int
    }
    
    // JSONを取得してデコード
    func fetchShogiRoomData(roomID: String, completion: @escaping (ShogiRoomData?) -> Void) {
        let urlString = "\(endpoint)/room/\(roomID).json"
        guard let url = URL(string: urlString) else {print("Invalid URL.");completion(nil);return}
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            do {
                // JSONをデコード
                var roomData = try JSONDecoder().decode(ShogiRoomData.self, from: data)
                roomData.sHave = roomData.sHave ?? []
                roomData.gHave = roomData.gHave ?? []
                roomData.move = roomData.move ?? ""
                completion(roomData)
            } catch {
                print("Error decoding JSON: \(error)")
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    
    
    
    func updateGote() {
        let baseURL = "\(endpoint)/room/\(roomID).json"
        guard let url = URL(string: baseURL) else {print("Invalid URL");return}
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // リクエストボディにデータを設定
        let requestBody = ["gote": my_Player_name]
        do {request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {print("Failed to serialize request body: \(error)");return}
        // データタスクを作成して実行
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {print("Request failed with error: \(error)");return}
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print("Successfully updated gote with \(my_Player_name)")
                } else {
                    print("Failed with status code: \(httpResponse.statusCode)")
                }
            }
        }
        task.resume()
    }
    
    
    
    
    
    func saveStringToKifuFolder(content:String,sente:String,gote:String,win:String) {
        // 現在のビューコントローラを取得
        guard let viewController = self.view?.window?.rootViewController else {
            print("ビューコントローラを取得できませんでした")
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd" // 日付フォーマット
        let dateString = dateFormatter.string(from: Date())
        let fileName = "先手\(sente),後手\(gote),\(win)の勝ち_\(dateString).txt" // ファイル名
        
        let temporaryURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            // 一時ファイルに保存
            try content.write(to: temporaryURL, atomically: true, encoding: .utf8)
            
            // UIDocumentPickerを使用して保存先を選択させる
            let documentPicker = UIDocumentPickerViewController(forExporting: [temporaryURL])
            documentPicker.delegate = viewController as? UIDocumentPickerDelegate
            documentPicker.allowsMultipleSelection = false
            viewController.present(documentPicker, animated: true, completion: nil)
        } catch {
            print("一時ファイル作成失敗: \(error)")
        }
    }
    var Online_not_enough_data_teban = 0
    func showLoadBoardAlert() {
        guard let view = view else { return }
        let alertController = UIAlertController(title: "棋譜読み込み", message: "現在の盤面は失われます。", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.clearButtonMode = .whileEditing
            textField.autocorrectionType = .no
            textField.keyboardType = .default
            textField.returnKeyType = .done
            textField.placeholder = "棋譜情報を貼り付けてください"
            //DispatchQueue.main.async {textField.becomeFirstResponder()}
        }
        let confirmAction = UIAlertAction(title: "棋譜読み込み", style: .default) { _ in
            if let newboard = alertController.textFields?.first?.text, !newboard.isEmpty{
                let input_result = self.unclipString(clipString: newboard)
                if input_result.iserror {
                    return
                }else{
                    self.flipped = false
                    self.board = input_result.board
                    self.sHave = input_result.sHave
                    self.gHave = input_result.gHave
                    self.history_board = input_result.hboard
                    self.H_Shave = input_result.hshave
                    self.H_Ghave = input_result.hghave
                    self.H_P = input_result.hp
                    let n = self.H_P.count
                    if n <= input_result.teban {
                        self.displayErrorLog("not found enough history\(input_result.teban)")
                        self.countTEBAN = n - 1
                        //self.Online_not_enough_data_teban = input_result.teban - n + 1
                        //self.teban_label.text = "\(self.countTEBAN + self.Online_not_enough_data_teban)"
                        self.now_Player = self.H_P[n - 1]
                    }else{
                        self.countTEBAN = input_result.teban
                        self.now_Player = self.H_P[self.countTEBAN]
                    }
                    self.reset_after_movePiece(will_place: true)
                    if (self.H_Shave.last!.contains("王")) || (self.H_Ghave.last!.contains("王")) {
                        self.countTEBAN = input_result.hboard.count - 1
                        self.now_Player = self.H_P[self.countTEBAN]
                    }
                    //if self.now_Player == "G" {self.countTEBAN += 1}
                    //teban_label.text = String(countTEBAN)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        DispatchQueue.main.async {
            view.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    private let chatBase = ChatBase()
    private var chatMessages: [ChatBase.ChatMessage] = [] //local keep chat messages
    var updateInterval: TimeInterval = 10.0
    var lastUpdateTime: TimeInterval = 0
    override func update(_ currentTime: TimeInterval) {
        if currentTime - lastUpdateTime > updateInterval {
            lastUpdateTime = currentTime
            if String(gameMode.prefix(6)) == "Online" {fetchAndUpdateChatMessages()}
        }
    }
    private func fetchAndUpdateChatMessages() {
        chatBase.fetchNewChatMessages { [weak self] newMessages in
            guard let self = self else { return }
            self.chatMessages.append(contentsOf: newMessages)
            for (_, message) in chatMessages.enumerated() {
                var show_txt = message.message
                var show = true
                let substrings = ["!room!", "!log!", "!admin!","!privatelog!"]
                for substring in substrings {if show_txt.contains(substring) {show = false}}
                let (name, sentence) = chatBase.extractStrings(from: show_txt)
                if name == my_Player_name && message.name == NETopposeNAME {
                    show_txt = "@@-> \(sentence ?? "")"
                } else if name != "" && message.name == my_Player_name{
                    show_txt = sentence ?? ""
                } else{
                    show = false
                }
                if show{displayChat("\(show_txt)")}
            }
            self.chatMessages = []
        }
    }
    func isValidName(_ name: String) -> Bool {
        let pattern = "^[\\p{Hiragana}\\p{Katakana}\\p{Han}a-zA-Z0-9_-]+$"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {return false}
        let range = NSRange(location: 0, length: name.utf16.count)
        return regex.firstMatch(in: name, options: [], range: range) != nil
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
                    self.chatBase.sendChatMessage(message: "@\(self.NETopposeNAME)@\(message)")
                    self.displayErrorLog("チャット送信済")
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
}



class Piece {
    var id: String
    var type: String
    var position: CGPoint
    var shogiposition: CGPoint
    var owner: String
    init(id: String, type: String, position: CGPoint, shogiposition:CGPoint,owner: String) {
        self.id = id
        self.shogiposition = shogiposition
        self.owner = owner
        self.type = type
        self.position = position
    }
}
/*
 // UITextFieldDelegateの拡張
 extension GameScene: UITextFieldDelegate {
 func textFieldShouldReturn(_ textField: UITextField) -> Bool {
 textField.resignFirstResponder()
 print("入力されたテキスト: \(textField.text ?? "")")
 
 return true
 }
 }
 */

