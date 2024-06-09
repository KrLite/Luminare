//
//  LuminareModalWindow.swift
//
//
//  Created by Kai Azim on 2024-04-14.
//
// Huge thanks to https://cindori.com/developer/floating-panel :)

import SwiftUI

class LuminareModal<Content>: NSWindow where Content: View {
    @Binding var isPresented: Bool
    let closeOnDefocus: Bool
    let compactMode: Bool

    init(
        view: () -> Content,
        isPresented: Binding<Bool>,
        closeOnDefocus: Bool,
        compactMode: Bool
    ) {
        self._isPresented = isPresented
        self.closeOnDefocus = closeOnDefocus
        self.compactMode = compactMode
        super.init(
            contentRect: .zero,
            styleMask: [.fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        let hostingView = NSHostingView(rootView: LuminareModalView(view(), compactMode: compactMode)
            .environment(\.floatingPanel, self)
            .environment(\.tintColor, LuminareSettingsWindow.tint))

        collectionBehavior.insert(.fullScreenAuxiliary)
        level = .floating
        backgroundColor = .clear
        contentView = hostingView
        contentView?.wantsLayer = true
        ignoresMouseEvents = false
        isOpaque = false
        hasShadow = true
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        animationBehavior = .documentWindow

        center()
    }

    func updateShadow(for duration: Double) {
        guard isPresented else { return }

        let frameRate: Double = 60
        let updatesCount = Int(duration * frameRate)
        let interval = duration / Double(updatesCount)

        for i in 0...updatesCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * interval) {
                self.invalidateShadow()
            }
        }
    }

    override func close() {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.15
            self.animator().alphaValue = 0
        }, completionHandler: {
            super.close()
        })
        self.isPresented = false
    }

    override func resignMain() {
        super.resignMain()

        if closeOnDefocus {
            close()
        }
    }

    override func keyDown(with event: NSEvent) {
        let wKey = 13
        if event.keyCode == wKey && event.modifierFlags.contains(.command) {
            close()
            return
        }
        super.keyDown(with: event)
    }

    override func mouseDown(with event: NSEvent) {
        let titlebarHeight: CGFloat = compactMode ? 12 : 16
        if event.locationInWindow.y > frame.height - titlebarHeight {
            super.performDrag(with: event)
        } else {
            super.mouseDragged(with: event)
        }
    }

    override var canBecomeKey: Bool {
        return true
    }

    override var canBecomeMain: Bool {
        return true
    }
}

struct LuminareModalModifier<PanelContent>: ViewModifier where PanelContent: View {
    @Binding var isPresented: Bool
    @ViewBuilder let view: () -> PanelContent
    @State private var panel: LuminareModal<PanelContent>?
    let closeOnDefocus: Bool
    let compactMode: Bool

    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { newValue in
                if newValue {
                    present()
                } else {
                    close()
                }
            }
            .onDisappear {
                isPresented = false
                close()
            }
    }

    private func present() {
        guard panel == nil else { return }
        DispatchQueue.main.async {
            self.panel = LuminareModal(
                view: view,
                isPresented: $isPresented,
                closeOnDefocus: closeOnDefocus,
                compactMode: compactMode
            )
            self.panel?.orderFrontRegardless()
            self.panel?.makeKey()
        }
    }

    private func close() {
        panel?.close()
        panel = nil
    }
}

extension View {
    public func luminareModal<Content: View>(
        isPresented: Binding<Bool>,
        closeOnDefocus: Bool = false,
        compactMode: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.modifier(
            LuminareModalModifier(
                isPresented: isPresented,
                view: content,
                closeOnDefocus: closeOnDefocus,
                compactMode: compactMode
            )
        )
    }
}
