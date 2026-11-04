
// exercise library
// persistent model

import Foundation
import SwiftData

@Model
final class Exercise {
    var id: UUID
    var name: String
    var equipment: String

    init (
        id: UUID = UUID(),
        name: String,
        equipment: String
    ) {
        self.id = id
        self.name = name
        self.equipment = equipment
    }
}
