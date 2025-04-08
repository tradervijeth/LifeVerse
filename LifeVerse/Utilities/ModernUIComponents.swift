//
//  ModernUIComponents.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 18/03/2025.
//

import SwiftUI

// MARK: - Modern UI Components

/// A modern card view with shadow and press animation
struct ModernCardView<Content: View>: View {
    let content: Content
    @State private var isPressed: Bool = false

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(15)
            .shadow(
                color: Color.black.opacity(0.1),
                radius: isPressed ? 2 : 5,
                x: 0,
                y: isPressed ? 1 : 3
            )
            .scaleEffect(isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.3), value: isPressed)
            .onTapGesture {
                withAnimation {
                    isPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            isPressed = false
                        }
                    }
                }
            }
    }
}

/// A circular stat meter with animated fill
struct StatMeterView: View {
    let value: Double
    let maxValue: Double
    let label: String
    let color: Color

    var body: some View {
        VStack {
            ZStack {
                // Background track
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 10)
                    .frame(width: 80, height: 80)

                // Progress
                Circle()
                    .trim(from: 0, to: CGFloat(value / maxValue))
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [color.opacity(0.7), color]),
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(), value: value)

                // Value text
                Text("\(Int(value))")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

/// A modern button with gradient and shadow
struct ModernButton: View {
    let text: String
    let icon: String?
    let color: Color
    let action: () -> Void

    init(text: String, icon: String? = nil, color: Color = .blue, action: @escaping () -> Void) {
        self.text = text
        self.icon = icon
        self.color = color
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.body)
                }

                Text(text)
                    .fontWeight(.medium)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [color, color.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 3)
        }
    }
}

/// A progress bar with gradient fill
struct GradientProgressBar: View {
    let value: Double
    let maxValue: Double
    let height: CGFloat
    let colors: [Color]

    init(value: Double, maxValue: Double = 100, height: CGFloat = 8, colors: [Color]? = nil) {
        self.value = value
        self.maxValue = maxValue
        self.height = height
        self.colors = colors ?? [.blue, .blue.opacity(0.7)]
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: height)

                // Progress
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: colors),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: min(CGFloat(value / maxValue) * geometry.size.width, geometry.size.width), height: height)
                    .animation(.spring(response: 0.6), value: value)
            }
        }
        .frame(height: height)
    }
}

/// A modern event card with visual styling based on event type
struct EventCardModern: View {
    let event: LifeEvent
    let makeChoice: ((EventChoice) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Image(systemName: eventIcon(event.type))
                    .foregroundColor(.white)
                    .font(.headline)

                Text(event.title)
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Text(String(event.year))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        eventColor(event.type),
                        eventColor(event.type).opacity(0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

            // Event content
            VStack(alignment: .leading, spacing: 12) {
                Text(event.description)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)

                if let outcome = event.outcome {
                    Divider()

                    Text(outcome)
                        .font(.subheadline)
                        .italic()
                        .foregroundColor(.secondary)
                }

                if let choices = event.choices, let makeChoice = makeChoice {
                    Divider()

                    Text("What will you do?")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.bottom, 4)

                    ForEach(choices) { choice in
                        Button(action: {
                            makeChoice(choice)
                        }) {
                            Text(choice.text)
                                .font(.body)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(eventColor(event.type).opacity(0.5), lineWidth: 1)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color(UIColor.systemBackground))
                                        )
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
        }
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }

    // Helper methods
    func eventColor(_ type: LifeEvent.EventType) -> Color {
        switch type {
        case .birth: return .blue
        case .school: return .orange
        case .graduation: return .purple
        case .career: return .green
        case .relationship: return .pink
        case .health: return .red
        case .financial: return .mint
        case .random: return .gray
        case .death: return .black
        case .retirement: return .indigo
        }
    }

