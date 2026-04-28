
import SwiftUI

struct LaunchAnimation: View {
    @State private var animate = false
    @State private var drift = false

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

            ZStack {
                TimelineView(.animation) { timeline in
                    let time = timeline.date.timeIntervalSinceReferenceDate

                    ZStack {
                LaunchBubble(
                    color: Color(hex: "#5B7CFF").opacity(0.66),
                    size: 420,
                    blur: 18,
                    baseOffset: CGSize(width: -230, height: -320),
                    animatedOffset: CGSize(width: -190, height: -270),
                    scaleFrom: 1.0,
                    scaleTo: 1.08,
                    drift: drift,
                    duration: 9.5,
                    time: time
                )

                LaunchBubble(
                    color: Color(hex: "#315BFF").opacity(0.62),
                    size: 360,
                    blur: 16,
                    baseOffset: CGSize(width: 215, height: 360),
                    animatedOffset: CGSize(width: 170, height: 300),
                    scaleFrom: 1.0,
                    scaleTo: 1.12,
                    drift: drift,
                    duration: 10.5,
                    time: time
                )

                LaunchBubble(
                    color: Color(hex: "#774B1C").opacity(0.56),
                    size: 310,
                    blur: 14,
                    baseOffset: CGSize(width: 230, height: -330),
                    animatedOffset: CGSize(width: 185, height: -280),
                    scaleFrom: 1.0,
                    scaleTo: 1.1,
                    drift: drift,
                    duration: 8.8,
                    time: time
                )

                LaunchBubble(
                    color: Color(hex: "#F0F0F0").opacity(0.9),
                    size: 290,
                    blur: 12,
                    baseOffset: CGSize(width: -210, height: 360),
                    animatedOffset: CGSize(width: -160, height: 315),
                    scaleFrom: 1.0,
                    scaleTo: 1.07,
                    drift: drift,
                    duration: 11.2,
                    time: time
                )

                LaunchBubble(
                    color: Color(hex: "#D0DAFF").opacity(0.85),
                    size: 170,
                    blur: 8,
                    baseOffset: CGSize(width: -155, height: -70),
                    animatedOffset: CGSize(width: -115, height: -105),
                    scaleFrom: 0.98,
                    scaleTo: 1.13,
                    drift: drift,
                    duration: 7.8,
                    time: time
                )

                LaunchBubble(
                    color: Color(hex: "#F0F0F0").opacity(0.92),
                    size: 140,
                    blur: 8,
                    baseOffset: CGSize(width: 118, height: -155),
                    animatedOffset: CGSize(width: 92, height: -120),
                    scaleFrom: 1.0,
                    scaleTo: 1.12,
                    drift: drift,
                    duration: 8.6,
                    time: time
                )

                LaunchBubble(
                    color: Color(hex: "#6E8BFF").opacity(0.82),
                    size: 92,
                    blur: 5,
                    baseOffset: CGSize(width: 0, height: -310),
                    animatedOffset: CGSize(width: 26, height: -352),
                    scaleFrom: 0.96,
                    scaleTo: 1.18,
                    drift: drift,
                    duration: 6.9,
                    time: time
                )

                LaunchBubble(
                    color: Color(hex: "#774B1C").opacity(0.58),
                    size: 108,
                    blur: 6,
                    baseOffset: CGSize(width: -120, height: 190),
                    animatedOffset: CGSize(width: -82, height: 152),
                    scaleFrom: 1.0,
                    scaleTo: 1.16,
                    drift: drift,
                    duration: 7.3,
                    time: time
                )

                LaunchBubble(
                    color: Color(hex: "#8BA2FF").opacity(0.78),
                    size: 82,
                    blur: 5,
                    baseOffset: CGSize(width: 185, height: 110),
                    animatedOffset: CGSize(width: 150, height: 82),
                    scaleFrom: 0.98,
                    scaleTo: 1.18,
                    drift: drift,
                    duration: 7.6,
                    time: time
                )
                    }
                }

                LaunchSparkles(drift: drift)

                VStack(spacing: 18) {
                    Text("Axis")
//                        .font(AppTypography.title)
                        .font(.custom("IstokWeb-Regular", size: 36, relativeTo: .title))
                        .foregroundStyle(Color(hex: "#774B1C"))
                        .tracking(1.2)
                        .opacity(animate ? 1 : 0.7)
                        .scaleEffect(animate ? 1 : 0.96)
                        .shadow(color: Color(hex: "#F0F0F0").opacity(0.45), radius: 10, x: 0, y: 0)
                        .animation(.easeOut(duration: 1.15), value: animate)
                }
            }
            .compositingGroup()
        }
        .onAppear {
            animate = true
            drift = true
        }
    }
}

private struct LaunchBubble: View {
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
                            colors: [
                                Color.white.opacity(0.12),
                                Color.clear
                            ],
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

private struct LaunchSparkles: View {
    let drift: Bool

    private let points: [CGSize] = [
        CGSize(width: -145, height: -175),
        CGSize(width: 118, height: -238),
        CGSize(width: 196, height: -38),
        CGSize(width: -182, height: 48),
        CGSize(width: 144, height: 190),
        CGSize(width: -42, height: 246)
    ]

    var body: some View {
        ZStack {
            ForEach(points.indices, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(drift ? 0.85 : 0.35))
                    .frame(width: index.isMultiple(of: 2) ? 5 : 3,
                           height: index.isMultiple(of: 2) ? 5 : 3)
                    .blur(radius: 1.2)
                    .shadow(color: .white.opacity(0.55), radius: 10, x: 0, y: 0)
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
    LaunchAnimation()
}
