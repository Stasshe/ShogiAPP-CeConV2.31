class ConnectAI {
    
    // 盤面をSFEN形式に変換する関数
    func convertToSFEN(board: [[String]], shave: [String], ghave: [String], countTEBAN: String, player: String) -> String {
        var sfen = ""
        for row in board {
            var emptyCount = 0
            for square in row {
                if square.isEmpty {
                    emptyCount += 1
                } else {
                    if emptyCount > 0 {
                        sfen += String(emptyCount)
                        emptyCount = 0
                    }
                    sfen += convertPieceToSFEN(piece: square)
                }
            }
            if emptyCount > 0 {
                sfen += String(emptyCount)
            }
            sfen += "/"
        }
        // 最後のスラッシュを削除
        sfen = String(sfen.dropLast())
        // 持ち駒部分の変換
        let shavePart = convertHandPiecesToSFEN(holdings: shave,sfen_owner: "S")
        let ghavePart = convertHandPiecesToSFEN(holdings: ghave,sfen_owner: "G")
        var have_piece = shavePart + ghavePart
        if have_piece == "--" {have_piece = "-"}
        sfen += " \(player) \(have_piece) \(countTEBAN)"
        return sfen
    }
    
    
    
    // 駒の記号に変換する関数
    private func convertPieceToSFEN(piece: String) -> String {
        switch piece {
        case "香-G": return "l"
        case "桂-G": return "n"
        case "銀-G": return "s"
        case "金-G": return "g"
        case "王-G": return "k"
        case "飛-G": return "r"
        case "角-G": return "b"
        case "歩-G": return "p"
            //
        case "香-S": return "L"
        case "桂-S": return "N"
        case "銀-S": return "S"
        case "金-S": return "G"
        case "王-S": return "K"
        case "飛-S": return "R"
        case "角-S": return "B"
        case "歩-S": return "P"
            //
        case "圭-G": return "n"
        case "杏-G": return "l"
        case "全-G": return "s"
        case "龍-G": return "r"
        case "馬-G": return "b"
        case "と-G": return "p"
            //
        case "圭-S": return "N"
        case "杏-S": return "L"
        case "全-S": return "S"
        case "龍-S": return "R"
        case "馬-S": return "B"
        case "と-S": return "P"
        default: return ""
        }
    }
    
    // 持ち駒の変換
    private func convertHandPiecesToSFEN(holdings: [String],sfen_owner:String) -> String {
        var handPieces = [String: Int]()
        // 持ち駒の種類ごとに個数をカウント
        for piece in holdings {handPieces[piece, default: 0] += 1}
        // SFEN形式に変換
        var result = ""
        for (piece, count) in handPieces.sorted(by: { $0.key < $1.key }) {
            let piece_name = convertPieceToSFEN(piece: piece+"-"+sfen_owner)
            if count == 1 {
                result += piece_name // 1枚なら駒の種類だけ記載
            } else {
                result += "\(count)\(piece_name)" // 2枚以上なら枚数を記載
            }
        }
        return result.isEmpty ? "-" : result // 持ち駒がない場合は「-」
    }
}
