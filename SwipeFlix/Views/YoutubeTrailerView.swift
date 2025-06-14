//
//  YoutubeTrailerView.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-06-14.
//

import SwiftUI
import YouTubePlayerKit

struct YouTubeTrailerView: View {
    let videoID: String

    var body: some View {
        VStack {
            Text("Trailer")
                .font(.title2.bold())
                .padding(.top)
            
            YouTubePlayerView(
                YouTubePlayer(source: .video(id: videoID))
            )
            .frame(height: 250)
            .cornerRadius(12)
            .padding()

            Spacer()
        }
    }
}
