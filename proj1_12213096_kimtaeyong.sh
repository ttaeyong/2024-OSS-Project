#!/bin/bash
if [ $# -ne 3 ]; then #if the number of arguments are not 3 -> Error Message
	echo "usage: ./2024-OSS-Project1.sh file1 file2 file3"
	exit 1
fi

#starting Program with whoami
echo "************OSS1 - Project1************"
echo "*        StudentID : 12213096         *"
echo "*        Name : Taeyong Kim           *"
echo "***************************************"

#initialize selectedMode, and userAnswer variable so that user can choice
selectedMode=0
userAnswer=0

until [ $selectedMode -eq 7 ] #loop until user wants 7. Exit
do
	echo -e  "\n[MENU]
1. Get the data of Heung-Min Son's Current Club, Appearances, Goals, Assists in players.csv
2. Get the team data to enter a league position in teams.csv
3. Get the Top-3 Attendance matches in mateches.csv
4. Get the team's league position and team's top scorer in teams.csv & players.csv
5. Get the modified format of date_GMT in matches.csv
6. Get the data of the winning team by the largest difference on home stadium in teams.csv & matches.csv
7. Exit"
	read -p "Enter your CHOICE (1~7) : " selectedMode #mode selection

	#branch out to each modes by selectedMode from user using case statement
	case "$selectedMode" in
		1)
			read -p "Do you want to get the Heung-Min Son's data? (y/n) : " userAnswer
			if [ $userAnswer = "y" ]; then
				awk -F, '$1=="Heung-Min Son" { printf "Team:%s, Apperance:%s, Goal:%s, Assist:%s\n", $4, $6, $7, $8 }' $2
			fi;; #else, do nothing to select mode again
		2)
			read -p "What do you want to get the team data of league_position[1~20] : " userAnswer
			awk -F, -v pos="$userAnswer" '$6==pos { print $6, $1, $2/($2+$3+$4) }' $1 ;;
		3)
			read -p "Do you want to know Top-3 attendance data and average attendance? (y/n) : " userAnswer
                        if [ $userAnswer = "y" ]; then
				echo "***Top-3 Attendance Match***"
				cat $3 | sort -t, -n -r -k 2 | awk -F, 'NR <= 3 { printf "\n%s vs %s (%s)\n%s %s\n", $3, $4, $1, $2, $7}'
			fi;; #else, do nothing to select mode again
		4)
			read -p "Do you want to get each team's ranking and the highest-scoring player? (y/n) : " userAnswer
			if [ $userAnswer = "y" ]; then
				IFS=$'\n'
				for var in $(cat $1 | sort -t, -n -k 6);
				do
					teamName=$(echo $var | cut -d, -f 1)
					teamPos=$(echo $var | cut -d, -f 6)
					if [ $teamName != "common_name" ]; then
						printf "\n%s %s\n" $teamPos $teamName
						awk -v tN="$teamName" -F, 'BEGIN {max=0} $4==tN && (0+max)<$7 {maxName=$1; max=$7;} END { print maxName, max }' $2
					fi
				done
			fi;;
		5)
			read -p "Do you want to modify the format of date? (y/n) : " userAnswer
			if [ $userAnswer = "y" ]; then
				awk -F, 'NR>1 && NR<12 {print $1}' $3 | sed -r 's/Jan/01/; s/Feb/02/; s/Mar/03/; s/Apr/04/; s/May/05/; s/Jun/06/; s/Jul/07/; s/Aug/08/; s/Sep/09/; s/Oct/10/; s/Nov/11/; s/Dec/12/; s/([0-9]+) ([0-9]+) ([0-9]+) - ([0-9]+:[0-9]+[a-z]+)/\3\/\1\/\2 \4/'
			fi;;
		6)
			read -p " 1) Arsenal			11) LiverPool
 2) Tottenham Hotspur		12) Chelsea
 3) Manchester City		13) West Ham United
 4) Leicester City		14) Watford
 5) Crystal Palace		15) NewCastle United
 6) Everton			16) Cardiff City
 7) Burnley			17) Fulham
 8) Southampton			18) Brighton & Hove Albion
 9) AFC Bournemouth		19) Huddersfield Town
10) Manchester United		20) Wolverhampton Wanderers
Enter your team number : " userAnswer

			teamName=$(awk -v tNum="${userAnswer}" -F, 'NR==tNum+1 { print $1 }' $1)
			largestDiff=$(awk -v tN="${teamName}" -F, 'BEGIN { max=0 } $3==tN && ($5-$6)>(0+max) { max=$5-$6 } END { print max }' $3)
			awk -v tN="${teamName}" -v lD="${largestDiff}" -F, '$3==tN && ($5-$6)==(0+lD) { printf "\n%s\n%s %s vs %s %s\n", $1, $3, $5, $4, $6 }' $3;;
		7)
			printf "Bye!\n\n";;
	esac
done
exit 0 #exit the program
