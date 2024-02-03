//
//  File.swift
//  
//
//  Created by Lukas Simonson on 2/3/24.
//

import Vapor

class ErrorHandlingMiddleware: AsyncMiddleware {
    public func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        do {
            let response = try await next.respond(to: request)
            return response
        } catch {
            request.logger.report(error: error)
            switch error {
                case let respondable as RespondableError:
                    return respondable.response
                case let abort as AbortError:
                    guard let data = abort.reason.data(using: .utf8)
                    else { return Response(status: abort.status, headers: abort.headers, body: "An Unknown Error Occurred") }
                    return Response(status: abort.status, headers: abort.headers, body: .init(data: data))
                default:
                    guard !request.application.environment.isRelease,
                          let data = "\(error)".data(using: .utf8)
                    else { return Response(status: .internalServerError, body: "An Unknown Error Occurred") }
                    return Response(status: .internalServerError, body: .init(data: data))
            }
        }
    }
}

protocol RespondableError: Error {
    var response: Response { get }
}
