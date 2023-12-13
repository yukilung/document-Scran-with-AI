//
//  Bill.swift
//  Scanner
//
//  Created by Jack on 18/5/2021.
//

import Foundation
import MapKit

class Bill {
    var x: CGFloat = 0
    var y: CGFloat = 0
    var text: String = ""
    
    func addressExtract(_ components: [Bill]) -> String {
        var address = [String]()
        for component in components {
            print("Text: \(component.text) X: \(component.x) Y: \(component.y)\n")
            
            if component.x >= 0.11691397981919473 && component.x <= 0.1448541579940594 && component.y >= 0.8135239357172057 && component.y <= 0.9066133720930233 {
                address.append(component.text)
            }
            
        }
        
        let addressString = address.joined(separator: " ")
        let addressTrimmed = addressString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let regexEnglish = "[0-9]{1,}.(Unit|UNIT|Flat|FLAT|Room|ROOM|RM|Floor|FLOOR|[0-9]+[/F]).+(HK|Hong Kong|HONG KONG|KLN|Kowloon|KOWLOON|NT|New Territories|NEW TERRITORIES)$"
        let regexChinese = ".*(香港|九龍|新界).*(室)$"
        
        var addressResult = addressTrimmed.match(regexChinese).first?[0] ?? ""
        
        if addressResult.isEmpty {
            addressResult = addressTrimmed.match(regexEnglish).first?[0] ?? addressTrimmed
        }
        
        print("address \(addressResult)")
        
        return addressResult
    }
    
    // Convert Address to coordinate
    func addressCoordinate(address: String,
                               completion: @escaping(CLLocation?) -> Void) {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            
            guard error == nil else {
                print("*** Error in \(#function): \(error!.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let placemark = placemarks?[0] else {
                print("*** Error in \(#function): placemark is nil")
                completion(nil)
                return
            }
            
            guard let location = placemark.location else {
                print("*** Error in \(#function): placemark is nil")
                completion(nil)
                return
            }

            completion(location)
        }
    }
}

extension String {
    func match(_ regex: String) -> [[String]] {
        let nsString = self as NSString
        return (try? NSRegularExpression(pattern: regex, options: []))?.matches(in: self, options: [], range: NSMakeRange(0, nsString.length)).map { match in
            (0..<match.numberOfRanges).map { match.range(at: $0).location == NSNotFound ? "" : nsString.substring(with: match.range(at: $0)) }
        } ?? []
    }
}

