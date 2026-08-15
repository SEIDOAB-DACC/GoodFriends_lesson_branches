# Exercise: Extending the GoodFriends Project with a Credit Card Model

This exercise will guide you through extending the current codebase (branch `8-extensions`) by adding a new Credit Card model and integrating it into the data access layer. Finally we will remove the Quote Models

## Prerequisites
- You have cloned the repository and checked out the `8-extensions` branch.
- You have a working .NET development environment.

---

## Steps

### 1. Create a New Feature Branch
Create a new branch from `8-extensions` for your work. Name it `8a-extensions-creditcard`

---

### 2. Create new User-Secrets
- Open your current User Secrets secrets.json file. On Configuration/Configuration.csproj right click -> Manage User Secrets
  Double click on the tab secrets.json to make sure the file stays open
- In Configuration/Configuration.csproj remove the tag  <UserSecretsId>....</UserSecretsId>. Save the file
- Open new empty User Secrets secrets.json file. On Configuration/Configuration.csproj right click -> Manage User Secrets
- Replace the entire content of the empty secrets.json with the entire content of the old secrets.json

---

### 3. Rename the database

- In readme-clr1.txt, database-rebuild-all.ps, database-rebuild-all.sh, appsettings.json, secrets.json file rename `sql-friends`to name `sql-creditcards`

---

### 4. Add a Credit Card Model
Create interface `ICreditCard.cs` in the `Models/` folder.
Create a new model class `CreditCard.cs` in the `Models/` folder with the ISeed<> implemented. Example:

```csharp
public class CreditCard : ICreditCard, ISeed<CreditCard>
{
    public virtual Guid CreditCardId { get; set; }

    public CardIssues Issuer { get; set; }
    public string Number { get; set; }
    public string ExpirationYear { get; set; }
    public string ExpirationMonth { get; set; }    

    public string CardHolderName { get; set; }

    public string EncryptedToken { get; set; } //AES encrypted version of the cc

    #region Seeder
    public bool Seeded { get; set; } = false;

    public CreditCard Seed (SeedGenerator seeder)
    {
        Seeded = true;
        CreditCardId = Guid.NewGuid();
        
        Issuer = seeder.FromEnum<CardIssues>();

        Number = $"{seeder.Next(2222, 9999)}-{seeder.Next(2222, 9999)}-{seeder.Next(2222, 9999)}-{seeder.Next(2222, 9999)}";
        ExpirationYear = $"{seeder.Next(25, 32)}";
        ExpirationMonth = $"{seeder.Next(01, 13):D2}";


        CardHolderName = seeder.FullName;
        return this;
    }
    #endregion
}
```
---

### 5. Add a Corresponding DbModel
Create a new class `CreditCardDbM.cs` in the `DbModels/` folder. The class shall inherit from CreditCard Model and override the EGC specific properties. 
Implement ISeed<> by simply calling the Seed method of the base class. Example:

```csharp
public class CreditCardDbM : CreditCard, ISeed<CreditCardDbM>
{
    [Key]
    public override Guid CreditCardId { get; set; }

    public new CreditCardDbM Seed(SeedGenerator seeder)
    {
        base.Seed(seeder);
        return this;
    }
}
```
---

### 6. Register the DbSet in DbContext
In `DbContext/MainDbContext.cs`, add a `DbSet<CreditCardDbM>` property:

```csharp
    public DbSet<CreditCardDbM> CreditCards { get; set; }
```

---

### 7. Seed the Credit Card DbModel
In `DbRepos/AdminDbRepos.cs`, update the `SeedAsync` method to seed `nrItems` `CreditCardDbM` instance. Example:

```csharp
// ...existing code...
        var creditcards = seeder.ItemsToList<CreditCardDbM>(nrItems);
        _dbContext.CreditCards.AddRange(creditcards);
// ...existing code...
```

---

### 8. Build and Test
- Build the solution and ensure no errors
- Follow the instructions in readme-clr1.txt to build the databases and run the application and verify the new model is seeded.

---

### 9. Remove all template models
- remove Quote, IQuote from Models 
- remove QuoteDbM from DbModels  
- remove QuoteDbM registration in DbContext/MainDbContext
- remove QuoteDbM Seeding in DbRepos/AdminDbRepos.SeedAsync.
- Build the solution and ensure no errors
- Follow the instructions in readme-clr1.txt to build the databases and run the application and verify the new model is seeded.

---

### 10. Make a new standalone solution from the branch
USE File explorer
- Copy the entire solution folder GoodFriends_lesson_branches
- Rename the new folder to CreditCards
- Delete the .git folder in CreditCards

USE Visual Studio Code
- Open the folder CreditCards
- Delete the file GoodFriends.code-workspace
- Create a new Workspace using File->Save Workspace As...
- Rename file GoodFriends.sln to CreditCards.sln 
- Rename GoodFriends.sln to CreditCards.slnin in tasks.json
- Make an intial git commit
- Publish your repo to your gitub


---

## Deliverables
- A new standalone solution from the brancn with above changes
---
