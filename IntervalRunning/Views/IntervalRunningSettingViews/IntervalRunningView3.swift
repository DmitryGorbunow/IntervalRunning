//
//  IntervalRunningView3.swift
//  IntervalRunning
//
//  Created by Dmitry Gorbunow on 8/3/23.
//

import UIKit

class IntervalRunningView3: UIView {
    
    private lazy var distanceQuestionLabel: UILabel = {
        let label = UILabel()
        label.text = "Задайте темп для медленных отрезков"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 25, weight: .light)
        label.textColor = UIColor(named: "dark")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var paceSlider: UISlider = {
        let slider = UISlider()
        slider.tintColor = UIColor(named: "yellow")
        slider.addTarget(self, action: #selector(paceSliderDidSlide), for: .valueChanged)
        slider.minimumValue = 2
        slider.maximumValue = 13
        slider.value = 8
        slider.minimumValueImage = UIImage(systemName: "hare")
        slider.maximumValueImage = UIImage(systemName: "tortoise")
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    lazy var paceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 100, weight: .heavy)
        label.textColor = UIColor(named: "dark")
        label.text = "8:00"
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
        addSubview(paceLabel)
        addSubview(paceSlider)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            distanceQuestionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            distanceQuestionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            distanceQuestionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            paceLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            paceLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            paceLabel.topAnchor.constraint(equalTo: distanceQuestionLabel.bottomAnchor, constant: 16),
            paceLabel.heightAnchor.constraint(equalToConstant: 100),
            
            paceSlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            paceSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            paceSlider.topAnchor.constraint(equalTo: paceLabel.bottomAnchor, constant: 32),
            
        ])
    }
    
    @objc func paceSliderDidSlide(_ sender: UISlider!) {
        let userSetPace = round(10 * sender.value) / 10
        paceLabel.text = SettingViewController.convertPace(pace: userSetPace)
        DataManager.shared.set(key: "TempoForSlowSegments", value: userSetPace)
    }
}

