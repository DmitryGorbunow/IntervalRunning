//
//  NewRunViewController.swift
//  IntervalRunning
//
//  Created by Dmitry Gorbunow on 5/24/23.
//

import UIKit
import CoreLocation
import MapKit
import AVFoundation

protocol DataTransferProtocol {
    func setTypeOfTraining(typeOfTraining: TypeOfTraining)
    func setPace(pace: Float)
    func setIntervalRunningParameters(parameters: IntervalRunningParameters)
}

class NewRunViewController: UIViewController, DataTransferProtocol {

    private var typeOfTraining = TypeOfTraining.normalRunning
    private var intervalRunningParameters: IntervalRunningParameters? = nil
    private var currentPace = 0.0
    private var run: Run?
    private let locationManager = LocationManager.shared
    private var seconds = 0
    private var timer: Timer?
    private var tempoControlTimer: Timer?
    private var distance = Measurement(value: 0, unit: UnitLength.meters)
    private var locationList: [CLLocation] = []
    private var player: AVAudioPlayer!
    private var setPace: Float = 0.0
    private var intervalRunningSegmentsArray = [Segment]()
    
    private lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.showsUserLocation = true
        map.layer.cornerRadius = 25
        map.translatesAutoresizingMaskIntoConstraints = false
        map.tintColor = UIColor(named: "yellow")
        map.mapType = .mutedStandard
        map.pointOfInterestFilter = .excludingAll
        return map
    }()
    
    private lazy var distanceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "0.00"
        label.textColor = UIColor(named: "dark")
        label.font = UIFont.systemFont(ofSize: 60, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var distanceMeasurementLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "км"
        label.textColor = UIColor(named: "dark")
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "00:00:00"
        label.font = UIFont.systemFont(ofSize: 40, weight: .medium)
        label.textColor = UIColor(named: "dark")
        return label
    }()
    
    private lazy var paceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 100, weight: .heavy)
        label.text = "0:00"
        label.textColor = UIColor(named: "dark")
        return label
    }()
    
    private lazy var currentPaceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        label.text = "0:00"
        label.textColor = UIColor(named: "dark")
        return label
    }()
    
    private lazy var paceMeasurementLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        label.text = "мин/км"
        label.textColor = UIColor(named: "dark")
        return label
    }()
    
    private lazy var typeOfTrainingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textColor = UIColor(named: "dark")
        return label
    }()
    
    private lazy var horizontalAccuracyImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "noSignal")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var speakerImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "speaker.slash.fill")
        imageView.tintColor = UIColor(named: "blue")
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private lazy var startButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 120, weight: .medium, scale: .small)
        let largeRun = UIImage(systemName: "figure.run.circle.fill", withConfiguration: largeConfig)
        button.setImage(largeRun, for: .normal)
        button.tintColor = UIColor(named: "dark")
        return button
    }()
    
    private lazy var stopButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 120, weight: .medium, scale: .small)
        let largeRun = UIImage(systemName: "stop.circle", withConfiguration: largeConfig)
        button.setImage(largeRun, for: .normal)
        button.tintColor = UIColor(named: "dark")
        button.isMultipleTouchEnabled = false
        button.isHidden = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(stopButtonTapped))
        button.addGestureRecognizer(tapGestureRecognizer)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(stopButtonLongPressed))
        longPressRecognizer.minimumPressDuration = 1
        button.addGestureRecognizer(longPressRecognizer)
        return button
    }()
    
    private lazy var settingButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor(named: "dark")
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .medium, scale: .small)
        let largeSettings = UIImage(systemName: "gear", withConfiguration: largeConfig)
        button.setImage(largeSettings, for: .normal)
        button.addTarget(self, action: #selector(settingTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupView()
        setupConstraints()
        mapView.delegate = self
        
        if let location = locationManager.location {
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            mapView.setRegion(region, animated: true)
        } else {
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.334826, longitude: -122.009056), latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
        
        if (locationManager.location?.horizontalAccuracy ?? 0 <= 0)
        {
            // No Signal
            horizontalAccuracyImage.image = UIImage(named: "noSignal")
        }
        else if (locationManager.location?.horizontalAccuracy ?? 0 > 163)
        {
            // Poor Signal
            horizontalAccuracyImage.image = UIImage(named: "lowSignal")
        }
        else if (locationManager.location?.horizontalAccuracy ?? 0 > 48)
        {
            // Average Signal
            horizontalAccuracyImage.image = UIImage(named: "averageSignal")
        }
        else
        {
            // Full Signal
            horizontalAccuracyImage.image = UIImage(named: "maximumSignal")
        }
        
        print(locationManager.location?.horizontalAccuracy ?? 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        self.setPace = DataManager.shared.get(key: "Pace") as? Float ?? 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        locationManager.stopUpdatingLocation()
    }
    
    private func setupView() {
        view.addSubview(mapView)
        view.addSubview(stopButton)
        view.addSubview(startButton)
        view.addSubview(paceLabel)
        view.addSubview(paceMeasurementLabel)
        view.addSubview(timeLabel)
        view.addSubview(distanceLabel)
        view.addSubview(distanceMeasurementLabel)
        view.addSubview(settingButton)
        view.addSubview(currentPaceLabel)
        view.addSubview(horizontalAccuracyImage)
        view.addSubview(speakerImage)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            timeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 64),
            timeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -64),
            timeLabel.heightAnchor.constraint(equalToConstant: 40),
            
            distanceLabel.bottomAnchor.constraint(equalTo: distanceMeasurementLabel.topAnchor, constant: -8),
            distanceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 64),
            distanceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -64),
            distanceLabel.heightAnchor.constraint(equalToConstant: 60),
            
            distanceMeasurementLabel.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -16),
            distanceMeasurementLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 64),
            distanceMeasurementLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -64),
            distanceMeasurementLabel.heightAnchor.constraint(equalToConstant: 20),
            
            paceLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 32),
            paceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            paceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            paceLabel.heightAnchor.constraint(equalToConstant: 100),
            
            paceMeasurementLabel.topAnchor.constraint(equalTo: paceLabel.bottomAnchor, constant: 4),
            paceMeasurementLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 64),
            paceMeasurementLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -64),
            paceMeasurementLabel.heightAnchor.constraint(equalToConstant: 30),
            
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            startButton.heightAnchor.constraint(equalToConstant: 120),
            startButton.widthAnchor.constraint(equalToConstant: 120),
            
            stopButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stopButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            stopButton.heightAnchor.constraint(equalToConstant: 120),
            stopButton.widthAnchor.constraint(equalToConstant: 120),
            
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            settingButton.centerYAnchor.constraint(equalTo: startButton.centerYAnchor),
            settingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: (view.frame.width / 4) + 15),
            settingButton.heightAnchor.constraint(equalToConstant: 50),
            settingButton.widthAnchor.constraint(equalToConstant: 50),
            
            currentPaceLabel.centerYAnchor.constraint(equalTo: startButton.centerYAnchor),
            currentPaceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -((view.frame.width / 4) + 15)),
            currentPaceLabel.heightAnchor.constraint(equalToConstant: 30),
            currentPaceLabel.widthAnchor.constraint(equalToConstant: 150),
            
