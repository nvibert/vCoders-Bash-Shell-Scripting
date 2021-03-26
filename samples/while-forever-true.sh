#!/bin/bash

#
# Simple while loop that counts up to 10
#

#
# Step 1 : Set our counter "i" to zero (note no spaces)
#
i=0

#
# Step 2 : Print a start message
#
echo "The while loop is starting" 

#
# Step 3 : This will loop forever ...
#
while true
do
	echo "While loop will only stop when you Cntrl-C. Currently i is $i"
	#
	# Wait 1 second before continuing
	#
	sleep 1
	#
	# Increment the value of counter "i" in each pass.
	# The `quotes` is used for command substitution, meaning
	# whatever is inside is run as a command within the script.
	# expr evaluates an expression, such as an addition.
	# Result of command assigns a new value to "i"
	#
	i=`expr $i + 1`
done
