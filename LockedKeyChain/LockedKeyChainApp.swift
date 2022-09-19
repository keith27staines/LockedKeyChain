//
//  LockedKeyChainApp.swift
//  LockedKeyChain
//
//  Created by Keith Staines on 16/09/2022.
//

import SwiftUI

@main
struct LockedKeyChainApp: App {
    
    // @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    @StateObject private var reporter: Reporter
    
    init() {
        let clock = Clock()
        _reporter = StateObject(wrappedValue: Reporter(clock: clock))
        UNUserNotificationCenter.current().delegate = reporter
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(reporter: reporter, reportView: reportView, keyValueStorage: KeychainStorageFactory(reporter: reporter).localStorage)
        }
    }
    
    var reportView: ReportView {
        ReportView(reporter: reporter)
    }
}

extension Reporter: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    }
}

extension LockedKeyChainApp {
    func setupAirship() {
        
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
    
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // do something with token
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // report error
    }
}
