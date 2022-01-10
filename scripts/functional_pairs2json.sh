#!/bin/bash
#
# example usage: scripts/functional_pairs2json.sh < functional/mockpairs_20210630.tsv > src/server/populate-db/raw-data/connections/mockpairs_20210630.json
#
# 

TYP=4

echo "["
grep -v '0\.0$' | while read line; do
    PRE=$(awk '{print $1}' <<< $line)
    POST=$(awk '{print $2}' <<< $line)
    WEIGHT=$(awk '{print $3}' <<< $line)
    cat<<CONN
  ${LINE0}
  {
    "pre": "${PRE}",
    "post": "${POST}",
    "typ": ${TYP},
    "syn": [
      ${WEIGHT}
    ]
CONN
  LINE0="},"
done

cat<<END_CONN
  }
]
END_CONN
