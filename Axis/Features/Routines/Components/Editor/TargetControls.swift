//
//  TargetControls.swift
//  Axis
//
//  Created by Arturo Ayala on 5/7/26.
//

import SwiftUI

struct TargetControl: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.custom("NotoSans-Regular", size: 13, relativeTo: .caption))
                .foregroundStyle(.white.opacity(0.9))

            HStack(spacing: 12) {
                Button {
                    guard value > range.lowerBound else { return }
                    withAnimation(.smooth(duration: 0.18)) {
                        value -= 1
                    }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 13, weight: .bold))
                        .frame(width: 28, height: 28)
                        .background(.white.opacity(0.10))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white.opacity(value > range.lowerBound ? 0.86 : 0.28))
                .disabled(value <= range.lowerBound)

                Text("\(value)")
                    .font(.custom("NotoSans-Regular", size: 22, relativeTo: .title3))
                    .foregroundStyle(.white)
                    .frame(minWidth: 28)
                    .contentTransition(.numericText())

                Button {
                    guard value < range.upperBound else { return }
                    withAnimation(.smooth(duration: 0.18)) {
                        value += 1
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                        .frame(width: 28, height: 28)
                        .background(AppColors.TextBlue.opacity(0.18))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(AppColors.TextBlue)
                .disabled(value >= range.upperBound)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(12)
        .background(.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        }
    }
}
