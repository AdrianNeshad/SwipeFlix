//
//  SwipeFlixApp.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-05-31.
//

import SwiftUI

@main
struct SwipeFlixApp: App {    
    @StateObject private var watchList = WatchListManager()

    var body: some Scene {
        WindowGroup {
            SwipeFlixIndex()
                .environmentObject(watchList)
                .preferredColorScheme(.dark)
        }
    }
}
