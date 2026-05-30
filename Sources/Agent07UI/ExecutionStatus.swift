//
//  ExecutionStatus.swift
//  Agent07UI
//
//  Generic execution status enum used by StatusBadge.
//

import Foundation

/// Lifecycle status of a running operation. Drives `StatusBadge` rendering.
public enum ExecutionStatus: String, Codable, Sendable, CaseIterable, Hashable {
    /// Operation hasn't started yet.
    case idle
    /// Operation is in flight.
    case running
    /// Operation finished successfully.
    case success
    /// Operation finished with an error.
    case error
}
