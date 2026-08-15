# Models Project Analysis Exercise

## 📖 Prerequisites

Please thoroughly read the **5-models-explanation.md** file. 
Analyse Models project and specifically


### Models

1. Analyze the relationship between `IQuote` and `Quote` classes
2. Examine how the Models project integrates with other parts of the solution
3. Examine the `IEquatable<Quote>` implementation
   - Explain which properties are used for equality comparison
   - Discuss why `QuoteId` is NOT used in the equality comparison, what is the implication?

### Usage of Models in AppWebApi


1. **Models moved into separate project**
   - Compare to 4-logger branch and see how the class classes Quote and SeedGenerator are moved out of the AppWebApi project
   - Check `AppWebApi/AppWebApi.csproj` and identify the reference to Models project

2. **API Method Analysis** (15 points)
   - Find the `Quotes()` method in `AdminController.cs`
   - Identify the return type of the method
   - Explain why the method returns `List<IQuote>` instead of `List<Quote>`

3. **Object Creation Pattern** (10 points)
   - Analyze this code snippet from the controller:
     ```csharp
     var quotes = new SeedGenerator().AllQuotes
         .Select(goodQuote => new Quote(goodQuote))
         .ToList<IQuote>();
     ```
   - Explain each step of this transformation
   - Discuss why concrete `Quote` objects are created but cast to `IQuote`


