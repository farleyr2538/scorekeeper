//
//  Errors.swift
//  ScoreKeeper
//
//  Created by Rob Farley on 02/06/2026.
//

import Foundation

enum gameError : Error {
    case tooManyPlayers
    case noPlayers
}

enum unknownError : Error {
    case unknownError
}

enum addRoundError : Error {
    case invalidScore
}

enum addPlayerError : Error {
    case noName
    case existingName
    case tooManyPlayers
}
