# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Axis is a native iOS workout-tracking app built with SwiftUI and SwiftData. It allows users to create workout routines, run live workout sessions (with planned Apple Watch integration), and review completed workouts.

## Build & Run

Open `Axis.xcodeproj` in Xcode and run on a simulator or device. There is no package manager (no SPM dependencies, no CocoaPods).

To run tests: `Cmd+U` in Xcode, or via CLI:
```
xcodebuild test -project Axis.xcodeproj -scheme Axis -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Architecture

### App Initialization (`Axis/App/`)
- `AxisApp.swift` — entry point; creates the `SwiftData` model container with all seven models and injects `AppState` as an environment object.
- `RootView.swift` — controls the timed onboarding sequence: `launch (0s) → greeting (2.8s) → guide (6.2s) → main (10.2s)`. The four states are a private `OnboardingStep` enum local to this file.
- `MainTabView.swift` — currently renders `RoutinesHome` directly; tab bar not yet built out.
- `AppState.swift` — `ObservableObject` with a single flag: `hasCompletedOnboarding`.

### Data Models (`Axis/Core/Models/`)
All models are SwiftData `@Model` classes. They form a lifecycle chain:

```
Exercise (library)
  └─ TemplateExercise  ← belongs to WorkoutTemplate (a saved routine)
       └─ ActiveExercise  ← belongs to ActiveWorkout (live session)
            └─ CompletedExercise  ← belongs to CompletedWorkout (history)
```

- **Exercise** — exercise library entry (`name`, `equipment`, `isCustom`).
- **TemplateExercise** — links an `Exercise` to a `WorkoutTemplate` with `targetSets`, `targetReps`, `orderIndex`.
- **WorkoutTemplate** — a saved routine containing an ordered array of `TemplateExercise`.
- **ActiveWorkout** — instantiated from a `WorkoutTemplate` via `convenience init(template:)`; tracks `elapsedTime`, `currentExerciseIndex`, `isPaused`.
- **ActiveExercise** — live state per exercise: `currentRepCount`, `completedSets`; `isComplete` is a computed property.
- **CompletedWorkout / CompletedExercise** — immutable history snapshots, created from `ActiveWorkout` via `convenience init(from:)`.

### Services (`Axis/Core/Services/`)
- `WorkoutSessionManager.swift` — `@Observable` class that owns the in-progress `ActiveWorkout`. All workout interaction (start, pause, resume, incrementRep, completeSet, finish) goes through this manager. It is not yet wired into the SwiftData context; `finishWorkout()` returns a `CompletedWorkout` but the caller is responsible for inserting it.
- `WatchConnectionCheck.swift` — placeholder; currently empty.

### Features

**Launch** (`Features/Launch/`) — `LaunchView` wraps `LaunchAnimation`.

**Onboarding** (`Features/Onboarding/`) — `OnboardingGreeting` wraps `QuoteBlock`; `OnboardingGuide` wraps `WatchConnectionStatusBlock`. Both are thin wrappers — logic lives in the components.

**Routines** (`Features/Routines/`) — The only built-out feature so far.
- `RoutinesHome` — lists saved `WorkoutTemplate` rows fetched via `@Query`; opens `CreateRoutine` sheet or `RoutineEditor` sheet.
- `CreateRoutine` — form for naming a new routine and picking exercises from the library.
- `RoutineEditor` — edits an existing `WorkoutTemplate`.
- `Components/Editor/` — `AddExerciseSection`, `ExerciseCard`, `TargetControls` are shared between create and edit flows.
- `Data/ExerciseOptionLibrary.swift` — static array of ~80 `ExerciseOption` values (not persisted in SwiftData; used for the picker).
- `Data/EquipmentType.swift` — `EquipmentType` enum (`barbell`, `dumbbell`, `cable`, `bodyweight`, `machine`) and the `ExerciseOption` struct.

**History** (`Features/History/`) — Feature currently in development.
- here users will be able to see past completed workouts
- the history feature will display cards as the format
- each card will have the name of the completed workout, the date completed, the elapsed time, list of exercises



### Theme (`Axis/Theme/`)
- `AppColors.swift` — all colors as `static let` on a struct; `Color(hex:)` extension supports 3/6/8-digit hex.
- `AppTypography.swift` — two fonts: `IstokWeb-Regular` (titles, 32pt) and `NotoSans-Regular` (body, 24pt). Font files live in `Istok_Web/` and `Noto_Sans/` at the repo root.

## State Management Patterns

- **Global session state** (`AppState`) — passed as `.environmentObject`.
- **Workout session state** (`WorkoutSessionManager`) — `@Observable`; should be passed via `.environment` or instantiated at the view level that needs it.
- **Persistence** — SwiftData `@Query` for reads, `@Environment(\.modelContext)` for writes.
- Views own local UI state with `@State`; no view models yet.

## Direction for app
- iphone will be used to create and view routines
- apple watch will be used to start and end workouts
