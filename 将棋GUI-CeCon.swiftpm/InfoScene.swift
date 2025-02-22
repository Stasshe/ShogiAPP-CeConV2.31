import UIKit

class InfoViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        let scrollView = UIScrollView(frame: view.bounds)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.contentSize = CGSize(width: view.frame.width, height: 2500) // コンテンツの高さを設定
        // スクロールインジケーターのスタイルと色
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.indicatorStyle = .white
        // スクロールインジケーターのインセット調整
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
        view.addSubview(scrollView)

        let closeButton = UIButton(type: .system)
        closeButton.setTitle("閉じる", for: .normal)
        closeButton.setTitleColor(.cyan, for: .normal)
        closeButton.frame = CGRect(x: 80, y: 20, width: 60, height: 30)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        
        
        let textView = UILabel()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = .white
        textView.numberOfLines = 0
        textView.text = """
        【ライセンス】
        pixabay/pintarest
        他
        個人利用のため詳細は省く
        
        【詳細説明】
            ・AIは「一人で研究」モードのみで使用可能です。外部の公開APIを使用し、「技巧」AIを使わせていただいています。作成者、並びにAPI化をした人に感謝します。
        
            ・しかしこのAIですが、Queryでsfenデータを送信する際、成駒を+で表現することができません。+はurlではEncodeされてしまいますが、サーバー側でデコード処理をしていないようですので、成駒は全て通上の駒として認識されています。仕方がありません。
        
            ・オンライン対戦は学校のwifiが遅い時は、ラグが発生する場合があります。最速で1秒ですが、平均3秒のラグは発生します。
            
        
        
        【機能追加履歴】
        -v2.31:放置してた問題（オンライン対戦で、相手がどこに打ってきたか）を解決
        -v2.30.d:王手
        -v2.30:対戦中の個人チャット追加
        -v2.28: ChatからroomIDのコピーができる、基本メッセージをUItextFieldに変更
        -v2.1~5: その他機能・UI・仕様変更
        -v2.0: オンライン対戦実装
        -v1.8: 一人で研究モードひとまず完成
        - v1.0: GUI/基本機能を実装
        - v0.8: Consoleでの将棋を実現
        
        【バグ修正履歴】
        -v2.31:小さいミス修正
        -v2.30.c: 成駒選択の時に正しく保存されていなかった
        -v2.29.d:福袋バグ
        -v2.29.c:スイッチ系のロジック
        -v2.29.b:盤面反転時における強制成駒
        -v2.29.a:ゲームシーン中での総合チャット追加
        -v2.28.U.H:飛車などの成駒で2.28.Uにおけるバグ再現可能
        -v2.28.U.f:忘れたけど何か少し変えた
        -v2.28.U:駒の動きチェック無効中（棋譜再現用）、一手目で王将を取った時に発生するクラッシュ
                 →バグ修正と同時にこの機能周りの利便性向上
        -v2.28.S:王将を取った時に発生する、2手同時巻き戻しバグを修正することによって起こる上書きの複製バグ
        -v2.28.S_pre: v2.28.Rの修正によるバグ（棋譜巻き戻し時の上書き保存機能のindexのずれ）
        -v2.28.R: 棋譜巻き戻し時から、棋譜履歴保存機能を切り、試合を進め、保存機能を切った時と違う手番で保存機能をオンにして更に試合を進め、全て巻き戻した時に発生するバグ
        　　　　　　→大幅な修正
        　　　　　　また、オンライン対戦での再入室時の棋譜を研究モードに貼り付けた時、同様のバグ
        -v2.26.a~d:以下のバグを修正
            ・後手が王をとる→自動的に一手前に戻るのでもう一度同じ手で王をとる→模譜情報コピー、貼り付け→後手の持ち駒の王が別の駒に変わるのでそのまま続行できるようになる
            ・盤面の駒を取り情報をコピペ(一手戻っても起こるかも)すると先手の持ち駒が後手の持ち駒に複製される(繰り返し使用することで重ねがけ可能)
            ・後手のターンのときにコピペをすることで後手のターンをスキップすることができる
            ・反転した後に手数を進めて反転した手まで戻すと駒が反転する
            ・王置き換えバグ使用後、先手が王をとる→一手前に戻す(先手後手関係なく持ち駒が全て消える)→一手先に進めるという手順をするととったはずの王が消えるか別の駒に置き換わる
            ・先手が残り一手で後手の王が取れる盤面(王手のとき)をコピペして王をとるとクラッシュする
            ・オンライン対戦の部屋番号入力時に模譜のコピーを入力するとクラッシュする(普通なら部屋が見つかりませんと表示される)
            ・模譜履歴保存状態でコピペした後に模譜履歴保存を切りコピペし、一手進めるボタンを押し続けると模譜履歴保存状態でコピーしたときの盤面になり、2回目にペーストした時の盤面にならない(再起動して2回目の模譜をペーストも同じことが起こる)
            ・オンライン対戦で後手のターンで終わっていても再起動して再び入室すると先手のターンになる(片方がオフラインのときに再入室したときだけ確認完了)
            ・模譜履歴保存状態で試合を進めて模譜履歴保存を切り、再び試合を進め、模譜履歴保存を切ったときと先手後手が逆のときに再び模譜履歴保存状態で試合を進めてコピペすると一手進めるボタンで最初から一手ずつ進めていくと保存していないところのデータはないが先手と後手は関係なくきりかわるので先手後手が入れ替わってしまう
            ・観戦モードのときに反転を押してから盤面をコピーし貼り付けると駒が反転してコピーされる
            
        -v2.25: オンライン対戦中のプレイヤーが差した後の盤面更新による干渉を修正
        
        -v2.24:王取得後に先手後手入れ替わるバグ
        
        -v2.23:以下の手順のクラッシュなど
            王(玉)をとる
            →勝利者と敗北者の表示
            →初期状態に戻す
            →もう一度王(玉)をとる(勝利者と敗北者の表示がでない)
            →一手前に戻す
            →もう一度別の方法で王(玉)をとる(ここの状態を①とする)
            →一手前に戻す
            →一手先に進める(本来はこの手よりは先に進めない)
            →一手先に進める
            →①と同じ状態になる(この手より先には進めない、戻るのはできる)
            
        -v2.21~2: 忘れた。チャット機能系。
        
        - v2.20: チャット機能追加
        
        """
        textView.frame = CGRect(x: 20, y: 50, width: view.frame.width - 40, height: 1600)
        scrollView.addSubview(textView)
        
        let middleTxt = UILabel()
        middleTxt.font = UIFont.systemFont(ofSize: 16)
        middleTxt.textColor = .white
        middleTxt.numberOfLines = 0
        middleTxt.text = """
        -------------------------------------------------------
        
        アプリ作成：石田尚幹
        デバッグ調査：白井悠雅,横山遙紀
        
        -------------------------------------------------------
        
        このアプリケーションは、MITライセンスの下で提供されています。これは、以下の条件に従う限り、自由に使用、コピー、修正、マージ、公開することができます。
        
            MIT License
            
            Copyright (c) [2024年] [石田尚幹]
            
            Permission is hereby granted, free of charge, to any person obtaining a copy
            of this software and associated documentation files (the "Software"), to deal
            in the Software without restriction, including without limitation the rights
            to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
            copies of the Software, and to permit persons to whom the Software is
            furnished to do so, subject to the following conditions:
                
            The above copyright notice and this permission notice shall be included in all
            copies or substantial portions of the Software.
            
            THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
            IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
            FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
            AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
            LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
            OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
            SOFTWARE.
        
        """
        middleTxt.font = UIFont.systemFont(ofSize: 16)
        middleTxt.textColor = .white
        middleTxt.textAlignment = .center
        middleTxt.frame = CGRect(x: 20, y: 1700, width: view.frame.width - 40, height: 500)
        scrollView.addSubview(middleTxt)
    }
    
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
