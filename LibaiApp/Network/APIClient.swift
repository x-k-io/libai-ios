import Foundation

/// HTTP 方法
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

/// API 客户端 - 负责网络请求
final class APIClient {
    static let shared = APIClient()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = AppConfig.timeoutInterval
        self.session = URLSession(configuration: config)
        
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .useDefaultKeys
        self.decoder.dateDecodingStrategy = .iso8601
        
        self.encoder = JSONEncoder()
        self.encoder.keyEncodingStrategy = .useDefaultKeys
    }
    
    /// 发送请求（兼容写法）
    func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .get,
        parameters: [String: Any]? = nil,
        body: Codable? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        let request = try buildRequest(
            endpoint: endpoint,
            method: method,
            parameters: parameters,
            body: body,
            requiresAuth: requiresAuth
        )
        
        let (data, response) = try await performRequest(request)
        return try parseResponse(data: data, response: response)
    }
    
    /// 发送分页请求
    func requestPage<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .get,
        parameters: [String: Any]? = nil,
        body: Codable? = nil,
        requiresAuth: Bool = true
    ) async throws -> PageResult<T> {
        let request = try buildRequest(
            endpoint: endpoint,
            method: method,
            parameters: parameters,
            body: body,
            requiresAuth: requiresAuth
        )
        
        let (data, response) = try await performRequest(request)
        return try parsePageResponse(data: data, response: response)
    }
    
    /// 刷新 Token
    func refreshToken() async throws -> AccountToken {
        guard let refreshToken = TokenManager.shared.refreshToken else {
            throw APIError.tokenExpired
        }
        
        let body = RefreshTokenRequest(refreshToken: refreshToken)
        let response: AccountToken = try await self.request(
            endpoint: "/security/refreshAccessToken",
            method: .post,
            body: body,
            requiresAuth: false
        )
        
        if let accessToken = response.accessToken, let refreshToken = response.refreshToken {
            TokenManager.shared.saveTokens(accessToken: accessToken, refreshToken: refreshToken)
        }
        
        return response
    }
    
    // MARK: - Private
    private func buildRequest(
        endpoint: String,
        method: HTTPMethod,
        parameters: [String: Any]?,
        body: Codable?,
        requiresAuth: Bool
    ) throws -> URLRequest {
        guard var urlComponents = URLComponents(string: AppConfig.baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        if let parameters = parameters {
            urlComponents.queryItems = parameters.map {
                URLQueryItem(name: $0.key, value: "\($0.value)")
            }
        }
        
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if requiresAuth, let token = TokenManager.shared.accessToken {
            request.setValue(token, forHTTPHeaderField: "x-token")
        } else if requiresAuth {
            print("[API Auth] WARNING: No token for \(endpoint)")
        }
        
        // ✅ 修复：去掉 try?，编码失败直接抛出异常，不再静默吞错误
        if let body = body {
            request.httpBody = try encoder.encode(body)
        }
        
        // ====================== 完整请求日志打印 ======================
        print("\n========== [API REQUEST START] ==========")
        print("👉 Method: \(method.rawValue)")
        print("👉 URL: \(url.absoluteString)")
        print("👉 Headers:")
        if let headers = request.allHTTPHeaderFields {
            for (key, value) in headers {
                // token只打印前20位，避免明文全输出
                if key.lowercased() == "x-token" {
                    print("   \(key): \(value.prefix(20))...")
                } else {
                    print("   \(key): \(value)")
                }
            }
        } else {
            print("   (empty)")
        }
        
        if let bodyData = request.httpBody, let bodyStr = String(data: bodyData, encoding: .utf8) {
            print("👉 Body: \(bodyStr)")
        }
        print("========== [API REQUEST END] ==========\n")
        // =============================================================
        
        return request
    }
    
    private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        return try await withCheckedThrowingContinuation { continuation in
            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: APIError.networkError(error))
                    return
                }
                guard let data = data, let response = response else {
                    continuation.resume(throwing: APIError.invalidResponse)
                    return
                }
                continuation.resume(returning: (data, response))
            }
            task.resume()
        }
    }
    
    private func parseResponse<T: Codable>(data: Data, response: URLResponse) throws -> T {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        // ====================== 响应头打印 ======================
        print("\n========== [API RESPONSE START] ==========")
        print("✅ StatusCode: \(httpResponse.statusCode)")
        print("✅ Response Headers:")
        for (key, value) in httpResponse.allHeaderFields {
            print("   \(key): \(value)")
        }
        // =======================================================
        
        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401:
            throw APIError.tokenExpired
        case 403:
            throw APIError.noPermission
        default:
            throw APIError.invalidResponse
        }
        
        do {
            // 调试：打印原始响应JSON
            if let jsonStr = String(data: data, encoding: .utf8) {
                print("✅ Response Body: \(jsonStr)")
            }
            print("========== [API RESPONSE END] ==========\n")
            
            let apiResponse = try decoder.decode(APIResponse<T>.self, from: data)
            
            guard apiResponse.isSuccess else {
                let code = apiResponse.code ?? -1
                let message = apiResponse.message ?? "未知错误"
                if code == 200101 {
                    throw APIError.tokenExpired
                }
                throw APIError.businessError(code: code, message: message)
            }
            
            guard let result = apiResponse.data else {
                throw APIError.invalidResponse
            }
            
            return result
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.decodeError(error)
        }
    }
    
    private func parsePageResponse<T: Codable>(data: Data, response: URLResponse) throws -> PageResult<T> {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        print("\n========== [PAGE API RESPONSE START] ==========")
        print("✅ StatusCode: \(httpResponse.statusCode)")
        print("✅ Response Headers:")
        for (key, value) in httpResponse.allHeaderFields {
            print("   \(key): \(value)")
        }
        if let jsonStr = String(data: data, encoding: .utf8) {
            print("✅ Response Body: \(jsonStr)")
        }
        print("========== [PAGE API RESPONSE END] ==========\n")
        
        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401:
            throw APIError.tokenExpired
        case 403:
            throw APIError.noPermission
        default:
            throw APIError.invalidResponse
        }
        
        do {
            // ✅ 这里解码 APIResponse<[T]>，data是数组
            let apiResponse = try decoder.decode(APIResponse<[T]>.self, from: data)
            
            guard apiResponse.isSuccess else {
                let code = apiResponse.code ?? -1
                let message = apiResponse.message ?? "未知错误"
                if code == 200101 {
                    throw APIError.tokenExpired
                }
                throw APIError.businessError(code: code, message: message)
            }
            
            // 组装PageResult
            let pageResult = PageResult<T>(
                records: apiResponse.data,
                pageCount: apiResponse.pagination?.pageCount,
                total: apiResponse.pagination?.total
            )
            return pageResult
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.decodeError(error)
        }
    }
}
