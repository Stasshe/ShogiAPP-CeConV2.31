import Foundation
class ShogiMoveParser{
    /*
     To do
     成銀、成香などをkifファイル読み込み・書き出し時に相互変換
     同　金　などの、同の処理
     */
    var current_player = "G"//後手を初期値にして処理
    var is_ok_p_select = true
    var da_piece = false
    var count_board = 0
    let promotionMap: [String: String] = ["飛":"龍","角": "馬","銀": "全","桂": "圭","香": "杏","歩":"と"]
    
    var sHave: [String]
    var gHave: [String]
    var board: [[String]]
    var kif: [String]
    // 初期化処理
    init(board: [[String]], sHave: [String], gHave: [String]) {
        self.board = board
        self.sHave = sHave
        self.gHave = gHave
        self.kif = []
    }
    func toKanjiNumber(number: Int) -> String {
        guard (0...9).contains(number) else {return "範囲外の数字です"}
        let kanjiNumbers: [String] = ["一", "二", "三", "四", "五", "六", "七", "八", "九"]
        return kanjiNumbers[number]
    }
    func toFullWidthArabicNumber(number: Int) -> String {
        guard (0...9).contains(number) else {return "範囲外の数字です"}
        let numberString = String(number)
        return numberString.unicodeScalars.map { scalar in
            // 全角に変換するUnicodeの範囲は、半角数字のUnicodeに0xFEE0を加える
            String(UnicodeScalar(scalar.value + 0xFEE0)!)
        }.joined()
    }
    
    func kif(fromxy: String,tox:Int,toy:Int,qualifier:String){
        let pieceType = String(board[toy - 1][9 - tox].prefix(1))
        let kif_one = toFullWidthArabicNumber(number: tox) + toKanjiNumber(number: toy) + pieceType
        if qualifier == "打" {
            kif.append(kif_one+"打")
        } else {
            kif.append(kif_one + pieceType + qualifier + "(\(fromxy))")
        }
        print(kif)
    }
    
    
    func coordinateToIndex(x: Int, y: Int) -> (Int, Int) {
        let xIndex = y - 1 ;let yIndex = 9 - x//xとyを交換
        return (xIndex, yIndex)
    }
    
