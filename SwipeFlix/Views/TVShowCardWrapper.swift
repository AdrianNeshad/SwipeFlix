//
//  TVShowCardWrapper.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-06-06.
//

import SwiftUI

struct TVShowCardWrapper: View {
    let show: TVShow
    var tapAction: (() -> Void)? = nil

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        Group {
            if horizontalSizeClass == .compact {
                TVShowCard(show: show, tapAction: tapAction) // iPhone-version
            } else {
                TVShowCard_iPad(show: show, tapAction: tapAction) // iPad-version
            }
        }
    }
}
