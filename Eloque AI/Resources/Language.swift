//
//  Language.swift
//  Eloque AI
//
//  Created by Adrian Neshad on 2025-06-09.
//

import SwiftUI

class StringManager {
    static let shared = StringManager()
    @AppStorage("appLanguage") var appLanguage: String = "en"
    
    private let sv: [String: String] = [
        "settings": "Inställningar",
        "otherapps": "Andra appar",
        "eloquefeedback": "Eloque feedback",
        "givefeedback": "Ge feedback",
        "checkouteloque": "Kolla in Eloque AI appen!",
        "sharetheapp": "Dela appen",
        "ratetheapp": "Betygsätt appen",
        "about": "Om",
        "processing...": "Bearbetar...",
        "purchasecouldntrestore": "Inga köp kunde återställas",
        "restorefailed": "Återställning misslyckades",
        "purchaserestored": "Ditt köp har återställts",
        "restorepurchase": "Återställ köp", 
        "cancel": "Avbryt",
        "clear": "Rensa",
        "darkmode": "Mörkt läge",
        "appearance": "Utseende",
        "purchasefailed": "Köpet misslyckades, försök igen",
        "thanksforpurchase": "Tack för ditt köp!",
        "loading...": "Laddar...",
        "Index_banner": "Välj en lokal AI-modell och börja chatta säkert, offline och enkelt.",
        "nomodelchosen": "Ingen modell vald",
        "choosemodel": "📥 Välj modell",
        "gotochat": "💬 Gå till chatt",
        "chat": "Chatt",
        "send": "Skicka",
        "download": "Ladda ner",
        "chosenmodel": "Vald modell:",
        "models": "AI-modeller",
        "downloading": "Laddar ner...",
        "delete": "Radera",
        "size": "Storlek:",
        "choosemodelfirst": "Välj en modell först",
        "choosemodelfirsttext": "Du måste ladda ner och välja en modell innan du kan använda chatten",
        "chathistory": "Chatthistorik",
        "thinking": "Tänker",
        "recommended": "Rekommenderad enhet:",
    ]
    
    private let en: [String: String] = [
        "settings": "Settings",
        "otherapps": "Other apps",
        "eloquefeedback": "Eloque feedback",
        "givefeedback": "Give feedback",
        "checkouteloque": "Check out the Eloque AI app!",
        "sharetheapp": "Share the app",
        "ratetheapp": "Rate the app",
        "about": "About",
        "processing...": "Processing...",
        "purchasecouldntrestore": "No purchases could be restored",
        "restorefailed": "Restore failed",
        "purchaserestored": "Your purchase has been restored",
        "restorepurchase": "Restore purchase",
        "cancel": "Cancel",
        "clear": "Clear",
        "darkmode": "Dark mode",
        "appearance": "Appearance",
        "purchasefailed": "Purchase failed, please try again",
        "thanksforpurchase": "Thanks for your purchase!",
        "loading...": "Loading...",
        "Index_banner": "Choose a local AI-model and start chatting safe, offline, and simple",
        "nomodelchosen": "No model chosen",
        "choosemodel": "📥 Choose model",
        "gotochat": "💬 Go to chat",
        "chat": "Chat",
        "send": "Send",
        "download": "Download",
        "chosenmodel": "Chosen model:",
        "models": "AI-Models",
        "downloading": "Downloading...",
        "delete": "Delete",
        "size": "Size:",
        "choosemodelfirst": "Choose a model first",
        "choosemodelfirsttext": "You must download and choose a model before you can use the chat",
        "chathistory": "Chat history",
        "thinking": "Thinking",
        "recommended": "Recommended device:",
    ]
    
    private var tables: [String: [String: String]] {
        [
            "sv": sv,
            "en": en,
        ]
    }

    func get(_ key: String) -> String {
        tables[appLanguage]?[key] ?? key
    }
}
