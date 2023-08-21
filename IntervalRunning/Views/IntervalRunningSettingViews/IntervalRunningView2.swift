//
//  IntervalRunningView2.swift
//  IntervalRunning
//
//  Created by Dmitry Gorbunow on 8/3/23.
//

import UIKit

class IntervalRunningView2: UIView {
    
    private lazy var distanceQuestionLabel: UILabel = {
        let label = UILabel()
        label.text = "Задайте длину в метрах для каждого из отрезков:"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 25, weight: .light)
        label.textColor = UIColor(named: "dark")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var distanceSlider: UISlider = {
        let slider = UISlider()
        slider.tintColor = UIColor(named: "yellow")
        slider.addTarget(self, action: #selector(paceSliderDidSlide), for: .valueChanged)
        slider.minimumValue = 0
        slider.maximumValue = 1000
        slider.value = 500
        slider.minimumValueImage = UIImage(systemName: "figure.walk")
        slider.maximumValueImage = UIImage(systemName: "flag.checkered")
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    lazy var distanceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 100, weight: .heavy)
        label.textColor = UIColor(named: "dark")
        label.text = "500"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        backgroundColor = .red
        translatesAutoresizingMaskIntoConstraints = false
        
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(distanceQuestionLabel)
        addSubview(distanceLabel)
        addSubview(distanceSlider)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            distanceQuestionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            distanceQuestionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            distanceQuestionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            distanceLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            distanceLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            distanceLabel.topAnchor.constraint(equalTo: distanceQuestionLabel.bottomAnchor, constant: 16),
            distanceLabel.heightAnchor.constraint(equalToConstant: 100),
            
            distanceSlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            distanceSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            distanceSlider.topAnchor.constraint(equalTo: distanceLabel.bottomAnchor, constant: 32),
            
        ])
    }
    
    @objc func paceSliderDidSlide(_ sender: UISlider!) {
        
        let step: Float = 50
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
        
        let userSetPace = Int(sender.value)
        distanceLabel.text = String(userSetPace)
        DataManager.shared.set(key: "LengthOfTheSegment", value: userSetPace)
    }
}

