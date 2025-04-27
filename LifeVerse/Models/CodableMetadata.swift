//
//  CodableMetadata.swift
//  LifeVerse
//
//  Created to provide a Codable metadata structure
//

import Foundation

/// A wrapper struct for metadata that can be encoded and decoded
struct CodableMetadata: Codable {
    // Store all values as strings for simplicity
    private var values: [String: String] = [:]
    
    /// Initialize with an empty metadata dictionary
    init() {}
    
    /// Initialize with an existing metadata dictionary
    init(from metadata: [String: Any]) {
        for (key, value) in metadata {
            // Convert all values to strings
            if let boolValue = value as? Bool {
                values[key] = String(boolValue)
            } else if let intValue = value as? Int {
                values[key] = String(intValue)
            } else if let doubleValue = value as? Double {
                values[key] = String(doubleValue)
            } else if let stringValue = value as? String {
                values[key] = stringValue
            } else if let uuidValue = value as? UUID {
                values[key] = uuidValue.uuidString
            }
        }
    }
    
    /// Initialize from a decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        values = try container.decode([String: String].self, forKey: .values)
    }
    
    /// Encode to an encoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(values, forKey: .values)
    }
    
    private enum CodingKeys: String, CodingKey {
        case values
    }
    
    /// Set a value in the metadata
    mutating func setValue(_ value: Any, forKey key: String) {
        // Convert value to string and store
        if let boolValue = value as? Bool {
            values[key] = String(boolValue)
        } else if let intValue = value as? Int {
            values[key] = String(intValue)
        } else if let doubleValue = value as? Double {
            values[key] = String(doubleValue)
        } else if let stringValue = value as? String {
            // If empty string is passed, remove the key
            if stringValue.isEmpty {
                values.removeValue(forKey: key)
            } else {
                values[key] = stringValue
            }
        } else if let uuidValue = value as? UUID {
            values[key] = uuidValue.uuidString
        }
    }
    
    /// Get a value from the metadata
    func getValue(forKey key: String) -> Any? {
        guard let stringValue = values[key] else {
            return nil
        }
        
        // Try to convert back to original types
        if stringValue == "true" {
            return true
        } else if stringValue == "false" {
            return false
        } else if let intValue = Int(stringValue) {
            return intValue
        } else if let doubleValue = Double(stringValue) {
            return doubleValue
        } else if let uuid = UUID(uuidString: stringValue) {
            return uuid
        } else {
            return stringValue
        }
    }
    
    /// Convert to a dictionary
    func toDictionary() -> [String: Any] {
        var result: [String: Any] = [:]
        
        for (key, stringValue) in values {
            // Try to convert back to original types
            if stringValue == "true" {
                result[key] = true
            } else if stringValue == "false" {
                result[key] = false
            } else if let intValue = Int(stringValue) {
                result[key] = intValue
            } else if let doubleValue = Double(stringValue) {
                result[key] = doubleValue
            } else if let uuid = UUID(uuidString: stringValue) {
                result[key] = uuid
            } else {
                result[key] = stringValue
            }
        }
        
        return result
    }
}
