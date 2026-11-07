import Foundation

/// Simple in-memory cache with TTL for network responses.
public actor MemoryCache<Value> {
    private struct Entry {
        let value: Value
        let expiresAt: Date
    }

    private var storage: [String: Entry] = [:]
    private let defaultTTL: TimeInterval

    public init(defaultTTL: TimeInterval = 300) {
        self.defaultTTL = defaultTTL
    }

    public func get(_ key: String) -> Value? {
        guard let entry = storage[key] else { return nil }
        if entry.expiresAt < Date() {
            storage[key] = nil
            return nil
        }
        return entry.value
    }

    public func set(_ key: String, value: Value, ttl: TimeInterval? = nil) {
        let expires = Date().addingTimeInterval(ttl ?? defaultTTL)
        storage[key] = Entry(value: value, expiresAt: expires)
    }

    public func remove(_ key: String) {
        storage[key] = nil
    }

    public func clear() {
        storage.removeAll()
    }
}
