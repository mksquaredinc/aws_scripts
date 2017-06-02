#!/bin/bash
# Author: Max Keiper
# Version: 1.0
# Purpose: This script will allow you to select a presetup AWS profile and query, create, delete IAM accounts.

clear
echo "Which AWS profile do you want to use(max,pmmax,pmmaxgov):"
read awsProfile
echo
clear

echo "What type of output do you want(num)? (1.Text, 2.JSON, 3. Table)?"
read uType
if [ "$uType" == '1' ]; then
	export AWS_DEFAULT_OUTPUT="text"    
elif [ "$uType" == '2' ]; then
	export AWS_DEFAULT_OUTPUT="json"
elif [ "$uType" == '3' ]; then
  export AWS_DEFAULT_OUTPUT="table"
else
	exit
fi
# echo $AWS_DEFAULT_OUTPUT
clear

options=("1. List Users/Get User Info" "2. Create a new user" "3. Delete a user" "4. Add Console access to a existing user" "4. Add CLI access to an existing user" 
"6. Write user info to file and encrypt." 
"Quit")

echo "			MAIN MENU			"
echo "------------------------------------------------------"
select menuChoice in "${options[@]}"
do
	case $menuChoice in
      "1. List Users/Get User Info")
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
		"2. Create a new user")
			echo "Enter the User Name you want to create:"
			read uname
			echo
			createOutput=$(aws iam create-user --user-name "$uname" --profile "$awsProfile")
			echo "$createOutput"
		;;
		"3. Delete a user")
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
		"4. Add Console access to a existing user")
			echo "Enter the User Name you want to add Console access to:"
			read uname
			echo "Enter the password, make sure it is complex:"
      read upassword
      conOutput=$(aws iam create-login-profile --user-name "$uname" --password "$upassword" --password-reset-required --profile "$awsProfile")
		;;
		"5. Add CLI access to an existing user")
			echo "Enter the User Name you want to add CLI/Programatic access to:"
			read uname
			progOutput=$(aws iam create-access-key --user-name "$uname" --profile "$awsProfile")
		;;
    "6. Write user info to file and encrypt.")
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

