#!/bin/bash
#
# example usage: scripts/functional_pairs2json.sh functional/mockpairs_20210630.tsv 50
#
# 50 = time where the marker will appear in the timeline

set -e

# Arguments
infile="$1"
name="$infile"
name=${name##*/}
name=${name%.*}
time=$2

TYP=4
outfile="src/server/populate-db/raw-data/connections/${name}.json"
tmpoutfile="${name}.json"
dsfile=src/server/populate-db/raw-data/datasets.json
dstmpfile=tmpdatasets.json

if [ $# -lt 2 ]; then
  time=25
fi
if [ "$time" = "" ] || [ $time -lt 1 ] || [ $time -gt 55 ]; then
  echo "ERROR: Invalid time [${time}]. Must be a number between 1 and 55."
  exit 2
fi

if [ "$name" == "" ]; then
  echo "ERROR: Could not parse name"
  exit 3
fi

if [ ! -f "$dsfile" ]; then
  echo "ERROR: Could not find the ${dsfile} file"
  exit 4
fi

echo "[" > $tmpoutfile
grep -v -E '[^0-9\.]0$' "$infile" | while read line; do
    PRE=$(awk '{print $1}' <<< $line)
    POST=$(awk '{print $2}' <<< $line)
    WEIGHT=$(awk '{print $3}' <<< $line)
    perl -e 'print STDERR (join(" ",@ARGV), "          \r")' "$PRE" "$POST" "$WEIGHT"
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
done >> $tmpoutfile

cat >> $tmpoutfile <<END_CONN
  }
]
END_CONN
mv "$tmpoutfile" "$outfile"
echo "JSON DONE                 "

echo "[" > $dstmpfile
cat >> $dstmpfile <<END_DS
   {
      "id": "${name}",
      "name": "${name}",
      "type": "head",
      "time": ${time},
      "visualTime": ${time},
      "description": "${name}"
   },
END_DS
grep -v '^.$' $dsfile >> $dstmpfile
echo "]" >> $dstmpfile

unset RESPONSE
read -p "Manually edit the entry automatically added to the datasets file? [y/n]: " -n1 RESPONSE;
if [ "$RESPONSE" = "y" ]; then
  vi "$dstmpfile"
fi
echo
mv "$dstmpfile" "$dsfile"

echo "DONE"
echo "Files created/edited:"
echo
echo "    ${outfile}"
echo "    ${dsfile}"
