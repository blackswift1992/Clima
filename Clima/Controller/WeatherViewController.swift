//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

extension UIView{
     func blink() {
         self.alpha = 0.2
         UIView.animate(withDuration: 1, delay: 0.0, options: [.curveLinear, .repeat, .autoreverse], animations: {self.alpha = 1.0}, completion: nil)
     }
}

class WeatherViewController: UIViewController {
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var gpsSearchingLabel: UILabel!
    @IBOutlet weak var degreeLabel: UILabel!
    @IBOutlet weak var celsiusLabel: UILabel!
    @IBOutlet weak var gpsButton: UIButton!
    
    
    
    let weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
     
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // the text field should report back to (сповіщатиме про зміни) our view controller.
        hideViewElements()
        
        searchTextField.delegate = self
        weatherManager.delegate = self
        locationManager.delegate = self
        
        gpsSearchingLabel.blink()
        
        //Requests the user’s permission to use location services while the app is in use.
        locationManager.requestWhenInUseAuthorization()
        //this method "Request for a one-time delivery of the user's current location."
        locationManager.requestLocation()
        
        hideKeyboardWhenTappedAround()
    }
    
    @IBAction func gpsButtonPressed(_ sender: UIButton) {
        gpsSearchingLabel.isHidden = false
        locationManager.requestLocation()
//        searchTextField.endEditing(true)
    }
    
    func hideViewElements() {
        conditionImageView.image = UIImage(systemName: "globe.europe.africa.fill")
        temperatureLabel.isHidden = true
        degreeLabel.isHidden = true
        celsiusLabel.isHidden = true
        cityLabel.isHidden = true
    }
    
    func showViewElements() {
        temperatureLabel.isHidden = false
        degreeLabel.isHidden = false
        celsiusLabel.isHidden = false
        cityLabel.isHidden = false
    }
}


//MARK: - UITextFieldDelegate


extension WeatherViewController: UITextFieldDelegate {
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
        
    }
    
    
    //підключивши протокол UITextFieldDelegate і назначивши об'єкт нашого контролера в якості делегата для textField-а тепер нам стають доступні подібні методи де ми можемо відслідковувати всі дії користувача коли той працює з textField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    
    //This is the equivalent of our text field saying, "Hey, view controller, the user stopped editing."
    //цей метод виконується під час виконання строки "searchTextField.endEditing(true)"
    //тобто цей метод виконується перед тим як зникне клавіатура вводу
    func textFieldDidEndEditing(_ textField: UITextField) {
        //Use searchTextField.text to find weather for that city
        if let city = searchTextField.text {
            weatherManager.fetchWeather(byCityName: city)
            gpsButton.isEnabled = true
        }
        
        searchTextField.text = ""
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        gpsButton.isEnabled = false
    }
    
    //This is the text field saying, "Excuse me, view controller, the user just tapped elsewhere. What should I do sir?" Цей методи дуже корисний для валідації вводу
//    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        if textField.text != "" {
//            return true
//        } else {
//            textField.placeholder = "Type city/country..."
//            return false
//        }
//    }
}


//MARK: - WeatherManagerDelegate


extension WeatherViewController: WeatherManagerDelegate {
    func gotIncorrectInputData() {
        DispatchQueue.main.async {
//            self.hideViewElements()
            self.searchTextField.placeholder = "Type valid location"
        }
    }
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.cityLabel.text = weather.cityName
            self.temperatureLabel.text = String(format: "%.1f", weather.temp)
            self.conditionImageView.image = UIImage(systemName: weather.sfSymbolName)
            self.searchTextField.placeholder = "Search"
            self.gpsSearchingLabel.isHidden = true
            self.showViewElements()
        }
    }
    
    
    func didFailWithError(error: Error) {
        print(error)
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
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}



extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
