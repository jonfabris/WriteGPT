//
//  WriteGPTApp.swift
//  WriteGPT
//
//  Created by Jon Fabris on 8/12/24.
//

import SwiftUI

@main
struct WriteGPTApp: App {
    var body: some Scene {
        WindowGroup {
            MainView(viewModel: MainViewModel())
        }
    }
}
