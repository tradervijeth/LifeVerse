//
//  Banking_TransactionType.swift
//  LifeVerse
//
//  Created to fix duplicate enums issue
//

import Foundation

// Define the enum directly rather than using a type alias
enum Banking_TransactionType: String, Codable {
    case deposit = "Deposit"
    case withdrawal = "Withdrawal"
    case transfer = "Transfer"
    case payment = "Payment"
    case fee = "Fee"
    case interest = "Interest"
    case loan = "Loan"
    case purchase = "Purchase"
    case refund = "Refund"
    case cashback = "Cashback"
    case directDeposit = "Direct Deposit"
    case check = "Check"
    case atmTransaction = "ATM Transaction"
    case wireTransfer = "Wire Transfer"
    case investmentReturn = "Investment Return"
    case sale = "Sale"
    case tax = "Tax"
    case investment = "Investment"
    case specialEvent = "Special Event"
}
