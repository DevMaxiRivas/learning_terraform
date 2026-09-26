#!/bin/bash
export DB_INSTANCE=dn1234
echo $DB_INSTANCE

export FILE_PATH="./check_connection.py"

if [[ -f $FILE_PATH ]]; then
    echo "The file exists."
    python3 $FILE_PATH >> ./script.log 2>&1
else
    echo "The $FILE_PATH does not exist."
fi