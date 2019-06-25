#!/bin/bash

#############################PLEASE READ##########################################
# This is an archive script with a simple ui created by callum teesdale 15423186 #
# run using "bash archive.sh" in the terminal					 #
# Use the arrow keys to move through the menu and enter key to select		 #
# Assumes that the directory you want archive and write to exists		 #
#										 #
# 										 #
#									 	 #
##################################################################################


# Store menu options selected by the user
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
	dialog --backtitle "Archive Script" --title "${t}" --clear --msgbox "$(<$OUTPUT)" ${h} ${w}
}
#
# Purpose - Change tar settings
#
function tar_settings(){
while true
do

### display sub menu###
dialog --clear --backtitle "Archive Script" \
--title "Archive Script" \
--menu "Select an option" 15 50 4 \
DateTime "Change the tar settings" \
Source "Change Source location" \
Destination "Change Destination" \
Name "Change File Name" \
Exit "Back" 2>"${INPUT}"

menuitem=$(<"${INPUT}")


# handles hte user input
case $menuitem in
	DateTime) dateTime;;
	Execute) execute;;
	Source) fsource;;
	Destination) fdest;;
	Name) fname;;
	Exit) echo "Bye"; break;;
esac
# if temp files found, delete them
[ -f $OUTPUT ] && rm $OUTPUT
[ -f $INPUT ] && rm $INPUT
done

}

#change file name 
function fname(){
# open fd
exec 3>&1

# Store data to $fname variable
fname=$(dialog --ok-label "Save" \
	  --backtitle "Change Name" \
	  --title "Change Name" \
	  --form "Enter File name " \
15 50 0 \
	"Name:" 1 1	"$fname.tar.gz" 	1 30 30 0 \
2>&1 1>&3)

# close fd
exec 3>&-

# display values just entered for testing
echo "$fname"


}

#change destination 
function fdest(){
# open fd
exec 3>&1

# Store data to $fdest variable
fdest=$(dialog --ok-label "Save" \
	  --backtitle "Change Destination" \
	  --title "Change Destionation" \
	  --form "Enter path to the destination, path starts at home, directory must exist" \
15 50 0 \
	"Destination:" 1 1	"$fdest" 	1 30 30 0 \
2>&1 1>&3)

# close fd
exec 3>&-

# display values just entered for testing
echo "$fdest"

}


#change source location

function fsource(){
# open fd
exec 3>&1

# Store data to $src variable
fsrc=$(dialog --ok-label "Save" \
	  --backtitle "Change Source" \
	  --title "Change Source" \
	  --form "Enter path to the source, path starts at home, directory must all ready exist" \
15 50 0 \
	"Source:" 1 1	"$fsrc" 	1 30 30 0 \
2>&1 1>&3)

# close fd
exec 3>&-

# display values just entered for testing
echo "$fsrc"


}

#Change tar date/time settings
function dateTime(){

# Store data to $VALUES variable
values=$(dialog --ok-label "Save" \
	  --backtitle "Date Time Settings" \
	  --title "Date/Time" \
	  --form "Change The date/Time settings mins(0-59/*) hour(0-23/*) day(1-31/*) month(1-12/*) day of week(0-6/sunday=0)" \
15 50 0 \
	"Minutes:" 1 1	"$mins" 	1 10 15 0 \
	"Hours:"    2 1	"$hours"  	2 10 15 0 \
	"Day:"    3 1	"$day"  	3 10 15 0 \
	"Month:"     4 1	"$month" 	4 10 15 0 \
	"Week Day:"     5 1	"$wkday" 	5 10 15 0 2>&1 >/dev/tty)


# display values just entered
echo "$values"
}


#
#Execute tar command
#
function execute(){
rm cronlog
#
#Test that all variables are set
#

	echo fsrc="$fsrc"
	echo fdest="$fdest"
	echo fname="$fname"
	echo values="$values"
#Take the cron settings and assign them to an individual variable
i=0
while read -r line; do
	((i++))
	declare var$i="${line}"
done <<< "${values}"
echo "var1=${var1}"
echo "var2=${var2}"
echo "var3=${var3}"
echo "var4=${var4}"
echo "var5=${var5}"

#Get the date and time and format it
date=`date '+%Y-%m-%d %H:%M:%S'`

#execute the users settings
crontab -l >> cronlog
echo "${var1} ${var2} ${var3} ${var4} ${var5} tar -czf ./$fdest/$fname $fsrc on $date" >> cronlog
cat cronlog
crontab cronlog
}

function main(){
while true
do

### display main menu ###
dialog --clear --backtitle "Archive Script" \
--title "Archive Script" \
--menu "Select an option" 15 50 4 \
TarSettings "Change the tar settings" \
Execute "Execute with current settings" \
Exit "Exit to the shell" 2>"${INPUT}"

menuitem=$(<"${INPUT}")


# handle user input
case $menuitem in
	TarSettings) tar_settings;;
	Execute) execute;;
	Exit) echo "Bye"; break;;
esac
# if temp files found, delete them
[ -f $OUTPUT ] && rm $OUTPUT
[ -f $INPUT ] && rm $INPUT
done
}
main
