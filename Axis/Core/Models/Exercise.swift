
// exercise library
import Foundation
import SwiftData

@Model
final class Exercise {
    var id: UUID
    var name: String
    var equipment: String
    var isCustom: Bool
    
    init (
        id: UUID = UUID(),
        name: String,
        equipment: String,
        isCustom: Bool = false
    ) {
        self.id = id
        self.name = name
        self.equipment = equipment
        self.isCustom = isCustom
    }
}
