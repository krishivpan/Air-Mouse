//
//  AirMouseCommunication.swift
//  Air Mouse
//
//  Created by Rehan Jetha on 2025-11-15.
//

import Foundation

enum AirMouseKey {
    static let gesture = "gesture"
}

enum AirMouseGesture: String {
    case leftSwipe
    case rightSwipe
    case upSwipe
    case downSwipe
    case clockSwipe
    case counterSwipe
    case tap
    case clench
}
