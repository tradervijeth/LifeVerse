//
//  UnifiedCareerEnums.swift
//  LifeVerse
//
//  Created to fix duplicate enum declarations
//

import Foundation

// Industry sectors
enum Industry: String, Codable, CaseIterable {
    case technology = "Technology"
    case healthcare = "Healthcare"
    case finance = "Finance"
    case education = "Education"
    case government = "Government"
    case retail = "Retail"
    case manufacturing = "Manufacturing"
    case entertainment = "Entertainment"
    case hospitality = "Hospitality"
    case construction = "Construction"
    case agriculture = "Agriculture"
    case energy = "Energy"
    case transportation = "Transportation"
    case legal = "Legal"
    case art = "Art and Design"
    case science = "Science and Research"
}

// Unified Career Level enum that combines both versions
enum UnifiedCareerLevel: String, Codable, CaseIterable {
    case entry = "Entry Level"
    case junior = "Junior"
    case associate = "Associate"
    case mid = "Mid Level"
    case senior = "Senior"
    case lead = "Lead"
    case manager = "Manager"
    case director = "Director"
    case executive = "Executive"
    case cLevel = "C-Level"

    // Get the salary multiplier for this level
    func salaryMultiplier() -> Double {
        switch self {
        case .entry: return 1.0
        case .junior: return 1.2
        case .associate: return 1.5
        case .mid: return 1.5
        case .senior: return 2.0
        case .lead: return 2.5
        case .manager: return 3.0
        case .director: return 4.0
        case .executive: return 5.0
        case .cLevel: return 8.0
        }
    }

    // Get the next level in career progression
    func nextLevel() -> UnifiedCareerLevel? {
        switch self {
        case .entry: return .junior
        case .junior: return .associate
        case .associate: return .mid
        case .mid: return .senior
        case .senior: return .lead
        case .lead: return .manager
        case .manager: return .director
        case .director: return .executive
        case .executive: return .cLevel
        case .cLevel: return nil
        }
    }
}

// Unified Degree Field enum that combines both versions
enum UnifiedDegreeField: String, Codable, CaseIterable {
    case computerScience = "Computer Science"
    case engineering = "Engineering"
    case biology = "Biology"
    case nursing = "Nursing"
    case business = "Business"
    case fineArts = "Fine Arts"
    case psychology = "Psychology"
    case education = "Education"
    case undeclared = "Undeclared"
    case finance = "Finance"
    case medicine = "Medicine"
    case law = "Law"
    case arts = "Arts and Humanities"
    case science = "Science"
    case mathematics = "Mathematics"
    case sociology = "Sociology"
    case accounting = "Accounting"
    case architecture = "Architecture"
    case communications = "Communications"
    case music = "Music"
    case none = "None"
}

// Unified Career Specialization enum that combines both versions
enum UnifiedCareerSpecialization: String, Codable, CaseIterable {
    // Technology
    case softwareDevelopment = "Software Development"
    case softwareDeveloper = "Software Developer"
    case systemsArchitect = "Systems Architect"
    case dataScience = "Data Science"
    case dataScientist = "Data Scientist"
    case networkSecurity = "Network Security"
    case cyberSecurityAnalyst = "Cyber Security Analyst"
    case aiSpecialist = "AI Specialist"
    case networkAdministrator = "Network Administrator"

    // Business
    case marketing = "Marketing"
    case finance = "Finance"
    case humanResources = "Human Resources"

    // Healthcare
    case surgery = "Surgery"
    case surgeon = "Surgeon"
    case pediatrics = "Pediatrics"
    case pediatrician = "Pediatrician"
    case generalPractitioner = "General Practitioner"
    case psychiatrist = "Psychiatrist"
    case cardiologist = "Cardiologist"
    case neurologist = "Neurologist"
    case nursepractitioner = "Nurse Practitioner"

    // Legal
    case litigation = "Litigation"
    case corporateLaw = "Corporate Law"
    case corporateLawyer = "Corporate Lawyer"
    case criminalLawyer = "Criminal Lawyer"
    case familyLawyer = "Family Lawyer"
    case patentAttorney = "Patent Attorney"

    // Engineering
    case electricalEngineering = "Electrical Engineering"
    case mechanicalEngineering = "Mechanical Engineering"

    // Education
    case teaching = "Teaching"
    case elementaryTeacher = "Elementary Teacher"
    case highSchoolTeacher = "High School Teacher"
    case professor = "Professor"
    case specialEducation = "Special Education"

    // General
    case administration = "Administration"
    case research = "Research"
    case design = "Design"
    case general = "General"
}
