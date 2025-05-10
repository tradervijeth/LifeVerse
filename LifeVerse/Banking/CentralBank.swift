//
//  CentralBank.swift
//  LifeVerse
//
//  Created by Claude on 27/04/2025.
//

import Foundation

class CentralBank: Codable {
    private var baseRate: Double // The central bank base interest rate
    private var inflationTarget: Double = 0.02 // 2% inflation target
    
    // Historical rates for analysis
    private var historicalRates: [YearlyRate] = []
    
    struct YearlyRate: Codable {
        let year: Int
        let rate: Double
        let inflation: Double
    }
    
    init(baseRate: Double) {
        self.baseRate = baseRate
        
        // Initialize with some historical data
        let currentYear = Calendar.current.component(.year, from: Date())
        for i in 0..<10 {
            let year = currentYear - i
            let historicalRate = baseRate - Double(i) * 0.002 // Trending slightly upward
            historicalRates.append(YearlyRate(
                year: year,
                rate: max(0.005, historicalRate), // Minimum 0.5%
                inflation: 0.02 + Double.random(in: -0.01...0.01) // Around 2%
            ))
        }
        
        // Sort by year for consistency
        historicalRates.sort { $0.year < $1.year }
    }
    
    // Get the current base rate
    func getBaseRate() -> Double {
        return baseRate
    }
    
    // Set a new base rate
    func setBaseRate(_ rate: Double) {
        baseRate = rate
    }
    
    // Record a new yearly rate
    func recordYearlyRate(year: Int, inflation: Double) {
        // Record the current rate and provided inflation for this year
        historicalRates.append(YearlyRate(
            year: year,
            rate: baseRate,
            inflation: inflation
        ))
        
        // Keep last 30 years of history
        if historicalRates.count > 30 {
            historicalRates.removeFirst()
        }
    }
    
    // Get the historical rates
    func getHistoricalRates() -> [YearlyRate] {
        return historicalRates
    }
    
    // Project future rates based on economic indicators
    func projectFutureRates(years: Int, projectedInflation: Double) -> [YearlyRate] {
        var projections: [YearlyRate] = []
        let currentYear = Calendar.current.component(.year, from: Date())
        
        // Simple projection model
        var projectedRate = baseRate
        
        for i in 1...years {
            // Adjust rate based on inflation deviation from target
            let inflationDeviation = projectedInflation - inflationTarget
            projectedRate += inflationDeviation * 0.5 // 50% weight on inflation deviation
            
            // Add some random noise for realism
            projectedRate += Double.random(in: -0.003...0.003)
            
            // Ensure rate doesn't go negative or unreasonably high
            projectedRate = max(0.001, min(0.15, projectedRate))
            
            projections.append(YearlyRate(
                year: currentYear + i,
                rate: projectedRate,
                inflation: projectedInflation + Double.random(in: -0.005...0.005)
            ))
        }
        
        return projections
    }
    
    // Handle economic shock (recession, boom, etc.)
    func respondToEconomicShock(type: ShockType) {
        switch type {
        case .recession:
            // Lower rates to stimulate economy
            baseRate = max(0.001, baseRate - 0.01)
        case .inflation:
            // Raise rates to combat inflation
            baseRate += 0.01
        case .financialCrisis:
            // Drastic cuts in emergency
            baseRate = max(0.001, baseRate - 0.03)
        case .economicBoom:
            // Raise rates to prevent overheating
            baseRate += 0.005
        }
    }
    
    // Economic shock types
    enum ShockType {
        case recession
        case inflation
        case financialCrisis
        case economicBoom
    }
    
    // Codable conformance
    enum CodingKeys: String, CodingKey {
        case baseRate, inflationTarget, historicalRates
    }
}
