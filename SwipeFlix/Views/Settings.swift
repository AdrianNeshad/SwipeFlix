//
//  Settings.swift
//  SwipeFlix
//
//  Created by Adrian Neshad on 2025-05-31.
//

import SwiftUI
import StoreKit
import MessageUI
import AlertToast

struct Settings: View {
    @EnvironmentObject private var watchList: WatchListManager
    @AppStorage("adsRemoved") private var adsRemoved = false
    @StateObject private var storeManager = StoreManager()
    @State private var showShareSheet = false
    @State private var showRestoreAlert = false
    @State private var showPurchaseSheet = false
    @State private var restoreStatus: RestoreStatus?
    @State private var showMailFeedback = false
    @State private var mailErrorAlert = false
    @State private var showClearAlert = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var selectedSourceURL: URL? = nil

    enum RestoreStatus {
        case success, failure
    }

    var body: some View {
        Form {
            Section(header: Text("Source")) {
                Button(action: {
                    selectedSourceURL = URL(string: "https://www.themoviedb.org/")
                }) {
                    Image("tmdb")
                        .resizable()
                        .aspectRatio(contentMode: .fit) 
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            Section(header: Text("Watchlists")) {
                Button(action: {
                    showClearAlert = true
                }) {
                    Text("Clear Movie Watchlist")
                        .foregroundColor(.red)
                }
                .confirmationDialog("Do you want to clear your saved titles?",
                    isPresented: $showClearAlert,
                    titleVisibility: .visible
                ) {
                    Button("Clear", role: .destructive) {
                        watchList.clearMovies()

                        toastMessage = "Watchlist Cleared"
                        withAnimation {
                            showToast = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation {
                                showToast = false
                            }
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                }
                Button(action: {
                    showClearAlert = true
                }) {
                    Text("Clear TV Shows Watchlist")
                        .foregroundColor(.red)
                }
                .confirmationDialog("Do you want to clear your saved titles?",
                    isPresented: $showClearAlert,
                    titleVisibility: .visible
                ) {
                    Button("Clear", role: .destructive) {
                        watchList.clearTVShows()

                        toastMessage = "Watchlist Cleared"
                        withAnimation {
                            showToast = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation {
                                showToast = false
                            }
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                }
            }
            /*
            // Köp-sektion
            Section(header: "Ad-free") {
                if !adsRemoved {
                    Button(action: {
                        showPurchaseSheet = true
                    }) {
                        HStack {
                            Image(systemName: "lock.open")
                            Text("Unlock Ad-free Experience")
                            Spacer()
                            if let product = storeManager.products.first {
                                Text(product.localizedPrice)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .sheet(isPresented: $showPurchaseSheet) {
                        PurchaseView(storeManager: storeManager, isUnlocked: $adsRemoved)
                    }
                } else {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                        Text("Ad-free Experience")
                            .foregroundColor(.green)
                    }
                }

                Button("Restore Purchases") {
                    storeManager.restorePurchases()
                    showRestoreAlert = true
                }
                .alert(isPresented: $showRestoreAlert) {
                    switch restoreStatus {
                    case .success:
                        return Alert(
                            title: Text("Purchases Restored"),
                            message: Text("Your purchases have been restored."),
                            dismissButton: .default(Text("OK")))
                    case .failure:
                        return Alert(
                            title: Text("Restore Failed"),
                            message: Text("No purchases could be restored."),
                            dismissButton: .default(Text("OK")))
                    default:
                        return Alert(
                            title: Text("Processing..."),
                            message: nil,
                            dismissButton: .cancel())
                    }
                }
                .onReceive(storeManager.$transactionState) { state in
                    if state == .restored {
                        restoreStatus = .success
                        adsRemoved = true
                    } else if state == .failed {
                        restoreStatus = .failure
                    }
                }
            }
            */
            Section("About") {
                Button("Rate the App") {
                    requestReview()
                }
                Button("Share the App") {
                    showShareSheet = true
                }
                .sheet(isPresented: $showShareSheet) {
                    let message = "Check out the FlixSwipe app! 📲"
                    let appLink = URL(string: "https://apps.apple.com/us/app/flixswipe/id6746682499")!
                    ShareSheet(activityItems: [message, appLink])
                        .presentationDetents([.medium])
                }

                Button("Give Feedback") {
                    if MFMailComposeViewController.canSendMail() {
                        showMailFeedback = true
                    } else {
                        mailErrorAlert = true
                    }
                }
                .sheet(isPresented: $showMailFeedback) {
                    MailFeedback(isShowing: $showMailFeedback,
                                 recipientEmail: "Adrian.neshad1@gmail.com",
                                 subject: "FlixSwipe Feedback",
                                 messageBody: "")
                }
            }
            Section("Other Apps") {
                Link(destination: URL(string: "https://apps.apple.com/us/app/univert/id6745692591")!) {
                    HStack {
                        Image("univert")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .cornerRadius(8)
                        Text("Univert")
                    }
                }
                
                Link(destination: URL(string: "https://apps.apple.com/us/app/unifeed/id6746576849")!) {
                    HStack {
                        Image("unifeed")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .cornerRadius(8)
                        Text("Unifeed")
                    }
                }
            }

            Section {
                EmptyView()
            } footer: {
                VStack(spacing: 4) {
                    AppVersion()
                }
                .font(.caption)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, -100)
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            storeManager.getProducts(productIDs: ["SwipeFlix.AdsRemoved"]) //Ändra
        }
        .toast(isPresenting: $showToast) {
            AlertToast(type: .complete(Color.green), title: toastMessage)
        }
        .sheet(item: $selectedSourceURL) { url in
            SafariView(url: url)
        }
    }
    @Environment(\.requestReview) var requestReview
}
