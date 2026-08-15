
# Navigation Properties in DbModels Project

This document explains in detail how navigation properties are implemented in all models within the `DbModels` project, focusing on Entity Framework Core (EFC) mapping strategies and the use of the `[NotMapped]` attribute.

---

## General Pattern

In the `DbModels` project, models often inherit from base classes or interfaces. Navigation properties are managed to:

- Allow EFC to map relationships using concrete types (e.g., `FriendDbM`)
- Allow the rest of the application to use abstractions (e.g., `IFriend`)

- Avoid EFC mapping errors by marking interface-based navigation properties with `[NotMapped]`
- Convert the concrete database relationship to an abstract relationship.
- Prevent unwanted serialization of concrete database relationship with `[JsonIgnore]`

---

## Model-by-Model Details


### AddressDbM

```csharp
[NotMapped] // removed from EFC
// The getter converts the concrete List<FriendDbM> to List<IFriend> so the rest of the app can use abstractions,
// even though EFC only maps the concrete FriendsDbM property.
public override List<IFriend> Friends { get => FriendsDbM?.ToList<IFriend>(); set => new NotImplementedException(); }

[JsonIgnore] // do not include in any json response from the WebApi
public List<FriendDbM> FriendsDbM { get; set; } = null;
```

- **[NotMapped]**: Prevents EFC from mapping the interface-based `Friends` property.
- **Concrete Navigation**: `FriendsDbM` is mapped by EFC and used for database relationships.
- **Convert Navigation to Abstraction** Convert the concrete database relationship to an abstract relationship.
- **Purpose**: Allows the application to work with `IFriend` while EFC works with `FriendDbM`.

---


### FriendDbM

```csharp
[NotMapped]
// The getter returns the concrete AddressDbM as IAddress, so the app can use the abstraction while EFC only maps AddressDbM.
public override IAddress Address { get => AddressDbM; set => new NotImplementedException(); }

[JsonIgnore]
[ForeignKey("AddressId")]
public AddressDbM AddressDbM { get; set; } = null;

[NotMapped]
// The getter converts the concrete List<PetDbM> to List<IPet> for abstraction use in the app.
public override List<IPet> Pets { get => PetsDbM?.ToList<IPet>(); set => new NotImplementedException(); }

[JsonIgnore]
public List<PetDbM> PetsDbM { get; set; } = null;

[NotMapped]
// The getter converts the concrete List<QuoteDbM> to List<IQuote> for abstraction use in the app.
public override List<IQuote> Quotes { get => QuotesDbM?.ToList<IQuote>(); set => new NotImplementedException(); }

[JsonIgnore]
public List<QuoteDbM> QuotesDbM { get; set; } = null;
```

- **[NotMapped]**: Used on all interface-based navigation properties (`Address`, `Pets`, `Quotes`).
- **Concrete Navigation**: EFC maps `AddressDbM`, `PetsDbM`, and `QuotesDbM` for relationships.
- **Convert Navigation to Abstraction** Convert the concrete database relationship to an abstract relationship.
- **Purpose**: Ensures correct object graphs and EFC compatibility.

---


### PetDbM

```csharp
[ForeignKey("FriendId")]
[JsonIgnore]
public FriendDbM FriendDbM { get; set; } = null;

[NotMapped]
// The getter returns the concrete FriendDbM as IFriend, so the app can use the abstraction while EFC only maps FriendDbM.
public override IFriend Friend { get => FriendDbM; set => new NotImplementedException(); }
```

- **[NotMapped]**: Prevents EFC from mapping the interface-based `Friend` property.
- **Concrete Navigation**: EFC maps `FriendDbM` for the relationship.
- **Convert Navigation to Abstraction** Convert the concrete database relationship to an abstract relationship.
- **Purpose**: Allows the application to use `IFriend` while EFC uses `FriendDbM`.

---


### QuoteDbM

```csharp
[NotMapped]
// The getter converts the concrete List<FriendDbM> to List<IFriend> so the rest of the app can use abstractions,
// even though EFC only maps the concrete FriendsDbM property.
public override List<IFriend> Friends { get => FriendsDbM?.ToList<IFriend>(); set => new NotImplementedException(); }

[JsonIgnore]
public List<FriendDbM> FriendsDbM { get; set; } = null;
```

- **[NotMapped]**: Prevents EFC from mapping the interface-based `Friends` property.
- **Concrete Navigation**: EFC maps `FriendsDbM` for the relationship.
- **Convert Navigation to Abstraction** Convert the concrete database relationship to an abstract relationship.
- **Purpose**: Ensures correct object graphs and EFC compatibility.

---

## Why Use This Pattern?

- **[NotMapped]**: Prevents EFC from attempting to map properties it cannot handle (like interface-based lists or properties).
- **Concrete Navigation**: Ensures EFC can create the correct foreign key relationships and load related entities.
- **Convert Navigation to Abstraction** Convert the concrete database relationship to an abstract relationship.
- **Object Graph Consistency**: The interface-based property allows the rest of the application to work with abstractions, while the concrete property ensures correct data loading and persistence.
- **[JsonIgnore]**: Prevents unwanted serialization of concrete database relationship

---

## Conclusion

By combining `[NotMapped]` on interface-based navigation properties with concrete navigation properties for EFC, the `DbModels` project achieves both clean domain abstractions and correct database relationships. This approach is essential when working with inheritance and interfaces in EFC models.
