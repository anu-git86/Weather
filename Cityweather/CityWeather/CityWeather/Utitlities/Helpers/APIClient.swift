//
//  APIClient.swift
//  CityWeather
//
//  Created by Anusha Vempati on 9/9/24.
//

import Foundation

struct APIClient {

    // MARK: - Properties
    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()

    private static let successRange = 200..<300

    // MARK: - SendRequest
    static func sendRequest<T: Decodable>(with urlString: String) async throws -> T? {
        guard let url = URL(string: urlString) else {
            throw NetworkingError.badUrl
        }

        let request = URLRequest(url: url)
        request.logCURL(pretty: true)

        let (data, response) = try await URLSession.shared.data(for: request)
        let validData = try validate(data: data, response: response)
        
        do {
            return try decoder.decode(T.self, from: validData)
        } catch let DecodingError.dataCorrupted(context) {
            print(context)
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("error: ", error)
        }
        return nil
    }

    // MARK: - Validate
    private static func validate(data: Data, response: URLResponse) throws -> Data {
        guard let code = (response as? HTTPURLResponse)?.statusCode else {
            throw NetworkingError.networkError
        }

        if successRange.contains(code) {
            return data
        } else {
            switch code {
            case 401:
                throw NetworkingError.unauthorized
            case 404:
                throw NetworkingError.notFound
            default:
                throw NetworkingError.irregularError(statusCode: code)
            }
        }
    }
}


extension URLRequest {
    @discardableResult
    func logCURL(pretty: Bool = false) -> String {
        print("============= cURL ============= \n")
        
        let newLine = pretty ? "\\\n" : ""
        let method = (pretty ? "--request " : "-X ") + "\(self.httpMethod ?? "GET") \(newLine)"
        let url: String = (pretty ? "--url " : "") + "\'\(self.url?.absoluteString ?? "")\' \(newLine)"
        
        var cURL = "curl "
        var header = ""
        var data: String = ""
        
        if let httpHeaders = self.allHTTPHeaderFields, httpHeaders.keys.count > 0 {
            for (key, value) in httpHeaders {
                header += (pretty ? "--header " : "-H ") + "\'\(key): \(value)\' \(newLine)"
            }
        }
        
        if let bodyData = self.httpBody, let bodyString = String(data: bodyData, encoding: .utf8), !bodyString.isEmpty {
            data = "--data '\(bodyString)'"
        }
        
        cURL += method + url + header + data
        print(cURL)
        return cURL
    }
}
