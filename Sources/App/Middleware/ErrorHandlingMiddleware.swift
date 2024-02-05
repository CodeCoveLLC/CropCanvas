//
//  File.swift
//  
//
//  Created by Lukas Simonson on 2/3/24.
//

import Vapor

class ErrorHandlingMiddleware: AsyncMiddleware {
    
    private static var jsonHeader = HTTPHeaders([("Content-Type", "application/json; charset=utf-8")])
    
    private static var unknownError: Response = Response(
        status: .internalServerError,
        headers: jsonHeader,
        body: "{ \"code\": 500, \"reason\": \"An Unknown Error Occurred\" }"
    )
    
    private struct ErrorResponse: Content {
        let status: UInt
        let reason: String
    }
    
    public func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        do {
            let response = try await next.respond(to: request)
            return response
        } catch {
            request.logger.report(error: error)
            switch error {
                case let abort as AbortError:
                    guard let data = try? JSONEncoder().encode(ErrorResponse(status: abort.status.code, reason: abort.reason))
                    else { return Self.unknownError }
                    
                    var headers = abort.headers
                    headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")
                    
                    return Response(status: abort.status, headers: headers, body: .init(data: data))
                default:
                    guard !request.application.environment.isRelease,
                          let data = try? JSONEncoder().encode(ErrorResponse(status: 500, reason: String(describing: error)))
                    else { return Self.unknownError }
                    return Response(status: .internalServerError, headers: Self.jsonHeader, body: .init(data: data))
            }
        }
    }
}
