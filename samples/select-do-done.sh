#!/bin/bash

#
# Select statement which loops, and does different actions depending on input
# Normally used when there are multiple different choices that need handling
# Often used in conjunction with a case-esac statement, as is the case here
#

#
# A custom prompt for the select construct can be created using the PS3 environment variable
#

PS3="Enter a direction to travel using 1,2,3 or 4, or 5 to quit: "

select var in North South East West q
do

	case $var in
	
#
# This produces a numbered menu list of items, where the numbers
# are assigned to the items in the list of items in the select statement
#
# The $var variable is assigned to the corresponding item in the list
#
# The case statement is used to determine which action to take
#

		North) echo "You are now heading North"
		;;

		South) echo "You are now heading South"
		;;

		East) echo "You are now heading East"
		;;

		West) echo "You are now heading West"
		;;

#
# break is a special case-esac parameter which gracefully leaves the condition
#
		q) echo "You are now finished travelling"
		break
		;;
#
# * is the wildcard that catches every other entry
#
		*) echo "Unknown input option selected"
		exit
		;;
	esac
	
done
