//
//  SettingViewController.swift
//  IntervalRunning
//
//  Created by Dmitry Gorbunow on 5/31/23.
//

import UIKit

class SettingViewController: UIViewController {
    
    let typeTraining = ["Бег с заданным темпом", "Интервальный бег", "Обычный бег"]
    
    var delegate: DataTransferProtocol?
    
    private var setPace = 5.0
    
    private lazy var typeTrainingPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.layer.cornerRadius = 10
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private lazy var paceSlider: UISlider = {
        let slider = UISlider()
        slider.tintColor = UIColor(named: "yellow")
        slider.addTarget(self, action: #selector(paceSliderDidSlide), for: .valueChanged)
        slider.minimumValue = 2
        slider.maximumValue = 10
        slider.minimumValueImage = UIImage(systemName: "hare")
        slider.maximumValueImage = UIImage(systemName: "tortoise")
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private lazy var paceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 100, weight: .heavy)
        label.text = "5.0"
        label.textColor = UIColor(named: "dark")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.layer.opacity = 0.95
        
        setupView()
        setupConstraints()
        
        typeTrainingPicker.delegate = self
        typeTrainingPicker.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let pace = DataManager.shared.get(key: "Pace")
        paceSlider.value = pace
        paceLabel.text = String(pace)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let pace = DataManager.shared.get(key: "Pace")
        delegate?.pass(data: pace)
        
        print(pace)
    }
    
    private func setupView() {
        view.addSubview(typeTrainingPicker)
        view.addSubview(paceSlider)
        view.addSubview(paceLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            typeTrainingPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            typeTrainingPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            typeTrainingPicker.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            typeTrainingPicker.heightAnchor.constraint(equalToConstant: 200),
            
            paceSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            paceSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            paceSlider.topAnchor.constraint(equalTo: paceLabel.bottomAnchor, constant: 32),
            
            paceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            paceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            paceLabel.topAnchor.constraint(equalTo: typeTrainingPicker.bottomAnchor, constant: 16),
            paceLabel.heightAnchor.constraint(equalToConstant: 100)
            
        ])
    }
    
    @objc func paceSliderDidSlide(_ sender: UISlider!) {
        let userSetPace = round(10 * sender.value) / 10
        paceLabel.text = String(userSetPace)
        self.setPace = Double(userSetPace)
        DataManager.shared.set(key: "Pace", value: userSetPace)
    }
}

extension SettingViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        typeTraining.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return typeTraining[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            paceSlider.isHidden = false
            paceLabel.isHidden = false
        } else if row == 1 {
            paceSlider.isHidden = true
            paceLabel.isHidden = true
        } else if row == 2 {
            paceSlider.isHidden = true
            paceLabel.isHidden = true
        }
    }
    
    
}
