#!/bin/bash
# Author: Max Keiper
# Version: 1.0
# Purpose: This script will allow you to select a presetup AWS profile and query, create, delete IAM accounts.

clear
echo "Which AWS profile do you want to use(max,pmmax,pmmaxgov):"
read awsProfile
echo
clear

echo "What type of output?"
outOptions=(
	"Text"
	".JSON" 
	"Table"
)
select outMenuChoice in "${outOptions[@]}"
do
 case $outMenuChoice in
	"Text")
		export AWS_DEFAULT_OUTPUT="text"
		break
	;;
	".JSON")
		export AWS_DEFAULT_OUTPUT="json"
		break
	;;
	"Table")
  	export AWS_DEFAULT_OUTPUT="table"
		break
	;;
	*)echo Invalid Option;;
 esac
done
# echo $AWS_DEFAULT_OUTPUT
clear

options=(
	"List Users/Get User Info"
	"Create a new user"
	"Delete a user"
	"Add Console access to a existing user"
	"Add CLI access to an existing user" 
	"Write user info to file and encrypt." 
	"Quit"
)

echo "	AWS UAC MAIN MENU			"
echo "------------------------------------------------------"
select menuChoice in "${options[@]}"
do
	case $menuChoice in
      "List Users/Get User Info")
        echo "Do you want to (1)list all users or (2)exact search or (3)wild card search:"
        read choice
        if [ $choice == '1' ]; then
        	echo "Listing all users:"
					echo "------------------"
					aws iam list-users --profile $awsProfile
				elif [ $choice == '2' ]; then
					echo "Enter the username you want to search for:"
					read uname
					aws iam get-user --profile $awsProfile --user-name $uname
					echo
				elif  [ $choice == '3' ]; then
				  echo "Enter the username you want to search for:"
					read uname
					aws iam list-users --profile $awsProfile | grep "$uname"
				fi  
      ;; 		
		"Create a new user")
			echo "Enter the User Name you want to create:"
			read uname
			echo
			createOutput=$(aws iam create-user --user-name "$uname" --profile "$awsProfile")
			echo "$createOutput"
		;;
		"Delete a user")
      echo "Enter the User Name you want to delete(no output = success)":
      read uname
			aws iam list-access-keys --user-name "$uname" --profile "$awsProfile"
			if [ $? -eq 0 ]; then
			  deleteOutput=$(aws iam delete-user --user-name "$uname" --profile "$awsProfile")
        if [ $? -eq 0 ]; then
          echo "Deleted User $uname Successfully"
        else
					echo "$deleteOutput"
        fi
			else	
				echo "Enter the Active Access-Key:"
				read aKey
				aws iam delete-access-key --access-key "$aKey" --user-name "$uname" --profile "$awsProfile"
      	deleteOutput=$(aws iam delete-user --user-name "$uname" --profile "$awsProfile")
				if [ $? -eq 0 ]; then
					echo "Deleted User $uname Successfully"
				else
					echo "$deleteOutput"
				fi
			fi
		;;
		"Add Console access to a existing user")
			echo "Enter the User Name you want to add Console access to:"
			read uname
			echo "Enter the password, make sure it is complex:"
      read upassword
      conOutput=$(aws iam create-login-profile --user-name "$uname" --password "$upassword" --password-reset-required --profile "$awsProfile")
		;;
		"Add CLI access to an existing user")
			echo "Enter the User Name you want to add CLI/Programatic access to:"
			read uname
			progOutput=$(aws iam create-access-key --user-name "$uname" --profile "$awsProfile")
		;;
    "Write user info to file and encrypt.")
    	finOutput="AWS USER INFO"$'\n'"----------------------------"$'\n'"User Account: $createOutput"$'\n'"Console User Info: $conOutput"$'\n'"Console Pass: $upassword"$'\n'"CLI User Access Key/Secret Key: $progOutput"
			destFile=~/Desktop/iam_script/"$uname".txt
			echo "$finOutput"
			echo "$finOutput" > $destFile
			gpg -c "$destFile"
		;;
		"Quit")
			exit
		;;
		*)echo Invalid Option;;
	esac
done

