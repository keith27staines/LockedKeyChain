//
//  ReportView.swift
//  LockedKeyChain
//
//  Created by Keith Staines on 19/09/2022.
//

import SwiftUI

struct ReportView: View {
    
    @ObservedObject var reporter: Reporter
    
    var body: some View {
        List(reporter.report) { item in
            Text(item.description)
        }
    }
}

struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportView(reporter: Reporter(clock: Clock()))
    }
}
