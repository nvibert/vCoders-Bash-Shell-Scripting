#!/bin/bash

#
# Simple if-then-else statement
#

#
# Step 1 : Get a value to test - "read" gets input from command line
#

echo "Enter a number:"
read number

#
# Step 2 : Test the value of the number. Is it less than (-lt) 10,
# greater than (-gt) 10. If netiher, then it must be equal to 10.
#
# elif can be used to continue testing with the loop
#
# Note that there are [[ ]] around the expressions. Some shells
# will require this, some are ok with just a single [ ] pairing
# This is one of those shell nuances.
#

if [[ $number -lt 10 ]]
then
	echo "The number entered, $number, is less than 10"
elif [[ $number -gt 10 ]]
then
	echo "The number entered, $number, is greater than 10"
else
	echo "The number entered, $number, is equal to 10"
fi
