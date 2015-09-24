#!/bin/bash

#
# Copyright (C) 2015 University of Chicago.
# See COPYRIGHT notice in top-level directory.
#

# change behavior of shell error code following failure of a piped command
set -o pipefail

if [ $# -ne 2 ]; then
    echo "Usage: darshan-summary-per-file.sh <input_file.gz> <output_directory>"
    exit 1
fi

# count number of files present in log
filecount=`darshan-parser --file-list $1| egrep -v '^(#|$)' | cut -f 1-2 | uniq | wc -l`
rc=$?
if [ $rc -ne 0 ]; then
   exit $rc
fi

# create output file directory
mkdir $2
rc=$?
if [ $rc -ne 0 ]; then
   exit $rc
fi

# loop through all files in log
counter=0
darshan-parser --file-list $1| egrep -v '^(#|$)' | cut -f 1-2 | uniq |
while read -r hash suffix stuff ; do
        counter=$((counter+1))
	file=$(basename $suffix)
	if [ -x $file.gz ] ; then
		$file = $file.$hash.gz
	fi
        echo Status: Generating summary for file $counter of $filecount: $file
        echo =======================================================
	darshan-convert --file $hash $1 $2/$file.gz
        rc=$?
        if [ $rc -ne 0 ]; then
           exit $rc
        fi
	darshan-job-summary.pl $2/$file.gz --output $2/$file.pdf
        rc=$?
        if [ $rc -ne 0 ]; then
           exit $rc
        fi
done 

echo =======================================================
echo darshan-summary-per-file.sh done.  Results can be found in $2/\*.pdf.