    func eventIcon(_ type: LifeEvent.EventType) -> String {
        switch type {
        case .birth: return "heart.circle.fill"
        case .school: return "book.circle.fill"
        case .graduation: return "graduationcap.circle.fill"
        case .career: return "briefcase.circle.fill"
        case .relationship: return "person.2.circle.fill"
        case .health: return "heart.circle.fill"
        case .financial: return "dollarsign.circle.fill"
        case .random: return "questionmark.circle.fill"
        case .death: return "xmark.circle.fill"
        case .retirement: return "house.circle.fill"
        }
    }
}

/// A modern property card with visual styling
struct PropertyCardModern: View {
    let property: PropertyInvestment
    let bankManager: BankManager
    let currentYear: Int
    var onTap: (() -> Void)? = nil

    // Helper methods to move logic outside of body
    private func getMortgage() -> BankAccount? {
        if let mortgageId = property.mortgageId {
            return bankManager.getAccount(id: mortgageId)
        }
        return nil
    }

    private func getMortgageBalance(mortgage: BankAccount?) -> Double {
        return mortgage != nil ? abs(mortgage!.balance) : 0.0
    }

    private func calculateEquity(property: PropertyInvestment, mortgageBalance: Double) -> (Double, Int) {
        // Calculate actual equity: property value minus mortgage balance
        let equity = property.currentValue - mortgageBalance
        print("DEBUG PropertyCard: Property value: \(property.currentValue), Mortgage balance: \(mortgageBalance), Equity: \(equity)")

        // Calculate equity percentage
        let equityPercentage = mortgageBalance > 0
            ? Int((1 - (mortgageBalance / property.currentValue)) * 100)
            : 100

        return (equity, equityPercentage)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Property Image (would be customized based on property type)
            ZStack {
                Image(systemName: property.isRental ? "building.2" : "house")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                    .padding()
                    .foregroundColor(.white)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                property.isRental ? Color.blue : Color.green,
                                property.isRental ? Color.blue.opacity(0.7) : Color.green.opacity(0.7)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Property status badge
                VStack {
                    HStack {
                        Spacer()
                        Text(property.isRental ? "RENTAL" : "RESIDENCE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(4)
                            .padding(8)
                    }
                    Spacer()
                }
            }

            // Property details
            VStack(alignment: .leading, spacing: 12) {
                let mortgage = getMortgage()
                let mortgageBalance = getMortgageBalance(mortgage: mortgage)
                // We'll use the equity calculation where it's needed

                VStack(alignment: .leading, spacing: 4) {
                    Text("Property Value")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack {
                        Text("$\(Int(property.currentValue).formattedWithSeparator())")
                            .font(.headline)
                            .fontWeight(.bold)

                        Spacer()

                        HStack(spacing: 2) {
                            if mortgageBalance > 0 {
                                Image(systemName: "building.columns")
                                    .font(.caption)
                                Text("Mortgaged \(Int((mortgageBalance / property.currentValue) * 100))%")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.orange.opacity(0.1))
                                    .cornerRadius(4)
                            } else {
                                Image(systemName: "checkmark.circle")
                                    .font(.caption)
                                Text("Owned")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(4)
                            }
                        }
                    }
                }

                Divider()

                // Financial details
                HStack {
                    // Mortgage info
                    VStack(alignment: .leading, spacing: 4) {
                        if mortgageBalance > 0 {
                            Text("Mortgage Balance")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text("$\(Int(mortgageBalance).formattedWithSeparator())")
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                        } else {
                            Text("Down Payment")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            // Assume down payment was around 20% of purchase price
                            let downPayment = property.purchasePrice * 0.2
                            Text("$\(Int(downPayment).formattedWithSeparator())")
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }

                    Spacer()

                    // Equity or rent info
                    VStack(alignment: .trailing, spacing: 4) {
                        if property.isRental {
                            Text("Monthly Rent")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text("$\(Int(property.monthlyRent).formattedWithSeparator())")
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        } else {
                            Text("Equity")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            let (equity, equityPercentage) = calculateEquity(property: property, mortgageBalance: mortgageBalance)

                            Text("$\(Int(equity).formattedWithSeparator()) (\(equityPercentage)%)")
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }
                }

                // For rental properties, show performance
                if property.isRental {
                    Divider()

                    // Calculate cap rate
                    let capRate = property.calculateCapRate() * 100
                    let capRateColor: Color =
                        capRate > 8 ? .green :
                        (capRate > 5 ? .yellow : .red)

                    HStack(alignment: .center) {
                        // Cap rate
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Cap Rate")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text(String(format: "%.1f%%", capRate))
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundColor(capRateColor)
                        }

                        Spacer()

                        // View details button
                        HStack {
                            Text("Details")
                                .font(.caption)
                                .fontWeight(.medium)

                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(20)
                        .foregroundColor(.blue)
                    }
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
        }
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .onTapGesture {
            if let onTap = onTap {
                onTap()
            }
        }
    }
}

// RelationshipCardModern has been moved to its own file in Views/Components

// Helper extension for rounded corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// Character attribute meter view
struct CharacterAttributeMeter: View {
    let attribute: String
    let value: Int
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            // Icon with colored background
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
            }

            // Attribute name
            Text(attribute)
                .font(.caption)
                .foregroundColor(.secondary)

            // Value and progress bar
            VStack(spacing: 4) {
                Text("\(value)")
                    .font(.headline)
                    .foregroundColor(color)

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(color.opacity(0.2))
                            .frame(height: 6)
                            .cornerRadius(3)

                        Rectangle()
                            .fill(color)
                            .frame(width: CGFloat(value) / 100 * geometry.size.width, height: 6)
                            .cornerRadius(3)
                    }
                }
                .frame(height: 6)
            }
        }
        .frame(width: 80)
    }
}

