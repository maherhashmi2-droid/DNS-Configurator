//
//  OptionsView.swift
//  DNS Configurator
//
//  Created by Takahiko Inayama on 2020/09/21.
//

import SwiftUI
import NetworkExtension

struct OptionsView: View {
    @State private var showAlert = false
    @State private var showRemovalConfirmation = false
    @State private var showActiveAlert = false
    @EnvironmentObject var dnsSettings: DNSSettings
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        VStack {
            Text("Extras")
                .font(.headline)
            List {
                Section(header: Text("Options")) {
                    if dnsSettings.active != nil {
                        Button(action: { validateToRemoveDoH() }) {
                            Text("Remove the resolver setting")
                                .foregroundColor(.red)
                        }
                        .alert(isPresented: $showAlert) {
                            if showActiveAlert {
                                return Alert(
                                    title: Text("Can't remove active setting"),
                                    message: Text("Please select another DNS provider in Setting app."),
                                    dismissButton: .default(Text("OK")) {
                                        showActiveAlert = false
                                    }
                                )
                            } else {
                                return Alert(
                                    title: Text("Confirmation"),
                                    message: Text("Are you sure to remove the resolver setting?"),
                                    primaryButton: .destructive(Text("Remove")) {
                                        dnsSettings.removeDoH()
                                        showRemovalConfirmation = false
                                    },
                                    secondaryButton: .cancel {
                                        showRemovalConfirmation = false
                                    }
                                )
                            }
                        }
                    } else {
                        Text("No options available.")
                            .foregroundColor(.gray)
                    }
                }
                
                Section(header: Text("About This App")) {
                    Button("Source Code (github.com)") {
                        if let url = URL(string: "https://github.com/TETRA2000/DNS-Configurator") {
                            openURL(url)
                        }
                    }
                }
            }
        }
    }

    func validateToRemoveDoH() {
        NEDNSSettingsManager.shared().loadFromPreferences { loadError in
            if let loadError = loadError {
                print(loadError)
                return
            }
            
            Task { @MainActor in
                let isEnabled = NEDNSSettingsManager.shared().isEnabled
                if isEnabled {
                    showActiveAlert = true
                } else {
                    showRemovalConfirmation = true
                }
                showAlert = true
            }
        }
    }
}

struct OptionsView_Previews: PreviewProvider {
    static var previews: some View {
        OptionsView()
            .environmentObject(DNSSettings())
    }
}
