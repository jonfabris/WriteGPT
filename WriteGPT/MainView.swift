//
//  ContentView.swift
//  WriteGPT
//
//  Created by Jon Fabris on 8/12/24.
//

import Foundation
import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel
  
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text("Sample - enter the text to refine/evaluate")
                    TextEditor(text: $viewModel.sourceText)
                        .navigationTitle("WriteGPT")
                    Spacer().frame(height: 12)
                    Text("Prompt - prompt sent to chatGpt")
                    TextEditor(text: $viewModel.promptText)
                        .disabled(viewModel.selectedMode != .freeform && viewModel.selectedMode != .images)
                }
                Spacer().frame(width: 12)
                VStack {
                    Button("Generate >") {
                        viewModel.generate()
                    }
                    Spacer().frame(height: 16)
                    SpinnerView()
                        .opacity(viewModel.isLoading ? 1 : 0)
                }
                Spacer().frame(width: 12)
                VStack {
                    HStack {
                        Spacer()
                        Text("Results")
                        Spacer()
                        Button(action: viewModel.clearResults) {
                            Image(systemName: "eraser")
                        }
                        .scaleEffect(0.8, anchor: .center)
                    }
                    .frame(height: 16)
                    if viewModel.selectedMode == .images {
                        if viewModel.generatedText.contains("http"),
                           let url = URL(string: viewModel.generatedText) {
                            TextEditor(text: $viewModel.generatedText)
                            ImageView(url: url)
                        }
                    } else {
                        TextEditor(text: $viewModel.generatedText)
                    }
                }
            }
            Spacer().frame(height: 16)
            
            Picker("", selection: $viewModel.selectedMode) {
                ForEach(Mode.allCases) { option in
                    Text(option.rawValue)
                }
            }
            .pickerStyle(.radioGroup)
            .horizontalRadioGroupLayout()
            
            Spacer().frame(height: 16)
            
            switch viewModel.selectedMode {
            case .freeform:
                freeformView
            case .selections:
                selectionsView
            case .tasks:
                tasksView
            case .images:
                extrasView
            }
        }
        .padding(.all, 20)
    }
    
    var selectionsView: some View {
        VStack(spacing: 10) {
            Picker("Writer", selection: $viewModel.selectedWriter) {
                ForEach(viewModel.writers, id: \.self) { item in
                    Text(item)
                }
            }
            Picker("Style", selection: $viewModel.selectedStyle) {
                ForEach(viewModel.styles, id: \.self) { item in
                    Text(item)
                }
            }
            VStack {
                ForEach($viewModel.selectedQualities) { $item in
                    Toggle(item.id, isOn: $item.selected)
                        .onChange(of: item.selected) {
                            print("toggled to \(item.selected)")
                        }
                }
            }
        }
        .padding()
        .border(.gray)
    }
    
    var tasksView: some View {
        VStack(spacing: 10) {
            Picker("", selection: $viewModel.selectedTask) {
                ForEach(viewModel.specificTasks) { option in
                    Text(option.description).tag(option)
                }
            }
            .pickerStyle(.radioGroup)
        }
        .padding()
        .border(.gray)
    }
    
    var freeformView: some View {
        VStack {
            Text("Type prompt in the prompt field. Use [] to indicate where the sample text should be inserted.")
        }
        .padding()
        .border(.gray)
    }
    
    var extrasView: some View {
        VStack {
            Text("Type prompt in the prompt field to generate an image.")
        }
        .padding()
        .border(.gray)
    }

    func ImageView(url: URL) -> some View {
        let image = NSImage(contentsOf: url)!
        var body: some View {
            Image(nsImage: image)
                .resizable()
                .frame(width: 256, height: 256, alignment:.center)
        }
        return body
    }
}

#Preview {
    MainView(viewModel: MainViewModel())
}

struct SpinnerView: View {
  var body: some View {
    ProgressView()
      .progressViewStyle(CircularProgressViewStyle(tint: .blue))
      .scaleEffect(0.5, anchor: .center)
      .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
          // Simulates a delay in content loading
          // Perform transition to the next view here
        }
      }
  }
}



