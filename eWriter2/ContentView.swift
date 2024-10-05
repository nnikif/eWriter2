//
//  ContentView.swift
//  eWriter2
//
//  Created by Nikolay Nikiforov on 03.10.2024.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: eWriter2Document
//    let webSocketHandler: WebSocketHandler
    
    @State private var cursorPosition: Int = 0 // Track the cursor position
    @State private var startSelection: Int? = nil // Track start of the selection
    @State private var endSelection: Int? = nil
    @State private var showOverlay = false
    @State private var ipAddress: String = "Fetching IP..."

//    let webSocketHandler: WebSocketHandler
        
    var body: some View {
        ZStack {
            VStack {
            // Use custom UITextView to track selected text and cursor
            TextViewWithSelectionObserver(
                text: $document.text,
                cursorPosition: $cursorPosition,
                startSelection: $startSelection,
                endSelection: $endSelection,
                onSelectionChange: { cursorPosition, startSelection, endSelection in
                    sendCursorSelectionUpdate(cursorPosition: cursorPosition, startSelection: startSelection, endSelection: endSelection, document:  document)
                }
                
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .onChange(of: document.text) { oldValue, newValue in
                sendDocumentUpdate(oldText: oldValue, newText: newValue, cursorPosition: cursorPosition)
            }
            .onAppear {
                       ipAddress = getWiFiAddress() ?? "Unable to fetch IP"
                   }
                
            Button(action: {
                // Toggle the overlay when button is pressed
                showOverlay.toggle()
            }) {
                Text("Hide Screen")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
                Text("Open this address in a web browser:")
                                .font(.headline)
                                .padding()

                            Text(ipAddress+":8787")
                                .font(.title)
                                .padding()
        }
            if showOverlay {
                           Color.black // Fully opaque black overlay
                               .ignoresSafeArea()   // Ensure the overlay covers the entire screen
                               .onTapGesture {
                                   // Restore the interface when the screen is touched
                                   showOverlay = false
                               }
                       }
            
    }
        }
}

func sendCursorSelectionUpdate(cursorPosition: Int, startSelection: Int?, endSelection: Int?, document: eWriter2Document) {
        let text = document.text
        let cursorParagraphInfo = getCursorParagraphInfo(text: text, cursorPosition: cursorPosition, selectionStart: startSelection, selectionEnd: endSelection)
        if let cursorParagraphInfo {
            let cursorData = convertJSONToString(jsonObject: cursorParagraphInfo.toDictionary())
            let messageObject = MessageObject(messageType: "cursorUpdate", details: nil, cursorPositon: cursorData)
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.025) {
                WebSocketBroadcaster.shared.broadcast(message: convertJSONToString(jsonObject: messageObject.toDictionary()))
            }
        }
    }

func sendDocumentUpdate(oldText: String, newText: String, cursorPosition: Int) {
    WebSocketBroadcaster.shared.documentText = newText
    let messageObject = calculateDiffResponse(oldText: oldText, newText: newText, cursorPosition: cursorPosition)
    let jsonString = convertJSONToString(jsonObject: messageObject.toDictionary())
    WebSocketBroadcaster.shared.broadcast(message: jsonString)
}


#Preview {
    ContentView(document: .constant(eWriter2Document()))
}
