//
//  AirMouseCommunication.swift
//  Air Mouse

import Foundation

enum AirMouseKey {
    static let gesture = "gesture"
}

enum AirMouseGesture: String, CaseIterable {
    case leftSwipe
    case rightSwipe
    case upSwipe
    case downSwipe
    case clockSwipe
    case counterSwipe
    case tap
    case clench
}
