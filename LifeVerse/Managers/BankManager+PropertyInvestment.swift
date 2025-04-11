//
//  BankManager+PropertyInvestment.swift
//  LifeVerse
//
import Foundation

// Extension to BankManager to handle property investments
extension BankManager {
    // MARK: - Property Investment Management

    // Create a new property investment with optional mortgage
    func createPropertyInvestment(propertyValue: Double, downPayment: Double, isRental: Bool, monthlyRent: Double = 0, term: Int = 30, currentYear: Int) -> (property: PropertyInvestment?, mortgage: Banking_Account?) {
        print("DEBUG: Creating property investment, value: \(propertyValue), down payment: \(downPayment)")

        // Minimum down payment is 20% for investment properties and 5% for personal residence
        let minimumDownPayment = propertyValue * (isRental ? 0.2 : 0.05)

        if downPayment < minimumDownPayment {
            print("DEBUG: Down payment too low, required minimum: \(minimumDownPayment)")
            return (nil, nil)
        }

        // Check if the character has enough money for the down payment
        if getCharacterMoney() < downPayment {
            print("DEBUG: Not enough money for down payment")
            return (nil, nil)
        }

        // We'll deduct the down payment only after successful property creation

        // Create the collateral asset
        let collateral = addCollateralAsset(
            type: Banking_CollateralType.realEstate,
            description: isRental ? "Investment Property" : "Residential Property",
            value: propertyValue,
            purchaseYear: currentYear
        )

        print("DEBUG: Created collateral asset: \(collateral.id.uuidString)")

        // Create mortgage if not paying cash
        var mortgage: Banking_Account? = nil
        if downPayment < propertyValue {
            // Loan amount is property value minus down payment
            let loanAmount = propertyValue - downPayment
            print("DEBUG: Creating mortgage with loan amount: \(loanAmount)")

            // Create the mortgage account with slightly higher interest for investment property
            let investmentPropertyPremium = isRental ? 0.005 : 0.0 // 0.5% higher for rental properties

            // Open account with custom interest rate
            mortgage = openAccount(
                type: Banking_AccountType.mortgage,
                initialDeposit: loanAmount,
                loanAmount: loanAmount,
                term: term
            )

            if let mortgage = mortgage {
                print("DEBUG: Created mortgage account: \(mortgage.id.uuidString) with balance: \(mortgage.balance)")

                // Adjust interest rate if mortgage was created
                if let mortgageIndex = accounts.firstIndex(where: { $0.id == mortgage.id }) {
                    accounts[mortgageIndex].interestRate += investmentPropertyPremium
                    accounts[mortgageIndex].collateralId = collateral.id
                    // Store the soon-to-be-created property's ID for direct reference
                    let propertyId = UUID() // Generate now and use the same one for the property
                    accounts[mortgageIndex].propertyId = propertyId // Store in mortgage
                    print("DEBUG: Adjusted mortgage interest rate and linked collateral")

                    // We'll use this same ID when creating the property
                    let property = createPropertyWithId(
                        id: propertyId,
                        collateralId: collateral.id,
                        purchasePrice: propertyValue,
                        purchaseYear: currentYear,
                        mortgageId: mortgage.id,
                        isRental: isRental,
                        monthlyRent: monthlyRent
                    )

                    if property != nil {
                        // Now that we've successfully created the property, deduct the down payment
                        setCharacterMoney(getCharacterMoney() - downPayment)
                    }

                    return (property, mortgage)
                } else {
                    print("DEBUG: Failed to find mortgage in accounts array after creation")
                }
            } else {
                print("DEBUG: Failed to create mortgage account")
            }
        } else {
            print("DEBUG: No mortgage needed (paying cash)")

            // Create the property investment with a fresh ID for cash purchases
            let propertyId = UUID()
            let property = createPropertyWithId(
                id: propertyId,
                collateralId: collateral.id,
                purchasePrice: propertyValue,
                purchaseYear: currentYear,
                mortgageId: nil,
                isRental: isRental,
                monthlyRent: monthlyRent
            )

            if property != nil {
                // Now that we've successfully created the property, deduct the down payment
                setCharacterMoney(getCharacterMoney() - downPayment)
            }

            return (property, nil)
        }

        // This code should not be reached due to early returns above
        print("DEBUG: ERROR - createPropertyInvestment fallthrough path reached!")
        return (nil, nil)
    }

    // Helper method to create a property with a specific ID
    private func createPropertyWithId(
        id: UUID,
        collateralId: UUID,
        purchasePrice: Double,
        purchaseYear: Int,
        mortgageId: UUID?,
        isRental: Bool,
        monthlyRent: Double
    ) -> PropertyInvestment? {
        // Create the property investment
        let property = PropertyInvestment(
            name: isRental ? "Rental Property" : "Residential Property",
            collateralId: collateralId,
            purchasePrice: purchasePrice,
            purchaseYear: purchaseYear,
            isRental: isRental,
            monthlyRent: monthlyRent,
            propertyType: Banking_PropertyType.singleFamily,
            location: Banking_PropertyLocation.suburban
        )

        // Set the property ID to match the one we generated or set in the mortgage
        var updatedProperty = property
        updatedProperty.id = id
        updatedProperty.mortgageId = mortgageId

        // Add to property investments collection
        propertyInvestments.append(updatedProperty)
        print("DEBUG: Added property to investments collection, now have \(propertyInvestments.count) properties")

        // Add purchase transaction to history
        let transaction = Banking_Transaction(
            date: Date(),
            type: Banking_TransactionType.purchase,
            amount: purchasePrice,
            description: isRental ? "Purchased investment property" : "Purchased property",
            year: purchaseYear
        )
        transactionHistory.append(transaction)

        // Just return the property investment - the caller already has the mortgage if needed
        return updatedProperty
    }

