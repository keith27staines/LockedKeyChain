//
//  Reporter.swift
//  LockedKeyChain
//
//  Created by Keith Staines on 19/09/2022.
//

import Foundation
import UIKit
import Combine

typealias Report = [ReportItem]

class Reporter: NSObject, ObservableObject {

    @Published var report: Report
    
    private var subscriptions = Set<AnyCancellable>()
    private (set) var clock: Clock
    
    init(clock: Clock) {
        self.clock = clock
        report = Report()
        super.init()

        NotificationCenter
            .default
            .publisher(for: UIApplication.protectedDataWillBecomeUnavailableNotification)
            .sink { [weak self] note in
                self?.reportEvent(.protectedDataWillBecomeAvailable)
            }.store(in: &subscriptions)
        
        NotificationCenter
            .default
            .publisher(for: UIApplication.protectedDataDidBecomeAvailableNotification)
            .sink { [weak self] note in
                self?.reportEvent(.protectedDataDidBecomeAvailable)
            }
            .store(in: &subscriptions)
        reportEvent(.reporterInitialised)
    }
    
    func reportEvent(_ event: ReportItem.Event) {
        let id = report.count
        let item = ReportItem(id: id, time: clock.runtime, event: event)
        print(item.description)
        report.append(item)
    }
}






