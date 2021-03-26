#!/bin/bash

#
# Simple case statement that does different actions depending on input
# Normally used when there are multiple different choices that need handling
#

#
# Step 1 : Input a value
#
echo "Enter a value between 1-4, or q to quit"
read var

#
# Step 2 : Print a start message
#
echo "The case statement is starting"

#
# Step 3 : Do an action based on inputted value
#
case $var in
#
# This has been greatly simplified as we just reply
# with a statement that matches the input. However
# it should be obvious that each of the case conditions
# could be greatly extended to do major actions.
#
	1) echo "You selected option 1"
	;;
	2) echo "You selected option 2"
	;;
	3) echo "You selected option 3"
	;;
	4) echo "You selected option 4"
	;;
	q) echo "You selected q to quit"
	exit
	;;
	*) echo "Unknown input option >> $var << selected"
	exit
	;;
esac

#
# Step 4 : Print a stop message - will only happen if program does not exit
#
echo "The case statement is stopping"
