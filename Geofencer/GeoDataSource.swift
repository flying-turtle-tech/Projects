//
//  GeoDataSource.swift
//  Geofencer
//
//  Created by Jonathan Kovach on 1/9/22.
//

import Foundation
import CoreLocation

class GeoDataSource {
    static func circleRegionFrom(address: String, completion: @escaping (CLCircularRegion?) -> Void) {
         CLGeocoder().geocodeAddressString(address) { (placemarks, error) in
            if let err = error {
                print("Error geocoding address \(err.localizedDescription)")
                completion(nil)
            }
            if let marks = placemarks,
               let mark = marks.first,
               let location = mark.location {
                let coordinate = location.coordinate
                completion(CLCircularRegion(center: coordinate, radius: CLLocationDistance(100), identifier: address))
            } else {
                completion(nil)
            }
        }
    }
}
