//
//  ReportItem.swift
//  LockedKeyChain
//
//  Created by Keith Staines on 19/09/2022.
//

import UIKit

struct ReportItem: Identifiable, CustomStringConvertible {
    
    static var numberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 6
        formatter.minimumFractionDigits = 3
        formatter.maximumFractionDigits = 3
        return formatter
    }()
    
    let id: Int
    let time: TimeInterval
    let event: Event
    
    var outcome: Outcome? {
        switch event {
        case .reporterInitialised,
             .pushNotificationReceived,
             .protectedDataWillBecomeAvailable,
             .protectedDataDidBecomeAvailable:
            return nil
        case .pushNotificationsRequested(let outcome),
             .createKeychain(let outcome),
             .writeKey(let outcome),
             .readKey(let outcome):
            return outcome
        }
    }
    
    init(id: Int, time: TimeInterval, event: Event) {
        self.id = id
        self.time = time
        self.event = event
    }
    
    var protectedDataAvailable: Bool { UIApplication.shared.isProtectedDataAvailable }
    
    var description: String {
        """
        Id: \(id)
        Datestamp: \(Self.numberFormatter.string(from: NSNumber(value: time)) ?? "")
        Protected Data: \(protectedDataAvailable ? "Available" :  "Unavailable")
        Event: \(event.description)
        Outcome: \(outcome?.description ?? "N/A")
        """
    }
    
    enum Event: CustomStringConvertible {
        case reporterInitialised
        case pushNotificationReceived
        case protectedDataWillBecomeAvailable
        case protectedDataDidBecomeAvailable
        case pushNotificationsRequested(Outcome)
        case createKeychain(Outcome)
        case writeKey(Outcome)
        case readKey(Outcome)
        
        var description: String {
            switch self {
            case .reporterInitialised:
                return "Event: reporterInitialised"
            case .pushNotificationReceived:
                return "Event: pushNotificationsReceived"
            case .protectedDataWillBecomeAvailable:
                return "Event: protectedDataWillBecomeAvailable"
            case .protectedDataDidBecomeAvailable:
                return "Event: protectedDataDidbecomeAvailable"
            case .pushNotificationsRequested(let outcome):
                return "Event: pushNotificationsRequested:\(outcome.description)"
            case .createKeychain(let outcome):
                return "Event: createKeychain\nOutcome:\(outcome.description)"
            case .readKey(let outcome):
                return "Event: readKey\nOutcome:\(outcome.description)"
            case .writeKey(let outcome):
                return "Event: writeKey\nOutcome:\(outcome.description)"
            }
        }
    }

    enum Outcome: CustomStringConvertible {
        case success
        case failure(String)
        
        var description: String {
            switch self {
            case .success:
                return "Success"
            case .failure(let reason):
                return "Failure\n[\(reason)]"
            }
        }
    }
}
