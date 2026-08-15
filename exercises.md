# Exercise Suggestions: Creating Endpoints and Controllers

These exercises are designed to help you practice creating your own API endpoints and controllers using the `SeedGenerator.AllQuotes` data source in the project.

## Exercise 1: Create a GET Endpoint for All Quotes
- **Goal:** Implement a new endpoint that returns all quotes from `SeedGenerator.AllQuotes`.
- **Steps:**
  1. Add a new action method in an existing controller (e.g., `AdminController`) or create a new controller.
  2. The method should return the full list of quotes as JSON.
  3. Test the endpoint using Swagger.

## Exercise 2: Create a GET Endpoint for a Random Quote
- **Goal:** Implement an endpoint that returns a single random quote from `SeedGenerator.AllQuotes`.
- **Steps:**
  1. Add a new action method that selects a random quote from the list.
  2. Return the randomly selected quote as JSON.
  3. Test the endpoint to ensure it returns different quotes on multiple requests.

## Exercise 3: Create Your Own Quotes Controller
- **Goal:** Create a new controller called `QuotesController` with endpoints for quotes.
- **Steps:**
  1. Add a new controller file named `QuotesController.cs`.
  2. Implement at least two endpoints:
      - One to return all quotes.
      - One to return a random quote.
  3. (Optional) Add an endpoint to search for quotes containing a specific word or phrase.
  4. Register the new controller in your API and test all endpoints.

---

**Tip:** Use the `SeedGenerator.AllQuotes` property as your data source for all exercises. Check the SeedGenerate solution, in particular the project AppUsage, for details on how to use AllQuotes.
