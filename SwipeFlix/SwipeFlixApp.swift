//
//  SwipeFlixApp.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-05-31.
//

import SwiftUI
import GoogleMobileAds

@main
struct SwipeFlixApp: App {    
    @StateObject private var watchList = WatchListManager()

    init() {
        // Initialisera Google Mobile Ads SDK
        MobileAds.shared.start()
    }

    var body: some Scene {
        WindowGroup {
            SwipeFlixIndex()
                .environmentObject(watchList)
                .preferredColorScheme(.dark)
        }
    }
}
