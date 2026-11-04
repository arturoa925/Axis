# Axis

**Small actions. Repeated daily.**

Axis is a strength-training app for iPhone and Apple Watch. Build workout routines on your iPhone, run them from your wrist set by set, and see every finished session in your history on the phone. The two apps stay in sync through **WatchConnectivity**.

Built with **SwiftUI**, **SwiftData**, and **WatchConnectivity**.

---

## How it works

```
 iPhone                                         Apple Watch
┌──────────────────────────┐                  ┌──────────────────────────┐
│ Create / edit routines   │ ── templates ──► │ Pick a routine           │
│ (SwiftData)              │  application     │ Track reps & sets        │
│                          │  context         │ Pause / resume timer     │
│ History of completed     │ ◄── workout ──── │ Session complete         │
│ workouts                 │  sendMessage /   │                          │
│                          │  transferUserInfo│                          │
└──────────────────────────┘                  └──────────────────────────┘
```

1. **Plan on iPhone.** Create a routine, pick exercises from the built-in library, and set target sets and reps for each one.
2. **Train on Apple Watch.** Your routines show up on the Watch automatically. Start one, count reps with the + and − buttons, and complete each set. Axis moves to the next exercise on its own.
3. **Review on iPhone.** When you finish, the Watch sends a summary back to your phone, and the phone saves it to History.

---

## Features

### iPhone
- **Routine builder**: search a library of **141 exercises** and filter it by equipment (barbell, dumbbell, kettlebell, cable, bodyweight, machine)
- **Per-exercise targets**: set target sets and reps for each exercise, and remove exercises (the order stays in sequence when you do)
- **Routine editor**: change existing routines; every change syncs to the Watch automatically
- **History**: a card for each completed workout showing the date, duration, and sets and reps per exercise
- **Onboarding**: animated launch screen, a greeting, and a one-time guide that also shows whether your Watch is connected

### Apple Watch
- **Routine picker** that lists the routines sent from your iPhone
- **Live session**: elapsed timer, current exercise, a rep counter with + and − buttons, and set progress ("Set 2 of 4")
- **Pause and resume**: time spent paused doesn't count toward the workout duration
- **Session summary** that sends the finished workout back to your iPhone

### Time-based theme
Both apps switch between a day theme (7am–7pm) and a night theme automatically. There's no toggle; a timer checks the clock every minute and again whenever the app comes to the foreground.

### Accessibility
- VoiceOver-aware onboarding: when VoiceOver is on, the timed transitions wait for you to tap **Continue** so focus isn't pulled away while it's still reading
- Shared accessibility modifiers in `Theme/AccessibilityModifiers.swift`

---

## Architecture

### Data model (SwiftData, iPhone)

```
WorkoutTemplate ──► [TemplateExercise] ──► Exercise          (the plan)
CompletedWorkout ──► [CompletedExercise]                      (what you actually did)
```

- `Exercise`: an entry in the exercise library (name, equipment, whether it's custom)
- `TemplateExercise`: an exercise placed in a routine, with its order and target sets and reps
- `WorkoutTemplate`: a named routine
- `CompletedWorkout` / `CompletedExercise`: a snapshot of a finished session. It's stored separately so editing a routine later never changes past history.

### Phone ↔ Watch sync

Only small, lightweight `Codable` payloads cross the connection. SwiftData models never leave the phone.

| Direction | Payload | Transport | Why |
| --- | --- | --- | --- |
| iPhone → Watch | `[WatchTemplatePayload]` | `updateApplicationContext` | Only the latest set of routines matters, and the Watch gets it the next time it wakes |
| Watch → iPhone | `WatchCompletedWorkoutPayload` | `sendMessage`, falling back to `transferUserInfo` | Delivered immediately when the phone is reachable; otherwise queued so a finished workout is never lost |

On the phone, `PhoneConnectivityManager` publishes the incoming workout, and `RoutinesHome` turns it into a `CompletedWorkout` and saves it.

### Watch session logic
`WatchWorkoutSession` (`@Observable`) holds all of the in-workout state: rep counting, set completion, moving to the next exercise, the pause and resume clock, and building the payload. The views stay thin, and the logic can be tested without any UI.

### Project structure

```
Axis/                          # iPhone app
├── App/                       # AxisApp, RootView (onboarding flow), AppState
├── Core/
│   ├── Models/                # SwiftData models
│   └── Services/              # PhoneConnectivityManager, Watch payloads
├── Features/
│   ├── Launch/  Onboarding/
│   ├── Routines/              # Home, CreateRoutine, RoutineEditor, exercise library
│   └── History/
└── Theme/                     # Colors, typography, button style, ThemeManager
AxisWatch Watch App/           # watchOS app
├── Services/                  # WatchConnectivityManager, WatchWorkoutSession, theme
└── Views/                     # Greeting, WorkoutSelector, StartedWorkout, WorkoutComplete
AxisTests/                     # iPhone unit tests
AxisWatch Watch AppTests/      # Watch unit tests
```

---

## Testing

Both targets use **Swift Testing** (`@Suite` / `@Test`), with about 100 tests in total:

- **iPhone (51):** converting a Watch payload into a `CompletedWorkout`, the template and completed-exercise models, `EquipmentType`, and `RoutineEditingLogic` (exercise filtering and save validation)
- **Watch (51):** `WatchWorkoutSession` from start to finish (rep tracking, completing sets, moving between exercises, the last-exercise check, pausing and resuming, building the payload) and `WatchActiveExercise`

Run them in Xcode with **⌘U**, choosing the iPhone or Watch scheme.

---

## Getting Started

### Requirements
- Xcode 26 or later
- iOS 26.4 or later and watchOS 26.5 or later
- A paired Apple Watch, or a paired iPhone and Apple Watch simulator, to test sync

### Run it
```bash
git clone https://github.com/arturoa925/Axis.git
cd Axis
open Axis.xcodeproj
```

1. Set your **Team** under *Signing & Capabilities* for the `Axis` and `AxisWatch Watch App` targets, and change the bundle IDs (`AA.Axis`, `AA.Axis.watchkitapp`) to your own.
2. Run the **Axis** scheme on an iPhone simulator that has a paired Watch simulator, then run the **AxisWatch Watch App** scheme on that Watch.
3. Create a routine on the phone. It should appear on the Watch within a few seconds.

---

## Roadmap

- [ ] HealthKit workout sessions on the Watch (heart rate, active calories). `CompletedWorkout` already has `totalCalories` and `averageHeartRate` fields ready for this
- [ ] Custom exercises (`Exercise.isCustom` is already in the model)
- [ ] Progress charts in History

---

## Author

**Arturo Ayala**: [GitHub](https://github.com/arturoa925) · [LinkedIn](https://linkedin.com/in/arturo-ayala-775493187)
