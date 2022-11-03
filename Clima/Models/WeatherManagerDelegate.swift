import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    
    func didFail(errorMessage: String)
    
    func gotIncorrectInputData()
}
