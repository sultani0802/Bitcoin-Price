//
//  ViewController.swift
//  Bitcoin Cost
//
//  Created by Haamed Sultani on 2018-09-18.
//  Copyright © 2018 Sultani. All rights reserved.
//

import UIKit
import SwiftyJSON // Makes handling JSON objects easier
import Alamofire // Makes networking requests easier

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    // MARK: - Networking Variables
    let baseURL = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTC"
    let API_KEY = ""
    let publicKey = "MGY2MzhiYzgwZjcwNGU3ZDlhMTdjNDdlMzY0YTk5ODQ"
    var finalURL = ""
    
    // MARK: - Variables
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    let currencySymbolsArray = ["$", "R$", "$", "¥", "€", "£", "$", "Rp", "₪", "₹", "¥", "$", "kr", "$", "zł", "lei", "₽", "kr", "$", "$", "R"]
    
    // MARK: - IB Outlets
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var currencyPickerView: UIPickerView!
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        currencyPickerView.delegate = self
        currencyPickerView.dataSource = self
        
        getBitcoinAuth()
    }
    
    // MARK: - Networking
    // This method fetches the price of 1 Bitcoin based on the currency chosen in the picker view
    func getBitcoinPrice(url: String, symbol: Int) {
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    let bitcoinJSON : JSON = JSON(response.result.value!) // Create a JSON object from the result
                    
                    self.parseJSONData(json: bitcoinJSON, symbol: symbol) // Handle the JSON object
                } else {
                    // We couldn't connect to the bitcoin endpoint
                    print("Error connecting to Bitcoin endpoint")
                }
        }
    }
    
    // Currently, this method is not in use in the app
    // It is automatically called in ViewDidLoad for testing purposes only because I only have a free account on their website
    // This was just for my own enjoyment to give myself a challenge to make a request using a SHA256 encrypted header
    func getBitcoinAuth(){
        let time: Int = Int(NSDate().timeIntervalSince1970) // Creating Epoch timestamp (required by Bitcoin website)
        let payload: String = String(time) + "." + publicKey // Payload required by Bitcoin website
        let digestValue = payload.hmac(key: privateKey) // Digest value required by Bitcoin website
        let xSig = payload + "." + digestValue // This string is the header required by the Bitcoin endpoint
    
        print(digestValue) // This is the header we have to supply with our GET request
        
        
        Alamofire.request("https://apiv2.bitcoinaverage.com/indices/global/ticker/all?crypto=BTC&fiat=USD,EUR", method: .get, headers: ["X-signature": xSig])
            .responseString { response in
                
                if response.result.isSuccess {
                    // Do stuff with the data
                    let bitcoinJSON : JSON = JSON(response.result.value!) // Create a JSON object from the result
                    print(bitcoinJSON)
                } else {
                    // We couldn't connect to the bitcoin endpoint
                    print("Error connecting to Bitcoin endpoint")
                }
        }
    }
    
    // MARK: - JSON Parsing
    // If the JSON we received from the API call isn't nil then call the update UI method
    func parseJSONData(json: JSON, symbol: Int) {
        if let price = json["ask"].double {
            updateUI(price: price, symbol: symbol) // Send data to UI update method
        }
    }
    
    
    // MARK: - Update UI Methods
    func updateUI(price: Double, symbol: Int){
        priceLabel.text = String(currencySymbolsArray[symbol]) + " " + String(price) // Update the label with the corresponding price
    }
    
    // MARK: - Picker View Delegate Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // Only one column
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencyArray.count // Equal to the number of items in the picker view array
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencyArray[row] // Fill in the Picker View with our array contents
    }
    
    // This method allows you to perform some action depending on the row the user selected
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        finalURL = baseURL + currencyArray[row]
        
        getBitcoinPrice(url: finalURL, symbol: row)
    }
}

// This extension allows me to encrypt a string with a key using SHA256
// HOW TO USE:
// stringToBeEncrypted.hmac(key: myKey)  => your encrypted string
extension String {
    func hmac(key: String) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), key, key.count, self, self.count, &digest)
        let data = Data(bytes: digest)
        return data.map { String(format: "%02hhx", $0) }.joined()
    }
}
