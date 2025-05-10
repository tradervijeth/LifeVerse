//
//  GameManager+Banking.swift
//  LifeVerse
//
import Foundation

// Extension to GameManager for banking functionality
extension GameManager {

    // MARK: - Banking Methods

    // Show banking view
    func showBanking() {
        showBankingView = true
    }

    // Hide banking view
    func hideBanking() {
        showBankingView = false
    }

    // Show property investment view
    func showPropertyInvestment() {
        showPropertyInvestmentView = true
    }

    // Hide property investment view
    func hidePropertyInvestment() {
        showPropertyInvestmentView = false
    }

    // Get net worth calculation
    func getBankingNetWorth() -> Double {
        return getBankingNetWorthForYear(currentYear)
    }

    // Get net worth calculation with specific year
    func getBankingNetWorthForYear(_ year: Int) -> Double {
        var netWorth = 0.0

        // Add character's cash
        if let character = character {
            netWorth += character.money

            // Add value of possessions
            for possession in character.possessions {
                netWorth += possession.value * (Double(possession.condition) / 100.0)
            }
        }

        // Add bank accounts, investments, and property value from bank manager
        netWorth += bankManager.calculateNetWorth()

        return netWorth
    }

    // Buy property
    func buyProperty(value: Double, downPayment: Double, isRental: Bool, monthlyRent: Double) -> Bool {
        guard let character = character else { return false }

        // Check age requirement - must be 18 or older
        if character.age < 18 {
            let ageRestrictionEvent = LifeEvent(
                title: "Age Restriction",
                description: "You must be at least 18 years old to purchase property.",
                type: .financial,
                year: currentYear,
                outcome: "Unable to complete purchase.",
                effects: []
            )
            currentEvents.append(ageRestrictionEvent)
            return false
        }

        // Check funds for down payment
        if character.money < downPayment {
            let insufficientFundsEvent = LifeEvent(
                title: "Insufficient Funds",
                description: "You don't have enough money for the down payment.",
                type: .financial,
                year: currentYear,
                outcome: "Unable to complete purchase.",
                effects: []
            )
            currentEvents.append(insufficientFundsEvent)
            return false
        }

        // Create the property investment
        let result = bankManager.createPropertyInvestment(
            propertyValue: value,
            downPayment: downPayment,
            isRental: isRental,
            monthlyRent: monthlyRent,
            term: 30,
            currentYear: currentYear
        )

        // Check if successful
        if result.property != nil {
            // Update character's money (the bank manager already deducted the down payment)
            if var updatedCharacter = self.character {
                updatedCharacter.money = bankManager.characterMoney
                self.character = updatedCharacter
            }

            // Create property purchase event with explicit type annotations
            let eventTitle: String = isRental ? "Investment Property Purchase" : "Home Purchase"
            let description: String = isRental ?
                "You purchased an investment property for $\(Int(value).formattedWithSeparator())." :
                "You purchased a home for $\(Int(value).formattedWithSeparator())."

            let details: String = result.mortgage != nil ?
                "You made a down payment of $\(Int(downPayment).formattedWithSeparator()) and took out a mortgage for the remainder." :
                "You paid cash for the property."

            let purchaseEvent = LifeEvent(
                title: eventTitle,
                description: description,
                type: .financial,
                year: currentYear,
                outcome: details,
                effects: [
                    EventChoice.CharacterEffect(attribute: "money", change: -Int(downPayment))
                ]
            )

            currentEvents.append(purchaseEvent)

            // If this is a home purchase (not rental), update character's residence
            if !isRental {
                if var updatedCharacter = self.character {
                    updatedCharacter.residence = .house
                    self.character = updatedCharacter
                }
            }

            return true
        } else {
            // Failed to create property
            let failureEvent = LifeEvent(
                title: "Property Purchase Failed",
                description: "Unable to complete property purchase.",
                type: .financial,
                year: currentYear,
                outcome: "The transaction could not be completed.",
                effects: []
            )
            currentEvents.append(failureEvent)
            return false
        }
    }

    // Sell property
    func sellProperty(propertyId: UUID, sellingPrice: Double) -> (success: Bool, message: String) {
        if character == nil { return (false, "Character not found") }

        // Check if property exists
        guard let property = bankManager.propertyInvestments.first(where: { $0.id == propertyId }) else {
            return (false, "Property not found")
        }

        // Sell the property
        let result = bankManager.sellProperty(propertyId: propertyId, sellingPrice: sellingPrice, currentYear: currentYear)

        if result.success {
            // Update character's money
            if var updatedCharacter = self.character {
                updatedCharacter.money = bankManager.characterMoney

                // If this was the character's residence, update residence status
                if !property.isRental && updatedCharacter.residence == .house {
                    updatedCharacter.residence = .apartment // Default back to apartment
                }

                self.character = updatedCharacter
            }

            // Create property sale event
            let eventTitle = property.isRental ? "Investment Property Sale" : "Home Sale"
            let description = property.isRental ?
                "You sold your investment property for $\(Int(sellingPrice).formattedWithSeparator())." :
                "You sold your home for $\(Int(sellingPrice).formattedWithSeparator())."

            let saleEvent = LifeEvent(
                title: eventTitle,
                description: description,
                type: .financial,
                year: currentYear,
                outcome: result.message,
                effects: [
                    EventChoice.CharacterEffect(attribute: "money", change: Int(result.proceeds))
                ]
            )

            currentEvents.append(saleEvent)
            if var updatedCharacter = self.character {
                updatedCharacter.lifeEvents.append(saleEvent)
                self.character = updatedCharacter
            }

            return (true, result.message)
        } else {
            // Failed to sell property
            let failureEvent = LifeEvent(
                title: "Property Sale Failed",
                description: "Unable to complete property sale.",
                type: .financial,
                year: currentYear,
                outcome: result.message,
                effects: []
            )
            currentEvents.append(failureEvent)
            return (false, result.message)
        }
    }

    // Get estimated selling price for a property
    func getEstimatedSellingPrice(propertyId: UUID) -> (min: Double, average: Double, max: Double)? {
        // Find the property
        guard let property = bankManager.propertyInvestments.first(where: { $0.id == propertyId }) else {
            return nil
        }
        
        // Get current value from property
        let baseValue = property.currentValue
        
        // Calculate range based on market conditions
        let minValue = baseValue * 0.9  // 10% below market value
        let avgValue = baseValue
        let maxValue = baseValue * 1.1  // 10% above market value
        
        return (minValue, avgValue, maxValue)
    }
}
