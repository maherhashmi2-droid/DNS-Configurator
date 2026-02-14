//
//  DNS_ConfiguratorTests.swift
//  DNS ConfiguratorTests
//
//  Created by Takahiko Inayama on 2020/09/20.
//

import XCTest
@testable import DNS_Configurator

// MARK: - DoHConfig Tests

class DoHConfigTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testInitializationWithCorrectValues() {
        let servers = ["8.8.8.8", "8.8.4.4"]
        let serverURL = "https://dns.google/dns-query"
        let displayText = "Google DNS"
        
        let config = DoHConfig(servers: servers, serverURL: serverURL, displayText: displayText)
        
        XCTAssertEqual(config.servers, servers)
        XCTAssertEqual(config.serverURL, serverURL)
        XCTAssertEqual(config.displayText, displayText)
    }
    
    func testUniqueIdentifier() {
        let config1 = DoHConfig(servers: ["1.1.1.1"], serverURL: "https://example.com", displayText: "Test 1")
        let config2 = DoHConfig(servers: ["1.1.1.1"], serverURL: "https://example.com", displayText: "Test 1")
        
        XCTAssertNotEqual(config1.id, config2.id, "Each DoHConfig should have a unique ID")
    }
    
    func testIdentifiableConformance() {
        let config = DoHConfig(servers: ["1.1.1.1"], serverURL: "https://example.com", displayText: "Test")
        
        // If it compiles, it conforms to Identifiable
        let _: UUID = config.id
        XCTAssertNotNil(config.id)
    }
    
    // MARK: - Server Address Tests
    
    func testIPv4Addresses() {
        let ipv4Servers = ["8.8.8.8", "8.8.4.4", "1.1.1.1", "1.0.0.1"]
        let config = DoHConfig(servers: ipv4Servers, serverURL: "https://dns.example.com", displayText: "IPv4 DNS")
        
        XCTAssertEqual(config.servers.count, 4)
        XCTAssertTrue(config.servers.contains("8.8.8.8"))
        XCTAssertTrue(config.servers.contains("1.1.1.1"))
    }
    
    func testIPv6Addresses() {
        let ipv6Servers = ["2606:4700:4700::1111", "2606:4700:4700::1001"]
        let config = DoHConfig(servers: ipv6Servers, serverURL: "https://dns.example.com", displayText: "IPv6 DNS")
        
        XCTAssertEqual(config.servers.count, 2)
        XCTAssertTrue(config.servers.contains("2606:4700:4700::1111"))
    }
    
    func testMixedIPv4AndIPv6Addresses() {
        let mixedServers = ["1.1.1.1", "1.0.0.1", "2606:4700:4700::1111", "2606:4700:4700::1001"]
        let config = DoHConfig(servers: mixedServers, serverURL: "https://cloudflare-dns.com/dns-query", displayText: "Cloudflare DNS")
        
        XCTAssertEqual(config.servers.count, 4)
    }
    
    func testEmptyServersArray() {
        let config = DoHConfig(servers: [], serverURL: "https://dns.example.com", displayText: "Empty DNS")
        
        XCTAssertTrue(config.servers.isEmpty)
    }
    
    func testServerOrderPreserved() {
        let orderedServers = ["first", "second", "third", "fourth"]
        let config = DoHConfig(servers: orderedServers, serverURL: "https://example.com", displayText: "Ordered")
        
        XCTAssertEqual(config.servers[0], "first")
        XCTAssertEqual(config.servers[1], "second")
        XCTAssertEqual(config.servers[2], "third")
        XCTAssertEqual(config.servers[3], "fourth")
    }
    
    // MARK: - Provider Configuration Tests
    
    func testCloudflareConfiguration() {
        let config = DoHConfig(
            servers: ["1.1.1.1", "1.0.0.1", "2606:4700:4700::1111", "2606:4700:4700::1001"],
            serverURL: "https://cloudflare-dns.com/dns-query",
            displayText: "Cloudflare DNS"
        )
        
        XCTAssertEqual(config.displayText, "Cloudflare DNS")
        XCTAssertTrue(config.serverURL.contains("cloudflare"))
        XCTAssertEqual(config.servers.count, 4)
    }
    
    func testGoogleDNSConfiguration() {
        let config = DoHConfig(
            servers: ["8.8.8.8", "8.8.4.4", "2001:4860:4860::8888", "2001:4860:4860::8844"],
            serverURL: "https://dns.google/dns-query",
            displayText: "Google Public DNS"
        )
        
        XCTAssertEqual(config.displayText, "Google Public DNS")
        XCTAssertTrue(config.serverURL.contains("google"))
        XCTAssertEqual(config.servers.count, 4)
    }
}

