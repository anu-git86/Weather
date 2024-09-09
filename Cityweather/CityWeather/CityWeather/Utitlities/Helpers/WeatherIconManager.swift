//
//  WeatherIconManager.swift
//  CityWeather
//
//  Created by Anusha Vempati on 9/9/24.
//

import Foundation
import UIKit

class WeatherIconManager {
    static let shared = WeatherIconManager()
    private let cache = NSCache<NSString, UIImage>()

    func fetchWeatherIcon(iconCode: String, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = cache.object(forKey: iconCode as NSString) {
            completion(cachedImage)
            return
        }
        
        let iconURLString = "https://openweathermap.org/img/wn/\(iconCode)@2x.png"
        guard let url = URL(string: iconURLString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                self.cache.setObject(image, forKey: iconCode as NSString)
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
}
