# RegEx Validation Documentation

This document explains all the Regular Expression (RegEx) checks and validation patterns used in the GoodFriends application for input validation and data integrity.

## Table of Contents
1. [Controller Validations](#controller-validations)
2. [DTO EnsureValidity Methods](#dto-ensurevalidity-methods)
3. [RegEx Pattern Explanations](#regex-pattern-explanations)
4. [Best Practices](#best-practices)

## Controller Validations

### AddressesController.Read Method
**Location:** `AppWebApi/Controllers/AddressesController.cs` (Line ~37)

```csharp
// RegEx check to ensure filter only contains a-z, 0-9, and spaces
if (!string.IsNullOrEmpty(filter) && !Regex.IsMatch(filter, @"^[a-zA-Z0-9\s]*$"))
{
    throw new ArgumentException("Filter can only contain letters (a-z), numbers (0-9), and spaces.");
}
```

**Purpose:** Validates the filter parameter in the Read API endpoint to prevent injection attacks and ensure only safe characters are used for filtering.

**Pattern:** `^[a-zA-Z0-9\s]*$`
- **Allowed Characters:** Letters (a-z, A-Z), numbers (0-9), and spaces
- **Security:** Prevents SQL injection and other malicious input

## DTO EnsureValidity Methods

The `EnsureValidity()` methods in various DTO classes provide comprehensive input validation before data processing.

### FriendCuDto Validation
**Location:** `Models/DTO/CuDto.cs` (Line ~40)

#### FirstName and LastName Validation
```csharp
if (!string.IsNullOrEmpty(FirstName) && !Regex.IsMatch(FirstName, @"^[a-zA-Z0-9\s]*$"))
{
    throw new ArgumentException("FirstName can only contain letters (a-z), numbers (0-9), and spaces.");
}
```

**Pattern:** `^[a-zA-Z0-9\s]*$`
- **Purpose:** Ensures names contain only alphanumeric characters and spaces
- **Rationale:** Allows for names with numbers (e.g., "John Jr. 3rd") while preventing special characters that could cause issues

#### Email Validation
```csharp
if (!string.IsNullOrEmpty(Email) && !Regex.IsMatch(Email, @"^[^@\s]+@[^@\s]+\.[^@\s]+$"))
{
    throw new ArgumentException("Email has to be a valid email address.");
}
```

**Pattern:** `^[^@\s]+@[^@\s]+\.[^@\s]+$`
- **Purpose:** Validates basic email format
- **Breakdown:**
  - `[^@\s]+` - One or more characters that are NOT @ or whitespace (local part)
  - `@` - Literal @ symbol
  - `[^@\s]+` - One or more characters that are NOT @ or whitespace (domain name)
  - `\.` - Literal dot
  - `[^@\s]+` - One or more characters that are NOT @ or whitespace (top-level domain)

#### Birthday Validation
```csharp
if (Birthday.HasValue)
{
    var dateString = Birthday.Value.ToString("yyyy-MM-dd");
    var parsedDate = DateTime.Parse(dateString);
    
    if (parsedDate != Birthday.Value || parsedDate.Year < 1900 || parsedDate > DateTime.Now)
    {
        throw new ArgumentException("Birthday must be a valid date in the past (after 1900) or null.");
    }
}
```

**Purpose:** Ensures Birthday is a valid date using DateTime.Parse validation
- **Validates:** Date exists and is parseable
- **Range Check:** Must be after 1900 and not in the future
- **Nullable:** Allows null values

### AddressCuDto Validation
**Location:** `Models/DTO/CuDto.cs` (Line ~93)

#### Address Fields Validation
```csharp
if (!string.IsNullOrEmpty(StreetAddress) && !Regex.IsMatch(StreetAddress, @"^[a-zA-Z0-9\s]*$"))
{
    throw new ArgumentException("StreetAddress can only contain letters (a-z), numbers (0-9), and spaces.");
}
```

**Pattern:** `^[a-zA-Z0-9\s]*$` (same for City and Country)
- **Purpose:** Ensures address components contain only safe characters
- **Allows:** Letters, numbers, and spaces for international address compatibility

#### ZipCode Validation
```csharp
if (ZipCode <= 0) throw new ArgumentException("ZipCode has to be larger than zero");
```

**Purpose:** Ensures ZipCode is a positive integer

### PetCuDto Validation
**Location:** `Models/DTO/CuDto.cs` (Line ~134)

#### Pet Name Validation
```csharp
if (!string.IsNullOrEmpty(Name) && !Regex.IsMatch(Name, @"^[a-zA-Z0-9\s]*$"))
{
    throw new ArgumentException("Name can only contain letters (a-z), numbers (0-9), and spaces.");
}
```

**Pattern:** `^[a-zA-Z0-9\s]*$`
- **Purpose:** Validates pet names using the same safe character set

#### Enum Validations
```csharp
if (!Enum.IsDefined(typeof(AnimalKind), Kind)) throw new ArgumentException("Kind has to be set to a valid value");
if (!Enum.IsDefined(typeof(AnimalMood), Mood)) throw new ArgumentException("Mood has to be set to a valid value");
```

**Purpose:** Ensures enum values are valid and defined in the respective enumerations

### QuoteCuDto Validation
**Location:** `Models/DTO/CuDto.cs` (Line ~167)

#### Quote Text Validation
```csharp
if (!string.IsNullOrEmpty(Quote) && !Regex.IsMatch(Quote, @"^[a-zA-Z0-9\s.,!?']*$"))
{
    throw new ArgumentException("Quote can only contain letters (a-z), numbers (0-9), spaces, and punctuation (.,!?').");
}
```

**Pattern:** `^[a-zA-Z0-9\s.,!?']*$`
- **Purpose:** Allows quotes to contain common punctuation for natural language
- **Allowed Punctuation:** Period (.), comma (,), exclamation (!), question (?), apostrophe (')
- **Rationale:** Quotes need punctuation for proper grammar and meaning

#### Author Validation
```csharp
if (!string.IsNullOrEmpty(Author) && !Regex.IsMatch(Author, @"^[a-zA-Z0-9\s]*$"))
{
    throw new ArgumentException("Author can only contain letters (a-z), numbers (0-9), and spaces.");
}
```

**Pattern:** `^[a-zA-Z0-9\s]*$`
- **Purpose:** Validates author names using the standard safe character set

## RegEx Pattern Explanations

### Common Pattern: `^[a-zA-Z0-9\s]*$`
- `^` - Start of string anchor
- `[a-zA-Z0-9\s]` - Character class containing:
  - `a-z` - Lowercase letters
  - `A-Z` - Uppercase letters
  - `0-9` - Digits
  - `\s` - Whitespace characters (spaces, tabs, newlines)
- `*` - Zero or more of the preceding character class
- `$` - End of string anchor

### Extended Pattern: `^[a-zA-Z0-9\s.,!?']*$`
Same as above, plus:
- `.` - Period
- `,` - Comma
- `!` - Exclamation mark
- `?` - Question mark
- `'` - Apostrophe/single quote

### Email Pattern: `^[^@\s]+@[^@\s]+\.[^@\s]+$`
- `[^@\s]` - Negated character class (anything except @ and whitespace)
- `+` - One or more of the preceding character class
- `@` - Literal @ symbol
- `\.` - Escaped period (literal dot)

## Best Practices

### Security Considerations
1. **Input Sanitization:** All user inputs are validated before processing
2. **Injection Prevention:** RegEx patterns prevent SQL injection and XSS attacks
3. **Consistent Patterns:** Similar fields use the same validation patterns for consistency

### Validation Strategy
1. **Null Checks:** All validations check for null/empty before applying RegEx
2. **Clear Error Messages:** Each validation provides specific, user-friendly error messages
3. **Exception Handling:** Uses `ArgumentException` for validation failures
4. **DateTime Validation:** Uses `DateTime.Parse` for robust date validation

### Maintenance Guidelines
1. **Pattern Updates:** When adding new allowed characters, update both the RegEx and error message
2. **Documentation:** Keep this document updated when validation rules change
3. **Testing:** Ensure all validation patterns are thoroughly tested with edge cases
4. **Consistency:** Use the same patterns across similar fields for user predictability

## Error Handling
All validation methods throw `ArgumentException` with descriptive messages that:
- Clearly state what went wrong
- Specify what characters/values are allowed
- Provide guidance for correcting the input

This approach ensures consistent error handling throughout the application and provides clear feedback to API consumers.