import Foundation

class ChatBase{
    //var chatMessages: [ChatMessage] = []
    func extractStrings(from message: String) -> (String?, String?) {
        // 正規表現パターンを定義
        let pattern = "@([^@]+)@(.+)"
        // 正規表現オブジェクトを作成
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return ("", "")
        }
        
        // 一致結果を検索
        let matches = regex.matches(in: message, options: [], range: NSRange(location: 0, length: message.utf16.count))
        // 一致結果が見つからなかった場合
        guard let match = matches.first else {
            return ("", "")
        }
        // NSRange から String に変換
        if let range1 = Range(match.range(at: 1), in: message),
           let range2 = Range(match.range(at: 2), in: message) {
            let extracted1 = String(message[range1])
            let extracted2 = String(message[range2])
            return (extracted1, extracted2)
        }
        return ("", "")
    }
    func sendChatMessage(message: String) {
        //SendButton.text = "++++send chat メッセージ送信中++++"
        var url:URL! = URL(string: "\(endpoint)/chat.json")
        let admin_announce = String(message.prefix(5)) == "admin" && my_Player_name == "Roughfts"
        var send_message = message
        if admin_announce {
            url = URL(string: "\(endpoint)/admin.json")
            send_message = String(message.dropFirst(5))
            DispatchQueue.main.async {
                self.sendChatMessage(message: "!admin!\(send_message)")
            }
        }
        let chatData: [String: Any] = [
            "name": admin_announce ? "運営" : my_Player_name,
            "message": send_message,
            "timestamp": Date().timeIntervalSince1970
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: chatData)
        URLSession.shared.dataTask(with: request) { [self] _, _, error in
            if let error = error {print("Error sending chat message: \(error.localizedDescription)")
            } else {print("Message sent successfully");deleteOldChats(admin:admin_announce)}
        }.resume()
    }
    
    
    func deleteOldChats(admin:Bool) {
        let which_url = admin ? "admin" : "chat"
        guard let url = admin ? URL(string: "\(endpoint)/admin.json") : URL(string: "\(endpoint)/chat.json") else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {print("Error fetching chats: \(error)");return}
            guard let data = data else {print("No data received.");return}
            do {
                if let chats = try JSONSerialization.jsonObject(with: data) as? [String: [String: Any]] {
                    let sortedChats = chats.sorted(by: {($0.value["timestamp"] as? Double ?? 0) > ($1.value["timestamp"] as? Double ?? 0)})
                    let chatsToDelete = sortedChats.dropFirst(18) // 最初の10個を残す
                    
                    //History Save ---- 30
                    
                    for (key, _) in chatsToDelete {print("Deleting chat ID: \(key)");self.deleteChat(messageId: key,admin:which_url)}
                } else {print("No chat messages found or wrong format received.")}
            } catch {print("Error parsing chat data: \(error)")}
        }.resume() // データタスクを開始
    }
    
    
    func deleteChat(messageId: String,admin:String) {
        guard let url = URL(string: "\(endpoint)/\(admin)/\(messageId).json") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        let deleteTask = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {print("Error deleting chat: \(error)");return}
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {print("Successfully deleted chat ID: \(messageId)")
            } else {print("Failed to delete chat ID: \(messageId)")}
        }
        deleteTask.resume() // 削除タスクを開始
    }
    
    
    struct ChatMessage: Codable, Hashable {
        let message: String
        let name: String
        let timestamp: Double
    }
    
    var previousChatMessages: Set<ChatMessage> = []
    func fetchNewChatMessages(completion: @escaping ([ChatMessage]) -> Void) {
        guard let url = URL(string: "\(endpoint)/chat.json") else {return}
        let task = URLSession.shared.dataTask(with: url) { [self] data, response, error in
            guard let data = data, error == nil else {return}
            let decoder = JSONDecoder()
            do {
                let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                var newChatMessages: [ChatMessage] = []
                for (_, value) in jsonDictionary ?? [:] {
                    if let chatMessageData = try? JSONSerialization.data(withJSONObject: value, options: []),
                       let chatMessage = try? decoder.decode(ChatMessage.self, from: chatMessageData) {
                        newChatMessages.append(chatMessage)
                    }
                }
                let newMessages = newChatMessages.filter { newMessage in
                    !previousChatMessages.contains(where: { $0.message == newMessage.message && $0.timestamp == newMessage.timestamp })
                }
                previousChatMessages.formUnion(newMessages)
                DispatchQueue.main.async {
                    let sortedNewMessages = newMessages.sorted { $0.timestamp < $1.timestamp }
                    completion(sortedNewMessages)
                }
            } catch {print("Error decoding JSON: \(error.localizedDescription)")}
        }
        task.resume()
    }
}
