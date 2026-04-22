//
//  AppState.swift
//  Axis
//
//  Created by Arturo Ayala on 4/21/26.
//

import Foundation
import SwiftUI
import Combine

final class AppState: ObservableObject {
    @Published var hasCompletedOnboarding: Bool = false
}
