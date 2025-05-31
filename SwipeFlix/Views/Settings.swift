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
    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("adsRemoved") private var adsRemoved = false
    @StateObject private var storeManager = StoreManager()
    @State private var showShareSheet = false
    @State private var showPurchaseSheet = false
    @State private var restoreStatus: RestoreStatus?
    @State private var showMailFeedback = false
    @State private var mailErrorAlert = false
    @State private var showClearAlert = false
    @State private var showToast = false
    @State private var toastMessage = ""
    
    enum RestoreStatus {
        case success, failure
    }
    
    var body: some View {
        Form {
            /*
             // Köp-sektion (om du vill återaktivera)
             Section(header: Text(appLanguage == "sv" ? "Reklamfritt" : "Ad-free")) {
             if !adsRemoved {
             Button(action: {
             showPurchaseSheet = true
             }) {
             HStack {
             Image(systemName: "lock.open")
             Text(appLanguage == "sv" ? "Lås upp reklamfri upplevelse" : "Unlock Ad-free Experience")
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
             Text(appLanguage == "sv" ? "Reklamfri upplevelse" : "Ad-free Experience")
             .foregroundColor(.green)
             }
             }
             
             Button(appLanguage == "sv" ? "Återställ köp" : "Restore Purchases") {
             storeManager.restorePurchases()
             showRestoreAlert = true
             }
             .alert(isPresented: $showRestoreAlert) {
             switch restoreStatus {
             case .success:
             return Alert(
             title: Text(appLanguage == "sv" ? "Köp återställda" : "Purchases Restored"),
             message: Text(appLanguage == "sv" ? "Dina köp har återställts." : "Your purchases have been restored."),
             dismissButton: .default(Text("OK")))
             case .failure:
             return Alert(
             title: Text(appLanguage == "sv" ? "Återställning misslyckades" : "Restore Failed"),
             message: Text(appLanguage == "sv" ? "Inga köp kunde återställas." : "No purchases could be restored."),
             dismissButton: .default(Text("OK")))
             default:
             return Alert(
             title: Text(appLanguage == "sv" ? "Bearbetar..." : "Processing..."),
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
            Section(header: "About") {
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
                                 subject: "Unifeed Feedback",
                                 messageBody: "")
                }
            }
            Section(header: "Other Apps") {
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
            storeManager.getProducts(productIDs: ["FlixSwipe.AdsRemoved"]) //Ändra
        }
        .toast(isPresenting: $showToast) {
            AlertToast(type: .complete(Color.green), title: toastMessage)
        }
    }
    @Environment(\.requestReview) var requestReview
}
