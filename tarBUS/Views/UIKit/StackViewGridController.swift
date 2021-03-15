//
//  StackViewGridController.swift
//  tarBUS
//
//  Created by Kuba Florek on 12/03/2021.
//

import UIKit

class StackViewGridController: UIViewController {
    var busStop: BusStop?

    let mySpacing: CGFloat = 5.0
    
    var departures: [NextDeparture] {
        getDepartures()
    }
    
    var rows: Int {
        let length = Double(departures.count)
        
        let divided = length / 3
        
        let number = Int(divided.rounded(.up))
        
        return number
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        stackedGrid(rows: rows, columns: 3, departures: departures, rootView: view)
    }

    func stackedGrid(rows: Int, columns: Int, departures: [NextDeparture], rootView: UIView){
        // Init StackView
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = mySpacing

        for row in 0 ..< rows {
            let horizontalSv = UIStackView()
            horizontalSv.axis = .horizontal
            horizontalSv.alignment = .center
            stackView.distribution = .equalSpacing
            horizontalSv.spacing = mySpacing

            for col in 0 ..< columns {
                if row * columns + col < departures.count {
                    let firstSpacer = UILabel()
                    firstSpacer.text = " "
                    
                    let secondSpacer = UILabel()
                    secondSpacer.text = " "
                    
                    let image = UIImageView(image: UIImage(systemName: "bus.fill"))
                    image.tintColor = .white
                    
                    let button = UIButton()
                    button.setTitle("\(departures[row * columns + col].busLine.name)", for: .normal)
                    horizontalSv.addArrangedSubview(button)
                    
                    let iconAndText = UIStackView()
                    iconAndText.axis = .horizontal
                    iconAndText.alignment = .center
                    iconAndText.distribution = .equalSpacing
                    iconAndText.spacing = mySpacing
                    iconAndText.backgroundColor = UIColor(named: "MainColor")
                    iconAndText.layer.cornerRadius = 6
                    iconAndText.addArrangedSubview(firstSpacer)
                    iconAndText.addArrangedSubview(image)
                    iconAndText.addArrangedSubview(button)
                    iconAndText.addArrangedSubview(secondSpacer)
                    
                    let hour = UILabel()
                    hour.text = "\(departures[row * columns + col].timeString)\(departures[row * columns + col].isTomorrow ? "*" : "")"
                    
                    let textAndLabel = UIStackView()
                    textAndLabel.axis = .vertical
                    textAndLabel.alignment = .center
                    textAndLabel.distribution = .equalSpacing
                    textAndLabel.spacing = mySpacing
                    textAndLabel.addArrangedSubview(iconAndText)
                    textAndLabel.addArrangedSubview(hour)
                    
                    
                    horizontalSv.addArrangedSubview(textAndLabel)
                }
            }
            stackView.addArrangedSubview(horizontalSv)
        }

        rootView.addSubview(stackView)

        // add constraints
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: rootView.topAnchor, constant: mySpacing).isActive = true
        stackView.leftAnchor.constraint(equalTo: rootView.leftAnchor, constant: mySpacing).isActive = true
        stackView.rightAnchor.constraint(equalTo: rootView.rightAnchor, constant: -mySpacing).isActive = true
        stackView.bottomAnchor.constraint(equalTo: rootView.bottomAnchor, constant: -mySpacing).isActive = true
    }
    
    func getDepartures() -> [NextDeparture] {
        guard let busStop = busStop else { return [] }
        let databaseHelper = DataBaseHelper()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        
        let date = Date()
        
        let departuresToday = databaseHelper.getNextDepartures(busStopId: busStop.id, dayTypes: databaseHelper.getCurrentDayType(currentDateString: formatter.string(from: date)), startFromTime: Date().minutesSinceMidnight)

        let departuresForNextDay = databaseHelper.getNextDepartures(busStopId: busStop.id, dayTypes: databaseHelper.getCurrentDayType(currentDateString: formatter.string(from: date.addingTimeInterval(86400))), startFromTime: 0)
        
        let tomorrowDepartures = departuresForNextDay.map { departure in
            departure.forTomorrow
        }
        return Array((departuresToday + tomorrowDepartures).prefix(6))
    }
}

