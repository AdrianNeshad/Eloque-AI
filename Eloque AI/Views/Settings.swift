//
//  Settings.swift
//  Eloque AI
//
//  Created by Adrian Neshad on 2025-06-09.
//

import SwiftUI
import MessageUI
import AlertToast
import StoreKit

struct Settings: View {
    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("appLanguage") private var appLanguage = "en"
    @State private var showRestoreAlert = false
    @State private var showPurchaseSheet = false
    @State private var restoreStatus: RestoreStatus?
    @Environment(\.requestReview) var requestReview
    @State private var showMailFeedback = false
    @State private var mailErrorAlert = false
    @State private var showClearAlert = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var showShareSheet = false
    
    enum RestoreStatus {
        case success, failure
    }

    var body: some View {
        Form {
            Section(header: Text(StringManager.shared.get("appearance"))) {
                Toggle(StringManager.shared.get("darkmode"), isOn: $isDarkMode)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                
                Picker("Språk / Language", selection: $appLanguage) {
                    Text("English").tag("en")
                    Text("Svenska").tag("sv")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            /*
            // Köp-sektion
            Section(header: Text(StringManager.shared.get("advancedunits"))) {
                if !advancedUnitsUnlocked {
                    Button(action: {
                        showPurchaseSheet = true
                    }) {
                        HStack {
                            Image(systemName: "lock.open")
                            Text(StringManager.shared.get("unlockadvancedunits"))
                            Spacer()
                            if let product = storeManager.products.first {
                                Text(product.localizedPrice)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .sheet(isPresented: $showPurchaseSheet) {
                        PurchaseView(storeManager: storeManager, isUnlocked: $advancedUnitsUnlocked)
                    }
                } else {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                        Text(StringManager.shared.get("advancedunitsunlocked"))
                            .foregroundColor(.green)
                    }
                }
                
                Button(StringManager.shared.get("restorepurchase")) {
                    storeManager.restorePurchases()
                    showRestoreAlert = true
                }
                .alert(isPresented: $showRestoreAlert) {
                    switch restoreStatus {
                    case .success:
                        return Alert(
                            title: Text(StringManager.shared.get("purchaserestored")),
                            message: Text(StringManager.shared.get("purchaserestored")),
                            dismissButton: .default(Text("OK")))
                    case .failure:
                        return Alert(
                            title: Text(StringManager.shared.get("restorefailed")),
                            message: Text(StringManager.shared.get("purchasecouldntrestore")),
                            dismissButton: .default(Text("OK")))
                    default:
                        return Alert(
                            title: Text(StringManager.shared.get("processing...")),
                            message: nil,
                            dismissButton: .cancel())
                    }
                }
                .onReceive(storeManager.$transactionState) { state in
                    if state == .restored {
                        restoreStatus = .success
                        advancedUnitsUnlocked = true
                    } else if state == .failed {
                        restoreStatus = .failure
                    }
                }
            }
            */
            
            Section(header: Text(StringManager.shared.get("about"))) {
                Button(StringManager.shared.get("ratetheapp")) {
                    requestReview()
                }
                Button(StringManager.shared.get("sharetheapp")) {
                                   showShareSheet = true
                               }
                               .sheet(isPresented: $showShareSheet) {
                                   let message = StringManager.shared.get("checkouteloque")
                                   let appLink = URL(string: "https://apps.apple.com/us/app/eloque-ai-local-llm/id6747086799")!
                                   ShareSheet(activityItems: [message, appLink])
                                       .presentationDetents([.medium])
                               }
                Button(StringManager.shared.get("givefeedback")) {
                    if MFMailComposeViewController.canSendMail() {
                        showMailFeedback = true
                    } else {
                        mailErrorAlert = true
                    }
                }
                .sheet(isPresented: $showMailFeedback) {
                    MailFeedback(isShowing: $showMailFeedback,
                                 recipientEmail: "Adrian.neshad1@gmail.com",
                                 subject: StringManager.shared.get("eloquefeedback"),
                                 messageBody: "")
                }
            }
            
            Section(header: Text(StringManager.shared.get("otherapps"))) {
                Link(destination: URL(string: "https://apps.apple.com/us/app/univert/id6745692591")!) {
                                    HStack {
                                        Image("univert")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .cornerRadius(8)
                                        Text("Univert - Unit Converter")
                                    }
                                }
                Link(destination: URL(string: "https://apps.apple.com/us/app/flixswipe-explore-new-movies/id6746716902")!) {
                    HStack {
                        Image("flixswipe")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .cornerRadius(8)
                        Text("FlixSwipe - Explore New Movies")
                    }
                }
            }
            
            Section {
                Text(appVersion)
            }
            
            Section {
                EmptyView()
            } footer: {
                AppFooter()
            }
        }
        .navigationTitle(StringManager.shared.get("settings"))  
        .toast(isPresenting: $showToast) {
                    AlertToast(type: .complete(Color.green), title: toastMessage)
                }
    }
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
        return "Version \(version) (\(build))"
    }
}