// MARK: - DNSSettings Tests

@MainActor
class DNSSettingsTests: XCTestCase {
    
    func testInitialState() {
        let settings = DNSSettings()
        
        XCTAssertNil(settings.active)
        XCTAssertFalse(settings.resolverEnabled)
    }
    
    func testResolverDisabledWhenActiveSetToNil() {
        let settings = DNSSettings()
        settings.resolverEnabled = true
        
        settings.active = nil
        
        XCTAssertFalse(settings.resolverEnabled, "resolverEnabled should become false when active is set to nil")
    }
    
    func testObservableConformance() {
        let settings = DNSSettings()
        
        // DNSSettings should be an ObservableObject
        // This verifies it can be used in SwiftUI contexts
        _ = settings.objectWillChange
        XCTAssertNotNil(settings.objectWillChange)
    }
    
    func testResolverEnabledCanBeSetIndependently() {
        let settings = DNSSettings()
        
        settings.resolverEnabled = true
        XCTAssertTrue(settings.resolverEnabled)
        
        settings.resolverEnabled = false
        XCTAssertFalse(settings.resolverEnabled)
    }
}

// MARK: - DNS URL Validation Tests

class DNSURLValidationTests: XCTestCase {
    
    func testValidHTTPSURL() {
        let urlString = "https://dns.google/dns-query"
        let url = URL(string: urlString)
        
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.scheme, "https")
    }
    
    func testCloudflareURLIsValid() {
        let urlString = "https://cloudflare-dns.com/dns-query"
        let url = URL(string: urlString)
        
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.host, "cloudflare-dns.com")
        XCTAssertEqual(url?.path, "/dns-query")
    }
    
    func testGoogleDNSURLIsValid() {
        let urlString = "https://dns.google/dns-query"
        let url = URL(string: urlString)
        
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.host, "dns.google")
        XCTAssertEqual(url?.path, "/dns-query")
    }
    
    func testURLWithQueryPath() {
        let urlString = "https://example.com/dns-query"
        let url = URL(string: urlString)
        
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.path.hasSuffix("/dns-query") ?? false)
    }
}

// MARK: - IP Address Format Tests

class IPAddressFormatTests: XCTestCase {
    
    func testIPv4AddressFormat() {
        let ipv4Addresses = ["8.8.8.8", "8.8.4.4", "1.1.1.1", "1.0.0.1"]
        
        for address in ipv4Addresses {
            let components = address.split(separator: ".")
            XCTAssertEqual(components.count, 4, "IPv4 should have 4 octets: \(address)")
        }
    }
    
    func testIPv6AddressFormat() {
        let ipv6Addresses = ["2606:4700:4700::1111", "2001:4860:4860::8888"]
        
        for address in ipv6Addresses {
            XCTAssertTrue(address.contains(":"), "IPv6 should contain colons: \(address)")
        }
    }
    
    func testCloudflareIPv4Addresses() {
        let cloudflareIPv4 = ["1.1.1.1", "1.0.0.1"]
        
        XCTAssertTrue(cloudflareIPv4.contains("1.1.1.1"))
        XCTAssertTrue(cloudflareIPv4.contains("1.0.0.1"))
    }
    
    func testGoogleIPv4Addresses() {
        let googleIPv4 = ["8.8.8.8", "8.8.4.4"]
        
        XCTAssertTrue(googleIPv4.contains("8.8.8.8"))
        XCTAssertTrue(googleIPv4.contains("8.8.4.4"))
    }
    
    func testDistinguishIPv4FromIPv6() {
        let ipv4 = "8.8.8.8"
        let ipv6 = "2001:4860:4860::8888"
        
        XCTAssertFalse(ipv4.contains(":"), "IPv4 should not contain colons")
        XCTAssertTrue(ipv6.contains(":"), "IPv6 should contain colons")
        XCTAssertTrue(ipv4.contains("."), "IPv4 should contain dots")
    }
}

// MARK: - Configuration Data Tests

class ConfigurationDataTests: XCTestCase {
    
    private var cloudflareConfig: DoHConfig!
    private var googleConfig: DoHConfig!
    
