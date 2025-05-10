# LifeVerse

A life simulation game focusing on financial and property management.

## Modular Architecture Overview

LifeVerse is designed with a highly modular architecture to support future expansion and maintainability.

### Core Structure

- **Models**: Core data structures like `PropertyInvestment`, `BankAccount`, etc.
- **Managers**: Business logic controllers, with the main managers being:
  - `GameManager`: Overall game state controller
  - `BankManager`: Financial system controller
- **Utilities**: Reusable helpers and extensions
- **Views**: SwiftUI interface components

### Extension-Based Modularity

The codebase uses Swift extensions to separate functionality into logical modules:

1. **BankManager+PropertyManagement.swift**: All property-related functions
2. **BankManager+Taxation.swift**: Tax calculation and reporting
3. **MarketConditionHelpers.swift**: Market condition conversions and utilities

## Adding New Features

### Adding New Property Types

1. Add a new case to `PropertyInvestment.PropertyType` enum in `PropertyInvestment.swift`
2. Update property creation methods in `BankManager+PropertyManagement.swift`

### Extending Market Conditions

1. Add new functionality to the appropriate extensions in `MarketConditionHelpers.swift`
2. No need to modify view code that uses these conditions

### Adding New Financial Products

1. Create a new extension file if needed (e.g., `BankManager+Investments.swift`)
2. Add relevant models to the Models directory
3. Implement manager logic in the extension file

## Coding Guidelines

1. **Minimize Dependencies**: Each module should rely on as few other modules as possible
2. **Use Extensions**: Group related functionality in extensions to maintain separation of concerns
3. **Centralize Formatting**: Use utilities in `FormattingExtensions.swift` for consistent presentation
4. **Property Access**: Access properties through proper accessor methods
5. **Market Condition Conversions**: Use the extensions in `MarketConditionHelpers.swift`

## Testing

When adding new functionality:

1. Create test cases in the appropriate test files
2. Test for edge cases in financial calculations
3. Ensure compatibility with existing functionality

---

Remember: The goal is to keep the codebase modular to allow for easy expansion of game features without extensive rework.
