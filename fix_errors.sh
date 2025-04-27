#!/bin/bash

# Fix for BankingView.swift line 62
sed -i '' 's/\.foregroundColor(\.foregroundColor(creditScoreCategoryColor())())/\.foregroundColor(creditScoreCategoryColor())/g' /Users/vithushanjeyapahan/Documents/GitHub/LifeVerse/LifeVerse/Views/BankingView.swift

# Fix for the first exhaustive switch (line 1017)
sed -i '' '/func transactionTypeIcon/,/}/ s/\(investmentReturn: return "chart\.line\.uptrend\.xyaxis"\)[^@]*}/\1\n        @unknown default: return "questionmark.circle"\n        }/g' /Users/vithushanjeyapahan/Documents/GitHub/LifeVerse/LifeVerse/Views/BankingView.swift

# Fix for the second exhaustive switch (line 1037)
sed -i '' '/func transactionTypeColor/,/}/ s/\(return \.orange\)[^@]*}/\1\n        @unknown default:\n            return .primary\n        }/g' /Users/vithushanjeyapahan/Documents/GitHub/LifeVerse/LifeVerse/Views/BankingView.swift

# Fix for AgeUpView.swift
sed -i '' 's/if let career = summary\.career {/if summary.career != nil {\n                    let career = summary.career!/g' /Users/vithushanjeyapahan/Documents/GitHub/LifeVerse/LifeVerse/Views/AgeUpView.swift

echo "Fixes applied!"