    // MARK: - Selling Properties

    /// Sell a property and handle all related financial transactions
    /// - Parameters:
    ///   - propertyId: The ID of the property to sell
    ///   - sellingPrice: The price at which the property is being sold
    ///   - currentYear: The current year in the game
    /// - Returns: A tuple containing success status, proceeds from the sale, and a message
    func sellProperty(propertyId: UUID, sellingPrice: Double, currentYear: Int) -> (success: Bool, proceeds: Double, message: String) {
        // Find the property
        guard let propertyIndex = propertyInvestments.firstIndex(where: { $0.id == propertyId }) else {
            return (false, 0, "Property not found")
        }

        let property = propertyInvestments[propertyIndex]
        var proceeds = sellingPrice
        var message = ""

        // Handle mortgage payoff if there is one
        if let mortgageId = property.mortgageId, let mortgageIndex = accounts.firstIndex(where: { $0.id == mortgageId }) {
            let mortgage = accounts[mortgageIndex]
            let mortgageBalance = abs(mortgage.balance) // Mortgage balance is stored as negative

            // Check if selling price covers the mortgage
            if sellingPrice < mortgageBalance {
                return (false, 0, "Selling price does not cover the mortgage balance of $\(Int(mortgageBalance))")
            }

            // Pay off the mortgage
            proceeds -= mortgageBalance

            // Close the mortgage account
            _ = closeAccount(accountId: mortgageId)

            message += "Mortgage paid off: $\(Int(mortgageBalance)). "
        }

        // Calculate capital gains or losses
        let capitalGain = sellingPrice - property.purchasePrice
        let capitalGainsTax = calculateCapitalGainsTax(gain: capitalGain, holdingYears: currentYear - property.purchaseYear)

        // Deduct capital gains tax if applicable
        if capitalGainsTax > 0 {
            proceeds -= capitalGainsTax
            message += "Capital gains tax: $\(Int(capitalGainsTax)). "
        }

        // Add proceeds to character's money
        setCharacterMoney(getCharacterMoney() + proceeds)

        // Add transaction record for the sale
        let saleTransaction = Banking_Transaction(
            date: Date(),
            type: .sale,
            amount: sellingPrice,
            description: "Sold \(property.isRental ? "rental property" : "residential property")",
            year: currentYear
        )
        transactionHistory.append(saleTransaction)

        // Add transaction record for capital gains tax if applicable
        if capitalGainsTax > 0 {
            let taxTransaction = Banking_Transaction(
                date: Date(),
                type: .tax,
                amount: -capitalGainsTax,
                description: "Capital gains tax on property sale",
                year: currentYear
            )
            transactionHistory.append(taxTransaction)
        }

        // Remove the property from investments
        propertyInvestments.remove(at: propertyIndex)

        // Remove the collateral asset
        if let collateralIndex = collateralAssets.firstIndex(where: { $0.id == property.collateralId }) {
            collateralAssets.remove(at: collateralIndex)
        }

        message += "Net proceeds: $\(Int(proceeds))"
        return (true, proceeds, message)
    }

    /// Calculate the capital gains tax on a property sale
    /// - Parameters:
    ///   - gain: The capital gain amount (selling price - purchase price)
    ///   - holdingYears: Number of years the property was held
    /// - Returns: The amount of capital gains tax
    private func calculateCapitalGainsTax(gain: Double, holdingYears: Int) -> Double {
        // No tax on losses
        if gain <= 0 {
            return 0
        }

        // Long-term capital gains tax rate (simplified)
        // In reality, this would depend on income bracket and other factors
        let taxRate = holdingYears >= 1 ? 0.15 : 0.25 // 15% for long-term, 25% for short-term

        return gain * taxRate
    }

    /// Get the estimated selling price range for a property
    /// - Parameters:
    ///   - propertyId: The ID of the property
    ///   - currentYear: The current year in the game
    /// - Returns: A tuple with minimum, average, and maximum estimated selling prices
    func getEstimatedSellingPrice(propertyId: UUID, currentYear: Int) -> (min: Double, average: Double, max: Double)? {
        // Find the property
        guard let property = propertyInvestments.first(where: { $0.id == propertyId }) else {
            return nil
        }

        // Calculate years owned
        let yearsOwned = currentYear - property.purchaseYear

        // Calculate appreciation based on years owned and property condition
        let baseAppreciation = pow(1 + property.appreciationRate, Double(yearsOwned))
        let conditionFactor = Double(property.propertyCondition.rawValue) / 100.0 // Convert condition to a factor

        // Calculate the current market value with appreciation and condition
        let marketValue = property.purchasePrice * baseAppreciation * conditionFactor

        // Calculate a range of possible selling prices
        let minPrice = marketValue * 0.9 // 10% below market value
        let maxPrice = marketValue * 1.1 // 10% above market value

        return (minPrice, marketValue, maxPrice)
    }
}
