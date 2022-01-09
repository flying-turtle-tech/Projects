//
//  Geofencer.swift
//  Geofencer
//
//  Created by Jonathan Kovach on 1/8/22.
//

import Foundation
import CoreLocation

protocol GeofencerProtocol: NSObject {
    func addRegion(region: CLRegion)
    func removeRegion(region: CLRegion)
    var manager: CLLocationManager { get set }
    
}

enum GeofencerError: Error {
    case monitoringNotAvailable
}

class Geofencer: NSObject {
    lazy var manager = CLLocationManager()
    weak var networkManager: NetworkManager?
    
    func start() throws {
        if !CLLocationManager.isMonitoringAvailable(for: CLRegion.self) {
            throw GeofencerError.monitoringNotAvailable
        }
        manager.delegate = self
        if manager.authorizationStatus != CLAuthorizationStatus.authorizedAlways {
            manager.requestAlwaysAuthorization()
        }
    }
    
    func addRegion(region: CLRegion) {
        manager.startMonitoring(for: region)
    }
    
    func removeRegion(region: CLRegion) {
        manager.stopMonitoring(for: region)
    }
}

extension Geofencer: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        networkManager?.makeRequest()
        print("Entered region! \(region)")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        networkManager?.makeRequest()
        print("Exited region! \(region)")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Failed to monitor region with error \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("Great, region monitoring started for \(region)")
    }
}
