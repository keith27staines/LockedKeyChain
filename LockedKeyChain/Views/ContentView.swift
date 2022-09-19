//
//  ContentView.swift
//  LockedKeyChain
//
//  Created by Keith Staines on 16/09/2022.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    
    let reporter: Reporter
    let reportView: ReportView
    
    init(reporter: Reporter, reportView: ReportView) {
        self.reporter = reporter
        self.reportView = reportView
    }
    
    var body: some View {
        VStack {
            buttonsView
            reportView
        }
        .padding()
    }
    
    var buttonsView: some View {
        VStack {
            Text("Push notifications")
                .padding(.bottom)
            Button("Request permission") {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        reporter.reportEvent(.pushNotificationsRequested(.success))
                    } else if let error = error {
                        reporter.reportEvent(.pushNotificationsRequested(.failure(error.localizedDescription)))
                    }
                }
            }.padding(.bottom)
            Button("Schedule notifications") {
                scheduleNotifications()
            }
        }
    }
    
    func scheduleNotifications() {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.subtitle = "Generate keychain read/write"
        content.sound = UNNotificationSound.default

        // show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // add our notification request
        UNUserNotificationCenter.current().add(request)
    }
}

struct ContentView_Previews: PreviewProvider {
    
    struct ContainerView: View {
        let clock: Clock
        let reporter: Reporter
        
        var body: some View {
            ContentView(reporter: reporter, reportView: makeReportView())
        }
        
        init() {
            self.clock = Clock()
            self.reporter = Reporter(clock: clock)
        }
        
        func makeReportView() -> ReportView {
            ReportView(reporter: reporter)
        }
    }
    
    static var previews: some View {
        ContainerView()
    }
}
