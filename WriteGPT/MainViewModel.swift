//
//  MainViewModel.swift
//  WriteGPT
//
//  Created by Jon Fabris on 8/12/24.
//

import Foundation
import SwiftUI

struct ToggleStruct: Identifiable {
    var id: String
    var selected: Bool
}

enum Mode: String, CaseIterable, Identifiable {
    case selections = "Use selections"
    case freeform = "Freeform"
    case tasks = "Specific tasks"
    case extras = "Extras"
    
    var id: Self { self }
}

struct TasksStruct: Identifiable, Hashable {
    var id: String
    var description: String
}

class MainViewModel: ObservableObject {
    
    var openAiHelper: OpenAiHelper
    
    @Published var selectedWriter: String = ""
    @Published var sourceText = ""
    @Published var promptText = ""
    @Published var generatedText = ""
    @Published var selectedStyle: String = ""
    @Published var selectedMode: Mode = .selections
    @Published var selectedTask: TasksStruct = TasksStruct(id: "", description: "")
    @Published var isLoading = false
    
    var writers = ["", "Steven King", "J.R.R. Tolkien", "Franz Kafka",
                   "William Faulkner", "Edgar Allan Poe", "James Joyce",
                   "Mark Twain", "Jules Verne", "Jane Austen", "Herman Melville", "H.P. Lovecraft",
                   "Isaac Asimov", "Arthur C. Clarke", "Robert Heinlein", "Ernest Hemingway", "Jack Kerouac", "Hunter S. Thompson"
    ]
    var styles = ["", "Epic Fantasy", "Sci-Fi", "Hard Boiled", "Gonzo Journalism", "Light Fantasy", "Horror"
    ]
    var qualities = ["show not tell", "evoking emotions", "increasing brevity", "increasing suspense", "make wordier", "keeping all original elements"
    ]
    
    var specificTasks = [
        TasksStruct(id: "Provide feedback and suggestions for improvement", description: "As an experienced writer your task is to analyze and suggest improvements for []. Your objective is to refine the text to better meet the standards and stylistic elements specific to the genre, thereby improving its overall quality and reader engagement. Provide detailed feedback that touches upon character development, plot structure, pacing, dialogue, and other genre-specific elements."),
        TasksStruct(id: "Edit for grammatical errors", description: "Act as an experienced writer with a strong grasp of grammar, syntax, and style. Your task is to meticulously review and correct grammatical errors in the following text []. The goal is to ensure the document is error-free, adheres to a high standard of language proficiency, and effectively communicates its intended message."),
        TasksStruct(id: "Show Not Tell", description: "Act as an experienced writer specializing in narrative techniques. Your task is to analyze the provided text [] and identify areas where the writing can be improved to be more immersive through the principle of \"show, not tell.\" Provide specific recommendations on how to rewrite sentences or paragraphs to evoke emotions, engage the reader’s senses, and offer deeper character insights without directly stating the information."),
        TasksStruct(id: "dialog", description: "As a writer skilled with dialog, how can I make this dialog [] more realistic and engaging?")
    ]
    
    @Published var selectedQualities: [ToggleStruct] = []
    
    init() {
        openAiHelper = OpenAiHelper()
        
        selectedTask = specificTasks.first!
        
        for q in qualities {
            selectedQualities.append(ToggleStruct(id: q, selected: false))
        }

    }
    
    func generate() {
        switch selectedMode {
        case .freeform:
            break
        case .tasks:
            generateTaskPrompt()
        case .selections:
            generateSelectionsPrompt()
        case .extras:
            runExtrasPrompt()
            return
        }
        
        Task { @MainActor in
            isLoading = true
            await runPrompt()
            isLoading = false
        }
    }
    
    func runExtrasPrompt() {
        Task { @MainActor in
            isLoading = true
            await runImagePrompt()
            isLoading = false
        }
    }
    
    func generateSelectionsPrompt() {
        promptText = ""
        
        if !selectedWriter.isEmpty {
            promptText += "In the style of \(selectedWriter).\n"
        }
        if !selectedStyle.isEmpty {
            promptText += "In the genre of \(selectedStyle).\n"
        }
        
        var numSelected = 0
        for q in selectedQualities {
            if q.selected {
                if (numSelected == 0) {
                    promptText += "Using the principals of "
                } else if numSelected > 0 {
                    promptText += ", "
                }
                numSelected += 1
                promptText += q.id
            }
        }
        promptText += ".\nRewrite the following selection []"
    }
    
    func generateTaskPrompt() {
        promptText = selectedTask.description
    }
    
    func insertSelectedTextIntoPrompt(_ text: String) -> String {
        guard text.contains("[]") else { return text }
        let split = text.split(separator: "[]")
        var newtext = split[0] + "[" + sourceText + "]"
        if split.count > 1 { newtext += split[1]}
        return newtext
    }
    
    @MainActor func runPrompt() async {
        let prompt = insertSelectedTextIntoPrompt(promptText)

        do {
            if !generatedText.isEmpty {
                generatedText += "\n\n***********************\n\n"
            }
            generatedText += try await openAiHelper.runPrompt(prompt: prompt)
        } catch {
        }
    }
    
    @MainActor func runImagePrompt() async {
        guard !promptText.isEmpty else { return }
        
        do {
            generatedText += try await openAiHelper.runImagePrompt(prompt: promptText)
        } catch {
        }
    }
    
    func clearResults() {
        generatedText = ""
    }
}
