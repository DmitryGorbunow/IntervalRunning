//
//  ResultsTableViewCell.swift
//  Interval Running
//
//  Created by Dmitry Gorbunow on 9/7/23.
//

import UIKit

class ResultsTableViewCell: UITableViewCell {
    static let identifier = "ResultsTableViewCell"
    
    private let dataLabel: UILabel = {
        let label = UILabel()
//        label.textAlignment = .center
        label.text = "08.09.2023"
        label.textColor = UIColor(named: "dark")
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.text = "5.93 км"
        label.textColor = UIColor(named: "dark")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.text = "18:32:12"
        label.textColor = UIColor(named: "dark")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let paceLabel: UILabel = {
        let label = UILabel()
        label.text = "5:23 мин/км"
        label.textColor = UIColor(named: "dark")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let resultsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(dataLabel)
        contentView.addSubview(resultsStackView)
        resultsStackView.addArrangedSubview(distanceLabel)
        resultsStackView.addArrangedSubview(durationLabel)
        resultsStackView.addArrangedSubview(paceLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            dataLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            dataLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            dataLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            
            resultsStackView.topAnchor.constraint(equalTo: dataLabel.bottomAnchor, constant: 5),
            resultsStackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            resultsStackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            resultsStackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
            
            
            
        ])
    }
    
    func configure(run: Run) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        let distance = Measurement(value: run.distance, unit: UnitLength.meters)
        
        let formattedPace = FormatDisplay.pace(distance: distance,
                                               seconds: Int(run.duration),
                                               outputUnit: UnitSpeed.minutesPerKilometer)
        
        dataLabel.text = dateFormatter.string(from: run.timestamp!)
        distanceLabel.text = String(format: "%.2f", run.distance / 1000) + " км"
        durationLabel.text = FormatDisplay.time(Int(run.duration))
        paceLabel.text = "\(formattedPace) мин/км"
    }
}
