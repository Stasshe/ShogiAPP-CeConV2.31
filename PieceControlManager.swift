import Foundation
import CoreGraphics

class PieceControlManager {
    
    // 駒ごとの動きの定義（簡単な例）
    func movesForPiece(type: String, owner: String, flipped:Bool) -> [(dx : Int, dy : Int, isInfinite: Bool)] {
        let formatted_type = String(type.prefix(1))
        //owner == "S" ? -1 : 1
        var dy_S_or_G = owner == "S" ? -1 : 1
        if flipped {dy_S_or_G *= -1}
        switch formatted_type {
        case "歩":
            return [(dx : 0, dy : dy_S_or_G, isInfinite: false)]
        case "香":
            return [(dx : 0, dy : dy_S_or_G, isInfinite: true)]
        case "桂":
            return [(dx : 1, dy : 2*dy_S_or_G, isInfinite: false),(dx : -1, dy : 2*dy_S_or_G, isInfinite: false)]
        case "角":
            return [(dx : 1, dy : 1, isInfinite: true), (dx : -1, dy : -1, isInfinite: true),
                    (dx : -1, dy : 1, isInfinite: true), (dx : 1, dy : -1, isInfinite: true)]
        case "飛":
            return [(dx : 1, dy : 0, isInfinite: true), (dx : -1, dy : 0, isInfinite: true),
                    (dx : 0, dy : 1, isInfinite: true), (dx : 0, dy : -1, isInfinite: true)]
        case "銀":
            return [(dx : 1, dy : dy_S_or_G, isInfinite: false),
                    (dx : -1, dy : dy_S_or_G, isInfinite: false),
                    (dx : 1, dy : 0 - dy_S_or_G, isInfinite: false), 
                    (dx : -1, dy : 0 - dy_S_or_G, isInfinite: false),
                    (dx : 0, dy : dy_S_or_G, isInfinite: false)
            ]
        case "王":
            return [(dx : 1, dy : 0, isInfinite: false), (-1, dy : 0, isInfinite: false),
                    (dx : 0, dy : 1, isInfinite: false), (dx : 0, dy : -1, isInfinite: false),
                    (dx : 1, dy : 1, isInfinite: false), (-1, dy : 1, isInfinite: false),
                    (dx : 1, dy : -1, isInfinite: false), (-1, dy : -1, isInfinite: false)
            ]
        case "と","杏","圭","全","金":
            return [(dx : 0, dy : 1, isInfinite: false),
                    (dx : 1, dy : dy_S_or_G, isInfinite: false),
                    (dx : -1, dy : dy_S_or_G, isInfinite: false),
                    (dx : 1, dy : 0, isInfinite: false),
                    (dx : -1, dy : 0, isInfinite: false),
                    (dx :0, dy : -1, isInfinite: false)
            ]     
        case "馬":
            return [(dx : 1, dy : 1, isInfinite: true), (dx : -1, dy : -1, isInfinite: true),
                    (dx : -1, dy : 1, isInfinite: true), (dx : 1, dy : -1, isInfinite: true),
                    (dx : 1, dy : 0, isInfinite: false), (-1, dy : 0, isInfinite: false),
                    (dx : 0, dy : 1, isInfinite: false), (dx : 0, dy : -1, isInfinite: false),
                    (dx : 1, dy : -1, isInfinite: false), (-1, dy : -1, isInfinite: false),
                    (dx : 1, dy : 1, isInfinite: false), (-1, dy : 1, isInfinite: false)]
            
        case "龍":
            return [(dx : 1, dy : 0, isInfinite: true), (-1, dy : 0, isInfinite: true),
                    (dx : 0, dy : 1, isInfinite: true), (dx : 0, dy : -1, isInfinite: true),
                    (dx : 1, dy : 1, isInfinite: false), (-1, dy : 1, isInfinite: false),
                    (dx : 1, dy : -1, isInfinite: false), (-1, dy : -1, isInfinite: false)]
        default:
            return []
        }
    }
    
    // 駒の動ける範囲（ableMove）を計算
    func calculateMovablePositions(for piece: Piece, on board: [[String]], flipped: Bool) -> [String] {
        var ableMove: [String] = []
        let sflipped = flipped
        let moves = movesForPiece(type: piece.type, owner: piece.owner, flipped: sflipped)
        let piecePos = piece.shogiposition
        // 各動きに対して、駒が動ける位置を計算
        for move in moves {
            var x = 9 - Int(piecePos.x)
            var y = Int(piecePos.y) - 1
            var enemy_count = 0
            while true {
                if enemy_count == 1 {break}
                x += move.dx
                y += move.dy
                // 盤面の範囲外に出ないように fit to the board index 
                if x < 0 || x >= 9 || y < 0 || y >= 9 { break }
                // 盤面上の座標を取得
                let boardPosition = String(9 - x)+String(y + 1)
                // もし空きマスまたは敵の駒があるなら、その座標を候補として追加
                let pieceAtPosition = board[y][x]
                if pieceAtPosition == "" {
                    ableMove.append(boardPosition)
                } else if pieceAtPosition.suffix(1) != piece.owner {
                    ableMove.append(boardPosition)
                    enemy_count += 1
                } else {//味方
                    break
                }
                // 無限に動ける場合（香、飛、角など）はそのまま次のマスへ
                if !move.isInfinite { break }
            }
        }
        return ableMove
    }
}
