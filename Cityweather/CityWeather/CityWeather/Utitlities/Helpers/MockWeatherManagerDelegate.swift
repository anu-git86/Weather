//
//  MockWeatherManagerDelegate.swift
//  CityWeather
//
//  Created by Anusha Vempati on 9/9/24.
//

import Foundation

class MockWeatherManagerDelegate: WeatherManagerDelegate {
    var didUpdateWeatherCalled = false
    var didFailWithErrorCalled = false
    var weather: WeatherModel?
    var error: NetworkingError?

    func didUpdateWeather(_ viewModel: ViewModel, weather: WeatherModel) {
        didUpdateWeatherCalled = true
        self.weather = weather
    }

    func didFailWithError(error: NetworkingError) {
        didFailWithErrorCalled = true
        self.error = error
    }
}
