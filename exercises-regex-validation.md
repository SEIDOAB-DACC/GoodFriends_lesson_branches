# Exercises: Relaxing `EnsureValidity()` RegEx Validation

**Related branch:** `19-input-validation`
**File to edit:** [Models/DTO/CuDto.cs](Models/DTO/CuDto.cs)
**Background reading:** [explanations.md](explanations.md)

## Why these exercises exist

The `EnsureValidity()` methods currently only allow the ASCII range `a-zA-Z0-9` (plus a
few punctuation marks). That's too strict for real data — the seed data in
[Models/SeedGenerator.cs](Models/SeedGenerator.cs) already contains Swedish city and
street names such as `Göteborg`, `Malmö`, `Örebro`, and `Äppelviksvägen`. As it stands,
if a real user tried to create a `Friend` living on `Äppelviksvägen` in `Malmö`, the
API would reject it with an `ArgumentException`, even though the data is perfectly
valid.

Your job in each exercise below is to widen the RegEx pattern(s) just enough to accept
realistic input, without opening the door to unsafe data (script injection, SQL
fragments, etc.). Keep validating — just validate the *right* set of characters.

> Tip: build and run the tests/manual requests after each change. Try both a
> **valid** Swedish/special-character example and an **invalid** example (e.g.
> `<script>`, `Robert'); DROP TABLE Friends;--`) to make sure your new pattern still
> blocks genuinely bad input.

## Test your RegEx at regexr.com

Before pasting a new pattern into `CuDto.cs`, try it out at
[regexr.com](https://regexr.com):

1. Paste your candidate pattern into the expression field.
2. Paste in a handful of test strings — both examples that should **pass**
   (e.g. `Björn`, `Göteborg`) and examples that should **fail** (e.g.
   `<script>`, `'; DROP TABLE`).
3. Only copy the pattern back into `EnsureValidity()` once regexr.com confirms
   it matches the valid cases and rejects the invalid ones.

This is much faster than rebuilding and calling the API for every tweak.

When answering, remember that C# escapes the pattern as a verbatim string
(`@"..."`), so a literal backslash in regexr.com (e.g. `\-`) is written the same
way inside the `@"..."` string in code.

---

## Exercise 1 — `FriendCuDto.FirstName` / `LastName`

**Current pattern:** `^[a-zA-Z0-9\s]*$`

**Problem:** Names like `Åsa`, `Björn`, `Anna-Lena`, and `O'Brien` are rejected.

**Task:**
1. Add the Swedish letters `å`, `ä`, `ö` (and uppercase `Å`, `Ä`, `Ö`) to the character class.
2. Allow a hyphen `-` for double names (`Anna-Lena`, `Karl-Johan`).
3. Allow an apostrophe `'` for names like `O'Brien`.

**Valid test input:** `Björn`, `Anna-Lena`, `O'Brien`
**Should still fail:** `Robert<script>`, `John;DROP TABLE`


---

## Exercise 2 — `AddressCuDto.StreetAddress`

**Current pattern:** `^[a-zA-Z0-9\s]*$`

**Problem:** `Äppelviksvägen 3`, `Drottninggatan 4A, lgh 1001`, and `Åsgatan 7-9` are all rejected.

**Task:**
1. Add Swedish letters `åäöÅÄÖ`.
2. Allow a hyphen `-` (house-number ranges like `7-9`).
3. Allow a comma `,` (apartment/floor info like `, lgh 1001`).
4. Allow a period `.` and forward slash `/` (abbreviations like `Sturegatan 3, 1 tr.` or `3/A`).

**Valid test input:** `Äppelviksvägen 3`, `Drottninggatan 4A, lgh 1001`
**Should still fail:** `<img src=x onerror=alert(1)>`

---

## Exercise 3 — `AddressCuDto.City`

**Current pattern:** `^[a-zA-Z0-9\s]*$`

**Problem:** `Göteborg`, `Malmö`, `Örebro`, and `Linköping` are all rejected.

**Task:**
1. Add Swedish letters `åäöÅÄÖ`.
2. Allow a hyphen `-` for compound city names (e.g. `Enköping-Norr`, real-world example: `Trollhättan-Vänersborg` region names).

**Valid test input:** `Göteborg`, `Malmö`, `Linköping`
**Should still fail:** `Malmö<script>alert(1)</script>`

---

## Exercise 4 — `AddressCuDto.Country`

**Current pattern:** `^[a-zA-Z0-9\s]*$`

**Problem:** Swedish spellings of country names, e.g. `Förenta staterna` are rejected because of `ö`/`ä`/`å`

**Task:**
1. Add Swedish letters `åäöÅÄÖ` to the character class.
2. Also allow parentheses for country names that include a qualifier, e.g.
   `Kongo (Kinshasa)`.

---

## Exercise 5 — `QuoteCuDto.Quote`

**Current pattern:** `^[a-zA-Z0-9\s.,!?']*$`

**Problem:** A Swedish quote such as `"Det är bättre att tända ett ljus än att förbanna mörkret."`
fails both because of the Swedish letters and because colons, semicolons,
parentheses, and dashes used in longer quotes aren't allowed.

**Task:**
1. Add Swedish letters `åäöÅÄÖ`.
2. Allow colon `:`, parentheses `()`, and hyphen/dash `-` for
   quotes that use them stylistically.

**Valid test input:** `Det är bättre att tända ett ljus än att förbanna mörkret.`
**Should still fail:** `"; DROP TABLE Quotes; --`

---

## Exercise 6 — `QuoteCuDto.Author`

**Current pattern:** `^[a-zA-Z0-9\s]*$`

**Problem:** `Åsa Larsson` fails (Swedish letters), and `J.R.R. Tolkien` fails
(periods used for initials), and `Marie-Louise Bern` fails (hyphenated first name).

**Task:**
1. Add Swedish letters `åäöÅÄÖ`.
2. Allow a period `.` for initials.
3. Allow a hyphen `-` for hyphenated names.

---

## Exercise 7 — `PetCuDto.Name`

**Current pattern:** `^[a-zA-Z0-9\s]*$`

**Problem:** Pet names like `Björn`, `Snö`, `Kitty-Cat`, and `D'Artagnan` are rejected.

**Task:**
1. Add Swedish letters `åäöÅÄÖ`.
2. Allow a hyphen `-` and apostrophe `'`.

---

Stuck? Check [answers-regex-validation.md](answers-regex-validation.md) for the
suggested pattern for each exercise.
