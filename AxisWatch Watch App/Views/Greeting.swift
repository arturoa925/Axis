import SwiftUI

struct Greeting: View {
    var onComplete: (() -> Void)? = nil

    @State private var drift = false
    @State private var showTitle = false
    @State private var showLine1 = false
    @State private var showLine2 = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "#E7DED4"),
                    Color(hex: "#D8CFC4"),
                    Color(hex: "#F3ECE4")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            TimelineView(.animation) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate
                ZStack {
                    GreetingBubble(
                        color: Color(hex: "#5B7CFF").opacity(0.66),
                        size: 190, blur: 9,
                        baseOffset: CGSize(width: -104, height: -144),
                        animatedOffset: CGSize(width: -86, height: -122),
                        scaleFrom: 1.0, scaleTo: 1.08,
                        drift: drift, duration: 9.5, time: time
                    )
                    GreetingBubble(
                        color: Color(hex: "#315BFF").opacity(0.62),
                        size: 162, blur: 8,
                        baseOffset: CGSize(width: 97, height: 162),
                        animatedOffset: CGSize(width: 77, height: 135),
                        scaleFrom: 1.0, scaleTo: 1.12,
                        drift: drift, duration: 10.5, time: time
                    )
                    GreetingBubble(
                        color: Color(hex: "#774B1C").opacity(0.56),
                        size: 140, blur: 7,
                        baseOffset: CGSize(width: 104, height: -149),
                        animatedOffset: CGSize(width: 83, height: -126),
                        scaleFrom: 1.0, scaleTo: 1.1,
                        drift: drift, duration: 8.8, time: time
                    )
                    GreetingBubble(
                        color: Color(hex: "#F0F0F0").opacity(0.9),
                        size: 130, blur: 6,
                        baseOffset: CGSize(width: -95, height: 162),
                        animatedOffset: CGSize(width: -72, height: 142),
                        scaleFrom: 1.0, scaleTo: 1.07,
                        drift: drift, duration: 11.2, time: time
                    )
                    GreetingBubble(
                        color: Color(hex: "#D0DAFF").opacity(0.85),
                        size: 76, blur: 4,
                        baseOffset: CGSize(width: -70, height: -32),
                        animatedOffset: CGSize(width: -52, height: -47),
                        scaleFrom: 0.98, scaleTo: 1.13,
                        drift: drift, duration: 7.8, time: time
                    )
                    GreetingBubble(
                        color: Color(hex: "#6E8BFF").opacity(0.82),
                        size: 41, blur: 2,
                        baseOffset: CGSize(width: 0, height: -140),
                        animatedOffset: CGSize(width: 12, height: -158),
                        scaleFrom: 0.96, scaleTo: 1.18,
                        drift: drift, duration: 6.9, time: time
                    )
                    GreetingBubble(
                        color: Color(hex: "#774B1C").opacity(0.58),
                        size: 49, blur: 3,
                        baseOffset: CGSize(width: -54, height: 86),
                        animatedOffset: CGSize(width: -37, height: 68),
                        scaleFrom: 1.0, scaleTo: 1.16,
                        drift: drift, duration: 7.3, time: time
                    )
                    GreetingBubble(
                        color: Color(hex: "#8BA2FF").opacity(0.78),
                        size: 37, blur: 2,
                        baseOffset: CGSize(width: 83, height: 50),
                        animatedOffset: CGSize(width: 68, height: 37),
                        scaleFrom: 0.98, scaleTo: 1.18,
                        drift: drift, duration: 7.6, time: time
                    )
                }
            }

            GreetingSparkles(drift: drift)

            VStack(spacing: 10) {
                Text("Axis")
                    .font(.custom("IstokWeb-Regular", size: 22, relativeTo: .title))
                    .foregroundStyle(WatchColors.textBrown)
                    .tracking(1.2)
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : 6)
                    .shadow(color: Color(hex: "#F0F0F0").opacity(0.45), radius: 6, x: 0, y: 0)
                    .animation(.easeOut(duration: 1.15), value: showTitle)

                VStack(spacing: 3) {
                    Text("Small Actions.")
                        .font(.system(size: 12))
                        .foregroundStyle(WatchColors.textBlue)
                        .opacity(showLine1 ? 1 : 0)
                        .offset(y: showLine1 ? 0 : 5)
                        .animation(.easeOut(duration: 0.8), value: showLine1)

                    Text("Repeated Daily.")
                        .font(.system(size: 12))
                        .foregroundStyle(WatchColors.textBlue)
                        .opacity(showLine2 ? 1 : 0)
                        .offset(y: showLine2 ? 0 : 5)
                        .animation(.easeOut(duration: 0.8), value: showLine2)
                }
            }
            .multilineTextAlignment(.center)
        }
        .onAppear {
            drift = true
            withAnimation(.easeOut(duration: 0.7)) { showTitle = true }
            withAnimation(.easeOut(duration: 0.8).delay(0.35)) { showLine1 = true }
            withAnimation(.easeOut(duration: 0.8).delay(0.65)) { showLine2 = true }
            Task {
                try? await Task.sleep(for: .seconds(3))
                onComplete?()
            }
        }
    }
}

