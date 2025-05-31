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

    enum RestoreStatus {
        case success, failure
    }

    var body: some View {
        Form {
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
                    let message = "Check out the Unifeed news app! 📲"
                    let appLink = URL(string: "https://apps.apple.com/us/app/unifeed/id6746576849")!
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
    }
    @Environment(\.requestReview) var requestReview
}
