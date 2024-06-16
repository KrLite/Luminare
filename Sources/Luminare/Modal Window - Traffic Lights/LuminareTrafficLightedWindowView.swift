//
//  LuminareTrafficLightedWindowView.swift
//  
//
//  Created by Kai Azim on 2024-06-15.
//

import SwiftUI

struct LuminareTrafficLightedWindowView<Content>: View where Content: View {
    @Environment(\.tintColor) var tintColor

    let sectionSpacing: CGFloat = 12
    let cornerRadius: CGFloat = 12
    let content: Content

    var body: some View {
        VStack {
            VStack(spacing: sectionSpacing) {
                content
            }
            .padding(.top, 40) // titlebar
            .fixedSize()
            .background {
                VisualEffectView(
                    material: .menu,
                    blendingMode: .behindWindow
                )
            }
            .overlay {
                // The bottom has a smaller corner radius because a compact button will be used there
                UnevenRoundedRectangle(
                    topLeadingRadius: cornerRadius,
                    bottomLeadingRadius: 8 + cornerRadius,
                    bottomTrailingRadius: 8 + cornerRadius,
                    topTrailingRadius: cornerRadius
                )
                .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
            }
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: cornerRadius,
                    bottomLeadingRadius: 8 + cornerRadius,
                    bottomTrailingRadius: 8 + cornerRadius,
                    topTrailingRadius: cornerRadius
                )
            )

            Spacer()
        }
        .buttonStyle(LuminareButtonStyle())
        .tint(tintColor())
        .ignoresSafeArea()
    }
}
