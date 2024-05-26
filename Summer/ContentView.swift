//
//  ContentView.swift
//  Summer
//
//  Created by Stefan Agusto Hutapea on 20/05/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    @State private var isStopped = false
    @State private var isSummarized = false
    @State private var timer: Timer?
    @State private var startTime: Date?
    @State private var elapsedTime: TimeInterval = 0.0

    var body: some View {
        VStack {
            // Timestamp or Summary Text
            Text(isSummarized ? "Summary" : timeString(from: elapsedTime))
                .font(.system(size: 100))
                .fontWeight(.regular)
                .foregroundColor(.white)
                .padding()

            // Meeting Transcription with auto-scroll
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading) {
                        Text(isRecording || !speechRecognizer.transcription.isEmpty ? speechRecognizer.transcription : "Tap the mic to start recording ...")
                            .foregroundColor(.white)
                            .padding()
                            .font(.system(size: 35))
                        
                        // Dummy Text view to scroll to
                        Text("")
                            .id("BOTTOM")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
                .onChange(of: speechRecognizer.transcription) { _ in
                    withAnimation {
                        proxy.scrollTo("BOTTOM", anchor: .bottom)
                    }
                }
            }

            // Mic/Stop/Summarize/Restart Button
            Button(action: {
                if isRecording {
                    stopRecording()
                } else if isStopped {
                    summarizeTranscription()
                } else if isSummarized {
                    resetSummary()
                } else {
                    startRecording()
                }
            }) {
                if isRecording {
                    Image(systemName: "stop.circle")
                        .resizable()
                        .frame(width: 106.51, height: 113.56)
                        .padding()
                        .foregroundColor(Color.red)
                } else if isStopped {
                    Image(systemName: "newspaper")
                        .resizable()
                        .frame(width: 106.51, height: 113.56)
                        .padding()
                        .foregroundColor(Color.blue)
                } else if isSummarized {
                    Image(systemName: "arrow.circlepath")
                        .resizable()
                        .frame(width: 106.51, height: 113.56)
                        .padding()
                        .foregroundColor(Color.blue)
                } else {
                    Image(systemName: "mic")
                        .resizable()
                        .frame(width: 78.66, height: 106.46)
                        .padding()
                        .foregroundColor(Color.blue)
                }
            }
            .padding()
        }
        .background(Color.black)
        .onAppear {
            speechRecognizer.requestAuthorization()
        }
    }

    // Function to start the timer
    func startTimer() {
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let startTime = self.startTime {
                self.elapsedTime = Date().timeIntervalSince(startTime)
            }
        }
    }

    // Function to stop the timer
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // Function to reset the timer
    func resetTimer() {
        elapsedTime = 0.0
    }

    // Function to format the elapsed time as a string
    func timeString(from time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Function to handle starting recording
    func startRecording() {
        isRecording = true
        startTimer()
        speechRecognizer.startTranscribing()
    }
    
    // Function to handle stopping recording
    func stopRecording() {
        isRecording = false
        isStopped = true
        stopTimer()
        speechRecognizer.stopTranscribing()
    }
    
    // Function to handle summarizing transcription
    func summarizeTranscription() {
        isStopped = false
        isSummarized = true
    }
    
    // Function to handle resetting summary
    func resetSummary() {
        resetTimer()
        speechRecognizer.transcription = ""
        isSummarized = false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
