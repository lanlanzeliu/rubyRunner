#!/bin/bash
if (echo -n ${SRC_JSON} | ruby ./runner.rb 1>stdout.txt 2>stderr.txt) then
   cat output.json
else
   stdout=$(cat stdout.txt)
   stderr=$(cat stderr.txt)
   cat << EOD > output.json
{
	"message": "runner failed!",
	"output": [
		"$stdout",
		"$stderr"
	]
}
EOD
cat output.json
fi