    func movePiece(
        board: inout [[String]],
        from: String,
        to: String,
        currentPlayer: String,
        sHave: inout [String],
        gHave: inout [String],
        qualifier: String,
        save_kif: Bool,
        moveable: Bool
    ) {
        //print(board)
        if qualifier == "打" || da_piece{
            let toX = Int(to.prefix(1))!
            let toY = Int(to.suffix(1))!
            let toIndex = coordinateToIndex(x: toX, y: toY)
            //kif(fromxy: "", tox: toX, toy: toY, qualifier: "打")
            if currentPlayer == "S" {
                if !sHave.contains(from){print("\(currentPlayer)はその駒を未所持です");is_ok_p_select=false;return}
                if board[toIndex.0][toIndex.1].isEmpty {board[toIndex.0][toIndex.1] = from+"-S"}
                if let index = sHave.firstIndex(of: from) {sHave.remove(at: index)}
            }else if currentPlayer == "G" {
                if !gHave.contains(from){print("\(currentPlayer)はその駒を未所持です");is_ok_p_select=false;return}
                if board[toIndex.0][toIndex.1].isEmpty {board[toIndex.0][toIndex.1] = from+"-G"}
                if let index = gHave.firstIndex(of: from) {gHave.remove(at: index)}
            }else {
                print(currentPlayer,"error")
            }
        }else if qualifier == "to_be_promote"{
            let toX = Int(to.prefix(1))!
            let toY = Int(to.suffix(1))!
            let toIndex = coordinateToIndex(x: toX, y: toY)
            if !moveable && !save_kif && board[toIndex.0][toIndex.1].contains("王"){is_ok_p_select = false;return}
            var piece_name = String(board[toIndex.0][toIndex.1].prefix(1))
            //kif.removeLast()
            if let promotedPiece = promotionMap[piece_name] {
                piece_name = promotedPiece
            }
            board[toIndex.0][toIndex.1]=piece_name+"-"+currentPlayer
        } else {
            let fromX = Int(from.prefix(1))!
            let fromY = Int(from.suffix(1))!
            let toX = Int(to.prefix(1))!
            let toY = Int(to.suffix(1))!
            let fromIndex = coordinateToIndex(x: fromX, y: fromY)
            let toIndex = coordinateToIndex(x: toX, y: toY)
            let reversePromotionMap = Dictionary(uniqueKeysWithValues: promotionMap.map { ($0.value, $0.key) })
            if !board[toIndex.0][toIndex.1].isEmpty {
                if !moveable && !save_kif && board[toIndex.0][toIndex.1].contains("王"){is_ok_p_select = false;return}
                let capturedPiece = board[toIndex.0][toIndex.1]
                if currentPlayer == "S" {
                    if capturedPiece.hasSuffix("-G") {
                        let pieceName = String(capturedPiece.prefix(capturedPiece.count - 2))
                        if let originalPiece = reversePromotionMap[pieceName] {
                            sHave.append(originalPiece)
                        } else {sHave.append(pieceName)}
                        board[toIndex.0][toIndex.1] = board[fromIndex.0][fromIndex.1] // 先手の駒を移動
                        board[fromIndex.0][fromIndex.1] = "" // 移動元を空にする
                    } else if capturedPiece.hasSuffix("-S") {
                        is_ok_p_select = false
                    }
                } else if currentPlayer == "G" {
                    if capturedPiece.hasSuffix("-S") {
                        // 先手の駒を後手の持ち駒に追加
                        let pieceName = String(capturedPiece.prefix(capturedPiece.count - 2))
                        //元の駒に変換
                        if let originalPiece = reversePromotionMap[pieceName] {
                            gHave.append(originalPiece)
                        } else {gHave.append(pieceName)}
                        board[toIndex.0][toIndex.1] = board[fromIndex.0][fromIndex.1] // 後手の駒を移動
                        board[fromIndex.0][fromIndex.1] = "" // 移動元を空にする
                    } else if capturedPiece.hasSuffix("-G") {
                        is_ok_p_select = false
                        print("自分の駒です")
                    }
                }
            } else {
                // 移動先に駒がない場合、ただ移動する
                board[toIndex.0][toIndex.1] = board[fromIndex.0][fromIndex.1]
                board[fromIndex.0][fromIndex.1] = "" // 移動元を空にする
            }
            
            //なる場合
            if qualifier == "成"{
                var piece_name = String(board[toIndex.0][toIndex.1].prefix(1))
                //print("\(piece_name)が成")
                // 成り駒に変換
                if let promotedPiece = promotionMap[piece_name] {
                    piece_name = promotedPiece
                }
                print(piece_name) // 出力: 全
                board[toIndex.0][toIndex.1]=piece_name+"-"+currentPlayer
            }
            
        }
    }
}
    /*
    func printBoard(board: [[String]]) {
        for row in board {print(row.map { $0.isEmpty ? "" : $0 }.joined(separator: " "))}
    }
    
    
    
    
    func convertFullWidthAndKanjiToHalfWidth(input: String) -> String {
        let kanjiToNumber: [Character: Character] = [
            "一": "1", "二": "2", "三": "3", "四": "4", "五": "5", "六": "6", "七": "7", "八": "8", "九": "9"
        ];var result = ""
        for char in input {
            if let halfWidth = kanjiToNumber[char] {
                result.append(halfWidth)
            } else if let scalar = char.unicodeScalars.first, scalar.value >= 0xFF01 && scalar.value <= 0xFF5E {
                let halfWidthChar = Character(UnicodeScalar(scalar.value - 0xFEE0)!)
                result.append(halfWidthChar)
            } else {result.append(char)}
        }
        return result
    }
    
    
    // 文字列からto、fromの情報を抽出する関数
    func parseShogiMove(move: String) -> (to: String, from: String, qualifier:String)? {
        let regexPattern = "([０-９一二三四五六七八九]+)([^\\(]+)\\(([^)]+)\\)"
        let regex = try! NSRegularExpression(pattern: regexPattern, options: [])
        let nsrange = NSRange(move.startIndex..<move.endIndex, in: move)    
        if move.contains("打") {
            da_piece = true
            let regexPattern = "([０-９一二三四五六七八九]+)(.*)打"
            let regex = try! NSRegularExpression(pattern: regexPattern, options: [])
            let nsrange = NSRange(move.startIndex..<move.endIndex, in: move)
            if let match = regex.firstMatch(in: move, options: [], range: nsrange) {
                let kanjiRange = Range(match.range(at: 1), in: move)!
                let betweenRange = Range(match.range(at: 2), in: move)!
                let kanjiPart = String(move[kanjiRange])
                let betweenText = String(move[betweenRange])
                let to = convertFullWidthAndKanjiToHalfWidth(input: kanjiPart)//打つ場所
                let from = betweenText//打つ駒の名前
                let qualifier = ""
                return (to,from, qualifier)
            }
        }
        da_piece = false
        if let match = regex.firstMatch(in: move, options: [], range: nsrange) {
            let toRange = Range(match.range(at: 1), in: move)!
            let fromRange = Range(match.range(at: 3), in: move)!        
            // 'to' は全角数字や漢数字から変換
            let to = convertFullWidthAndKanjiToHalfWidth(input: String(move[toRange]))
            // 'from' はそのまま
            let from = String(move[fromRange])
            var qualifier = String(move[move.index(move.startIndex, offsetBy: 3)])
            if qualifier == "(" {qualifier=""}
            return (to, from,qualifier)
        }
        return nil
    }
    
    
    
    
    */
    /*
    //--------------------------------------
    func cmd(cmd_phrase:String){
        is_ok_p_select = true
        if let result = parseShogiMove(move: cmd_phrase) {
            count_board+=1
            current_player = current_player == "S" ? "G" : "S"
            movePiece(board: &board, from: result.from, to: result.to, currentPlayer: current_player, sHave: &sHave, gHave: &gHave, qualifier: result.qualifier)
            if is_ok_p_select {
                //print("\n\(count_board)手目、player: \(current_player)",cmd_phrase)
                //print(gHave)
                //printBoard(board: board)
                //print(sHave)
            }else{
                count_board -= 1
                current_player = current_player == "S" ? "G" : "S"
            }
        } else {
            //print("Invalid move format")
        }
    }
    
    */
    /*
     # ----  ぴよ将棋 棋譜ファイル  ----
     棋戦：テスト
     戦型：
     開始日時：2024/12/07 11:31:46
     終了日時：
     手合割：平手
     先手：プレイヤー(R511)
     後手：Lv1 ひよこ(R30)
     手数----指手---------消費時間--
     1 ７六歩(77)( 0:02/00:00:02)   
     2 ８四歩(83)( 0:01/00:00:01)   
     3 ２六歩(27)( 0:01/00:00:03)
     4 ３四歩(33)( 0:01/00:00:02)    
     5 中断       ( 0:04/00:00:07)
     まで4手で中断
     
     */


