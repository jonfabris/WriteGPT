//
//  OpenAiHelper.swift
//  WriteGPT
//
//  Created by Jon Fabris on 8/13/24.
//

import Foundation
import OpenAIKit

// https://mrprogrammer.medium.com/integrating-openai-api-into-ios-application-using-swift-42b96614458b

enum AIMode {
    case completion
    case chatCompletion
}

class OpenAiHelper {
    
    var openAI: OpenAIKit
    let mode: AIMode
    
    init(mode: AIMode = .chatCompletion) {
        self.mode = mode
        let apiKeyService = BundledApiKeyService()
        
        let apiKey = apiKeyService.apiKeys!.ChatGptApiKey
        let organization = apiKeyService.apiKeys!.ChatGptOrganization
        openAI = OpenAIKit(apiToken: apiKey, organization: organization)
    }

    func runPrompt(prompt: String) async throws -> String {
        switch mode {
        case .completion:
            let model = AIModelType(rawValue: "gpt-3.5-turbo-instruct")!
            let result = await openAI.sendCompletion(prompt: prompt, model: model, maxTokens: 2048)
            switch result {
            case .success(let aiResult):
                print(aiResult)
                if let text = aiResult.choices.first?.text {
                    return text
                }
            case .failure(let error):
             /// https://platform.openai.com/docs/guides/error-codes/api-errors.
                print(error.localizedDescription)
                return error.localizedDescription
            }
        case .chatCompletion:
            let model = AIModelType(rawValue: "gpt-3.5-turbo")!
            let message = AIMessage(role: AIMessageRole.user, content: prompt)
            let result = await openAI.sendChatCompletion(newMessage: message, model: model, maxTokens: 2048)
            switch result {
            case .success(let aiResult):
                print(aiResult)
                if let text = aiResult.choices.first?.message?.content {
                    return text
                }
            case .failure(let error):
             /// https://platform.openai.com/docs/guides/error-codes/api-errors.
                print(error.localizedDescription)
                return error.localizedDescription
            }
        }
        return "error"
    }
    
    
    func runImagePrompt(prompt: String) async throws -> String {
        let result = await openAI.sendImagesRequest(prompt: prompt, size: .size1024, n: 1)
        switch result {
        case .success(let aiResult):
            print(aiResult)
            if let text = aiResult.data.first?.url {
                return text
            }
        case .failure(let error):
         /// https://platform.openai.com/docs/guides/error-codes/api-errors.
            print(error.localizedDescription)
            return error.localizedDescription
        }
        return "error"
    }

}
// [1]    (null)    "message" : "You exceeded your current quota, please check your plan and billing details. For more information on this error, read the docs: https://platform.openai.com/docs/guides/error-codes/api-errors."
