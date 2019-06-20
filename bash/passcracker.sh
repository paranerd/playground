#!/bin/bash
# passcracker -f [fileToCrack] (-w [wordlist] || -b)

n=0 # For tried-password-count
startTime="$(date +%s)"

word () {
    echo -e "Total: \t\t $(wc -l < $wordlist)" # \t = Tabulator
    echo -e "\n" # Needed b/c of latter formating
    while read line           
    do       
	echo -e "$(tput cuu1)$(tput cuu1)Checked: \t $n"
	echo -e "Trying: \t [$line] ..."
	unzip -q -o -P $line $archive 2> /dev/null
	#7z -p$line e $1
	if [ $? = 0 ]; then # Successful unzip (exit status "0" means "normal, no errors or warnings detected")
	    endTime="$(date +%s)"
	    total=$(($endTime - $startTime))
	    echo -e "$(tput cuu1)$(tput el)Success! \t [$line]" # Each cuu1 moves a line up, el deletes the current line
	    #echo "$(tput cud1)" # Move cursor down again to continue echo below previous lines
	    echo -e "Time: \t\t $total sec"
	    break
	fi
	n=$(($n+1))
	done < $wordlist
}

brute () {
    echo "Bruteforce!"
}

while getopts ":w:bf:" opt; do
  case $opt in
    w)
	wordlist="$OPTARG" >&2
	word # Calls wordlist-function
      ;;
    b)
	brute >&2 # Calls bruteforce-function
      ;;
    f)
	archive=$OPTARG >&2
	;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done
