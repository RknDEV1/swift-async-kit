import Foundation

public actor AsyncClient {

    public struct Configuration: Sendable {
        public var timeout: TimeInterval
        public var retry: RetryPolicy
        public var cacheEnabled: Bool

        public init(
            timeout: TimeInterval = 15,
            retry: RetryPolicy = .standard,
            cacheEnabled: Bool = false
        ) {
            self.timeout = timeout
            self.retry = retry
            self.cacheEnabled = cacheEnabled
        }
    }

    private let session: URLSession
    private let config: Configuration
    private let cache: MemoryCache<Data>

    public init(config: Configuration = .init()) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = config.timeout
        configuration.timeoutIntervalForResource = config.timeout
        self.session = URLSession(configuration: configuration)
        self.config = config
        self.cache = MemoryCache(defaultTTL: 300)
    }

    /// Performs a request with optional retry, timeout and cache.
    public func request(
        _ url: URL,
        method: String = "GET",
        headers: [String: String] = [:],
        body: Data? = nil,
        cacheKey: String? = nil
    ) async throws -> Data {

        if config.cacheEnabled, let key = cacheKey, let cached = await cache.get(key) {
            return cached
        }

        var lastError: Error = NetworkError.unknownFallback

        for attempt in 1...config.retry.maxAttempts {
            do {
                let data = try await perform(url: url, method: method, headers: headers, body: body)

                if config.cacheEnabled, let key = cacheKey {
                    await cache.set(key, value: data)
                }
                return data
            } catch is CancellationError {
                throw NetworkError.cancelled
            } catch {
                lastError = error
                if attempt == config.retry.maxAttempts { break }

                let delay = config.retry.delay * pow(config.retry.backoffMultiplier, Double(attempt - 1))
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }

        throw map(lastError)
    }

    /// Decodes JSON response.
    public func request<T: Decodable>(
        _ url: URL,
        as type: T.Type,
        method: String = "GET",
        headers: [String: String] = [:],
        body: Data? = nil,
        cacheKey: String? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let data = try await request(url, method: method, headers: headers, body: body, cacheKey: cacheKey)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decoding(error)
        }
    }

    private func perform(url: URL, method: String, headers: [String: String], body: Data?) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }

        guard (200...299).contains(http.statusCode) else {
            throw NetworkError.httpStatus(http.statusCode)
        }

        return data
    }

    private func map(_ error: Error) -> NetworkError {
        if let net = error as? NetworkError { return net }
        if (error as NSError).code == NSURLErrorTimedOut {
            return .timeout
        }
        if (error as NSError).code == NSURLErrorCancelled {
            return .cancelled
        }
        return .underlying(error)
    }
}

private extension NetworkError {
    static let unknownFallback = NetworkError.underlying(NSError(domain: "AsyncClient", code: -1))
}
