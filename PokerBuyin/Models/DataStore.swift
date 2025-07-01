// MARK: – App Delegate & Tab Bar

import UIKit
import Combine

struct Player: Codable {
    let id: UUID
    var name: String
}

struct Session: Codable {
    let id: UUID
    var date: Date
    var playerIds: [UUID]
    var firstBuyIn: Int
    var secondBuyIn: Int
    var additionalBuyIns: [UUID: Int]
    var finalChips: [UUID: Double?]
    var highHandOwner: UUID?
    var highHandType: String
    var highHandCards: String?
    var highHandValue: Double
    var isEnded: Bool = false
}

extension Notification.Name {
  static let sessionsDidChange = Notification.Name("sessionsDidChange")
}

class DataStore {
    static let shared = DataStore()
    private let usersKey = "users"
    private let sessionsKey = "sessions"
    private init() { load() }

    @Published private(set) var users:    [Player]  = []
    @Published private(set) var sessions: [Session] = []

    func addUser(name: String) {
        users.append(.init(id: .init(), name: name))
        saveUsers()
    }
    func deleteUser(id: UUID) {
        users.removeAll { $0.id == id }
        saveUsers()
    }
    func addSession(firstBuyIn: Int, secondBuyIn: Int, playerIds: [UUID]) {
        let highHandValue = Double(firstBuyIn - secondBuyIn) * Double(playerIds.count)
        let session = Session(
            id: .init(),
            date: .init(),
            playerIds: playerIds,
            firstBuyIn: firstBuyIn,
            secondBuyIn: secondBuyIn,
            additionalBuyIns: playerIds.reduce(into: [:]) { $0[$1] = 0 },
            finalChips: playerIds.reduce(into: [:]) { $0[$1] = nil },
            highHandOwner: nil,
            highHandType: "Full House",
            highHandCards: nil,
            highHandValue: highHandValue,
            isEnded: false
        )
        sessions.append(session)
        saveSessions()
        NotificationCenter.default.post(name: .sessionsDidChange, object: nil)
    }
    func updateSession(_ s: Session) {
        if let idx = sessions.firstIndex(where: { $0.id == s.id }) {
            sessions[idx] = s
            saveSessions()
        }
    }

    func endSession(id: UUID) {
         guard let i = sessions.firstIndex(where: { $0.id == id }) else { return }
         sessions[i].isEnded = true
         saveSessions()
     }

    private func saveUsers() {
        if let data = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(data, forKey: usersKey)
        }
    }
    private func saveSessions() {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: sessionsKey)
        }
    }
    private func load() {
        if let data = UserDefaults.standard.data(forKey: usersKey),
           let arr = try? JSONDecoder().decode([Player].self, from: data) {
            users = arr
        }
        if let data = UserDefaults.standard.data(forKey: sessionsKey),
           let arr = try? JSONDecoder().decode([Session].self, from: data) {
            sessions = arr
        }
    }
}
