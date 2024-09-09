//
//  WeatherViewController.swift
//  CityWeather
//
//  Created by Anusha Vempati on 9/9/24.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var cityNameLabel: UILabel!
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var weatherDescLabel: UILabel!
    @IBOutlet var feelsLikeLabel: UILabel!
    @IBOutlet var pressureLabel: UILabel!
    @IBOutlet var humidityLabel: UILabel!
    @IBOutlet var visibilityLabel: UILabel!
    @IBOutlet var windSpeedLabel: UILabel!
    @IBOutlet var windDirectionLabel: UILabel!
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var infoStackView: UIStackView!
    @IBOutlet var weatherIcon: UIImageView!
    
    // MARK: - Properties
    var viewModel = ViewModel()
    let locationManager = CLLocationManager()
    var activityIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Activity Indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicator.startAnimating()
        
        // StackView Styling
        infoStackView.layer.cornerRadius = 12
        
        // Config
        locationManager.delegate = self
        searchTextField.delegate = self
        viewModel.delegate = self
        if let city: String =  UserDefaultManager.shared.get(for: .city) {
            Task {
                await viewModel.fetchWeatherData(location: city)
            }
        } else {
            locationManager.requestWhenInUseAuthorization()
            checkLocationAvailablility()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
    }
    
    // MARK: - IBActions
    @IBAction func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
        activityIndicator.startAnimating()
    }
}

//MARK: - TextFieldDelegate

extension ViewController: UITextFieldDelegate {
    @IBAction func searchBtnPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Enter city name..."
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let city = searchTextField.text {
            UserDefaultManager.shared.set(city, for: .city)
            Task {
                await viewModel.fetchWeatherData(location: city)
            }
        }
        
        searchTextField.text = ""
        activityIndicator.startAnimating()
    }
}

//MARK: - WeatherManagerDelegate

extension ViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: ViewModel, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.tempLabel.text = weather.temperatureString
            self.cityNameLabel.text = weather.name
            self.weatherDescLabel.text = weather.descriptionString
            self.feelsLikeLabel.text = weather.feelsLikeString
            self.pressureLabel.text = weather.pressureString
            self.humidityLabel.text = weather.humidityString
            self.visibilityLabel.text = weather.visibilityString
            self.backgroundImage.image = weather.backgroundImage
            self.windSpeedLabel.text = weather.windSpeedString
            self.windDirectionLabel.text = weather.windDirectionString
            if let iconCode = weather.weather.first?.icon {
                WeatherIconManager.shared.fetchWeatherIcon(iconCode: iconCode) { [weak self] image in
                    self?.weatherIcon.image = image
                }
            }
            self.activityIndicator.stopAnimating()
        }
    }
    
    func didFailWithError(error: NetworkingError) {
        displaySimpleAlert(title: error.title, message: error.message)
    }
}

//MARK: - LocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            
            Task {
                await viewModel.fetchWeatherData(latitude: lat, longitude: lon)
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if UserDefaultManager.shared.get(for: .city) as String? == nil {
            checkLocationAvailablility()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        displaySimpleAlert(title: "Error", message: "Oops 😔 something went wrong finding your location. Please try again.")
    }
}

//MARK: - Additional methods

extension ViewController {
    func displaySimpleAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            self.activityIndicator.stopAnimating()
        }
    }
    
    func checkLocationAvailablility() {
        if CLLocationManager.locationServicesEnabled() {
            switch locationManager.authorizationStatus {
            case .notDetermined, .restricted, .denied:
                print("No access")
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.requestLocation()
            @unknown default:
                break
            }
        } else {
            displaySimpleAlert(title: "Error", message: "Seems like your location services are off. Please turn them on to enable this feature.")
        }
    }
}
