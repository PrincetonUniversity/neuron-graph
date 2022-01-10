# Functional data notes

## Add new mock data
Note that these steps result in a new json file in the file hierarchy which
when checked in, obviates the need to do the steps! But if importing new
mock data or updating one, this is how

1. reformat generated "pairwise.tsv" plaintext two-column format to json via scripts/functional_pairs2json.sh by redirecting stdin and stdout, writing result in the location suggested by adding_new_data, src/server/populate-db/raw-data/connections/<mockpairs_DATE.json> where DATE is of form YYYYMMDD

### Example

`scripts/functional_pairs2json.sh < functional/mockpairs_20210630.tsv > src/server/populate-db/raw-data/connections/mockpairs_20210630.json`

Note that functional_pairs2json.sh is a simplistic bash script that runs very slowly and is only a reference implementation.

2. add a new entry to src/server/populate-db/raw-data/datasets.json. Using shorter legacy format with less fields, and even then they are not all meaningful, such as time (age)

2a. when is first of a new typ need to update the switch statement starting at line 30 of "populate-connections.js" in the same connections folder

3. run `npm run populate-database`

