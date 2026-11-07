# Swift Async Kit

Advanced **async/await** networking utilities for Swift.

> Português: [README.pt-BR.md](README.pt-BR.md)

## Features

| Feature | Description |
|---------|-------------|
| **AsyncClient** | Typed requests with retry, timeout and cache |
| **RetryPolicy** | Exponential backoff |
| **MemoryCache** | Actor-based in-memory cache with TTL |
| **NetworkError** | Typed, localized errors |
| **AsyncTimeout** | Run any async work with a deadline |

## Install

```swift
.package(url: "https://github.com/RknDEV1/swift-async-kit.git", branch: "main")
```

## Usage

```swift
let client = AsyncClient(config: .init(
    timeout: 10,
    retry: .standard,
    cacheEnabled: true
))

struct User: Decodable { let id: Int; let name: String }

let user = try await client.request(
    URL(string: "https://api.example.com/user/1")!,
    as: User.self,
    cacheKey: "user-1"
)
```

## License

MIT
