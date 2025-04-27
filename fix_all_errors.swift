import Foundation

// This is a script to fix all remaining errors in the LifeVerse project

struct ErrorFix {
    static func runFixes() {
        fixBankingViewForegroundColor()
        fixTransactionTypeIconSwitch()
        fixTransactionTypeColorSwitch()
        fixAgeUpViewCareer()
        
        print("All fixes have been applied!")
    }
    
    // Fix for the .foregroundColor issue
    static func fixBankingViewForegroundColor() {
        let filePath = "/Users/vithushanjeyapahan/Documents/GitHub/LifeVerse/LifeVerse/Views/BankingView.swift"
        var fileContent = try! String(contentsOfFile: filePath)
        
        // Fix for line 62
        fileContent = fileContent.replacingOccurrences(of: ".foregroundColor(.foregroundColor(creditScoreCategoryColor())())",
                                                     with: ".foregroundColor(creditScoreCategoryColor())")
        
        try! fileContent.write(toFile: filePath, atomically: true, encoding: .utf8)
    }
    
    // Fix for transaction type icon switch
    static func fixTransactionTypeIconSwitch() {
        let filePath = "/Users/vithushanjeyapahan/Documents/GitHub/LifeVerse/LifeVerse/Views/BankingView.swift"
        var fileContent = try! String(contentsOfFile: filePath)
        
        let pattern = """
    func transactionTypeIcon\\(_\\s+type:\\s+BankTransactionType\\)\\s+->\\s+String\\s+{
        switch\\s+type\\s+{
        (.*?)
        }
    }
"""
        
        let replacement = """
    func transactionTypeIcon(_ type: BankTransactionType) -> String {
        switch type {
        case .deposit: return "arrow.down"
        case .withdrawal: return "arrow.up"
        case .transfer: return "arrow.left.arrow.right"
        case .payment: return "checkmark"
        case .fee: return "exclamationmark.circle"
        case .interest: return "percent"
        case .loan: return "dollarsign.square"
        case .purchase: return "cart"
        case .refund: return "arrow.uturn.down"
        case .cashback: return "gift"
        case .directDeposit: return "arrow.down.doc"
        case .check: return "doc.text"
        case .atmTransaction: return "building.columns"
        case .wireTransfer: return "network"
        case .investmentReturn: return "chart.line.uptrend.xyaxis"
        @unknown default: return "questionmark.circle"
        }
    }
"""
        
        let regex = try! NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
        let range = NSRange(fileContent.startIndex..<fileContent.endIndex, in: fileContent)
        fileContent = regex.stringByReplacingMatches(in: fileContent, options: [], range: range, withTemplate: replacement)
        
        try! fileContent.write(toFile: filePath, atomically: true, encoding: .utf8)
    }
    
    // Fix for transaction type color switch
    static func fixTransactionTypeColorSwitch() {
        let filePath = "/Users/vithushanjeyapahan/Documents/GitHub/LifeVerse/LifeVerse/Views/BankingView.swift"
        var fileContent = try! String(contentsOfFile: filePath)
        
        let pattern = """
    func transactionTypeColor\\(_\\s+type:\\s+BankTransactionType\\)\\s+->\\s+Color\\s+{
        switch\\s+type\\s+{
        (.*?)
        }
    }
"""
        
        let replacement = """
    func transactionTypeColor(_ type: BankTransactionType) -> Color {
        switch type {
        case .deposit, .refund, .cashback, .directDeposit, .interest, .investmentReturn:
            return .green
        case .withdrawal, .fee, .purchase, .atmTransaction:
            return .red
        case .transfer, .wireTransfer:
            return .blue
        case .payment, .check:
            return .purple
        case .loan:
            return .orange
        @unknown default:
            return .primary
        }
    }
"""
        
        let regex = try! NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
        let range = NSRange(fileContent.startIndex..<fileContent.endIndex, in: fileContent)
        fileContent = regex.stringByReplacingMatches(in: fileContent, options: [], range: range, withTemplate: replacement)
        
        try! fileContent.write(toFile: filePath, atomically: true, encoding: .utf8)
    }
    
    // Fix for the career variable in AgeUpView
    static func fixAgeUpViewCareer() {
        let filePath = "/Users/vithushanjeyapahan/Documents/GitHub/LifeVerse/LifeVerse/Views/AgeUpView.swift"
        var fileContent = try! String(contentsOfFile: filePath)
        
        // Replace the problematic code (with regex to be safer)
        fileContent = fileContent.replacingOccurrences(
            of: "if let career = summary\\.career \\{",
            with: "if summary.career != nil {\n                    let career = summary.career!",
            options: .regularExpression
        )
        
        try! fileContent.write(toFile: filePath, atomically: true, encoding: .utf8)
    }
}

// Run the fixes
ErrorFix.runFixes()