// Modern character header view
struct CharacterHeaderModern: View {
    let character: Character
    let currentYear: Int
    var bankManager: BankManager? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Top banner with name and age
            HStack {
                VStack(alignment: .leading) {
                    Text(character.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Age \(character.age) • \(character.gender.rawValue)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }

                Spacer()

                // Avatar placeholder - in a real app, you'd use a proper avatar system
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 60, height: 60)

                    Text(String(character.name.prefix(1)))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.blue, .purple]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

            // Character stats section
            VStack(spacing: 15) {
                // Money and education info
                HStack {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.green)

                        VStack(alignment: .leading) {
                            Text("Cash")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("$\(Int(bankManager?.getCharacterMoney() ?? character.money).formattedWithSeparator())")
                                .font(.headline)
                        }
                    }

                    Spacer()

                    HStack {
                        Image(systemName: "book.circle.fill")
                            .foregroundColor(.orange)

                        VStack(alignment: .leading) {
                            Text("Education")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(character.education.rawValue.capitalized)
                                .font(.headline)
                        }
                    }
                }
                .padding(.horizontal)

                Divider()
                    .padding(.horizontal)

                // Character attributes
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        CharacterAttributeMeter(
                            attribute: "Health",
                            value: character.health,
                            icon: "heart.fill",
                            color: .red
                        )

                        CharacterAttributeMeter(
                            attribute: "Happiness",
                            value: character.happiness,
                            icon: "face.smiling.fill",
                            color: .yellow
                        )

                        CharacterAttributeMeter(
                            attribute: "Intelligence",
                            value: character.intelligence,
                            icon: "brain",
                            color: .blue
                        )

                        CharacterAttributeMeter(
                            attribute: "Looks",
                            value: character.looks,
                            icon: "person.fill",
                            color: .purple
                        )

                        CharacterAttributeMeter(
                            attribute: "Athleticism",
                            value: character.athleticism,
                            icon: "figure.run",
                            color: .green
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .background(Color(UIColor.systemBackground))
            .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
        }
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}
