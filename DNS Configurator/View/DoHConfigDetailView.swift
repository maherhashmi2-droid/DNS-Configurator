//
//  DoHConfigDetailView.swift
//  DNS Configurator
//
//  Created by Takahiko Inayama on 2020/09/20.
//

import SwiftUI
import NetworkExtension

struct DoHConfigDetailView: View {
    let config: DoHConfig
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var dnsSettings: DNSSettings
    
    var body: some View {
        VStack {
            DoHConfigView(config: config)
            Button("Select this server") {
                applyDoH(config: config)
                presentationMode.wrappedValue.dismiss()
            }
        }
        .padding(.bottom)
        .navigationTitle(config.displayText)
    }
    
    func applyDoH(config: DoHConfig) {
        NEDNSSettingsManager.shared().loadFromPreferences { [dnsSettings] loadError in
            if let loadError = loadError {
                print(loadError)
                return
            }
            let dohSettings = NEDNSOverHTTPSSettings(servers: config.servers)
            dohSettings.serverURL = URL(string: config.serverURL)
            
            NEDNSSettingsManager.shared().dnsSettings = dohSettings
            NEDNSSettingsManager.shared().saveToPreferences { saveError in
                if let saveError = saveError {
                    print(saveError.localizedDescription)
                    return
                }
                
                Task { @MainActor in
                    dnsSettings.active = dohSettings
                    dnsSettings.resolverEnabled = NEDNSSettingsManager.shared().isEnabled
                }
            }
        }
    }
}

struct DoHConfigDetailView_Previews: PreviewProvider {
    static var previews: some View {
        DoHConfigDetailView(
            config: DoHConfig(
                servers: ["8.8.8.8", "8.8.4.4", "2001:4860:4860::8888", "2001:4860:4860::8844"],
                serverURL: "https://dns.google/dns-query",
                displayText: "Google Public DNS"
            )
        )
        .environmentObject(DNSSettings())
    }
}
