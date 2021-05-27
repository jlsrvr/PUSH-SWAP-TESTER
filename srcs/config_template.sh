#!/bin/bash

###################################
#     Mandatory configuration     #
###################################

#Edit the next line with the path of your push_swap project.
PATH_TO_PUSH_SWAP=REPLACE_THIS_WITH_THE_CORRECT_PATH

#If you use a relative path, don't put double quotes.
#For example :
#PATH_TO_PUSH_SWAP=~/push_swap		==> Right
#PATH_TO_PUSH_SWAP="~/push_swap"	==> Wrong

#If you encounter some problems with a relative path, use an absolute path.
#You can put double quotes with the absolute path.
#For example :
#PATH_TO_PUSH_SWAP=/home/user/push_swap	==> Right
#PATH_TO_PUSH_SWAP="/home/user/push_swap"	==> Right

###################################
#     Optionnal configuration     #
###################################

#By default, the max number of actions is set to score 4 points for stacks of size 100 and 500.
#Edit the next line to change the scale for 100 numbers.
#Less than | Points
#   700    |  5
#   900    |  4
#   1100   |  3
#   1300   |  2
#   1500   |  1
one_hundred_max=900
#Edit the next line to change the scale for 500 numbers.
#Less than | Points
#   5500   |  5
#   7000   |  4
#   8500   |  3
#   10000  |  2
#   11500  |  1
five_hundred_max=7000
#By default, the average will be taken over 25 runs of the function.
#Edit the next line to change the number of runs over which the average is taken.
number_of_runs=25
