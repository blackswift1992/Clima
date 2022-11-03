import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    @IBOutlet private weak var conditionImageView: UIImageView!
    
    @IBOutlet private weak var temperatureLabel: UILabel!
    @IBOutlet private weak var cityLabel: UILabel!
    
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var gpsSearchingLabel: UILabel!
    @IBOutlet private weak var degreeLabel: UILabel!
    @IBOutlet private weak var celsiusLabel: UILabel!
    @IBOutlet private weak var gpsButton: UIButton!
    
    private let weatherManager = WeatherManager()
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpDelegates()
        customizeViewElements()
        requestWeatherUsingGPS()
    }
}


//MARK: - UITextFieldDelegate


extension WeatherViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let city = searchTextField.text else { return }
        
        weatherManager.fetchWeather(byCityName: city)
        gpsButton.isEnabled = true
        searchTextField.text = ""
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        gpsButton.isEnabled = false
    }
}


//MARK: - WeatherManagerDelegate


extension WeatherViewController: WeatherManagerDelegate {
    func gotIncorrectInputData() {
        DispatchQueue.main.async {
            self.searchTextField.placeholder = "Type valid city name"
        }
    }
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        cityLabel.text = weather.cityName
        temperatureLabel.text = String(format: "%.1f", weather.temperature)
        conditionImageView.image = UIImage(systemName: weather.weatherConditionImage)
        searchTextField.placeholder = "Search"
        gpsSearchingLabel.isHidden = true
        
        showCityWeaterUIElements()
        turnOffGPSSearchingLabel()
    }
    
    func didFail(errorMessage: String) {
        turnOffGPSSearchingLabel()
        print(errorMessage)
    }
}


//MARK: - CLLocationManagerDelegate


extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingHeading()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(byLatitude: lat, andLongitude: lon)
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if locationManager.authorizationStatus.rawValue == 4 {
            DispatchQueue.main.async {
                self.turnOnGPSSearchingLabel()
            }
            
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}


//MARK: - @IBActions


private extension WeatherViewController {
    @IBAction func gpsButtonPressed(_ sender: UIButton) {
        if locationManager.authorizationStatus.rawValue == 4 {
            turnOnGPSSearchingLabel()
            locationManager.requestLocation()
        } else {
            showGPSAlertMessage()
        }
    }
    
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
}


//MARK: - Private methods


private extension WeatherViewController {
    func hideCityWeaterUIElements() {
        temperatureLabel.isHidden = true
        degreeLabel.isHidden = true
        celsiusLabel.isHidden = true
        cityLabel.isHidden = true
    }
    
    func showCityWeaterUIElements() {
        temperatureLabel.isHidden = false
        degreeLabel.isHidden = false
        celsiusLabel.isHidden = false
        cityLabel.isHidden = false
    }
    
    func turnOnGPSSearchingLabel() {
        gpsSearchingLabel.isHidden = false
        gpsSearchingLabel.startBlink()
    }
    
    func turnOffGPSSearchingLabel() {
        gpsSearchingLabel.isHidden = true
        gpsSearchingLabel.stopBlink()
    }
    
    func showGPSAlertMessage() {
        let alertMessage = UIAlertController(title: "Allow \"Clima\" to access your location", message: "Open \"Settings\" on your iPhone. Go to\"Privacy\". And in \"Location Services\" allow \"Clima\" app to determine your location.", preferredStyle: .alert)
        
        alertMessage.addAction(UIAlertAction(title: "Open \"Settings\"", style: .default) {_ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL, completionHandler: { (success) in
                    print("Settings opened: \(success)")
                })
            }
        })

        alertMessage.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        self.present(alertMessage, animated: true, completion: nil)
    }
    
    @objc func dismissKeyboardAfterTap() {
        view.endEditing(true)
    }
}


//MARK: - Set up methods


private extension WeatherViewController {
    func setUpDelegates() {
        weatherManager.delegate = self
        locationManager.delegate = self
        searchTextField.delegate = self
    }
    
    func customizeViewElements() {
        searchTextField.layer.cornerRadius = 20
        searchTextField.setLeftPaddingPoints(10)
        searchTextField.setRightPaddingPoints(10)
        
        hideCityWeaterUIElements()
        setGestureRecognizerToView()
    }
    
    func setGestureRecognizerToView() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardAfterTap))
        
        gestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    func requestWeatherUsingGPS() {
        if locationManager.authorizationStatus.rawValue == 4 {
            turnOnGPSSearchingLabel()
            //this method "Request for a one-time delivery of the user's current location.
            locationManager.requestLocation()
        } else {
            //Requests the user’s permission to use location services while the app is in use.
            locationManager.requestWhenInUseAuthorization()
        }
    }
}


