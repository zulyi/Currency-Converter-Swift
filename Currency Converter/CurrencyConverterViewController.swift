//
//  CurrencyConverterViewController.swift
//  Currency Converter
//
//  Created by Anton Golovatyuk on 18.12.2024.
//
import UIKit

class CurrencyConverterViewController: UIViewController {
    
    private let fromCurrencyPicker = UIPickerView()
    private let toCurrencyPicker = UIPickerView()
    private let amountTextField = UITextField()
    private let resultLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let currencies = ["EUR", "USD", "JPY", "GBP", "AUD", "CAD"]
    private let viewModel = CurrencyConverterViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.startAutoUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopAutoUpdate()
    }
    
    private func setupUI() {
        title = "Currency Converter"
        view.backgroundColor = .white
        
        amountTextField.placeholder = "Enter amount"
        amountTextField.borderStyle = .roundedRect
        amountTextField.keyboardType = .decimalPad
        amountTextField.addTarget(self, action: #selector(onAmountChanged), for: .editingChanged)
        view.addSubview(amountTextField)
        
        fromCurrencyPicker.dataSource = self
        fromCurrencyPicker.delegate = self
        toCurrencyPicker.dataSource = self
        toCurrencyPicker.delegate = self
        view.addSubview(fromCurrencyPicker)
        view.addSubview(toCurrencyPicker)
        
        resultLabel.text = "Converted Amount"
        resultLabel.font = .boldSystemFont(ofSize: 20)
        resultLabel.textAlignment = .center
        view.addSubview(resultLabel)
        
        // Activity Indicator
        view.addSubview(activityIndicator)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        fromCurrencyPicker.translatesAutoresizingMaskIntoConstraints = false
        toCurrencyPicker.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            amountTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            amountTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            amountTextField.widthAnchor.constraint(equalToConstant: 200),
            
            fromCurrencyPicker.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 20),
            fromCurrencyPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            fromCurrencyPicker.widthAnchor.constraint(equalToConstant: 150),
            
            toCurrencyPicker.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 20),
            toCurrencyPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            toCurrencyPicker.widthAnchor.constraint(equalToConstant: 150),
            
            resultLabel.topAnchor.constraint(equalTo: fromCurrencyPicker.bottomAnchor, constant: 40),
            resultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 20)
        ])
    }
    
    private func setupBindings() {
        viewModel.onResultUpdated = { [weak self] result in
            DispatchQueue.main.async {
                self?.resultLabel.text = result
            }
        }
        
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
        }
        
        viewModel.onErrorOccurred = { [weak self] errorMessage in
            DispatchQueue.main.async {
                self?.showErrorAlert(message: errorMessage)
            }
        }
    }
    
    // MARK: - Actions
    @objc private func onAmountChanged() {
        if let text = amountTextField.text, let value = Double(text) {
            viewModel.setAmount(value)
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension CurrencyConverterViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        currencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        currencies[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == fromCurrencyPicker {
            viewModel.setFromCurrency(currencies[row])
        } else {
            viewModel.setToCurrency(currencies[row])
        }
    }
}