//            horizontalAccuracyImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
//            horizontalAccuracyImage.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -15),
            horizontalAccuracyImage.centerXAnchor.constraint(equalTo: view.leadingAnchor, constant: view.frame.width / 8),
            horizontalAccuracyImage.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor),
            horizontalAccuracyImage.heightAnchor.constraint(equalToConstant: 20),
            
            speakerImage.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor),
            speakerImage.heightAnchor.constraint(equalToConstant: 30),
            speakerImage.widthAnchor.constraint(equalToConstant: 30),
            speakerImage.centerXAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.frame.width / 8),
            
        ])
    }
    
    func setTypeOfTraining(typeOfTraining: TypeOfTraining) {
        self.typeOfTraining = typeOfTraining
    }
    
    func setPace(pace: Float) {
        self.setPace = pace
    }
    
    func setIntervalRunningParameters(parameters: IntervalRunningParameters) {
        self.intervalRunningParameters = parameters
    }
    
    private func preparingForStart() {
        
        switch typeOfTraining {
        case .normalRunning:
            startRun()
        case .setPace:
            startRun()
            tempoControlTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
                self.tempoControl()
            }
        case .intervalRunning:
            startIntervalRunning()
        }
    }
    
    private func startIntervalRunning() {
        
//        let distanceIntRun = (intervalRunningParameters?.distance ?? 0) * 1000
        let lengthOfTheSegment = intervalRunningParameters?.lengthOfTheSegment ?? 0
//        let slowPace = intervalRunningParameters?.slowPace ?? 0
//        let fastPace = intervalRunningParameters?.fastPace ?? 0
        
        var flag = true
        var sumOfSegments = lengthOfTheSegment
        var segmentDistance = 0
        
        var segmentTime = 0
        seconds = 0
        distance = Measurement(value: 0, unit: UnitLength.meters)
        locationList.removeAll()
        updateDisplay()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.eachSecond()
            
            let currentDistance = (self.distance.value - Double(segmentDistance))
//            print(currentDistance)
            
            let currentTime = self.seconds - segmentTime
            
            let speedMagnitude = currentTime != 0 ? currentDistance / Double(currentTime) : 0
            let speed = Measurement(value: speedMagnitude, unit: UnitSpeed.metersPerSecond)
            let pace = speed.converted(to: .minutesPerKilometer).value
            
            print(pace)
            
//            print(currentTime)
            
//            let currentTemp = ((currentDistance) / Double(currentTime))
            
//            print(currentTemp)
            
            if self.distance.value > sumOfSegments {
                sumOfSegments += lengthOfTheSegment
                segmentDistance += Int(lengthOfTheSegment)
                segmentTime += self.seconds - segmentTime
                
                if flag {
                    print("Медленный отрезок")
                } else {
                    print("Быстрый отрезок")
                }
                flag.toggle()
            }
        }
        startLocationUpdates()
        mapView.removeOverlays(mapView.overlays)
        print("Быстрый отрезок")
    }
        
    private func startRun() {
        seconds = 0
        distance = Measurement(value: 0, unit: UnitLength.meters)
        locationList.removeAll()
        updateDisplay()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.eachSecond()
        }
        startLocationUpdates()
        mapView.removeOverlays(mapView.overlays)
    }
    
    private func stopRun() {
        locationManager.stopUpdatingLocation()
    }
    
    func eachSecond() {
        seconds += 1
        updateDisplay()
    }
    
    private func updateDisplay() {
        let formattedTime = FormatDisplay.time(seconds)
        distanceLabel.text = String(format: "%.2f", distance.value / 1000)
        timeLabel.text = "\(formattedTime)"
        paceLabel.text = FormatDisplay.pace(distance: distance, seconds: seconds, outputUnit: .minutesPerKilometer)
        currentPaceLabel.text = getCurrentPace()
//        horizontalAccuracyImage.text = String(locationManager.location?.horizontalAccuracy ?? 0)
//        speakerImage.text = String((locationManager.location?.speed ?? 0) * 3.6)
        
        if (locationManager.location?.horizontalAccuracy ?? 0 <= 0)
        {
            // No Signal
            horizontalAccuracyImage.image = UIImage(named: "noSignal")
        }
        else if (locationManager.location?.horizontalAccuracy ?? 0 > 163)
        {
            // Poor Signal
            horizontalAccuracyImage.image = UIImage(named: "lowSignal")
        }
        else if (locationManager.location?.horizontalAccuracy ?? 0 > 48)
        {
            // Average Signal
            horizontalAccuracyImage.image = UIImage(named: "averageSignal")
        }
        else
        {
            // Full Signal
            horizontalAccuracyImage.image = UIImage(named: "maximumSignal")
        }
        
        print(locationManager.location?.horizontalAccuracy ?? 0)
    }
    
    private func getCurrentPace() -> String {
        
        guard locationManager.location?.speed ?? 0 > 0 else { return "0:00" }
        
        currentPace = 60 / ((locationManager.location?.speed ?? 0) * 3.6)
        
        var displayedSeconds = String(format: "%.00f", modf(currentPace).1 * 60)
        
        if displayedSeconds.count == 1 {
            displayedSeconds = "0" + displayedSeconds
        }
        return String(format: "%.0f", modf(currentPace).0) + ":" + displayedSeconds
        
    }
    
    private func tempoControl() {
        
        let pace = 60 / ((distance.value / Double(seconds)) * 3.6)
        print(pace)
        guard pace > 0 else { return }
        
        if pace > Double(setPace) + 0.2 {
            let url = Bundle.main.url(forResource: "Вам необходимо ускориться", withExtension: "mp3")
            
            print("Вам необходимо ускориться")
            
            player = try! AVAudioPlayer(contentsOf: url!)
            player.play()
        } else if pace < Double(setPace) - 0.2   {
            let url = Bundle.main.url(forResource: "Вам необходимо замедлиться", withExtension: "mp3")
            
            print("Вам необходимо замедлиться")
            
            player = try! AVAudioPlayer(contentsOf: url!)
            player.play()
        }
    }
    
    
    private func startLocationUpdates() {
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 1
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
    }
    
    private func saveRun() {
        let newRun = Run(context: CoreDataStack.context)
        newRun.distance = distance.value
        newRun.duration = Int16(seconds)
        newRun.timestamp = Date()
        
        for location in locationList {
            let locationObject = Location(context: CoreDataStack.context)
            locationObject.timestamp = location.timestamp
            locationObject.latitude = location.coordinate.latitude
            locationObject.longitude = location.coordinate.longitude
            newRun.addToLocations(locationObject)
        }
        
        CoreDataStack.saveContext()
        
        run = newRun
    }
    
    
    private func convertPace(pace: Float) -> String {
        
        var displayedSeconds = String(format: "%.00f", modf(pace).1 * 60)
        
        if displayedSeconds.count == 1 {
            displayedSeconds = "0" + displayedSeconds
        }
        
        return String(format: "%.0f", modf(pace).0) + ":" + displayedSeconds
    }
    
    @objc func startTapped() {
        preparingForStart()
        startButton.isHidden = true
        stopButton.isHidden = false
        settingButton.isEnabled = false
    }
    
    @objc func stopTapped(sender: UILongPressGestureRecognizer) {
        self.stopRun()
        self.saveRun()
        startButton.isHidden = false
        stopButton.isHidden = true
        settingButton.isEnabled = true
        
        let vc = RunDetailsViewController()
        vc.run = run
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func settingTapped() {
        let vc = SettingViewController()
        vc.delegate = self
        present(vc, animated: true)
    }
    
    @objc func stopButtonTapped(sender: UITapGestureRecognizer){
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            
            // HERE
            self.stopButton.transform = CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1) // Scale your image
            
        }) { (finished) in
            UIView.animate(withDuration: 0.2, animations: {
                
                self.stopButton.transform = CGAffineTransform.identity // undo in 1 seconds
                
            })
        }
    }
    
    @objc func stopButtonLongPressed(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            self.stopRun()
            self.saveRun()
            startButton.isHidden = false
            stopButton.isHidden = true
            settingButton.isEnabled = true
            
            let vc = RunDetailsViewController()
            vc.run = run
            navigationController?.pushViewController(vc, animated: true)
            
            let url = Bundle.main.url(forResource: "Вам необходимо замедлиться", withExtension: "mp3")
            
            player = try! AVAudioPlayer(contentsOf: url!)
            player.play()
        }
    }
}

extension NewRunViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
            
            if let lastLocation = locationList.last {
                let delta = newLocation.distance(from: lastLocation)
                distance = distance + Measurement(value: delta, unit: UnitLength.meters)
                
                let coordinates = [lastLocation.coordinate, newLocation.coordinate]
                mapView.addOverlay(MKPolyline(coordinates: coordinates, count: 2))
                let region = MKCoordinateRegion(center: newLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                mapView.setRegion(region, animated: true)
                
            }
            
            locationList.append(newLocation)
        }
    }
}

extension NewRunViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = UIColor(named: "green")
        renderer.lineWidth = 6
        return renderer
    }
}


