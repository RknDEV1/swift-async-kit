import Foundation

public struct RetryPolicy: Sendable {
    public let maxAttempts: Int
    public let delay: TimeInterval
    public let backoffMultiplier: Double

    public init(maxAttempts: Int = 3, delay: TimeInterval = 0.5, backoffMultiplier: Double = 2.0) {
        self.maxAttempts = max(1, maxAttempts)
        self.delay = max(0, delay)
        self.backoffMultiplier = max(1, backoffMultiplier)
    }

    public static let none = RetryPolicy(maxAttempts: 1, delay: 0)
    public static let standard = RetryPolicy(maxAttempts: 3, delay: 0.5)
}
