//
//  NetworkingError.swift
//  CityWeather
//
//  Created by Anusha Vempati on 9/9/24.
//

import Foundation

enum NetworkingError: Error {
    case badUrl
    case badParsing
    case networkError
    case unauthorized
    case notFound
    case irregularError(statusCode: Int)
    case invalidInput 

    var title: String {
        switch self {
        case .badUrl:
            return "Oops 😔"
        case .badParsing:
            return "Error"
        case .networkError:
            return "Network Error"
        case .unauthorized:
            return "Unauthorized"
        case .notFound:
            return "Not Found"
        case .irregularError:
            return "Error"
        case .invalidInput:
            return "Invalid Input"
        }
    }

    var message: String {
        switch self {
        case .badUrl:
            return "We can't find this city. Please try again."
        case .badParsing:
            return "Oops 😔 something went wrong. Please try again."
        case .networkError:
            return "There was a problem connecting to the network. Please check your internet connection and try again."
        case .unauthorized:
            return "You are not authorized to access this resource. Please check your credentials and try again."
        case .notFound:
            return "The requested resource could not be found. Please check the URL and try again."
        case .irregularError(let statusCode):
            return "An unexpected error occurred. Status code: \(statusCode). Please try again."
        case .invalidInput:
            return "The input provided is not valid. Please enter a valid city name, or a combination of city name, state code, and country code."
        }
    }
}
