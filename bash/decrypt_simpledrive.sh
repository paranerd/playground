#!/bin/bash

decrypt () {
	key_hex="$(printf $key | xxd  -c 256 -ps)"
	getRealFilename
	
	# read reformatted content
	$(sed -i 's/_/\//g' $path)
	$(sed -i 's/-/+/g' $path)
	content="$(cat $path)"
	
	# extract IV from content
	iv=${content:64:16}
	iv_hex="$(printf $iv | xxd  -c 256 -ps)"

	# extract data (strip away hash and iv)
	base64=${content:80}
	
	echo -n $base64 > encrypted_base64
	
	destination=$(dirname $path)"/"$filename
	
	openssl enc -aes-256-cbc -d -in encrypted_base64 -out $destination -base64 -A -K $key_hex -iv $iv_hex
}

getRealFilename () {
	filename=$(basename $path)
	
	if [ "$encrypted" -eq 1 ]; then
		# re-format filename and cut 64 characters of hash
		filename=${filename:64}
		filename=${filename//_/\/}
		filename=${filename//-/+}
		
		# extract IV from filename and convert to hex
		iv_filename=${filename:0:16}
		iv_filename_hex="$(printf $iv_filename | xxd  -c 256 -ps)"
		filename=${filename:16}
		
		# decrypt filename
		filename=$(echo $filename | openssl enc -aes-256-cbc -d -base64 -A -K $key_hex -iv $iv_filename_hex)
	fi
}

# set an initial value for the flag
encrypted=0

# read the options
TEMP=`getopt -o ep:k: --long encrypted,path:,key: -n 'test.sh' -- "$@"`
eval set -- "$TEMP"

# extract options and their arguments into variables.
while true ; do
    case "$1" in
        -e|--encrypted) encrypted=1 ; shift ;;
        -p|--path)
            case "$2" in
                "") shift 2 ;;
                *) path=$2 ; shift 2 ;;
            esac ;;
		-k|--key)
            case "$2" in
                "") shift 2 ;;
                *) key=$2 ; shift 2 ;;
            esac ;;
        --) shift ; break ;;
        *) echo "Internal error!" ; exit 1 ;;
    esac
done

decrypt
