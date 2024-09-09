//
//  ViewModelTests.swift
//  CityWeatherTests
//
//  Created by Anusha Vempati on 9/9/24.
//

import XCTest
@testable import CityWeather

final class ViewModelTests: XCTestCase {
    var viewModel: ViewModel!
    var delegate: MockWeatherManagerDelegate!

    override func setUpWithError() throws {
        viewModel = ViewModel()
        delegate = MockWeatherManagerDelegate()
        viewModel.delegate = delegate
    }

    override func tearDownWithError() throws {
        viewModel = nil
        delegate = nil
    }

    func testFetchWeatherDataByLocationSuccess() async throws {
        // Given
        let expectation = XCTestExpectation(description: "Weather data fetched successfully")

        delegate.didUpdateWeatherCalled = false
        delegate.didFailWithErrorCalled = false
        viewModel.delegate = delegate
        
        // When
        await viewModel.fetchWeatherData(location: "London,UK")
        
        // Then
        XCTAssertTrue(delegate.didUpdateWeatherCalled, "Weather data should be updated successfully")
        XCTAssertNotNil(delegate.weather, "Weather data should not be nil")
        XCTAssertFalse(delegate.didFailWithErrorCalled, "Error should not be called")
        
        expectation.fulfill()
    }

    func testFetchWeatherDataByLocationFailure() async throws {
        // Given
        let expectation = XCTestExpectation(description: "Weather data fetch should fail")

        // Set delegate methods to update expectation
        delegate.didUpdateWeatherCalled = false
        delegate.didFailWithErrorCalled = false
        
        viewModel.delegate = delegate
        
        // When
        await viewModel.fetchWeatherData(location: "InvalidLocation")

        // Then
        XCTAssertTrue(delegate.didFailWithErrorCalled, "Error should be called")
        XCTAssertNil(delegate.weather, "Weather data should be nil")
        
        expectation.fulfill()
    }

    func testFetchWeatherDataByCoordinatesSuccess() async throws {
        // Given
        let expectation = XCTestExpectation(description: "Weather data fetched successfully by coordinates")

        // Set delegate methods to update expectation
        delegate.didUpdateWeatherCalled = false
        delegate.didFailWithErrorCalled = false
        
        viewModel.delegate = delegate
        
        // When
        await viewModel.fetchWeatherData(latitude: 51.5074, longitude: -0.1278)
        
        // Then
        XCTAssertTrue(delegate.didUpdateWeatherCalled, "Weather data should be updated successfully")
        XCTAssertNotNil(delegate.weather, "Weather data should not be nil")
        XCTAssertFalse(delegate.didFailWithErrorCalled, "Error should not be called")

        expectation.fulfill()
    }

    func testFetchWeatherDataByCoordinatesFailure() async throws {
        // Given
        let expectation = XCTestExpectation(description: "Weather data fetch should fail by coordinates")

        // Set delegate methods to update expectation
        delegate.didUpdateWeatherCalled = false
        delegate.didFailWithErrorCalled = false
        viewModel.delegate = delegate
        
        // When
        await viewModel.fetchWeatherData(latitude: 999.0, longitude: 999.0)
        
        // Then
        XCTAssertTrue(delegate.didFailWithErrorCalled, "Error should be called")
        XCTAssertNil(delegate.weather, "Weather data should be nil")
        expectation.fulfill()
    }
}
