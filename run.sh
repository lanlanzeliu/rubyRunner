#!/bin/bash
echo -n ${SRC_JSON} | ruby ./runner.rb 1>stdout.txt 2>stderr.txt

# This checks if the size of the Standard Error file is greater than zero
if [ -s stderr.txt ]
then
   echo "Ruby Runner Failed"

   cat stderr.txt
else
   cat output.json
fi

# If using puts in runner.rb for testing, seeing what values are in there, uncomment out the stdout.txt so that you
# get those written out to the screen as well
# cat stdout.txt