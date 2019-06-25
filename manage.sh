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

function EditGroup() {
# open fd
exec 3>&1
EditGroup=$(dialog --ok-label "Save" \
	  --backtitle "Edit Group" \
	  --title "Edit group" \
	  --form "Edit group" \
15 50 0 \
	"Old name:" 1 1	"$oldname" 	1 30 30 0 \
	"New name:" 2 1	"$newname" 	2 30 30 0 \
2>&1 1>&3)

# close fd
exec 3>&-

# display values just entered for testing
echo "$EditGroup"

while read -r line; do
	((i++))
declare EditGroup$i="${line}"
done <<< "${EditGroup}"
echo "oldname=${EditGroup1}"
echo "newname=${EditGroup2}"

echo `sudo groupmod -n ${EditGroup2} ${EditGroup1}`
}


function EditUser(){
# open fd
exec 3>&1
EditUser=$(dialog --ok-label "Save" \
	  --backtitle "Edit User" \
	  --title "Edit user" \
	  --form "Edit a user" \
15 50 0 \
	"Old username:" 1 1	"$oldusername" 	1 30 30 0 \
	"New Username:" 2 1	"$username" 	2 30 30 0 \
2>&1 1>&3)

# close fd
exec 3>&-

# display values just entered for testing
echo "$EditUser"

while read -r line; do
	((i++))
declare EditUser$i="${line}"
done <<< "${EditUser}"
echo "oldusername=${EditUser1}"
echo "newusername=${EditUser2}"

echo `sudo usermod -l ${EditUser2} ${EditUser1}`

}

function DeleteGroup(){
# open fd
exec 3>&1
DeleteGroup=$(dialog --ok-label "Save" \
	  --backtitle "Delete User" \
	  --title "Delete" \
	  --form "Delete" \
15 50 0 \
	"Group name:" 1 1	"$GroupName" 	1 30 30 0 \
2>&1 1>&3)

# close fd
exec 3>&-

# display values just entered for testing
echo "$DeleteGroup"

while read -r line; do
	((i++))
declare DeleteGroup$i="${line}"
done <<< "${DeleteGroup}"
echo `sudo groupdel -f ${DeleteGroup1}`
}

function DeleteUser(){

# open fd
exec 3>&1
DeleteUser=$(dialog --ok-label "Save" \
	  --backtitle "Delete User" \
	  --title "Delete" \
	  --form "Delete" \
15 50 0 \
	"Username:" 1 1	"$username" 	1 30 30 0 \
2>&1 1>&3)

# close fd
exec 3>&-

# display values just entered for testing
echo "$AddUser"

while read -r line; do
	((i++))
declare DeleteUser$i="${line}"
done <<< "${DeleteUser}"
echo `sudo userdel ${DeleteUser1}`

}

function AddGroup(){
# open fd
exec 3>&1
name=$(dialog --ok-label "Save" \
	  --backtitle "Add User" \
	  --title "Add a new user" \
	  --form "Add a new user" \
15 50 0 \
	"Name:" 1 1	"$name" 	1 30 30 0 \
	"ID:" 2 1	"$id" 	2 30 30 0 \
2>&1 1>&3)

# close fd
exec 3>&-

# display values just entered for testing
echo "$name"

while read -r line; do
	((i++))
declare name$i="${line}"
done <<< "${name}"
echo "group=${name1}"
echo "id=${name2}"

echo `sudo groupadd ${name1}`

}
function AddUser(){

# open fd
exec 3>&1
AddUser=$(dialog --ok-label "Save" \
	  --backtitle "Add User" \
	  --title "Add a new user" \
	  --form "Add a new user" \
15 50 0 \
	"Username:" 1 1	"$username" 	1 30 30 0 \
	"Password:" 2 1	"$Password" 	2 30 30 0 \
2>&1 1>&3)

# close fd
exec 3>&-

# display values just entered for testing
echo "$AddUser"

while read -r line; do
	((i++))
declare AddUser$i="${line}"
done <<< "${AddUser}"
echo "username=${AddUser1}"

echo `sudo useradd -m -p ${AddUser2} ${AddUser1} `
}



function main(){
while true
do

### display main menu ###
dialog --clear --backtitle "Manage" \
--title "Manage" \
--menu "Add a new user, group or edit and delete a user or group" 15 50 4 \
AddUser "Add user" \
AddGroup "Add group" \
DeleteUser "Delete User" \
DeleteGroup "Delete Group" \
EditGroup "Edit Group" \
EditUser "Edit User" \
Exit "Exit to the shell" 2>"${INPUT}"

menuitem=$(<"${INPUT}")


# handle user input
case $menuitem in
	AddUser) AddUser;;
	AddGroup) AddGroup;;
	DeleteUser) DeleteUser;;
	DeleteGroup) DeleteGroup;;
    EditGroup) EditGroup;;
    EditUser) EditUser;;
	Exit) echo "Bye"; break;;
esac
# if temp files found, delete them
[ -f $OUTPUT ] && rm $OUTPUT
[ -f $INPUT ] && rm $INPUT
done
}
main