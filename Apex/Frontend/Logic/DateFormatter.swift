//
//  DateFormatter.swift
//  Apex
//
//  Created by Maddisen Mohnsen on 12/24/25.
//

import Foundation
import SwiftUI

func dateFormat(_ eventDate: String) -> String? {
    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = "y-MM-dd"
    inputFormatter.locale = Locale(identifier: "en_US_POSIX")
    
    guard let date = inputFormatter.date(from: eventDate) else {
        return nil
    }
    
    let outputFormatter = DateFormatter()
    outputFormatter.dateFormat = "MMM d, y"
    outputFormatter.locale = Locale(identifier: "en_US_POSIX")
    
    let formattedDate = outputFormatter.string(from: date)
    
    return formattedDate
}
