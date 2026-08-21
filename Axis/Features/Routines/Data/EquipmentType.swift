//
//  EquipmentType.swift
//  Axis
//
//  Created by Arturo Ayala on 4/28/26.
//

import Foundation

enum EquipmentType: String, CaseIterable, Identifiable {
   case barbell
   case dumbbell
   case kettlebell
   case cable
   case bodyweight
   case machine

   var id: String { rawValue }

   var title: String {
       switch self {
       case .barbell:
           return "Barbell"
       case .dumbbell:
           return "Dumbbell"
       case .kettlebell:
           return "Kettlebell"
       case .cable:
           return "Cable"
       case .bodyweight:
           return "Bodyweight"
       case .machine:
           return "Machine"
       }
   }
}

struct ExerciseOption: Identifiable, Equatable {
   let id = UUID()
   let name: String
   let equipment: EquipmentType
}
