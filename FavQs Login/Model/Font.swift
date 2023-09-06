//
//  Font.swift
//  FavQs Login
//
//  Created by 陳佩琪 on 2023/9/6.
//

import Foundation

enum Font: Int {
    case helvetica, americanTypewriter, bradleyHand, gillSans, kailasa, markerFelt, snellRoundhand
    
    var name: String {
        switch self {
        case .helvetica:
            return "helvetica"
        case .americanTypewriter:
            return "American Typewriter"
        case .bradleyHand:
            return "Bradley Hand"
        case .gillSans:
            return "Gill Sans"
        case .kailasa:
            return "Kailasa"
        case .markerFelt:
            return "Marker Felt"
        case .snellRoundhand:
            return "Snell Roundhand"
        }
    }
}
