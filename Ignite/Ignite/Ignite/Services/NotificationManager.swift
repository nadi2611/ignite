import Foundation
import UserNotifications
import FirebaseAuth
import FirebaseFirestore
import UIKit

class NotificationManager {
    static let shared = NotificationManager()

    // MARK: - Permission

    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    // MARK: - Token

    static func saveFCMToken(_ token: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).updateData([
            "fcmToken": token
        ])
    }

    static func clearFCMToken() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).updateData([
            "fcmToken": FieldValue.delete()
        ])
    }

    // MARK: - Deep link on tap

    // Post a notification so HomeView can navigate to the right tab/chat
    static func handleTap(userInfo: [AnyHashable: Any]) {
        let type = userInfo["type"] as? String ?? ""
        let matchId = userInfo["matchId"] as? String ?? ""

        switch type {
        case "match":
            NotificationCenter.default.post(name: .didTapMatchNotification, object: nil)
        case "message":
            NotificationCenter.default.post(
                name: .didTapMessageNotification,
                object: nil,
                userInfo: ["matchId": matchId]
            )
        default:
            break
        }
    }
}

extension Notification.Name {
    static let didTapMatchNotification = Notification.Name("didTapMatchNotification")
    static let didTapMessageNotification = Notification.Name("didTapMessageNotification")
}
