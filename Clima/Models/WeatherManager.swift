import UIKit

class WeatherManager {
    private let appId = "63e96858d89b1f9ca568257e3d941a14"
    private var cityName: String?
    
    var delegate: WeatherManagerDelegate?
    
    private var partOfCoordinatesURL: String { "https://api.openweathermap.org/geo/1.0/direct?appid=\(appId)&limit=5&q="
    }
    
    private var partOfWeatherURL: String { "https://api.openweathermap.org/data/2.5/weather?appid=\(appId)&units=metric&lat="
    }
}



//MARK: - Public methods


extension WeatherManager {
    func fetchWeather(byLatitude lat: Double, andLongitude lon: Double) {
        let weatherStringURL = "\(self.partOfWeatherURL)\(lat)&lon=\(lon)"
        
        guard let weatherURL = URL(string: weatherStringURL) else { return }
        
        URLSession(configuration: .default).dataTask(with: weatherURL) { [weak self] (data, response, error) in
            if let safeError = error {
                DispatchQueue.main.async {
                    self?.delegate?.didFail(errorMessage: safeError.localizedDescription)
                }
            } else {
                guard let safeSelf = self,
                      let safeData = data,
                      let weather = safeSelf.parseWeatherDataJSON(safeData)
                else { return }
                
                let weatherModel = WeatherModel(cityName: self?.cityName ?? weather.name, temperature: weather.main.temp, weatherId: weather.weather[0].id)
                
                self?.cityName = nil
                
                DispatchQueue.main.async {
                    self?.delegate?.didUpdateWeather(safeSelf, weather: weatherModel)
                }
            }
        }.resume()
    }
    
    func fetchWeather(byCityName city: String) {
        let trimmedCityName = city.trim()
        
        if !trimmedCityName.isEmpty {
            guard let trimmedEncodedCityName = trimmedCityName
                .addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            else { return }
            
            cityName = trimmedCityName
            
            let coordinatesURL = "\(partOfCoordinatesURL)\(trimmedEncodedCityName)"

            performCoordinatesRequest(byCityNameURL: coordinatesURL)
        } else {
            delegate?.gotIncorrectInputData()
        }
    }
}


//MARK: - Private methods


private extension WeatherManager {
    func performCoordinatesRequest(byCityNameURL url: String){
        guard let coordinatesURL = URL(string: url) else { return }
        
        URLSession(configuration: .default).dataTask(with: coordinatesURL) { [weak self] (data, response, error) in
            if let safeError = error {
                DispatchQueue.main.async {
                    self?.delegate?.didFail(errorMessage: safeError.localizedDescription)
                }
            } else {
                guard let safeData = data,
                      let coordinates = self?.parseCoordinatesDataJSON(safeData)
                else { return }
                
                self?.fetchWeather(byLatitude: coordinates.lat, andLongitude: coordinates.lon)
            }
        }.resume()
    }
    
    func parseCoordinatesDataJSON(_ coordinatesJSON: Data) -> CoordinatesData? {
        var coordinatesData: CoordinatesData?

        do {
            let coordinatesArray = try JSONDecoder().decode([CoordinatesData].self, from: coordinatesJSON)

            if coordinatesArray.isEmpty {
                DispatchQueue.main.async {
                    self.delegate?.didFail(errorMessage: "Fetching weather goes wrong. Try again.")
                }
                
                cityName = nil
                return nil
            } else {
                coordinatesData = coordinatesArray[0]
            }
        } catch {
            DispatchQueue.main.async {
                self.delegate?.didFail(errorMessage: "Fetching weather goes wrong. Try again.")
            }
            
            print("Decoding coordinatesDataJSON throws an error")
        }
        
        return coordinatesData
    }
    
    func parseWeatherDataJSON(_ weatherJSON: Data) -> WeatherData? {
        var weatherData: WeatherData?
        
        do {
            weatherData = try JSONDecoder().decode(WeatherData.self, from: weatherJSON)
        } catch {
            DispatchQueue.main.async {
                self.delegate?.didFail(errorMessage: "Fetching weather goes wrong. Try again.")
            }
            
            print("Decoding weatherDataJSON throws an error")
        }
        
        return weatherData
    }
}
