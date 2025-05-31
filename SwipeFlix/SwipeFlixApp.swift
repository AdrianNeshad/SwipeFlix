//
//  SwipeFlixApp.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-05-31.
//

import SwiftUI

@main
struct SwipeFlixApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    var body: some Scene {
        WindowGroup {
            SwipeFlixIndex()
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
