import Foundation

public enum AsyncTimeout {

    /// Runs an async operation with a timeout.
    public static func run<T>(
        seconds: TimeInterval,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }

            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw NetworkError.timeout
            }

            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
}
