//
//  SwipeCard.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-05-31.
//

import SwiftUI

struct SwipeCard<Content: View>: View {
    let content: Content
    let onRemove: (_ like: Bool) -> Void

    @State private var offset: CGSize = .zero
    private let threshold: CGFloat = 100

    init(@ViewBuilder content: () -> Content, onRemove: @escaping (_ like: Bool) -> Void) {
        self.content = content()
        self.onRemove = onRemove
    }

    var body: some View {
        content
            .rotationEffect(.degrees(Double(offset.width / 20)))
            .offset(x: offset.width, y: offset.height)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation
                    }
                    .onEnded { _ in
                        if abs(offset.width) > threshold {
                            let liked = offset.width > 0
                            withAnimation(.spring()) {
                                offset = CGSize(width: liked ? 1000 : -1000, height: 0)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onRemove(liked)
                            }
                        } else {
                            withAnimation(.spring()) {
                                offset = .zero
                            }
                        }
                    }
            )
    }

}
