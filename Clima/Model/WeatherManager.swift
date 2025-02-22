//
//  WeatherManager.swift
//  Clima
//
//  Created by admin on 7/4/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation


protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager , weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=6c35d7a675e4a668e5808f44fb43d541&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees , longitude: CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String){
        //make url
        if let url = URL(string: urlString){
            // make session
            let session = URLSession(configuration: .default)
            // give sessio a task
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil{
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data{
                    if let weather = self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self , weather: weather)
                    }
                    
                }
            }
            // start the task
            task.resume()
            
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionID: id, cityName: name, temperature: temp)
            print(weather.conditionName)
            print(weather.temperatureString)
            return weather
            
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
        
    }
    
    
}



