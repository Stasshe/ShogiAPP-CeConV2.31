/*
AIの先手　後手　手順入れ替わってしまっている



*/
import SwiftUI
import SpriteKit
var endpoint = "https://shogi-gui-cecon-default-rtdb.firebaseio.com"
var my_Player_name: String {
    get {UserDefaults.standard.string(forKey: "my_Player_name") ?? "NoneName_Player"}
    set {UserDefaults.standard.set(newValue, forKey: "my_Player_name")}
}
var Crashed_roomID: String {
    get {UserDefaults.standard.string(forKey: "Crashed_roomID") ?? ""}
    set {UserDefaults.standard.set(newValue, forKey: "Crashed_roomID")}
}

var initboard = [
    ["香-G", "桂-G", "銀-G", "金-G", "王-G", "金-G", "銀-G", "桂-G", "香-G"],
    ["", "飛-G", "", "", "", "", "", "角-G", ""],
    ["歩-G", "歩-G", "歩-G", "歩-G", "歩-G", "歩-G", "歩-G", "歩-G", "歩-G"],
    ["", "", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", "", ""],
    ["歩-S", "歩-S", "歩-S", "歩-S", "歩-S", "歩-S", "歩-S", "歩-S", "歩-S"],
    ["", "角-S", "", "", "", "", "", "飛-S", ""],
    ["香-S", "桂-S", "銀-S", "金-S", "王-S", "金-S", "銀-S", "桂-S", "香-S"]
]
@main
struct GameApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .edgesIgnoringSafeArea(.all) // 画面全体を使用
                .accessibilityIgnoresInvertColors()
        }
    }
}

struct ContentView: View {
    var body: some View {
        SpriteView(scene: initialScene()) // 初期シーンを指定
            .ignoresSafeArea() // セーフエリアを無視して画面全体を使用
    }
    // 初期シーンを設定する関数
    func initialScene() -> SKScene {
        registerFont(withName: "KouzanGyoushoOTF")
        //KouzanBrushFontGyousyoOTF
        let menuScene = MenuScene(size: CGSize(width: 1080, height: 810)) // 初期画面としてGameSceneを使用
        menuScene.scaleMode = .aspectFill
        return menuScene
    }
}


func registerFont(withName name: String) {
    guard let fontURL = Bundle.main.url(forResource: name, withExtension: "otf"),
          let fontData = try? Data(contentsOf: fontURL) as CFData,
          let provider = CGDataProvider(data: fontData),
          let font = CGFont(provider) else {
        print("Failed to load font: \(name)")
        return
    }
    
    var error: Unmanaged<CFError>?
    if !CTFontManagerRegisterGraphicsFont(font, &error) {
        print("Error registering font: \(String(describing: error?.takeUnretainedValue()))")
    }
}
