//
//  NetworkManager.swift
//  Geofencer
//
//  Created by Jonathan Kovach on 1/8/22.
//

import Foundation

protocol NetworkManagerProtocol: AnyObject {
    func makeRequest(_ router: Router)
}

struct Request: Encodable {
    let address: String
    let time: String
    let exited: Bool?
    let entered: Bool?
}

struct Router {
    let url: URL
    let data: Request
    var jsonData: Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let jsonData = try? encoder.encode(data) {
            return jsonData
        } else {
            return nil
        }
    }
    
    static func entered(_ address: String) -> Router? {
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filename = url.appendingPathComponent("entered.json")
            let time = String(Date().timeIntervalSince1970)
            let request = Request(address: address, time: time, exited: nil, entered: true)
            return Router(url: filename, data: request)
        } else {
            return nil
        }
    }
    
    static func exited(_ address: String) -> Router? {
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filename = url.appendingPathComponent("exited.json")
            let time = String(Date().timeIntervalSince1970)
            let request = Request(address: address, time: time, exited: true, entered: nil)
            return Router(url: filename, data: request)
        } else {
            return nil
        }
    }
}

class JSONManager: NetworkManagerProtocol {
    static let shared = JSONManager()
    
    func makeRequest(_ router: Router) {
        guard let jsonData = router.jsonData else {
            print("No json data for \(router)")
            return
        }
        do {
            try jsonData.write(to: router.url)
        } catch {
            print("Failed to write to json")
        }
    }
}
