//
//  SettingViewController.swift
//  IntervalRunning
//
//  Created by Dmitry Gorbunow on 5/31/23.
//

import UIKit

class SettingViewController: UIViewController {
    
    let typeTraining = ["Обычный бег", "Бег с заданным темпом", "Интервальный бег"]
    
    var delegate: DataTransferProtocol?
    
    private var setPace = 5.0
    var intervalRunningScrollViewPage = 0
    
    let intervalRunningView1 = IntervalRunningView1()
    let intervalRunningView2 = IntervalRunningView2()
    let intervalRunningView3 = IntervalRunningView3()
    let intervalRunningView4 = IntervalRunningView4()
    
    private lazy var intervalRunningScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.isScrollEnabled = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var intervalRunningStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
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
        slider.isHidden = true
        return slider
    }()
    
    lazy var descriptionNormalRunLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Это стандартный режим бега, подходит для тренировок без контроля темпа"
        label.font = UIFont.systemFont(ofSize: 25, weight: .light)
        label.textColor = UIColor(named: "dark")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    lazy var descriptionRunningGivenPaceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Задайте желаемый темп:"
        label.font = UIFont.systemFont(ofSize: 25, weight: .light)
        label.textColor = UIColor(named: "dark")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private lazy var paceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 100, weight: .heavy)
        label.text = "5:00"
        label.textColor = UIColor(named: "dark")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private lazy var littleNextButton: UIButton = {
        let button = UIButton()
        button.setTitle("Далее", for: .normal)
        button.backgroundColor = UIColor(named: "yellow")
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        button.isHidden = true
        button.setShadow()
        return button
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setTitle("Назад", for: .normal)
        button.backgroundColor = UIColor(named: "yellow")
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        button.isHidden = true
        button.setShadow()
        return button
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.backgroundColor = UIColor(named: "yellow")
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.isHidden = true
        button.setShadow()
        return button
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
        paceSlider.value = pace as? Float ?? 0
        paceLabel.text = SettingViewController.convertPace(pace: pace as? Float ?? 0)
        
        let totalDistance  = DataManager.shared.get(key: "TotalDistance")
        let lengthOfTheSegment = DataManager.shared.get(key: "LengthOfTheSegment")
        let tempoForSlowSegments = DataManager.shared.get(key: "TempoForSlowSegments")
        let tempoForFastSegments = DataManager.shared.get(key: "TempoForFastSegments")
        
        intervalRunningView1.distanceSlider.value = totalDistance as? Float ?? 0
        intervalRunningView2.distanceSlider.value = lengthOfTheSegment as? Float ?? 0
        intervalRunningView3.paceSlider.value = tempoForSlowSegments as? Float ?? 0
        intervalRunningView4.paceSlider.value = tempoForFastSegments as? Float ?? 0
        
        intervalRunningView1.distanceLabel.text = String(totalDistance as? Int ?? 0)
        intervalRunningView2.distanceLabel.text = String(lengthOfTheSegment as? Int ?? 0)
        intervalRunningView3.paceLabel.text = SettingViewController.convertPace(pace: tempoForSlowSegments as? Float ?? 0)
        intervalRunningView4.paceLabel.text = SettingViewController.convertPace(pace: tempoForFastSegments as? Float ?? 0)
        
        let row = DataManager.shared.get(key: "selectedRow") as? Int
        
        if row == 0 {
            paceSlider.isHidden = true
            paceLabel.isHidden = true
            intervalRunningScrollView.isHidden = true
            littleNextButton.isHidden = true
            backButton.isHidden = true
            descriptionNormalRunLabel.isHidden = false
            descriptionRunningGivenPaceLabel.isHidden = true
            doneButton.isHidden = false
        } else if row == 1 {
            paceSlider.isHidden = false
            paceLabel.isHidden = false
            intervalRunningScrollView.isHidden = true
            littleNextButton.isHidden = true
            backButton.isHidden = true
            descriptionNormalRunLabel.isHidden = true
            descriptionRunningGivenPaceLabel.isHidden = false
            doneButton.isHidden = false
        } else if row == 2 {
            paceSlider.isHidden = true
            paceLabel.isHidden = true
            intervalRunningScrollView.isHidden = false
            littleNextButton.isHidden = false
            backButton.isHidden = false
            descriptionNormalRunLabel.isHidden = true
            descriptionRunningGivenPaceLabel.isHidden = true
            doneButton.isHidden = true
        }
        
        typeTrainingPicker.selectRow(row ?? 0, inComponent: 0, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let pace = DataManager.shared.get(key: "Pace")
        
        switch typeTrainingPicker.selectedRow(inComponent: 0) {
        case 0:
            delegate?.setTypeOfTraining(typeOfTraining: .normalRunning)
        case 1:
            delegate?.setTypeOfTraining(typeOfTraining: .setPace)
            delegate?.setPace(pace: pace as? Float ?? 0)
        case 2:
            delegate?.setTypeOfTraining(typeOfTraining: .intervalRunning)
            delegate?.setIntervalRunningParameters(parameters: IntervalRunningParameters(
                distance: DataManager.shared.get(key: "TotalDistance") as? Double ?? 0,
                lengthOfTheSegment: DataManager.shared.get(key: "LengthOfTheSegment") as? Double ?? 0,
                slowPace: DataManager.shared.get(key: "TempoForSlowSegments") as? Double ?? 0,
                fastPace: DataManager.shared.get(key: "TempoForFastSegments") as? Double ?? 0
            ))
        default:
            delegate?.setTypeOfTraining(typeOfTraining: .normalRunning)
        }
        
        DataManager.shared.set(key: "selectedRow", value: typeTrainingPicker.selectedRow(inComponent: 0))
    }
    
    private func setupView() {
        view.addSubview(typeTrainingPicker)
        view.addSubview(paceSlider)
        view.addSubview(paceLabel)
        view.addSubview(intervalRunningScrollView)
        intervalRunningScrollView.addSubview(intervalRunningStackView)
        intervalRunningStackView.addArrangedSubview(intervalRunningView1)
        intervalRunningStackView.addArrangedSubview(intervalRunningView2)
        intervalRunningStackView.addArrangedSubview(intervalRunningView3)
        intervalRunningStackView.addArrangedSubview(intervalRunningView4)
        view.addSubview(littleNextButton)
        view.addSubview(backButton)
        view.addSubview(descriptionNormalRunLabel)
        view.addSubview(descriptionRunningGivenPaceLabel)
        view.addSubview(doneButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            typeTrainingPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            typeTrainingPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            typeTrainingPicker.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
            typeTrainingPicker.heightAnchor.constraint(equalToConstant: 200),
            
            descriptionNormalRunLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            descriptionNormalRunLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionNormalRunLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            descriptionRunningGivenPaceLabel.topAnchor.constraint(equalTo: typeTrainingPicker.bottomAnchor, constant: 16),
            descriptionRunningGivenPaceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionRunningGivenPaceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            paceSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            paceSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            paceSlider.topAnchor.constraint(equalTo: paceLabel.bottomAnchor, constant: 32),
            
            paceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            paceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            paceLabel.topAnchor.constraint(equalTo: descriptionRunningGivenPaceLabel.bottomAnchor, constant: 16),
            paceLabel.heightAnchor.constraint(equalToConstant: 100),
            
            intervalRunningScrollView.topAnchor.constraint(equalTo: typeTrainingPicker.bottomAnchor),
            intervalRunningScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            intervalRunningScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            intervalRunningScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            
            intervalRunningStackView.topAnchor.constraint(equalTo: intervalRunningScrollView.topAnchor),
            intervalRunningStackView.bottomAnchor.constraint(equalTo: intervalRunningScrollView.bottomAnchor),
            intervalRunningStackView.leadingAnchor.constraint(equalTo: intervalRunningScrollView.leadingAnchor),
            intervalRunningStackView.trailingAnchor.constraint(equalTo: intervalRunningScrollView.trailingAnchor),
            intervalRunningStackView.heightAnchor.constraint(equalTo: intervalRunningScrollView.heightAnchor),
            
            intervalRunningView1.widthAnchor.constraint(equalTo: intervalRunningScrollView.widthAnchor),
            
            intervalRunningView2.widthAnchor.constraint(equalTo: intervalRunningScrollView.widthAnchor),
            
            intervalRunningView3.widthAnchor.constraint(equalTo: intervalRunningScrollView.widthAnchor),
            
            intervalRunningView4.widthAnchor.constraint(equalTo: intervalRunningScrollView.widthAnchor),
            
            littleNextButton.topAnchor.constraint(equalTo: intervalRunningScrollView.bottomAnchor, constant: 30),
            littleNextButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 16),
            littleNextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            littleNextButton.heightAnchor.constraint(equalToConstant: 50),
            
            backButton.topAnchor.constraint(equalTo: intervalRunningScrollView.bottomAnchor, constant: 30),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            backButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -16),
            backButton.heightAnchor.constraint(equalToConstant: 50),
            
            doneButton.topAnchor.constraint(equalTo: intervalRunningScrollView.bottomAnchor, constant: 30),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            doneButton.heightAnchor.constraint(equalToConstant: 50)
            
        ])
    }
    
    static func convertPace(pace: Float) -> String {
        
        var displayedSeconds = String(format: "%.00f", modf(pace).1 * 60)
        
        if displayedSeconds.count == 1 {
            displayedSeconds = "0" + displayedSeconds
        }
        
        return String(format: "%.0f", modf(pace).0) + ":" + displayedSeconds
    }
    
    func scrollToPage(page: Int, animated: Bool) {
        var frame: CGRect = self.intervalRunningScrollView.frame
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0
        self.intervalRunningScrollView.scrollRectToVisible(frame, animated: animated)
    }
    
    @objc func paceSliderDidSlide(_ sender: UISlider!) {
        let userSetPace = round(10 * sender.value) / 10
        paceLabel.text = SettingViewController.convertPace(pace: userSetPace)
        self.setPace = Double(userSetPace)
        DataManager.shared.set(key: "Pace", value: userSetPace)
    }
    
    @objc func nextButtonTapped() {
        if intervalRunningScrollViewPage < 3 {
            intervalRunningScrollViewPage += 1
            scrollToPage(page: intervalRunningScrollViewPage, animated: true)
        } else {
            dismiss(animated: true)
        }
    }
        
    
    @objc func backButtonTapped() {
        
        if intervalRunningScrollViewPage > 0 {
            intervalRunningScrollViewPage -= 1
            scrollToPage(page: intervalRunningScrollViewPage, animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc func doneButtonTapped() {
        dismiss(animated: true)
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
            paceSlider.isHidden = true
            paceLabel.isHidden = true
            intervalRunningScrollView.isHidden = true
            littleNextButton.isHidden = true
            backButton.isHidden = true
            descriptionNormalRunLabel.isHidden = false
            descriptionRunningGivenPaceLabel.isHidden = true
            doneButton.isHidden = false
        } else if row == 1 {
            paceSlider.isHidden = false
            paceLabel.isHidden = false
            intervalRunningScrollView.isHidden = true
            littleNextButton.isHidden = true
            backButton.isHidden = true
            descriptionNormalRunLabel.isHidden = true
            descriptionRunningGivenPaceLabel.isHidden = false
            doneButton.isHidden = false
        } else if row == 2 {
            paceSlider.isHidden = true
            paceLabel.isHidden = true
            intervalRunningScrollView.isHidden = false
            littleNextButton.isHidden = false
            backButton.isHidden = false
            descriptionNormalRunLabel.isHidden = true
            descriptionRunningGivenPaceLabel.isHidden = true
            doneButton.isHidden = true
        }
    }
}

