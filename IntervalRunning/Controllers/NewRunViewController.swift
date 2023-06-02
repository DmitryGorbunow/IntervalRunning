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
  func pass(data: Float)
}

class NewRunViewController: UIViewController, DataTransferProtocol {

    private var run: Run?
    
    private let locationManager = LocationManager.shared
    private var seconds = 0
    private var timer: Timer?
    private var distance = Measurement(value: 0, unit: UnitLength.meters)
    private var locationList: [CLLocation] = []
    
    var player: AVAudioPlayer!
    
    var setPace: Float = 5.0
    
    private lazy var blurView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "blue")
        view.layer.opacity = 0.3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.showsUserLocation = true
        map.layer.cornerRadius = 25
        map.translatesAutoresizingMaskIntoConstraints = false
        map.tintColor = UIColor(named: "yellow")
        map.layer.opacity = 0.4
        map.setShadow()
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
        label.text = "0.00"
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
    
    private lazy var startButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
//        button.backgroundColor = UIColor(named: "green")
        button.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
//        button.setTitle("Старт!", for: .normal)
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 120, weight: .medium, scale: .small)
               
        let largeRun = UIImage(systemName: "figure.run.circle.fill", withConfiguration: largeConfig)
        button.setImage(largeRun, for: .normal)
        button.tintColor = UIColor(named: "dark")
        button.setShadow()
        return button
    }()
    
    private lazy var stopButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(stopTapped), for: .touchUpInside)
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 120, weight: .medium, scale: .small)
               
        let largeRun = UIImage(systemName: "stop.circle", withConfiguration: largeConfig)
        button.setImage(largeRun, for: .normal)
        button.tintColor = UIColor(named: "dark")
        button.setShadow()
        button.isHidden = true
        
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
        button.setShadow()
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
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        blurView.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        self.setPace = DataManager.shared.get(key: "Pace")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        locationManager.stopUpdatingLocation()
    }
    
    private func setupView() {
        view.addSubview(blurView)
        view.addSubview(mapView)
        view.addSubview(stopButton)
        view.addSubview(startButton)
        view.addSubview(paceLabel)
        view.addSubview(paceMeasurementLabel)
        view.addSubview(timeLabel)
        view.addSubview(distanceLabel)
        view.addSubview(distanceMeasurementLabel)
        view.addSubview(settingButton)
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
            settingButton.widthAnchor.constraint(equalToConstant: 50)
        ])
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
        
        if distance.value > 0 {
            paceLabel.text = String(format: "%.2f", (Double(seconds) / 60) / (distance.value / 1000))
        }
    }
    
    private func startLocationUpdates() {
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10
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
    
    func pass(data: Float) {
        self.setPace = data
    }
    
    @objc func startTapped() {
        startRun()
        startButton.isHidden = true
        stopButton.isHidden = false
        print(setPace)
        settingButton.isEnabled = false
        
        let url = Bundle.main.url(forResource: "Вам необходимо ускориться", withExtension: "mp3")
           
          player = try! AVAudioPlayer(contentsOf: url!)
          player.play()
    }
    
    @objc func stopTapped() {
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
    
    @objc func settingTapped() {
        let vc = SettingViewController()
        vc.delegate = self
        present(vc, animated: true)
        
//        let sheetViewController = SettingViewController()
//        if let sheet = sheetViewController.sheetPresentationController {
//            sheet.detents = [.medium()]
//        }
//        present(sheetViewController, animated: true)
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
    renderer.strokeColor = UIColor(named: "dark")
    renderer.lineWidth = 6
    return renderer
  }
}


