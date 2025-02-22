import Foundation
import SpriteKit
import CoreGraphics

class PieceControlManager {
    func oute(in scene: SKScene) {
        // アニメーションするラベルを作成
        let outeLabel = SKLabelNode(text: "王手")
        outeLabel.fontName = "KouzanBrushFontGyousyoOTF"
        outeLabel.fontSize = 100
        outeLabel.fontColor = .red
        outeLabel.position = CGPoint(x: scene.size.width + 100, y: scene.size.height / 2)
        outeLabel.zPosition = 11
        outeLabel.setScale(0.5)
        scene.addChild(outeLabel)
        
        let outeLabel2 = SKLabelNode(text: "王手")
        outeLabel2.fontName = "KouzanBrushFontGyousyoOTF"
        outeLabel2.fontSize = 100
        outeLabel2.fontColor = .black
        outeLabel2.position = CGPoint(x: scene.size.width + 100 - 50, y: scene.size.height / 2 - 50)
        outeLabel2.zPosition = 10
        outeLabel2.setScale(0.5)
        scene.addChild(outeLabel2)
        
        // アニメーションの動き
        let moveToCenter = SKAction.move(to: CGPoint(x: scene.size.width / 2, y: scene.size.height / 2), duration: 1.0)
        moveToCenter.timingMode = .easeOut
        
        let moveToLeft = SKAction.move(to: CGPoint(x: -100, y: scene.size.height / 2 + CGFloat.random(in: -100...100)), duration: 2.0)
        moveToLeft.timingMode = .easeIn
        
        let moveSequence = SKAction.sequence([moveToCenter, moveToLeft])
        
        // スケールアクション
        let scaleUp = SKAction.scale(to: 1.5, duration: 1.0)
        scaleUp.timingMode = .easeOut
        
        let scaleDown = SKAction.scale(to: 0.8, duration: 2.0)
        scaleDown.timingMode = .easeIn
        
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        
        // 並列アクション
        let groupAction = SKAction.group([moveSequence, scaleSequence])
        
        // アクション完了後にラベルを削除
        let remove = SKAction.removeFromParent()
        let fullAction = SKAction.sequence([groupAction, remove])
        
        // アニメーションを開始
        outeLabel.run(fullAction)
        outeLabel2.run(fullAction)
    }
    func isOute(board: [[String]], nowPlayer: String) -> Bool {
        let opponent = nowPlayer == "S" ? "G" : "S"
        var opponentKingPosition: (x: Int, y: Int)? = nil
        // 相手の王の位置を探す
        for y in 0..<board.count {
            for x in 0..<board[y].count {
                if board[y][x] == "王-\(opponent)" {
                    opponentKingPosition = (x, y)
                    break
                }
            }
            if opponentKingPosition != nil { break }
        }
        
        guard let kingPosition = opponentKingPosition else {
            print("エラー: 相手の王が見つかりません")
            return false
        }
        
        // 今のプレイヤーの駒の動きをチェック
        for y in 0..<board.count {
            for x in 0..<board[y].count {
                let piece = board[y][x]
                guard piece.hasSuffix("-\(nowPlayer)") else { continue }
                let type = piece.split(separator: "-")[0]
                let moves = movesForPiece(type: String(type), owner: nowPlayer, flipped: false)
                
                // 駒ごとの動きを計算
                for move in moves {
                    
                    var currentX = x
                    var currentY = y
                    
                    repeat {
                        currentX += move.dx
                        currentY += move.dy
                        
                        // 盤面外のチェック
                        if currentX < 0 || currentX >= 9 || currentY < 0 || currentY >= 9 { break }
                        
                        // 王が動ける範囲に入っているか確認
                        if (currentX, currentY) == kingPosition {
                            return true
                        }
                        
                        // 無限移動が可能な駒でない場合、1回で終了
                        if !move.isInfinite { break }
                        // 自分の駒にぶつかった場合、停止
                        let nextPiece = board[currentY][currentX]
                        if nextPiece != ""{
                            break
                        }
                        
                    } while move.isInfinite
                }
            }
        }
        return false
    }
    
    
    
    
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
