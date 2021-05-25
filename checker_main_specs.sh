RED="\033[31m"
GREEN="\033[32m"
PINK="\033[35m"
CYAN="\033[36m"
BOLD="\033[1m"
UNDER="\033[4m"
BLINK="\033[5m"
RESET="\033[m"

clean=$1
declare -i test_number=0;

test () {
	describe=$1
	stack=$2
	instructions=$3
	test_number+=1

	printf "\n${BOLD}${describe} :\n${RESET}"
	printf $instructions | ../srcs/checker ${stack} > outputs/${test_number}_test_output
	diff -u outputs/${test_number}_output outputs/${test_number}_test_output
	RESULT=$?
	if [ ${RESULT} -eq 0 ]
	then
		printf "${GREEN}${BOLD}OK${RESET} see behaviour at: ${test_number}_output\n"
		rm -f outputs/${test_number}_test_output
	else
		echo
		printf "${RED}----KO----${RESET}\n"
	fi
}

clear
printf "${BOLD}${CYAN}<==== Compiling project ====>\n\n${RESET}"
make checker -C ../srcs
compilation=$?
if [ ${compilation} -ne 0 ]; then
	exit 1
fi
echo
echo

printf "${BOLD}${CYAN}<==== Running basic error tests ====>${RESET}"

test "Simple stack that comes out sorted with given instruction" "2 1 3 4" "sa\n"
test "Simple no arguments given"
test "Stack with false operation" "2 1 3 4" "toto"
test "Invalide stack NaN" "1 two 3 4" "sa"
test "Invalide stack duplication" "1 3 4 1" "sa"
test "No operations but stack sorted" "1 3 4 5" ""
test "No operations AND stack unsorted" "2 1 3 4" ""
test "Operations don't sort stack" "2 1 3 4" "pa"
test "Operations do sort stack with push" "3 2 1 0" "rra\npb\nsa\nrra\npa"
test "Operations do sort stack without push" "1 3 6 2" "rra\nsa"
test "500 numbers in stack"  "4993 4990 4976 4936 4934 4927 4919 4917 4893 4880 4877 4875 4861 4860 4838 4831 4803 4793 4783 4779 4762 4760 4741 4740 4735 4732 4691 4681 4670 4659 4655 4650 4635 4615 4605 4595 4583 4580 4579 4578 4575 4560 4559 4556 4551 4547 4546 4536 4515 4508 4487 4486 4476 4453 4450 4443 4414 4402 4394 4380 4376 4355 4352 4334 4329 4308 4304 4288 4287 4275 4274 4248 4234 4233 4229 4227 4226 4208 4207 4201 4197 4178 4166 4159 4157 4150 4137 4110 4103 4097 4084 4082 4070 4067 4039 4024 4022 4020 3994 3991 3973 3971 3967 3943 3939 3935 3926 3923 3888 3846 3832 3830 3823 3817 3807 3792 3786 3785 3766 3765 3756 3745 3737 3735 3732 3729 3712 3694 3673 3669 3665 3660 3655 3641 3633 3625 3623 3619 3609 3601 3600 3597 3588 3583 3577 3574 3569 3556 3546 3535 3524 3523 3498 3496 3481 3475 3472 3471 3449 3446 3445 3441 3433 3418 3417 3410 3402 3381 3367 3361 3349 3345 3334 3313 3302 3286 3256 3242 3229 3218 3215 3213 3202 3181 3158 3151 3138 3136 3126 3120 3110 3099 3078 3077 3060 3056 3051 3043 3025 3010 2973 2972 2948 2929 2920 2915 2910 2895 2883 2877 2875 2868 2866 2861 2856 2827 2824 2820 2808 2791 2790 2779 2775 2771 2769 2756 2739 2735 2713 2710 2708 2698 2687 2684 2682 2678 2659 2632 2631 2625 2614 2601 2596 2586 2585 2575 2547 2522 2517 2459 2447 2442 2430 2402 2390 2369 2365 2350 2345 2339 2334 2325 2313 2294 2287 2286 2282 2270 2261 2256 2251 2232 2218 2207 2193 2189 2183 2167 2153 2130 2128 2120 2114 2101 2093 2088 2076 2063 2060 2059 2056 2055 2045 2042 2041 2036 2014 2008 1977 1965 1963 1959 1938 1922 1905 1900 1888 1885 1881 1825 1818 1792 1755 1751 1743 1742 1741 1715 1711 1685 1677 1674 1666 1638 1637 1631 1612 1604 1599 1550 1535 1527 1514 1464 1454 1452 1448 1439 1433 1403 1396 1390 1382 1375 1368 1356 1354 1353 1349 1341 1329 1325 1320 1318 1300 1290 1280 1278 1264 1244 1226 1215 1214 1198 1196 1178 1166 1106 1102 1099 1050 1043 1023 1001 998 990 984 965 962 959 949 938 925 922 921 906 903 896 892 883 865 863 861 855 850 827 825 823 816 814 803 800 794 792 787 786 783 765 764 753 716 702 700 695 693 686 683 681 675 670 645 641 632 630 611 607 605 598 590 566 549 536 532 531 522 516 515 510 501 494 490 483 471 470 453 450 439 438 430 415 411 405 404 393 381 361 356 354 352 338 321 314 309 306 302 291 287 280 267 235 232 211 207 194 191 187 182 179 157 147 140 130 125 110 106 94 93 90 88 86 84 71 60 32 18 -5 -41 -77 -80 -96" "rra\nsa"

if [ $clean ]; then
	if [ $clean = "clean" ]; then
		make clean -C ../srcs
	elif [ $clean = "fclean" ]; then
		make fclean -C ../srcs
	else
		printf "Not an option"
	fi
fi
