#! /bin/bash
USAGE="usage: $0 <fill in usage>" 
DIR=~/.trashCan;  # Assigns the path to TrashCan to a variable
mkdir ~/.trashCan; # Creates the trasCan direcotry
touch ~/.trashCan/.monitorText; # creates a file called monitorText inside the TrashCan
clear; 
echo "Following Script was created by:"
echo "Spyridon Kalogeropoulos";
echo "S1632672";
sleep 1.5;
clear;

safeDel () # moves file or files into the trahCan Dir using the command [./safeDel.sh file file1 file2]
{
for filename in "$@"; do
mv "$filename" $DIR;
echo "$filename has successfully been moved to TrashCan!"
echo "$filename has successfully been moved to TrashCan!" >> ~/.trashCan/.monitorText;
done
}

list () {  #lists all none hiden files in the Trash can Directory and prints in the format of FILENAME-FILESIZE-FILETYPE
if [ "$(ls $DIR)" ]; then # checks is trashCan is empty
    for filename in $DIR/* ; do # initiates a loop
  LISTFILES=$(du -sb < $filename);
  FILE=$(basename $filename);
  TYPE=$(file -b $filename);
printf  "File: %s\t Size: %s\t Type: %s\t \n" "$FILE" "$LISTFILES" "$TYPE";
done # end of loop
else
    echo "Trashcan Directory is Empty"
fi # end of 'if'

}

recover () { # Recovers a file from the TrashCan into the Present Working Directory
  echo "Please specify the file you would like to recover"
  read name
  if [ -f ~/.trashCan/$name ]; then
     mv ~/.trashCan/$name .
     echo "File $name has been recovered"
     echo "File $(basename $name ) has been recovered from the TrashCan" >> ~/.trashCan/.monitorText
     else
     echo "File $name was not found"
     fi
}
recover2 () { # Same method as above but instead takes an OPTARG argument thus can be used without going through the menu but with a single command
if [ -f ~/.trashCan/$OPTARG ]; then
     mv ~/.trashCan/$OPTARG .
     echo "File $OPTARG has been recovered"
     echo "File $(basename $OPTARG ) has been recovered from the TrashCan" >> ~/.trashCan/.monitorText
     else
     echo "File $OPTARG was not found"
     fi
}

remove () { # Iterates through all the none hidden files in the trashCan directory and promts the user to answer Y/N if he wants to Delete them
  for filename in $DIR/*; do
    echo "do you wish to delete this file : $(basename $filename )";
    read yn;
    case $yn in
        [Yy]* ) rm $filename; 
                echo "The following file has been deleted $(basename $filename )" >> ~/.trashCan/.monitorText;
                echo "The following file has been deleted $(basename $filename )";;
        [Nn]* ) echo "";;
        * ) echo "Please answer yes or no.";;
    esac
done

}

total () { #Displays the total trashCan size
  echo "TrashCan size"
  echo "-------------"
 du -sb $DIR

}

monitor () { # Opens a new terminal window and starts the monitor script while keeping current monitor window open
xfce4-terminal -e ./monitor.sh &
}

monitor_kill () { # Closes the monitoring process
  pkill monitor.sh;
  #pkill -n bash;
}
MainTrap () { # A trap method which 1. prints the amount of regular files in the Directory 2. Prints a warning if the trashCan size exceeds 1kb
  SIZE=$(du -s $DIR | awk '{print $1}');
  
  cd $DIR
  funct=$(ls -l | grep ^- | wc -l)
  echo ""
  echo "|------------------------------------------------|"
  printf "| Number of regular files:$funct                      | \n" ;
  echo "|------------------------------------------------|"
  if [ "$SIZE" -gt 1 ]; then 
  echo "| WARNING ---- Directory size is larger than 1kb |"
  echo "|------------------------------------------------|"
  fi
  exit 0;
}

trap MainTrap EXIT SIGINT SIGTERM # Initiates the trap

while getopts :lr:dtmk args #options | Menu options
do
  case $args in
     l) list;;
     r) recover2;;
     d) remove;; 
     t) total;; 
     m) monitor;; 
     k) monitor_kill;;     
     :) echo "data missing, option -$OPTARG";;
    \?) echo "$USAGE";;
  esac
done

((pos = OPTIND - 1))
shift $pos

PS3='option> '

if (( $# == 0 )) # command line options
then if (( $OPTIND == 1 )) 
 then select menu_list in list recover delete total monitor kill exit
      do case $menu_list in
         "list") list;;
         "recover") recover;;
         "delete") remove;;
         "total") total;;
         "monitor") monitor;;
         "kill") monitor_kill;;
         "exit") exit 0;;
         *) echo "unknown option";;
         esac
      done
 fi
else safeDel "$@";
fi