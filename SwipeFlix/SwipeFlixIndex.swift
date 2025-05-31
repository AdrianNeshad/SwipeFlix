//
//  SwipeFlixIndex.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-05-31.
//

import SwiftUI

struct SwipeFlixIndex: View {
    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("AdsRemoved") private var AdsRemoved = false
    @StateObject private var storeManager = StoreManager()
    @State private var showingSheet = false

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    SwipeFlixIndex()
}
