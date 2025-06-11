//
//  SafariView.swift
//  Eloque AI
//
//  Created by Adrian Neshad on 2025-06-11.
//

import SwiftUI

struct GuideTextView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("appLanguage") private var appLanguage = "en"

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text(appLanguage == "sv" ? "Din omfattande guide till Eloque AI" : "Your Comprehensive Guide to Eloque AI")
                        .font(.title)
                        .bold()
                        .padding(.bottom, 5)

                    Text(appLanguage == "sv" ? "Välkommen till Eloque AI! Denna guide hjälper dig att komma igång och få ut det mesta av din upplevelse när du interagerar med AI-modeller." : "Welcome to Eloque AI! This guide will help you get started and make the most out of your experience interacting with AI models.")
                        .font(.body)
                        .padding(.bottom, 10)

                    Text(appLanguage == "sv" ? "1. Komma igång med Eloque AI" : "1. Getting Started with Eloque AI")
                        .font(.headline)
                        .padding(.vertical, 5)

                    Text(appLanguage == "sv" ? "Innan du kan börja chatta är det viktigt att **välja en språkmodell**. Gå till avsnittet 'Välj modell' för att ladda ner nya modeller eller välja en befintlig. När en modell är aktiv, tryck på 'Gå till chatt' för att starta en ny konversation. Dina två senaste konversationer sparas i 'Chatthistorik' för enkel åtkomst." : "Before you can begin chatting, it's essential to **choose a language model**. Go to the 'Choose Model' section to download new models or select an existing one. Once a model is active, tap 'Go to Chat' to start a new conversation. Your two most recent conversations will be saved in 'Chat History' for easy access.")
                        .padding(.bottom, 2)

                    Text(appLanguage == "sv" ? "\n2. Konsten att skapa effektiva prompter" : "\n2. The Art of Crafting Effective Prompts")
                        .font(.headline)
                        .padding(.vertical, 5)

                    Text(appLanguage == "sv" ? "Kvaliteten på AI:ns svar beror till stor del på hur väl du formulerar dina frågor, eller **prompter**. Här är några tips för att skriva bättre prompter:" : "The quality of the AI's responses largely depends on how well you formulate your questions, or **prompts**. Here are some tips for writing better prompts:")
                        .padding(.bottom, 2)

                    Text(appLanguage == "sv" ? "• **Var tydlig och specifik:** undvik tvetydighet. Berätta för AI:n exakt vad du vill att den ska göra eller svara på. Ju mer detaljerad din prompt är, desto mer relevant blir svaret." : "• **Be Clear and Specific:** Avoid ambiguity. Tell the AI exactly what you want it to do or answer. The more detailed your prompt, the more relevant the response will be.")
                        .padding(.bottom, 2)
                    Text(appLanguage == "sv" ? "• **Definiera rollen:** be AI:n att agera som en specifik persona (t.ex. 'Agera som en erfaren marknadsförare...' eller 'Du är en vänlig handledare...'). Detta hjälper AI:n att anpassa ton och stil." : "• **Define the Role:** Ask the AI to act as a specific persona (e.g., 'Act as an experienced marketer...' or 'You are a friendly tutor...'). This helps the AI tailor its tone and style.")
                        .padding(.bottom, 2)
                    Text(appLanguage == "sv" ? "• **Ange format:** om du vill ha svaret i ett visst format (t.ex. en lista, en tabell, ett kort stycke), ange det tydligt i prompten." : "• **Specify Format:** If you want the answer in a particular format (e.g., a list, a table, a short paragraph), clearly state that in the prompt.")
                        .padding(.bottom, 2)
                    Text(appLanguage == "sv" ? "• **Ge exempel:** om du har en komplex förfrågan, ge ett exempel på hur du vill att utdata ska se ut. Till exempel: 'Skriv en recension så här: [exempel]'" : "• **Provide Examples:** If you have a complex request, provide an example of how you want the output to look. For instance: 'Write a review like this: [example]'")
                        .padding(.bottom, 2)
                    Text(appLanguage == "sv" ? "• **Begränsa längden:** om du behöver ett kortfattat svar, be om det. 'Svara med maximalt 50 ord' kan vara till hjälp." : "• **Limit Length:** If you need a concise answer, ask for it. 'Respond with a maximum of 50 words' can be helpful.")
                        .padding(.bottom, 2)
                    Text(appLanguage == "sv" ? "• **Iterera och förfina:** om det första svaret inte är perfekt, förfina din prompt baserat på AI:ns svar. Det är en iterativ process." : "• **Iterate and Refine:** If the first response isn't perfect, refine your prompt based on the AI's answer. It's an iterative process.")

                    Text(appLanguage == "sv" ? "\n3. Att tänka på med AI-modeller" : "\n3. Considerations for AI Models")
                        .font(.headline)
                        .padding(.vertical, 5)

                    Text(appLanguage == "sv" ? "AI-modeller, särskilt de som körs lokalt, har vissa egenskaper du bör vara medveten om:" : "AI models, especially those running locally, have certain characteristics you should be aware of:")
                        .padding(.bottom, 2)

                    Text(appLanguage == "sv" ? "• **Modellstorlek kontra prestanda:** större modeller är ofta mer kapabla men kräver mer processorkraft och minne. Mindre modeller är snabbare men kan vara mindre 'intelligenta'. Experimentera för att hitta en balans som passar din enhet och dina behov." : "• **Model Size vs. Performance:** Larger models are often more capable but require more processing power and memory. Smaller models are faster but may be less 'intelligent.' Experiment to find a balance that suits your device and needs.")
                        .padding(.bottom, 2)
                    Text(appLanguage == "sv" ? "• **Hallucinationer:** AI-modeller kan ibland 'hitta på' information som inte är sann (känt som hallucinationer). Verifiera alltid viktig information från AI:n med tillförlitliga källor." : "• **Hallucinations:** AI models can sometimes 'make up' information that isn't true (known as hallucinations). Always verify important information from the AI with reliable sources.")
                        .padding(.bottom, 2)
                    Text(appLanguage == "sv" ? "• **Begränsad kunskap:** modeller har en 'brytpunkt' för sin kunskap – de vet inget om händelser som inträffade efter det datum de tränades. Detta är särskilt relevant för lokala modeller som inte uppdateras i realtid." : "• **Limited Knowledge:** Models have a 'cutoff point' for their knowledge—they know nothing about events that occurred after the date they were trained. This is especially relevant for local models that aren't updated in real-time.")
                        .padding(.bottom, 2)
                    Text(appLanguage == "sv" ? "• **Integritet:** eftersom Eloque AI kör modeller lokalt på din enhet skickas dina konversationer inte till någon extern server. Detta ger en hög nivå av integritet för dina data." : "• **Privacy:** Since Eloque AI runs models locally on your device, your conversations are not sent to any external server. This provides a high level of privacy for your data.")

                    Text(appLanguage == "sv" ? "\n4. Andra tips och felsökning" : "\n4. Other Tips & Troubleshooting")
                        .font(.headline)
                        .padding(.vertical, 5)

                    Text(appLanguage == "sv" ? "• **Hantera modeller:** du kan ladda ner och ta bort modeller i avsnittet 'Välj modell'. Ta bort oanvända modeller för att frigöra lagringsutrymme på din enhet." : "• **Manage Models:** You can download and delete models in the 'Choose Model' section. Delete unused models to free up storage space on your device.")
                        .padding(.bottom, 2)
                    Text(appLanguage == "sv" ? "• **Prestandaproblem:** om appen känns långsam, se till att inga andra krävande applikationer körs i bakgrunden. Ett annat alternativ är att prova en mindre AI-modell som kräver färre resurser." : "• **Performance Issues:** If the app feels slow, ensure no other demanding applications are running in the background. Another option is to try a smaller AI model that requires fewer resources.")
                        .padding(.bottom, 2)
                    Text(appLanguage == "sv" ? "• **Mörkt läge:** justera appens utseende i inställningarna om du föredrar mörkt läge." : "• **Dark Mode:** Adjust the app's appearance in settings if you prefer dark mode.")
                        .padding(.bottom, 2)
                    Text(appLanguage == "sv" ? "• **Språk:** Ändra appens språk i inställningarna om du vill ändra gränssnittsspråket." : "• **Language:** Change the app's language in settings if you wish to change the interface language.")

                    Text(appLanguage == "sv" ? "\nVi hoppas att du får stor nytta och glädje av Eloque AI!" : "\nWe hope you get great use and enjoyment out of Eloque AI!")
                        .font(.body)
                        .padding(.top, 10)
                        .bold()

                }
                .padding()
            }
            .navigationTitle("Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(StringManager.shared.get("close")) {
                        dismiss()
                    }
                }
            }
        }
    }
}
