#!/bin/bash
#are dialog, enter height and width and the area will be calculated and returned in sq cm and sq inches
# open fd
while :
do

exec 3>&1

# Store data to $VALUES variable
VALUES=$(dialog --ok-label "Calculate" \
	  --backtitle "Area Calculator" \
	  --title "Calculate the area of a rectangle" \
	  --form "Enter the height and width and hit enter. ^c to exit." \
15 50 0 \
	"Height" 1 1	"$height" 	1 10 15 0 \
	"Width"    2 1	"$width"  	2 10 15 0 \
	"Area cm="    3 1	"$sumcm"  	3 10 15 0 \
	"Area in="    4 1	"$sumin"  	4 10 15 0 \
2>&1 1>&3)

# close fd
exec 3>&-
i=0
while read -r line; do
	((i++))
	declare var$i="${line}"
done <<< "${VALUES}"




# display values just entered
echo "$VALUES"
echo "${var1}"
echo "${var2}"


#assume using integer
isinth=true
isintw=true

#Check to make sure height is an integer
if [[ ${var1} =~ ^[0-9]+$ ]]
then 
	echo height is int
#set isint to true
	isinth=true

#check if height is float
elif [[ ${var1} =~ ^[-+]?[0-9]*\.?[0-9]+$ ]]
then
	echo height is float
#set isint to false because it's a floating point number
	isinth=false
#if height is not int or float display error message
else
	dialog --infobox "Height '${var1}' is not an integer or float" 10 30 ; sleep 4
	${var1}=0
#	echo Please only use integers or floating points numbers
fi



#Check to make sure width is an int
if [[ ${var2} =~ ^[0-9]+$ ]]
then
	echo width is int
#set isint to true
	isintw=true

#check if width is float
elif [[ ${var2} =~ ^[-+]?[0-9]*\.?[0-9]+$ ]]
then
	echo width is float
#set isint to false because it's a floating point number
	isintw=false

#if height is not int or float display error message
else
	dialog --infobox "Width '${var2}' is not an integer or float" 10 30 ; sleep 4
	${var2}=0
#	echo Please only use integers or floating points numbers
fi


#if isint is true bc isn't needed
if [[ "$isinth" = true  && "$isintw" = true ]]
then
	sumcm=$((${var2} * ${var1}))
	sumin=$(echo "$sumcm / 6.452" | bc -l)
	echo area is $sumcm

#if using floating point numbers pipe into bc
elif [[ "$isinth" = false || "$isintw" = false ]]
then
	sumcm=$(echo "${var2} * ${var1}" | bc -l)
	sumin=$(echo "$sumcm / 6.452" | bc -l)
	echo area is $sumcm
	echo area is $sumin
else
	echo error
fi
done
