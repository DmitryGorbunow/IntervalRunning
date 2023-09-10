//
//  ViewController.swift
//  IntervalRunning
//
//  Created by Dmitry Gorbunow on 5/22/23.
//

import UIKit
import MapKit

class RunDetailsViewController: UIViewController {
    
    var run: Run!
    
    private lazy var distanceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor(named: "dark")
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = UIColor(named: "dark")
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        return label
    }()
    
    private lazy var paceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = UIColor(named: "dark")
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = UIColor(named: "dark")
        label.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        return label
    }()
    
    private lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.showsUserLocation = false
        map.tintColor = UIColor(named: "yellow")
        map.mapType = .mutedStandard
        map.pointOfInterestFilter = .excludingAll
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.backgroundColor = UIColor(named: "yellow")
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.setShadow()
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupConstraints()
        configureView()
        mapView.delegate = self
    }
    
    private func configureView() {
        
        
        let distance = Measurement(value: run.distance, unit: UnitLength.meters)
        let seconds = Int(run.duration)
//        let formattedDistance = FormatDisplay.distance(distance)
//        let formattedDate = FormatDisplay.date(run.timestamp)
        
        let date = run.timestamp
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        let dateString = dateFormatter.string(from: date!)
        
        let formattedTime = FormatDisplay.time(seconds)
        let formattedPace = FormatDisplay.pace(distance: distance,
                                               seconds: seconds,
                                               outputUnit: UnitSpeed.minutesPerKilometer)
        
        distanceLabel.text = "Дистанция:  \(String(format: "%.2f", run.distance / 1000)) км"
        dateLabel.text = dateString
        timeLabel.text = "Время:  \(formattedTime)"
        paceLabel.text = "Темп:  \(formattedPace) мин/км"
        
        loadMap()
    }
    
    private func setupViews() {
        view.addSubview(mapView)
        view.addSubview(distanceLabel)
        view.addSubview(timeLabel)
        view.addSubview(paceLabel)
        view.addSubview(dateLabel)
        view.addSubview(doneButton)
        
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            dateLabel.heightAnchor.constraint(equalToConstant: 40),
            
            distanceLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20 ),
            distanceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            distanceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            distanceLabel.heightAnchor.constraint(equalToConstant: 20),
            
            timeLabel.topAnchor.constraint(equalTo: distanceLabel.bottomAnchor, constant: 20),
            timeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            timeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            timeLabel.heightAnchor.constraint(equalToConstant: 20),
            
            paceLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 20),
            paceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            paceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            paceLabel.heightAnchor.constraint(equalToConstant: 20),
            
            doneButton.topAnchor.constraint(equalTo: paceLabel.bottomAnchor, constant: 40),
            doneButton.widthAnchor.constraint(equalToConstant: 200),
            doneButton.heightAnchor.constraint(equalToConstant: 50),
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            mapView.topAnchor.constraint(equalTo: doneButton.bottomAnchor, constant: 40),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    private func mapRegion() -> MKCoordinateRegion? {
        guard
            let locations = run.locations,
            locations.count > 0
        else {
            return nil
        }
        
        let latitudes = locations.map { location -> Double in
            let location = location as! Location
            return location.latitude
        }
        
        let longitudes = locations.map { location -> Double in
            let location = location as! Location
            return location.longitude
        }
        
        let maxLat = latitudes.max()!
        let minLat = latitudes.min()!
        let maxLong = longitudes.max()!
        let minLong = longitudes.min()!
        
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2,
                                            longitude: (minLong + maxLong) / 2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.3,
                                    longitudeDelta: (maxLong - minLong) * 1.3)
        
        let startPin = MKPointAnnotation()
        startPin.title = "Старт"
        startPin.coordinate = CLLocationCoordinate2D(
            latitude: latitudes.first! ,
            longitude: longitudes.first!
        )
        mapView.addAnnotation(startPin)
        
        let endPin = MKPointAnnotation()
        endPin.title = "Финиш"
        
        endPin.coordinate = CLLocationCoordinate2D(
            latitude: latitudes.last!,
            longitude: longitudes.last!
        )
        mapView.addAnnotation(endPin)
        
        
        return MKCoordinateRegion(center: center, span: span)
    }
    
    private func polyLine() -> [MulticolorPolyline] {
        
        // 1
        let locations = run.locations?.array as! [Location]
        var coordinates: [(CLLocation, CLLocation)] = []
        var speeds: [Double] = []
        var minSpeed = Double.greatestFiniteMagnitude
        var maxSpeed = 0.0
        
        // 2
        for (first, second) in zip(locations, locations.dropFirst()) {
            let start = CLLocation(latitude: first.latitude, longitude: first.longitude)
            let end = CLLocation(latitude: second.latitude, longitude: second.longitude)
            coordinates.append((start, end))
            
            //3
            let distance = end.distance(from: start)
            let time = second.timestamp!.timeIntervalSince(first.timestamp! as Date)
            let speed = time > 0 ? distance / time : 0
            speeds.append(speed)
            minSpeed = min(minSpeed, speed)
            maxSpeed = max(maxSpeed, speed)
        }
        
        //4
        let midSpeed = speeds.reduce(0, +) / Double(speeds.count)
        
        //5
        var segments: [MulticolorPolyline] = []
        for ((start, end), speed) in zip(coordinates, speeds) {
            let coords = [start.coordinate, end.coordinate]
            let segment = MulticolorPolyline(coordinates: coords, count: 2)
            segment.color = segmentColor(speed: speed,
                                         midSpeed: midSpeed,
                                         slowestSpeed: minSpeed,
                                         fastestSpeed: maxSpeed)
            segments.append(segment)
        }
        return segments
    }
    
    private func loadMap() {
        guard
            let locations = run.locations,
            locations.count > 0,
            let region = mapRegion()
        else {
            let alert = UIAlertController(title: "Error",
                                          message: "Sorry, this run has no locations saved",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: true)
            return
        }
        
        mapView.setRegion(region, animated: true)
        mapView.addOverlays(polyLine())
    }
    
    private func segmentColor(speed: Double, midSpeed: Double, slowestSpeed: Double, fastestSpeed: Double) -> UIColor {
        enum BaseColors {
            static let r_red: CGFloat = 1
            static let r_green: CGFloat = 20 / 255
            static let r_blue: CGFloat = 44 / 255
            
            static let y_red: CGFloat = 1
            static let y_green: CGFloat = 215 / 255
            static let y_blue: CGFloat = 0
            
            static let g_red: CGFloat = 0
            static let g_green: CGFloat = 146 / 255
            static let g_blue: CGFloat = 78 / 255
        }
        
        let red, green, blue: CGFloat
        
        if speed < midSpeed {
            let ratio = CGFloat((speed - slowestSpeed) / (midSpeed - slowestSpeed))
            red = BaseColors.r_red + ratio * (BaseColors.y_red - BaseColors.r_red)
            green = BaseColors.r_green + ratio * (BaseColors.y_green - BaseColors.r_green)
            blue = BaseColors.r_blue + ratio * (BaseColors.y_blue - BaseColors.r_blue)
        } else {
            let ratio = CGFloat((speed - midSpeed) / (fastestSpeed - midSpeed))
            red = BaseColors.y_red + ratio * (BaseColors.g_red - BaseColors.y_red)
            green = BaseColors.y_green + ratio * (BaseColors.g_green - BaseColors.y_green)
            blue = BaseColors.y_blue + ratio * (BaseColors.g_blue - BaseColors.y_blue)
        }
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
    @objc func doneButtonTapped() {
        dismiss(animated: true)
    }
}

extension RunDetailsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MulticolorPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = polyline.color
        renderer.lineWidth = 5
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "custom")
        
        switch annotation.title {
        case "Старт":
            annotationView.markerTintColor = UIColor(named: "yellow")
        case "Финиш":
            annotationView.markerTintColor = UIColor(named: "green")
        default:
            break
        }
        return annotationView
    }
}