    override func setUp() {
        super.setUp()
        cloudflareConfig = DoHConfig(
            servers: ["1.1.1.1", "1.0.0.1", "2606:4700:4700::1111", "2606:4700:4700::1001"],
            serverURL: "https://cloudflare-dns.com/dns-query",
            displayText: "Cloudflare DNS"
        )
        googleConfig = DoHConfig(
            servers: ["8.8.8.8", "8.8.4.4", "2001:4860:4860::8888", "2001:4860:4860::8844"],
            serverURL: "https://dns.google/dns-query",
            displayText: "Google Public DNS"
        )
    }
    
    override func tearDown() {
        cloudflareConfig = nil
        googleConfig = nil
        super.tearDown()
    }
    
    func testCloudflareServerCount() {
        XCTAssertEqual(cloudflareConfig.servers.count, 4)
    }
    
    func testGoogleServerCount() {
        XCTAssertEqual(googleConfig.servers.count, 4)
    }
    
    func testCloudflareHasBothIPVersions() {
        let hasIPv4 = cloudflareConfig.servers.contains { !$0.contains(":") }
        let hasIPv6 = cloudflareConfig.servers.contains { $0.contains(":") }
        
        XCTAssertTrue(hasIPv4, "Cloudflare config should have IPv4 addresses")
        XCTAssertTrue(hasIPv6, "Cloudflare config should have IPv6 addresses")
    }
    
    func testGoogleHasBothIPVersions() {
        let hasIPv4 = googleConfig.servers.contains { !$0.contains(":") }
        let hasIPv6 = googleConfig.servers.contains { $0.contains(":") }
        
        XCTAssertTrue(hasIPv4, "Google config should have IPv4 addresses")
        XCTAssertTrue(hasIPv6, "Google config should have IPv6 addresses")
    }
    
    func testDisplayTextsAreNotEmpty() {
        XCTAssertFalse(cloudflareConfig.displayText.isEmpty)
        XCTAssertFalse(googleConfig.displayText.isEmpty)
    }
    
    func testDisplayTextsAreUnique() {
        XCTAssertNotEqual(cloudflareConfig.displayText, googleConfig.displayText)
    }
    
    func testServerURLsUseHTTPS() {
        XCTAssertTrue(cloudflareConfig.serverURL.hasPrefix("https://"))
        XCTAssertTrue(googleConfig.serverURL.hasPrefix("https://"))
    }
    
    func testServerURLsHaveDNSQueryPath() {
        XCTAssertTrue(cloudflareConfig.serverURL.hasSuffix("/dns-query"))
        XCTAssertTrue(googleConfig.serverURL.hasSuffix("/dns-query"))
    }
    
    func testConfigurationsAreDistinct() {
        XCTAssertNotEqual(cloudflareConfig.id, googleConfig.id)
        XCTAssertNotEqual(cloudflareConfig.serverURL, googleConfig.serverURL)
        XCTAssertNotEqual(cloudflareConfig.servers, googleConfig.servers)
    }
}

// MARK: - Edge Case Tests

class EdgeCaseTests: XCTestCase {
    
    func testConfigWithSingleServer() {
        let config = DoHConfig(servers: ["1.1.1.1"], serverURL: "https://example.com", displayText: "Single")
        
        XCTAssertEqual(config.servers.count, 1)
    }
    
    func testConfigWithManyServers() {
        let servers = (1...10).map { "192.168.1.\($0)" }
        let config = DoHConfig(servers: servers, serverURL: "https://example.com", displayText: "Many")
        
        XCTAssertEqual(config.servers.count, 10)
    }
    
    func testConfigWithEmptyDisplayText() {
        let config = DoHConfig(servers: ["1.1.1.1"], serverURL: "https://example.com", displayText: "")
        
        XCTAssertTrue(config.displayText.isEmpty)
    }
    
    func testConfigWithLongDisplayText() {
        let longText = String(repeating: "A", count: 1000)
        let config = DoHConfig(servers: ["1.1.1.1"], serverURL: "https://example.com", displayText: longText)
        
        XCTAssertEqual(config.displayText.count, 1000)
    }
    
    func testConfigWithSpecialCharactersInDisplayText() {
        let specialText = "DNS 日本語 émoji 🌐"
        let config = DoHConfig(servers: ["1.1.1.1"], serverURL: "https://example.com", displayText: specialText)
        
        XCTAssertEqual(config.displayText, specialText)
    }
}
