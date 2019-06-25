#Script to calculate sales bonuses and display their order according to name or sales total

INPUT=/tmp/menu.sh.$$

# Storage file for displaying output
OUTPUT=/tmp/output.sh.$$



# trap and delete temp files
trap "rm $OUTPUT; rm $INPUT; exit" SIGHUP SIGINT SIGTERM




#
# display output using msgbox
#  $1 -> set msgbox height
#  $2 -> set msgbox width
#  $3 -> set msgbox title
#
function display_output(){
	local h=${1-10}			# box height default 10
	local w=${2-41} 		# box width default 41
	local t=${3-Output} 	# box title
	dialog --backtitle "Sales" --title "${t}" --clear --msgbox "$(<$OUTPUT)" ${h} ${w}
}
#Load filname.txt into a dialog box
function view_record() {
	dialog --textbox filename.txt 28 125
}


#Load filname.txt into a dialog box

function add_record(){
	tempfile="/tmp/tmp.tmp"
	filex="filename.txt"
	dialog --editbox "$filex" 28 125 2> "$tempfile"
	returncode=$?
	if [ $returncode -eq 0 ] ; then
	  rm "$filex"
	  mv "$tempfile" "$filex"
	fi
	

}

#Calculate the bonuses 

function Calculate(){
bonuslow=750
upperbound=1000000
lowerbound=99999
m1bound=100000
m2bound=999999
bonus1=0
bonus2=750
bonus3=1500
filex="filename.txt"
tempfile="tmp.txt"
while IFS=, read -r col1 col2 col3
do
    #echo "$col1 , $col2, $col3"
	if [ $col2 -ge $upperbound ]
	then 
	echo "$col1,$col2,$bonus3" >> tmp.txt
	elif [ $col2 -ge $m1bound ] && [ $col2 -le $m2bound ]
	then 
	echo "$col1,$col2,$bonus2" >> tmp.txt
	else [ $col2 -le $lowerbound ]
	#then
	echo "$col1,$col2,$bonus1" >> tmp.txt
	#else [ $col2 == $upperbound ]
	#echo "$col1,$col2,$bonus3" >> tmp.txt
	fi	
done < filename.txt

echo $VALUES
#printf "$VALUES" > filename.txt
rm "$filex"
mv "$tempfile" "$filex"



}

#Sort the filename.txt by the sales number
function sortSales(){

	while IFS=, read -r col1 col2 col3
	do
    arr+=("$col1,$col2,$col3")
	done < filename.txt

	echo "Array in original order: "
	for i in "${arr[@]}"
	do
    echo "$i "field2=`echo $i | cut -d ',' -f 2`
	done

	lines=`cat filename.txt | wc -l`

	#Performing Bubble sort
	for ((i = 0; i<$lines-1; i++))
	do
    for ((j = i; j<$lines-i-1; j++))
    do
        if (( `echo ${arr[j]} | cut -d ',' -f 2` > `echo ${arr[$((j+1))]} | cut -d ',' -f 2` ))
        then
                #swap
                temp=${arr[$j]}
                arr[$j]=${arr[$((j+1))]}
                arr[$((j+1))]=$temp
            fi
    done
done

echo "Array in sorted order: "
for i in "${arr[@]}"
do
    echo "$i" >> tmp.txt
done
filex="filename.txt"
tempfile="tmp.txt"
rm "$filex"
mv "$tempfile" "$filex"
unset arr

}


#Sort the filename.txt by name
function sortName(){
	while IFS=, read -r col1 col2 col3
	do
    arr+=("$col1,$col2,$col3")
	done < filename.txt

	echo "Array in original order Name: "
	for i in "${arr[@]}"
	do
    echo "$i "field1=`echo $i | cut -d ',' -f 1`
	done

	lines=`cat filename.txt | wc -l`

	#arr=`${arr[*]} | cut -d ',' -f 1  | sort`
	arr=($( for each in ${arr[@]}; do echo $each; done | sort))

	echo "Array in sorted order Name: "
	for i in "${arr[@]}"
do
    echo "$i" >> tmp.txt
done
	filex="filename.txt"
	tempfile="tmp.txt"
	rm "$filex"
	mv "$tempfile" "$filex"

	unset arr

}






#
# Purpose - Records Menu
#
function Records(){
	while true
	do

### display sub menu###
dialog --clear --backtitle "Records" \
--title "Records" \
--menu "Select an option" 15 50 4 \
AddRecord "Add a Record" \
ViewRecords "View Records" \
Exit "Back" 2>"${INPUT}"

menuitem=$(<"${INPUT}")



# handles hte user input
case $menuitem in
	AddRecord) add_record;;
	ViewRecords) view_record;;
	Exit) echo "Bye"; break;;
esac
# if temp files found, delete them
[ -f $OUTPUT ] && rm $OUTPUT
[ -f $INPUT ] && rm $INPUT
done

}



function main(){
while true
do

### display main menu ###
dialog --clear --backtitle "Sales" \
--title "Sales" \
--menu "Select an option" 15 50 4 \
Records "Add a Staff Record, or View a list of staff records from a file" \
Calculator "Calculate a bonus" \
SortByName "Sort by name" \
SortBySales "Sort by sales" \
Exit "Exit to the shell" 2>"${INPUT}"

menuitem=$(<"${INPUT}")


# handle user input
case $menuitem in
	Records) Records;;
	Calculator) Calculate;;
	SortByName) sortName;;
	SortBySales) sortSales;;
	Exit) echo "Bye"; break;;
esac
# if temp files found, delete them
[ -f $OUTPUT ] && rm $OUTPUT
[ -f $INPUT ] && rm $INPUT
done
}
main
