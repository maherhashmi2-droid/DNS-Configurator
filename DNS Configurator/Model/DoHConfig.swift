//
//  DoHConfig.swift
//  DNS Configurator
//
//  Created by Takahiko Inayama on 2020/09/20.
//

import Foundation

struct DoHConfig: Identifiable {
    let id = UUID()
    let servers: [String]
    let serverURL: String
    let displayText: String
}
