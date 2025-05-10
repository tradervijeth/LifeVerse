# LifeVerse Architecture Guidelines

This document outlines the architectural principles for the LifeVerse project to ensure consistency and maintainability.

## Core Architecture

LifeVerse follows a modular architecture with clear separation of concerns:

```
LifeVerse/
├── Models/           # Core data structures
├── Views/            # UI components 
├── Managers/         # Business logic and state management
├── Utilities/        # Shared helper functions and extensions
└── Banking/          # Banking system components
```

## Key Principles

### 1. Single Source of Truth

- Each function should be defined in exactly one place
- Extensions should be grouped by functionality not by specific methods
- Utility functions should be centralized in the appropriate utility files

### 2. File Organization

- **Models/**: Contains data structures and their domain-specific methods
- **Views/**: Contains SwiftUI views and view-specific extensions
- **Managers/**: Contains business logic organized by feature
- **Utilities/**: Contains reusable helper methods and extensions
- **Banking/**: Contains banking system integration code

### 3. Extension Guidelines

- Use extensions to organize code by functionality
- Name extension files after the main class being extended and their purpose (e.g., `BankManager+PropertyManagement.swift`)
- Do not duplicate functionality across multiple extensions

## Specific Guidelines

### Manager Extensions

1. **BankManager+PropertyManagement.swift**
   - Contains ALL property-related functionality
   - Includes property creation, selling, refinancing, analysis, etc.

2. **BankManager+Taxation.swift**
   - Contains ALL tax-related functionality

### Utility Extensions

1. **IntExtensions.swift**
   - Contains ALL Int-specific extensions
   - Includes formatting methods for numbers

2. **MarketConditionHelpers.swift**
   - Contains ALL market condition conversion and representation extensions
   - Includes methods for all market condition enum types

## Adding New Features

When adding new features:

1. Determine if the feature belongs in an existing extension
2. If not, create a new extension file named appropriately
3. Document the purpose of the extension at the top of the file
4. Add the new extension to this architecture document

## Best Practices

1. Add clear documentation comments to public methods
2. Use `MARK:` comments to organize code within files
3. Avoid duplicating functionality across files
4. Use appropriate access control (private, internal, public)
5. Consider extraction to a new extension file if a file grows too large

By following these guidelines, we can maintain a clean, modular, and maintainable codebase for LifeVerse.
