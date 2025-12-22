# ISO3166 Cumulus Account to Account Workflow

## Purpose
This workflow synchronizes geographic data from Cumulus Accounts to their parent Accounts in Dynamics 365. It identifies the highest MRR (Monthly Recurring Revenue) Cumulus Account for each Account and copies the country information from that Cumulus Account to the parent Account record. The workflow implements caching to optimize performance by reducing redundant database lookups for country records.

## Workflow Steps

### 1. Initialization Phase
- **Initialize Country Cache**: Creates an empty object variable (`varCountryCache`) to store country GUID lookups indexed by ISO alpha-2 country codes
- **Initialize Subdivision Cache**: Creates an empty object variable (`varSubdivisionCache`) to store subdivision GUID lookups by composite key (currently unused in the flow)

### 2. Data Retrieval
- **List Accounts with Cumulus Accounts**: Queries the Dynamics 365 database to retrieve up to 10 Account records that have associated Cumulus Accounts. The query selects: `accountid`, `name`, `revops_country`, and `revops_stateorprovince` fields

### 3. Processing Loop (For Each Account)
For each Account returned in the query:

#### 3.1 Get Cumulus Account Data
- **Get Highest MRR Cumulus Account**: Retrieves the Cumulus Account with the highest MRR value associated with the current Account, including ISO 3166 country and subdivision codes

#### 3.2 Conditional Processing
- **Check if Cumulus Account Found**: Verifies that a Cumulus Account was returned
  - If **NO**: Skip to next Account
  - If **YES**: Continue processing

#### 3.3 Extract Geographic Data
- **Compose Cumulus Data**: Extracts the `CountryAlpha2` and `SubdivisionCode` from the Cumulus Account for easier reference

#### 3.4 Country Lookup with Caching
- **Check Country Cache**: Determines if the country GUID for this country code is already cached
  
  **If Cached (YES branch)**:
  - **Get Cached Country**: Retrieves the country GUID from the cache variable
  
  **If Not Cached (NO branch)**:
  - **Get Country**: Queries the `revops_countries` table to find the country record matching the ISO country code
  - **Check if Country Found**: Verifies a country record was returned
    - If **YES**: **Cache Country** - Adds the country GUID to the cache using `addProperty()` for future iterations
    - If **NO**: Continue without caching

#### 3.5 Update Account Record
- **Update Account**: Updates the Account record's `revops_country` lookup field with the country GUID (either from cache or from the database query), using OData binding

### 4. Completion
- The workflow completes after processing all Accounts in the batch

## Key Features
- **Performance Optimization**: Implements in-memory caching to avoid repeated database queries for the same country codes
- **Prioritization Logic**: Uses the highest MRR Cumulus Account as the authoritative source for geographic data
- **Batch Processing**: Processes up to 10 Accounts per execution (configurable via `$top` parameter)