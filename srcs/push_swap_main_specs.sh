#!/bin/bash
PATH_TEST="$(cd "$(dirname "$0")" && pwd -P)"

source ${PATH_TEST}/colours.sh
system=`uname`
if [ $system == "Linux" ]; then
	checker=linux_checker
elif [ $system == "Darwin" ]; then
	checker=mac_checker
else
	printf "${RED}Sorry not compatible with operating system"
	exit
fi

if [ ! -e ${PATH_TEST}/../my_config.sh ]; then
	printf "${BOLD}my_config.sh${RESET} file not found.\n"
	printf "Creating file...\n"
	if [ -e ${PATH_TEST}/config_template.sh ]
	then
		cp ${PATH_TEST}/config_template.sh ${PATH_TEST}/../my_config.sh
		printf "File created with success in ${BOLD}${CYAN}${PATH_TEST}\n${RESET}"
		printf "${PINK}${UNDER}Edit my_config.sh file${RESET} with the path of your push_swap project.\n"
	else
		printf "${UNDER}Can't create my_config.sh file,${RESET} update or re-clone the repository and retry.\n"
		exit
	fi
	exit
fi

source ./my_config.sh

clean=$1
declare -i test_number=0;

progress_bar () {
	local w=80 p=$1;  shift
	printf -v dots "%*s" "$(( $p*$w/100 ))" ""; dots=${dots// /.};
	printf "\r\e[K|%-*s| %3d %% %s" "$w" "$dots" "$p" "$*";
}

average () {

	stack_size=$1
	runs=$2
	declare -i actions_count=0;
	iteration_count=0;
	fastest=0;
	slowest=0;

	printf "\n${BOLD}Stats for a ${stack_size} number long stack over ${runs} runs:${RESET}\n"
	echo > outputs/checker_result_for_average
	for ((i = 1; i <= $runs; i++ )); do
		percentage=$((${i}*100/${runs}))
		progress_bar ${percentage}
		if [ $stack_size == '5' ]; then
			stack=`ruby -e 'puts (-10..100).to_a.sample(5).join(" ")'`
		elif [ $stack_size == '100' ]; then
			stack=`ruby -e 'puts (-100..1000).to_a.sample(100).join(" ")'`
		else
			stack=`ruby -e 'puts (-100..1000).to_a.sample(500).join(" ")'`
		fi
		iteration_count=`${PATH_TO_PUSH_SWAP}/push_swap $stack | wc -l | xargs`
		result=`${PATH_TO_PUSH_SWAP}/push_swap $stack | ${PATH_TEST}/${checker} $stack`
		if [[ $result == *"KO"* ]] || [[ $result == *"Error"* ]]; then
			echo $stack >> outputs/checker_result_for_average
		fi
		echo $result >> outputs/checker_result_for_average
		if [ $i -eq 1 ] || [ $iteration_count -lt $fastest ]; then
			fastest=$iteration_count
		fi
		if [ $iteration_count -gt $slowest ]; then
			slowest=$iteration_count
		fi
		actions_count+=$iteration_count
	done
	grep 'KO\|Error' outputs/checker_result_for_average
	if [ $? -eq 0 ]; then
		new_file=outputs/failed_${stack_size}_average
		cp outputs/checker_result_for_average ${new_file}
		printf "\n  Checker status: ${RED}KO${RESET}\n"
		printf "  Find the failed stacks in ${new_file}\n"
	else
		printf "\n  Checker status: ${GREEN}OK${RESET}\n"
	fi
	printf "  Slowest: ${slowest}\n"
	printf "  Fastest: ${fastest}\n"
	average=`echo "scale=2; ${actions_count} / ${i}" | bc -l`
	printf "  On average: ${average}\n"
}

test () {
	scenario=$1
	describe=$2
	max_actions=$3
	stack=$4
	speed_info=
	test_number+=1


	printf "\n${BOLD}${describe} :\n${RESET}"
	if [ $scenario == 'E' ]; then
		${PATH_TO_PUSH_SWAP}/push_swap $stack > outputs/ps_${test_number}_test_output
	else
		if [ $max_actions ]; then
			actions_count=`${PATH_TO_PUSH_SWAP}/push_swap $stack | wc -l | xargs`
			if [ $actions_count -le $max_actions ]; then
				speed_info="${UNDER}Fast${RESET} "
			else
				speed_info="${BLINK}SLOW${RESET} "
				echo $stack
			fi
		fi
		${PATH_TO_PUSH_SWAP}/push_swap $stack | ${PATH_TEST}/${checker} $stack > outputs/ps_${test_number}_test_output
	fi
	if [ $speed_info ]; then
		printf "${speed_info}\n" >> outputs/ps_${test_number}_test_output
	fi
	if [ $scenario == 'E' ]; then
		if [ -z "$stack" ]; then
			diff -u outputs/ps_empty_output outputs/ps_${test_number}_test_output
		else
			diff -u outputs/ps_error_output outputs/ps_${test_number}_test_output
		fi
	else
		diff -u outputs/ps_green_output outputs/ps_${test_number}_test_output
	fi
	RESULT=$?
	if [ ${RESULT} -eq 0 ]
	then
		printf "  ${GREEN}${BOLD}OK${RESET} total actions : ${actions_count}\n"
		rm -f outputs/ps_${test_number}_test_output
	else
		printf "\n----${speed_info}${actions_count}${RED} KO${RESET}----"
	fi
}

clear
printf "${BOLD}${CYAN}<==== Compiling project ====>\n\n${RESET}"
make push_swap -C ${PATH_TO_PUSH_SWAP}
compilation=$?
if [ ${compilation} -ne 0 ]; then
	exit 1
fi
echo
echo

printf "${BOLD}${CYAN}<==== Running basic error tests ====>${RESET}"

test E "No stack given"
test E "Invalide stack NaN" "1 two 3 4"
test E "Invalide stack duplication" "1 1 3 4"
test V "Two numbers unsorted" 1 "2 1"
printf "\n${UNDER}${CYAN}Three numbers:${RESET}"
test V "Stack 1" 2 "2 1 3"
test V "Stack 2" 2 "3 2 1"
test V "Stack 3" 2 "3 -2147483648 2"
test V "Stack 4" 2 "-1 3 2"
test V "Stack 5" 2 "2 3 1"
printf "\n${UNDER}${CYAN}Four numbers:${RESET}"
test V "Sorted" 0 "1 3 4 5"
test V "Worst case scenario" 12 "4 3 2 1"
test V "Random" 12 "1564 3299 106 4186"
printf "\n${UNDER}${CYAN}Five numbers:${RESET}"
test V "Sorted" 0 "1 2 3 4 5"
test V "Worst case scenario" 12 "5 4 3 2 -1"
test V "Medium example" 12 "1 5 2 4 3"
test V "Random infinite loop" 12 "86 81 -6 21 67"
test V "Random infinite loop 2" 12 "16 9 70 37 34"
test V "Random too slow" 12 "75 64 18 73 69"
average 5 ${number_of_runs}
printf "\n${UNDER}${CYAN}100 numbers:${RESET} pass 900 aim sub 700"
test V "Sorted" 0 "2 87 161 190 218 276 342 376 418 452 546 628 635 704 727 819 838 877 965 1049 1143 1237 1338 1348 1353 1509 1524 1538 1541 1556 1599 1760 1787 1857 1896 1958 2093 2160 2181 2225 2296 2342 2366 2372 2547 2595 2613 2657 2727 2730 2748 2764 2770 2784 2787 2834 2861 2880 2943 3053 3060 3068 3145 3159 3222 3345 3391 3411 3432 3583 3611 3722 3780 3812 3896 3944 3976 4015 4095 4125 4224 4263 4279 4329 4355 4490 4495 4541 4644 4650 4681 4764 4768 4782 4848 4862 4906 4951 4979 4985" 0
test V "Descending" ${one_hundred_max} "100 99 97 96 92 91 90 87 84 83 82 80 78 77 75 73 71 70 66 64 63 62 61 60 58 57 56 51 50 47 45 38 36 34 31 30 29 28 24 20 19 17 16 13 11 8 7 5 3 0 -2 -3 -4 -7 -8 -9 -11 -12 -13 -17 -18 -19 -21 -23 -24 -26 -28 -29 -32 -33 -34 -37 -41 -42 -43 -44 -45 -47 -48 -51 -53 -56 -61 -65 -66 -69 -70 -71 -72 -73 -74 -76 -78 -80 -82 -84 -87 -92 -93 -94"
test V "Worst case scenario (descending except 1)" ${one_hundred_max} "100 99 97 96 92 91 90 87 84 83 82 80 78 77 73 75 71 70 66 64 63 62 61 60 58 57 56 51 50 47 45 38 36 34 31 30 29 28 24 20 19 17 16 13 11 8 7 5 3 0 -2 -3 -4 -7 -8 -9 -11 -12 -13 -17 -18 -19 -21 -23 -24 -26 -28 -29 -32 -33 -34 -37 -41 -42 -43 -44 -45 -47 -48 -51 -53 -56 -61 -65 -66 -69 -70 -71 -72 -73 -74 -76 -78 -80 -82 -84 -87 -92 -93 -94"
test V "Random slow 1" ${one_hundred_max} "932 659 161 605 106 940 243 30 277 232 737 890 933 224 610 853 826 408 635 842 946 584 355 194 627 -36 12 189 738 -59 86 -97 85 702 768 964 13 198 937 489 313 523 987 203 296 29 707 -84 871 226 -7 470 944 508 554 53 -52 26 463 844 396 87 623 668 170 966 785 953 239 -69 711 863 993 164 84 459 173 573 986 791 91 534 585 520 127 731 494 994 27 558 460 -25 219 266 9 92 984 615 451 301"
test V "Random slow 2" ${one_hundred_max} "434 800 718 38 185 992 540 929 140 858 788 224 762 420 973 93 714 486 -2 510 879 228 801 498 208 404 332 -100 130 661 407 348 -18 494 435 210 454 111 965 -81 0 -74 794 -15 326 752 432 372 95 -37 698 280 390 -3 63 51 766 164 914 648 181 442 995 451 403 547 -64 16 336 247 601 756 502 416 337 480 359 418 619 333 202 -5 655 947 822 605 791 360 261 205 92 239 250 142 14 469 66 549 248 32"
test V "Random slow 3" ${one_hundred_max} "488 -27 926 877 113 -51 296 -19 490 248 160 865 142 523 968 322 438 547 937 250 312 4 282 951 355 794 310 10 756 672 16 810 93 -72 351 17 -81 853 192 343 817 499 995 -34 529 27 266 139 916 -40 399 333 223 501 161 782 185 354 279 574 163 807 898 254 429 -43 639 390 269 95 275 179 847 950 903 981 660 628 933 191 180 593 1 527 387 512 686 305 421 320 11 533 129 850 607 466 174 439 184 -50"
test V "Random slow 4" ${one_hundred_max} "632 60 429 846 132 280 789 640 539 51 929 121 263 919 899 262 827 -85 88 776 113 288 855 216 597 788 882 438 284 984 417 303 590 517 53 383 834 -81 54 763 751 573 592 888 79 728 35 703 376 217 146 523 44 354 801 610 331 686 906 826 621 26 -77 227 -62 -67 289 -48 250 711 892 -58 292 665 17 452 979 779 480 875 591 326 140 116 456 927 638 15 -16 786 629 207 -25 770 725 338 768 191 -80 52"
test V "Random slow 5" ${one_hundred_max} "303 948 738 903 654 153 445 63 769 103 -46 317 145 79 150 682 781 302 633 585 503 487 343 214 841 447 878 441 -59 1000 328 221 542 678 818 13 -57 762 944 835 282 837 662 172 -10 694 557 588 311 281 42 273 390 154 651 797 370 479 644 744 395 193 -51 825 85 351 296 123 469 288 863 985 560 806 478 522 111 736 839 466 865 900 859 597 508 361 -24 217 212 274 179 17 16 65 -81 926 285 832 854 147"
average 100 ${number_of_runs}
printf "\n${UNDER}${CYAN}500 numbers:${RESET} pass 7000 aim sub 5500"
test V "Descending" ${five_hundred_max} "4993 4990 4976 4936 4934 4927 4919 4917 4893 4880 4877 4875 4861 4860 4838 4831 4803 4793 4783 4779 4762 4760 4741 4740 4735 4732 4691 4681 4670 4659 4655 4650 4635 4615 4605 4595 4583 4580 4579 4578 4575 4560 4559 4556 4551 4547 4546 4536 4515 4508 4487 4486 4476 4453 4450 4443 4414 4402 4394 4380 4376 4355 4352 4334 4329 4308 4304 4288 4287 4275 4274 4248 4234 4233 4229 4227 4226 4208 4207 4201 4197 4178 4166 4159 4157 4150 4137 4110 4103 4097 4084 4082 4070 4067 4039 4024 4022 4020 3994 3991 3973 3971 3967 3943 3939 3935 3926 3923 3888 3846 3832 3830 3823 3817 3807 3792 3786 3785 3766 3765 3756 3745 3737 3735 3732 3729 3712 3694 3673 3669 3665 3660 3655 3641 3633 3625 3623 3619 3609 3601 3600 3597 3588 3583 3577 3574 3569 3556 3546 3535 3524 3523 3498 3496 3481 3475 3472 3471 3449 3446 3445 3441 3433 3418 3417 3410 3402 3381 3367 3361 3349 3345 3334 3313 3302 3286 3256 3242 3229 3218 3215 3213 3202 3181 3158 3151 3138 3136 3126 3120 3110 3099 3078 3077 3060 3056 3051 3043 3025 3010 2973 2972 2948 2929 2920 2915 2910 2895 2883 2877 2875 2868 2866 2861 2856 2827 2824 2820 2808 2791 2790 2779 2775 2771 2769 2756 2739 2735 2713 2710 2708 2698 2687 2684 2682 2678 2659 2632 2631 2625 2614 2601 2596 2586 2585 2575 2547 2522 2517 2459 2447 2442 2430 2402 2390 2369 2365 2350 2345 2339 2334 2325 2313 2294 2287 2286 2282 2270 2261 2256 2251 2232 2218 2207 2193 2189 2183 2167 2153 2130 2128 2120 2114 2101 2093 2088 2076 2063 2060 2059 2056 2055 2045 2042 2041 2036 2014 2008 1977 1965 1963 1959 1938 1922 1905 1900 1888 1885 1881 1825 1818 1792 1755 1751 1743 1742 1741 1715 1711 1685 1677 1674 1666 1638 1637 1631 1612 1604 1599 1550 1535 1527 1514 1464 1454 1452 1448 1439 1433 1403 1396 1390 1382 1375 1368 1356 1354 1353 1349 1341 1329 1325 1320 1318 1300 1290 1280 1278 1264 1244 1226 1215 1214 1198 1196 1178 1166 1106 1102 1099 1050 1043 1023 1001 998 990 984 965 962 959 949 938 925 922 921 906 903 896 892 883 865 863 861 855 850 827 825 823 816 814 803 800 794 792 787 786 783 765 764 753 716 702 700 695 693 686 683 681 675 670 645 641 632 630 611 607 605 598 590 566 549 536 532 531 522 516 515 510 501 494 490 483 471 470 453 450 439 438 430 415 411 405 404 393 381 361 356 354 352 338 321 314 309 306 302 291 287 280 267 235 232 211 207 194 191 187 182 179 157 147 140 130 125 110 106 94 93 90 88 86 84 71 60 32 18 -5 -41 -77 -80 -96"
test V "Worst case scenario (descending except 1)" ${five_hundred_max} "4988 4985 4975 4974 4960 4951 4926 4914 4910 4887 4852 4829 4811 4803 4799 4788 4787 4786 4781 4779 4767 4747 4743 4731 4708 4699 4691 4690 4676 4666 4661 4657 4634 4630 4626 4618 4617 4596 4573 4569 4568 4561 4556 4538 4509 4503 4497 4494 4490 4475 4470 4467 4465 4458 4436 4421 4411 4397 4372 4371 4348 4343 4335 4329 4321 4317 4288 4278 4268 4257 4250 4241 4216 4207 4204 4185 4151 4145 4143 4141 4123 4118 4107 4088 4071 4062 4052 4021 4018 4017 4002 3990 3986 3982 3980 3975 3960 3934 3927 3910 3906 3903 3896 3895 3892 3856 3854 3851 3848 3834 3831 3828 3812 3805 3772 3770 3738 3734 3729 3720 3716 3712 3708 3707 3700 3692 3683 3664 3658 3650 3646 3630 3627 3623 3616 3613 3605 3600 3592 3588 3582 3540 3513 3453 3450 3429 3426 3425 3424 3407 3405 3377 3363 3352 3318 3314 3305 3287 3284 3280 3278 3273 3266 3249 3237 3230 3225 3220 3218 3213 3208 3197 3189 3182 3155 3146 3139 3118 3107 3075 3065 3056 3052 3046 3044 3028 2964 2960 2956 2950 2935 2927 2921 2919 2912 2909 2891 2882 2859 2853 2851 2839 2820 2817 2805 2802 2800 2785 2768 2765 2764 2761 2745 2735 2707 2693 2689 2661 2651 2640 2638 2637 2616 2614 2609 2597 2595 2578 2577 2568 2565 2547 2533 2523 2517 2513 2509 2502 2485 2475 2458 2453 2448 2447 2439 2430 2385 2371 2352 2351 2336 2326 2317 2299 2289 2284 2283 2281 2279 2266 2255 2224 2214 2208 2167 2166 2161 2156 2145 2135 2127 2102 2099 2096 2087 2083 2065 2057 2056 2054 2044 2023 2020 2002 1997 1980 1976 1973 1961 1943 1934 1912 1900 1898 1885 1855 1850 1839 1830 1824 1814 1793 1786 1779 1774 1743 1733 1730 1727 1716 1714 1710 1708 1691 1687 1686 1674 1666 1658 1647 1644 1643 1642 1638 1636 1620 1612 1605 1601 1581 1580 1578 1556 1551 1542 1528 1520 1500 1487 1482 1453 1450 1418 1416 1415 1406 1395 1390 1385 1373 1371 1355 1321 1316 1312 1289 1286 1282 1249 1230 1228 1215 1211 1195 1190 1179 1176 1171 1139 1136 1122 1118 1106 1067 1035 1023 1019 1013 1005 991 984 974 970 955 953 946 943 942 939 931 922 917 914 903 887 872 868 837 835 829 823 807 805 803 793 787 772 766 762 755 746 729 726 721 718 712 705 694 685 680 677 666 654 644 639 629 608 605 597 595 566 549 519 502 501 489 487 476 469 468 460 451 444 430 422 419 415 401 389 387 374 371 370 369 363 360 358 357 347 328 324 308 305 288 279 274 237 236 226 225 216 207 196 193 157 143 135 119 110 105 102 96 85 80 69 42 23 13 -5 -17 -21 -29 -30 -37 -45 -53 -59 -64 -85 -84"
average 500 ${number_of_runs}
