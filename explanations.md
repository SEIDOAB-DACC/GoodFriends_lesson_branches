# Annotations in DbModels Project

This document explains how data annotations are used in the models within the `DbModels` project. These annotations are attributes applied to classes and properties to control how they are mapped to the database and how validation is performed.

## 1. [Table]
- **Purpose:** Specifies the database table and schema that the class maps to.
- **Usage Example:**
  ```csharp
  [Table("Pets", Schema = "supusr")]
  sealed public class PetDbM : Pet { ... }
  ```
- **Explanation:** This tells Entity Framework to map the `PetDbM` class to the `Pets` table in the `supusr` schema.

## 2. [Key]
- **Purpose:** Marks a property as the primary key of the table.
- **Usage Example:**
  ```csharp
  [Key]
  public override Guid PetId { get; set; }
  ```
- **Explanation:** This designates `PetId` as the primary key for the `Pets` table.

## 3. [Required]
- **Purpose:** Indicates that a property is mandatory (cannot be null).
- **Usage Example:**
  ```csharp
  [Required]
  public override string Name { get; set; }
  ```
- **Explanation:** The `Name` property must have a value; it cannot be null in the database.

## 4. [Index]
- **Purpose:** Creates a database index on one or more properties to improve query performance and/or enforce uniqueness.
- **Usage Example (from AddressDbM):**
  ```csharp
  [Index(nameof(StreetAddress), nameof(ZipCode), nameof(City), nameof(Country), IsUnique = true)]
  sealed public class AddressDbM : Address, IEquatable<AddressDbM> { ... }
  ```
- **Explanation:**
  - This annotation creates a composite index on the `StreetAddress`, `ZipCode`, `City`, and `Country` columns in the `Addresses` table.
  - The `IsUnique = true` parameter enforces that the combination of these four fields must be unique for every row, preventing duplicate addresses in the database.
  - Using `[Index]` on the class level (as in `AddressDbM`) is supported in Entity Framework Core 5.0 and later.

## 5. [ForeignKey("FriendId")]
- **Purpose:** Specifies that a property is a foreign key in a relationship.
- **Usage Example (from PetDbM):**
  ```csharp
  [JsonIgnore]
  public Guid FriendId { get; set; }  // The foreign key property

  [ForeignKey("FriendId")]
  [JsonIgnore]
  public FriendDbM FriendDbM { get; set; }
  ```
- **Explanation:**
  - The `[ForeignKey("FriendId")]` annotation tells Entity Framework that the `FriendDbM` navigation property is linked via the `FriendId` foreign key.
  - **Important:** The property `FriendId` must be implemented in the model for the foreign key relationship to work. Entity Framework uses this property to create the foreign key constraint in the database and to manage the relationship between `PetDbM` and `FriendDbM`.

---

## Summary Table
| Annotation                | Purpose                                      |
|---------------------------|----------------------------------------------|
| [Table]                   | Maps class to a specific table/schema        |
| [Key]                     | Marks property as primary key                |
| [Required]                | Makes property non-nullable                  |
| [Index]                   | Adds a database index                        |
| [ForeignKey("...")]       | Defines foreign key relationship             |

These annotations help define the structure, relationships, and constraints of your database directly in your C# model classes, making your code more maintainable and expressive.
