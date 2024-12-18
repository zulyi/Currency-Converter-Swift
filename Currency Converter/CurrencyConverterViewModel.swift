//
//  CurrencyConverterViewModel.swift
//  Currency Converter
//
//  Created by Anton Golovatyuk on 19.12.2024.
//

import Foundation
import Alamofire

class CurrencyConverterViewModel {
    
    var onResultUpdated: ((String) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    var onErrorOccurred: ((String) -> Void)?
    
    
    private let baseURL = "http://api.evp.lt/currency/commercial/exchange"
    private var updateTimer: Timer?
    
    private var amount: Double = 1.0
    private var fromCurrency: String = "EUR"
    private var toCurrency: String = "USD"
    
    func setAmount(_ value: Double) {
        self.amount = value
        fetchConversionRate()
    }
    
    func setFromCurrency(_ currency: String) {
        self.fromCurrency = currency
        fetchConversionRate()
    }
    
    func setToCurrency(_ currency: String) {
        self.toCurrency = currency
        fetchConversionRate()
    }
    
    func startAutoUpdate() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            self?.fetchConversionRate()
        }
    }
    
    func stopAutoUpdate() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func fetchConversionRate() {
        onLoadingStateChanged?(true)
        let url = "\(baseURL)/\(amount)-\(fromCurrency)/\(toCurrency)/latest"
        
        AF.request(url).responseJSON { [weak self] response in
            self?.onLoadingStateChanged?(false)
            
            switch response.result {
            case .success(let json):
                if let dict = json as? [String: Any], let result = dict["amount"] as? String {
                    self?.onResultUpdated?("Result: \(result) \(self?.toCurrency ?? "")")
                } else {
                    self?.onErrorOccurred?("Invalid response format.")
                }
            case .failure(let error):
                self?.onErrorOccurred?("Failed to fetch conversion rate: \(error.localizedDescription)")
            }
        }
    }
}
