#!/bin/bash

#
# Simple for loop that counts up to 10
# 

#
# Step 1 : Print a start message
#
echo "The for loop is starting" 

#
# Step 2 : Loop with iterate "for" every number between 1 and 10
# The use of ".." here specifies a range between 2 values
#
for i in {1..10}
do
    echo "For loop will stop when i reaches 10. Currently i is $i"
	#
	# Wait 1 second before continuing
	#
	sleep 1
	#
done

#
# Step 3 : Print an end message
#
echo "The for loop is now finished" 