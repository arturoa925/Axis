import Foundation
import WatchConnectivity
import Observation

@Observable
final class WatchConnectivityManager: NSObject, WCSessionDelegate {
    var templates: [WatchTemplatePayload] = []
    var isPhoneReachable: Bool = false

    override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func sendCompletedWorkout(_ payload: WatchCompletedWorkoutPayload) {
        guard let data = try? JSONEncoder().encode(payload) else { return }
        WCSession.default.transferUserInfo([WatchMessageKey.completedWorkout: data])
    }


    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isPhoneReachable = session.isReachable
            self.loadTemplates(from: session.receivedApplicationContext)
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isPhoneReachable = session.isReachable
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async {
            self.loadTemplates(from: applicationContext)
        }
    }

    private func loadTemplates(from context: [String: Any]) {
        guard
            let data = context[WatchMessageKey.templates] as? Data,
            let decoded = try? JSONDecoder().decode([WatchTemplatePayload].self, from: data)
        else { return }
        templates = decoded
    }
}