private struct GreetingBubble: View {
    let color: Color
    let size: CGFloat
    let blur: CGFloat
    let baseOffset: CGSize
    let animatedOffset: CGSize
    let scaleFrom: CGFloat
    let scaleTo: CGFloat
    let drift: Bool
    let duration: Double
    let time: TimeInterval

    private var progress: CGFloat {
        CGFloat((sin(time / duration * .pi * 2) + 1) / 2)
    }

    private var liveOffset: CGSize {
        CGSize(
            width: baseOffset.width + (animatedOffset.width - baseOffset.width) * progress,
            height: baseOffset.height + (animatedOffset.height - baseOffset.height) * progress
        )
    }

    private var liveScale: CGFloat {
        scaleFrom + (scaleTo - scaleFrom) * progress
    }

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color.white.opacity(0.22),
                        color.opacity(0.52),
                        color.opacity(0.22),
                        color.opacity(0.03)
                    ],
                    center: UnitPoint(x: 0.38, y: 0.32),
                    startRadius: 2,
                    endRadius: size * 0.72
                )
            )
            .frame(width: size, height: size)
            .blur(radius: blur * 1.45)
            .overlay {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.white.opacity(0.12), Color.clear],
                            center: .topLeading,
                            startRadius: 1,
                            endRadius: size * 0.42
                        )
                    )
                    .blur(radius: blur * 0.75)
            }
            .scaleEffect(drift ? liveScale : scaleFrom)
            .offset(drift ? liveOffset : baseOffset)
    }
}

private struct GreetingSparkles: View {
    let drift: Bool

    private let points: [CGSize] = [
        CGSize(width: -65, height: -79),
        CGSize(width: 53, height: -107),
        CGSize(width: 88, height: -17),
        CGSize(width: -82, height: 22),
        CGSize(width: 65, height: 86),
        CGSize(width: -19, height: 111)
    ]

    var body: some View {
        ZStack {
            ForEach(points.indices, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(drift ? 0.85 : 0.35))
                    .frame(
                        width: index.isMultiple(of: 2) ? 3 : 2,
                        height: index.isMultiple(of: 2) ? 3 : 2
                    )
                    .blur(radius: 0.8)
                    .shadow(color: .white.opacity(0.55), radius: 6, x: 0, y: 0)
                    .offset(points[index])
                    .scaleEffect(drift ? 1.25 : 0.75)
                    .animation(
                        .easeInOut(duration: Double(2 + index) * 0.55)
                        .repeatForever(autoreverses: true),
                        value: drift
                    )
            }
        }
    }
}

#Preview {
    Greeting()
}
