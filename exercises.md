# Exercises: Loosely Coupled Customer and CreditCard Models, Service, and Controller

## Purpose
These exercises will guide you through creating a loosely coupled model of a `Customer` containing `FirstName`, `LastName`, and credit card info, with `CreditCard` as a separate model. You will also create a service to provide a list of Customer with creditcard information and a controller (`CustomerController`) with two endpoints: one returning credit card info in clear text, and one with encrypted credit card info.

---

## Exercise 1: Define the Models

1. **Create interfaces for loose coupling**
   - Create an `ICreditCard` interface with properties: `CardNumber`, `ExpiryMonth`, `ExpiryYear` (all as strings).
   - Create an `ICustomer` interface with properties: `FirstName`, `LastName` (strings), and a `CreditCard` property (of type `ICreditCard`).
2. **Create a `CreditCard` model**
   - Properties: `CardNumber`, `ExpiryMonth`, `ExpiryYear` (all as strings).
   - Implement the `ICreditCard` interface.
3. **Create a `Customer` model**
   - Properties: `FirstName`, `LastName` (strings), and a `CreditCard` property (of type `ICreditCard`).
   - Implement the `ICustomer` interface.
   - Ensure the models are in the Models project.

---

## Exercise 2: Create a Service

1. **Define an interface `ICustomerService`**
   - Method: `List<ICustomer> GetCustomers(int nrItems)`
2. **Implement the service as `CustomerService`**
   - Return a randomly seeded list of a number of Customers (nrItems), each with credit card info.
   - Register the service for dependency injection.

   - hint: to generate CreditCard info
        
        Given an enum type CardIssuer (you can put this type in the same file as you have ICreditCard)
        public enum CardIssuer {AmericanExpress, Visa, MasterCard, DinersClub}

        Issuer = seeder.FromEnum<CardIssuer>();

        Number = $"{seeder.Next(2222, 9999)}-{seeder.Next(2222, 9999)}-{seeder.Next(2222, 9999)}-{seeder.Next(2222, 9999)}";
        ExpirationYear = $"{seeder.Next(25, 32)}";
        ExpirationMonth = $"{seeder.Next(01, 13):D2}";


---

## Exercise 3: Create the Controller

1. **Create a `CustomerController`**
   - Inject `ICustomerService` via constructor.
2. **Add endpoint `/api/Customer/clear`**
   - Returns the list of Customer with credit card info in clear text.
3. **Add endpoint `/api/Customer/encrypted`**
   - Returns the same list of Customer, but with credit card info encrypted, use Encryptions AesEncryptToBase64 to encrypt the credit card class.

---

## Test Your Endpoints
- Use Swagger or Postman to verify both endpoints return the expected data.
- Discuss the importance of not exposing sensitive data in clear text in real applications.

---

**Tip:** Focus on keeping models, services, and controllers loosely coupled, in separate projects, by using interfaces and dependency injection.
