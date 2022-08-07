#!/bin/bash

c=0

function menu_header()
{
  clear
  echo -e "1.Signin \n \t1.Take test\n\t2.View test\n2.Signup\n3.Exit"  
  read -t 10 choice
 
  if [ -z $choice ]                                             #Display error message if there in no input from user in set time (10 secs)
  then
      echo "Error: Timeout, Please provide input "
      sleep 2
      menu_header

  else

      case $choice in
      1) sign_in
          ;;

      2) sign_up
	  ;;
      3) exit
	  ;;
      *) echo "Error: Invalid input"
	 sleep 2
          ;;

      esac  
  fi
}


function test_menu()
{
   clear
   echo -e "1.Take test\n2.View test\n3.Back to main menu"
   read choice

   if [ $choice -eq 1 ]
   then
       test_screen $1

   elif [ $choice -eq 2 ]
   then
       view_test $1

   elif [ $choice -eq 3 ]
   then
       menu_header
   
   else
       echo "Error: Invalid input"
       sleep 2
   fi

}


function sign_up()
{
    clear
    echo -n "Please choose your username: "					       #ask the user to enter username
    read username
   
    username_arr=(`cut -d " " -f1 /home/swizell/ECEP/LinuxSystem/project/usernames.txt`) #store all usernames in an array
    count=0									       #initialize count to 0

    if [[ $username =~ ^[0-9a-zA-Z]+$ ]]                                            #checking if username doesnt contain special characters
    then
	
	for i in `seq 0 $((${#username_arr[@]} - 1))`				    #loop for length of array - 1
	    
	do
	    if [ "$username" == "${username_arr[$i]}" ]				    #if username already exist print error message
	    then
	    	count=1
		break
	    fi

	done

           if [ $count -eq 0 ]						#if username doesnt exist execute the following line of code
	   then
    
	   echo -n "Please Enter a password: "				#ask user to enter password
           read -s password					#store user input into a variable password in set time(10 secs)
    


              if [[ ${#password} -ge 6 && "$password" == *[[:lower:]]* && "$password" == *[[:upper:]]* && "$password" == *[0-9]* && "$password" == *[[:punct:]]* ]]	
#checking if varaible password has atleast 6 characters 1 alphanumeric and 1 special character

              then

              echo
              echo -n "Please Re-enter your password: "
              read -s password_check
              echo


       	

                 if [ "$password" = "$password_check" ]		#verifying if both the passwords entered by user is the same    
                 then
         
                 echo $password >> passwords.txt                        #append value of the variable password in a file passwords.txt
                 echo $username >> usernames.txt                        #append value of the variable username in a file usernames.txt
	         echo "Registration sucessfull. Please hit any key to continue"
                 read press
	 if [ $press = 1 ]
	 then
	     menu_header
	 else
	     menu_header
	 fi
	


         else
	 echo "Error: The entered passwords do not match"              #print error message if passwords entered by user do not match
         sleep 3
	 menu_header
          fi


        else
	echo
	echo "Error: Weak password ! Your password should contain minimum 6 characters with atleast 1 upper case, 1 lower , 1 numeric and 1 special character" 
	#Print error message if password is weak
	sleep 3
	menu_header
    fi
            else
	    echo "Error: Username already exists. Please enter a new username"                    #Error message if username already exist

        fi
     
     
        else
	echo "Error: Username should contain only alphanumeric symbols"         #print error message if username contains special characters
fi


}



function sign_in ()
{

clear   
count1=0                                        #initialize count1 to 0 
echo -n "Please enter your username: "
read username
echo -n "Please enter your password: "
read -s -t 10 password                          #read user input in set time that is 10 seconds and store in variable password

if [ -z $password ]                             #displaying error message if timeout occurs
then
    echo "Error: timeout while entering password"
else

username_arr=(`cut -d " " -f1 /home/swizell/ECEP/LinuxSystem/project/usernames.txt`)  #storing the contents of file in an array
password_arr=(`cut -d " " -f1 /home/swizell/ECEP/LinuxSystem/project/passwords.txt`)

for i in `seq 0 $((${#username_arr[@]} - 1))`   #running the loop from 0 to length of array - 1
do
    if [ "$username" = "${username_arr[$i]}" ]  #if username already exist then increment count to 1
    then
	count1=1
	temp=$i

    fi

done

if [ $count1 -eq 1 -o $count1 -eq 0 ]
then
    if [ "$password" = "${password_arr[$temp]}" ] #checking if entered password matches with user password
    then
    echo
    echo "$username you are sucessfully logged in"
    sleep 2
    test_menu $username
    else
    echo Oops incorrect details
fi
fi
fi

}

function test_screen()

{
    clear
    lines=`wc -l /home/swizell/ECEP/LinuxSystem/project/question_bank.txt | cut -d " " -f1` 
    #store the total number of lines in file question_bank.txt in a variable lines

    c=0                                            #initialize variable count to 0
    ra=0					   #initialize variable right answer to 0

   
   for i in `seq 6 7 $(($lines - 1))`              #loop from 6 till lines in increment of 7
   do
       answer_arr=(`cut -d " " -f1 /home/swizell/ECEP/LinuxSystem/project/answers.txt`)      #storing content of file in an array
    
       
       echo
       echo "<-------TEST-------->"
       head -$i ./question_bank.txt | tail -6
       head -$i ./question_bank.txt | tail -6 >> ./test_data/answer_file.csv    #using head and tail command to view 6 lines at a time 
       head -$i ./question_bank.txt | tail -6 >> ./test_data/test_activity.log

       read -t 10 ans

       if [ -z $ans ]								 #reading input from user for 10 seconds
       then
        
	  echo "Error: Timeout , Please input your answer in 10 seconds"
	  echo Timeout >> ./test_data/answer_file.csv
	
       else

	   if [ "$ans" = "${answer_arr[$c]}" ]               #if user input matches the correct answer then increment ra variabe by 1                   
	   then
	       echo "Correct answer"
               echo "$ans is correct answer" >> ./test_data/answer_file.csv
               echo "$ans is correct answer" >> ./test_data/test_activity.log
	       ra=$(($ra+1))
	   
	   else
	       echo "Incorrect answer"
	       echo "$ans is wrong answer" >> ./test_data/answer_file.csv
               echo "$ans is wrong answer" >> ./test_data/test_activity.log
	   fi
        fi

	c=$(($c+1))
	
 done
 clear
 
 echo " $1 Your test score is $ra / 4 "
 echo " $1 Your test score is $ra / 4 " >> ./test_data/answer_file.csv
 echo " $1 Your test score is $ra / 4 " >> ./test_data/test_activity.log
 sleep 5
 test_menu $c
 


}

function view_test()

{

if [ $c -eq 0 ]
then
    clear
    echo You have not answered the test
    sleep 3
    test_menu


else
    clear
    echo "<--------$username Test Results-------->"
    echo
    tail -29 ./test_data/answer_file.csv
    echo
    echo -e "Press q to quit"
    read press

    if [ "$press" = "q" ]
    then
	exit

    else
	exit

    fi




fi

}

menu_header




