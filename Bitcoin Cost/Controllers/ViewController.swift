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
    let privateKey = "YmU1ZjgxMmVjNTU2NGRiNThiN2QyMDQ4NjkzMjI2MmE4Y2UyMDA0MGFjNWQ0OTczYTQ3NDY2MTYzMGQyOThlMQ"
    var finalURL = ""
    
    // MARK: - Variables
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    // MARK: - IB Outlets
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var currencyPickerView: UIPickerView!
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        currencyPickerView.delegate = self
        currencyPickerView.dataSource = self
    }
    
    // MARK: - Networking
    func getBitcoinPrice(url: String) {
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    // Do stuff with the data
                    let bitcoinJSON : JSON = JSON(response.result.value!) // Create a JSON object from the result
                    
                    print(bitcoinJSON)
                    
                    self.parseJSONData(json: bitcoinJSON) // Handle the JSON object
                } else {
                    // We couldn't connect to the bitcoin endpoint
                    print("Error connecting to Bitcoin endpoint")
                }
        }
    }
    
    // MARK: - JSON Parsing
    func parseJSONData(json: JSON) {
        if let price = json["ask"].double {
            updateUI(price: price) // Send data to UI update method
        }
    }
    
    
    // MARK: - Update UI Methods
    func updateUI(price: Double){
        priceLabel.text = String(price) // Update the label with the corresponding UI
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
        
        getBitcoinPrice(url: finalURL)
    }
}

