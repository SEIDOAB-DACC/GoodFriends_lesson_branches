# Answers: Relaxing `EnsureValidity()` RegEx Validation

Hints for [exercises-regex-validation.md](exercises-regex-validation.md). Try to solve
each exercise yourself (and test it at [regexr.com](https://regexr.com)) before
checking here.

## Exercise 1 — `FriendCuDto.FirstName` / `LastName`

```
^[a-zA-ZåäöÅÄÖ0-9\s'-]*$
```

## Exercise 2 — `AddressCuDto.StreetAddress`

```
^[a-zA-ZåäöÅÄÖ0-9\s,.\-\/]*$
```

## Exercise 3 — `AddressCuDto.City`

```
^[a-zA-ZåäöÅÄÖ0-9\s-]*$
```

## Exercise 4 — `AddressCuDto.Country`

```
^[a-zA-ZåäöÅÄÖ0-9\s()]*$
```

## Exercise 5 — `QuoteCuDto.Quote`

```
^[a-zA-ZåäöÅÄÖ0-9\s.,!?'\-:;()]*$
```

## Exercise 6 — `QuoteCuDto.Author`

```
^[a-zA-ZåäöÅÄÖ0-9\s.\-]*$
```

## Exercise 7 — `PetCuDto.Name`

```
^[a-zA-ZåäöÅÄÖ0-9\s'-]*$
```
