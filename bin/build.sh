#!/bin/bash
set -eo pipefail
DDL_FILENAME=${1:-ddl.sql}
DML_FILENAME=${2:-dml.sql}
REVISION=$(git rev-parse HEAD | cut -b 1-7)

echo "Building ${DDL_FILENAME} @ ${REVISION}"

# Build the DDL from the MANIFEST file
echo "-- Auto-constructed DDL file from version ${REVISION}" > ${DDL_FILENAME}
echo "" >> ${DDL_FILENAME}
while read file; do
  if [[ $file != --* ]] && [[ $file != "" ]]
  then
    cat $file >> ${DDL_FILENAME}
    echo "" >> ${DDL_FILENAME}
  fi
done <MANIFEST

echo "Bulding ${DML_FILENAME} @ ${REVISION}"
echo "-- Auto-constructed DDL file from version ${REVISION}" > ${DML_FILENAME}
echo "" >> ${DML_FILENAME}
find dml/ -type f -name "*.sql" -exec cat {} >> ${DML_FILENAME} \;
