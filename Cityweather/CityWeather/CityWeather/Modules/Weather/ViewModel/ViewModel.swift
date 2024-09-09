//
//  ViewModel.swift
//  CityWeather
//
//  Created by Anusha Vempati on 9/9/24.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ viewModel: ViewModel, weather: WeatherModel)
    func didFailWithError(error: NetworkingError)
}

struct ViewModel {
    var delegate: WeatherManagerDelegate?
    
    let openWeatherURL = "https://api.openweathermap.org/data/2.5/weather?&units=metric&appid=\(APISecret.key)"
    
    func fetchWeatherData(location: String) async {
        let components = location.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        var query: String
        
        switch components.count {
        case 1:
            query = components[0]
        case 2:
            query = "\(components[0]),\(components[1])"
        case 3:
            query = "\(components[0]),\(components[1]),\(components[2])"
        default:
            delegate?.didFailWithError(error: NetworkingError.invalidInput)
            return
        }
        
        let urlString = "\(openWeatherURL)&q=\(query)"
        let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        await performRequest(with: encodedUrlString ?? urlString)
    }
    
    func fetchWeatherData(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async {
        let urlString = "\(openWeatherURL)&lat=\(latitude)&lon=\(longitude)"
        await performRequest(with: urlString)
    }
    
    private func performRequest(with urlString: String) async {
        do {
            let decodedResponse: WeatherModel? = try await APIClient.sendRequest(with: urlString)
            if let weather = decodedResponse {
                delegate?.didUpdateWeather(self, weather: weather)
            } else {
                delegate?.didFailWithError(error: NetworkingError.badParsing)
            }
        } catch {
            delegate?.didFailWithError(error: error as! NetworkingError)
        }
    }
}
