import Foundation

struct WeatherModel {
    let cityName: String
    let temperature: Double
    let weatherId: Int
    var weatherConditionImage: String {
        switch weatherId {
        case 200...232:
            return "cloud.bolt.fill"
        case 300...321:
            return "cloud.drizzle"
        case 500...504:
            return "cloud.sun.rain"
        case 511:
            return "cloud.sleet"
        case 520...531:
            return "cloud.drizzle"
        case 600...622:
            return "snowflake"
        case 701...781:
            return "aqi.medium"
        case 800:
            return "sun.max"
        case 801:
            return "cloud.sun"
        case 802:
            return "cloud"
        case 803:
            return "cloud.fill"
        case 804:
            return "cloud.fill"
        default:
            return "questionmark.circle"
        }
    }
}
