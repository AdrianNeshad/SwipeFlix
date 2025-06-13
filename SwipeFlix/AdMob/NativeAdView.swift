//
//  Untitled.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-06-13.
//

import SwiftUI
import GoogleMobileAds // Glöm inte att importera AdMob SDK

// En wrapper för Google Mobile Ads Native Ad View (UIKit) i SwiftUI
struct NativeAdView: UIViewRepresentable {
    let nativeAd: NativeAd // Annonsen vi ska visa

    func makeUIView(context: Context) -> NativeAdView {
        // Ladda din XIB-fil. Ersätt "UnifiedNativeAdView" med namnet på din XIB-fil.
        guard let nibObjects = Bundle.main.loadNibNamed("UnifiedNativeAdView", owner: nil, options: nil),
              let adView = nibObjects.first as? NativeAdView else {
            fatalError("Could not load GADNativeAdView from nib.")
        }
        return adView
    }

    func updateUIView(_ uiView: NativeAdView, context: Context) {
        // Ställ in den native annonsen på din GADNativeAdView
        uiView.nativeAd = nativeAd

        // Mappa annonsens data till dina UI-element som är anslutna via Outlets i XIB:en.
        // Se till att dessa Outlets är korrekt kopplade i din XIB-fil.

        // Rubrik
        (uiView.headlineView as? UILabel)?.text = nativeAd.headline

        // Bild
        if let image = nativeAd.images?.first?.image {
            (uiView.imageView as? UIImageView)?.image = image
        } else {
            // Hantera fall där ingen bild finns, t.ex. dölj UIImageView
            (uiView.imageView as? UIImageView)?.image = nil
        }

        // Beskrivning
        (uiView.bodyView as? UILabel)?.text = nativeAd.body

        // Annonsörens namn (om tillgängligt)
        if let advertiser = nativeAd.advertiser {
            (uiView.advertiserView as? UILabel)?.text = advertiser
            uiView.advertiserView?.isHidden = false
        } else {
            uiView.advertiserView?.isHidden = true
        }

        // Annonsikon (om tillgängligt)
        if let icon = nativeAd.icon?.image {
            (uiView.iconView as? UIImageView)?.image = icon
            uiView.iconView?.isHidden = false
        } else {
            uiView.iconView?.isHidden = true
        }
        
        // Den lilla "AD"-etiketten - viktigt att visa!
        // GADNativeAdView.adChoicesView är avsedd för "AdChoices"-ikonen,
        // men kan också användas för en enkel textetikett som "AD".
        // Se till att din XIB har en UILabel ansluten till adChoicesView outlet.
        if let adLabel = uiView.adChoicesView as? UILabel {
            adLabel.text = "AD" // Eller "Annons"
            adLabel.font = .systemFont(ofSize: 12, weight: .bold)
            adLabel.backgroundColor = .systemYellow
            adLabel.textColor = .black
            adLabel.layer.cornerRadius = 3
            adLabel.layer.masksToBounds = true
            adLabel.textAlignment = .center
            adLabel.isHidden = false
            // Du kan behöva justera storleken på denna UILabel i din XIB så den passar texten
            // eller ställa in dess frame/constraints här programmatiskt.
        } else {
            uiView.adChoicesView?.isHidden = true
        }

        // Knapp för Call To Action (CTA)
        if let callToAction = nativeAd.callToAction {
            (uiView.callToActionView as? UIButton)?.setTitle(callToAction, for: .normal)
            uiView.callToActionView?.isHidden = false
        } else {
            uiView.callToActionView?.isHidden = true
        }

        // Andra valfria fält (om du inkluderar dem i din XIB och vill visa dem)
        // if let price = nativeAd.price { (uiView.priceView as? UILabel)?.text = price }
        // if let store = nativeAd.store { (uiView.storeView as? UILabel)?.text = store }
        // if let starRating = nativeAd.starRating { /* Ställ in stjärnbetyg */ }
    }
}
