import Foundation
import Combine
import WatchConnectivity

final class PhoneConnectivityManager: NSObject, WCSessionDelegate, ObservableObject {
    @Published var isWatchReachable: Bool = false
    @Published var pendingCompletedWorkout: WatchCompletedWorkoutPayload?

    override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        // registers watch
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    // light weight copy of model
    func syncTemplates(_ templates: [WorkoutTemplate]) {
        guard WCSession.default.activationState == .activated else { return }

        let payloads = templates.map { template in
            WatchTemplatePayload(
                id: template.id.uuidString,
                name: template.name,
                exercises: template.exercises
                    .sorted { $0.orderIndex < $1.orderIndex }
                    .map { ex in
                        WatchExercisePayload(
                            name: ex.exercise.name,
                            targetSets: ex.targetSets,
                            targetReps: ex.targetReps,
                            orderIndex: ex.orderIndex
                        )
                    }
            )
        }

        guard let data = try? JSONEncoder().encode(payloads) else { return }
        try? WCSession.default.updateApplicationContext([WatchMessageKey.templates: data])
    }


    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async { self.isWatchReachable = session.isReachable }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async { self.isWatchReachable = session.isReachable }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        handleWorkoutData(message)
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        handleWorkoutData(userInfo)
    }

    private func handleWorkoutData(_ dict: [String: Any]) {
        guard
            let data = dict[WatchMessageKey.completedWorkout] as? Data,
            let payload = try? JSONDecoder().decode(WatchCompletedWorkoutPayload.self, from: data)
        else { return }
        DispatchQueue.main.async { self.pendingCompletedWorkout = payload }
    }
}
