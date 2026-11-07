import Foundation

public enum NetworkError: Error, LocalizedError, Equatable {
    case invalidURL
    case noData
    case decoding(Error)
    case httpStatus(Int)
    case timeout
    case cancelled
    case underlying(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidURL: return "URL inválida"
        case .noData: return "Resposta vazia"
        case .decoding: return "Falha ao decodificar resposta"
        case .httpStatus(let code): return "Erro HTTP \(code)"
        case .timeout: return "Tempo limite excedido"
        case .cancelled: return "Requisição cancelada"
        case .underlying(let error): return error.localizedDescription
        }
    }

    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL), (.noData, .noData), (.timeout, .timeout), (.cancelled, .cancelled):
            return true
        case (.httpStatus(let a), .httpStatus(let b)):
            return a == b
        default:
            return false
        }
    }
}
