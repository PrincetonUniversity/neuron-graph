# Functional data notes

## Filtering mock data

The mock data we received had many connections between nodes that did not exist
in the head and caused errors (see [issue #7](https://github.com/PrincetonUniversity/neuron-graph/issues/7)).

The list of valid head nodes is in
[`cell-info.js`](https://github.com/PrincetonUniversity/neuron-graph/blob/166e1af40e586c3b500945d66314b95e88ab17cd/src/client/js/cell-info.js#L15-L53).
This was dumped into two files, `functional/head_nodes_col1.txt` and
`functional/head_nodes_col2.txt` which are written as grep pattern matches.
Running `functional/filter_headnodes.sh` will take the
`functional/mockpairs_20210630.tsv` file and convert it to the filtered
`functional/liefer_2021_mock.tsv`.

## Add new mock data

Note that these steps result in a new json file in the file hierarchy which
when checked in, obviates the need to do the steps! But if importing new mock
data or updating one, this is how

1. reformat generated `pairwise.tsv` plaintext two-column format to json via
   `scripts/functional_pairs2json.sh` by redirecting stdin and stdout, writing
   result in the location suggested by `adding_new_data`,
   `src/server/populate-db/raw-data/connections/<mockpairs_DATE.json>` where
   `DATE` is of form `YYYYMMDD`

    **Example**

    ```bash
        scripts/functional_pairs2json.sh \
            < functional/liefer_2021_mock.tsv \
            > src/server/populate-db/raw-data/connections/liefer_2021_mock.json
    ```

    Note that `functional_pairs2json.sh` is a simplistic bash script that runs
    very slowly and is only a reference implementation.

2. Add a new entry to `src/server/populate-db/raw-data/datasets.json`. Using
   shorter legacy format with less fields, and even then they are not all
   meaningful, such as time (age). Note, the `"id"` must match the base name of
   json file created in step 1 above.

   * If this data is the first of a new type, we need to update the switch
     statement starting at line 30 of `populate-connections.js` in the same
     connections folder

3. run `npm run populate-database`
