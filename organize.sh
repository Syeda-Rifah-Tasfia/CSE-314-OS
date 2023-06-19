#!bin/bash/sh

num_arguments=$#

#echo "Number of arguments: $num_arguments"

if [ "$num_arguments" -lt 4 ]; then
    echo "Usage:"
    echo "sh organize.sh <submission folder> <target folder> <test folder> <answer folder> [-v] [-noexecute]"
    echo " "
    echo "-v: verbose"
    echo "-noexecute: do not execute code files"
    kill -INT $$ 
fi

if [ -d "$2"/ ]; then
    rm -rf "$2"/
fi
mkdir "$2"
cd "$2"/

csv_file="result.csv"
echo "student_id, type, matched, not_matched" > "$csv_file"

mkdir C
mkdir Python
mkdir Java

cd ..
cd "$1"/

search_dir=$PWD
output_dir=$PWD

i=0
        folder="../$3"
        for testfile in "$folder"/*
        do
            i=`expr $i + 1`
        done

if [ "$5" = "-v" ]; then
    echo "Found $i test files"
fi

find "$search_dir" -type f -name "*.zip" | while read -r file
do
    #echo "Found zip file: $file"
    type=""
    filename=$(basename "$file" .zip)

    #echo $filename

    pattern="[0-9][0-9]05[0-9][0-9][0-9]"
    substring=$(echo "$filename" | grep -oE "$pattern")

    if [ "$5" = "-v" ]; then
        echo "Organizing files of $substring"
    fi
    
    if [ -d "$substring" ]; then
        # Remove the existing directory
        rm -rf "$substring"
    else
        mkdir $substring
    fi

    

    #output_dir = "$substring"

    unzip -o -q "$file" -d "$substring"

    #$? -eq 0
    if find "$search_dir" -type f -name "*.c" | grep -q .; then
        type=C
        if [ "$5" = "-v" ] && [ "$6" != "-noexecute" ]; then
            echo "Executing files of $substring"
        fi
        mkdir ../targets/C/$substring
        find "$search_dir" -type f -name "*.c" -exec mv {} "../$2/C/$substring/main.c" \;
        
        if [ "$6" != "-noexecute" ]; then
            #EXECUTION BEGINS
            
            gcc "../$2/C/$substring/main.c" -o "../$2/C/$substring/main.out"

            i=1
            folder="../$3"
            for testfile in "$folder"/*
            do
                # echo $i
                # echo $testfile
                "../$2/C/$substring/main.out" < "$testfile" > "../$2/C/$substring/out$i.txt"
                i=`expr $i + 1`
            done    

            #anspattern="[0-9]"
            folder="../$2/C/$substring"
            unmatched=0
            matched=0
            i=1

            folder1="../$2/C/$substring"
            folder2="../$4"
            file_extension=".txt"  # Change the extension to the desired file type

            anspattern="[0-9]"
            # Find the files with the same extension in folder1
            files_folder1=$(find "$folder1" -type f -name "*$file_extension")

            # Iterate over the files in folder1 and compare with files in folder2
            for file1 in $files_folder1; do
                # Extract the filename
                filename=$(basename "$file1")
                substr=$(echo "$filename" | grep -oE "$anspattern")
                
                # Find the corresponding file in folder2
                file2=$(find "$folder2" -type f -name "ans$i.txt")
                
                # # Compare the files if found
                if [ -n "$(echo "$ans$i.txt" | grep "$substr")" ]; then
                #if [[ $filename == *"$substr"* ]]; then
                    output=$(diff "$file1" "$file2")
                fi

                if [ -z "$output" ]; then
                    matched=`expr $matched + 1`
                else
                    unmatched=`expr $unmatched + 1`
                fi
                i=`expr $i + 1`
            done

            # echo "type = $type"
            # echo "matched = $matched"
            # echo "unmatched = $unmatched"
        
            echo "$substring","$type","$matched","$unmatched" >> "../$2/result.csv"
        fi


    elif find "$search_dir" -type f -name "*.java" | grep -q .; then
        type=Java
        if [ "$5" = "-v" ] && [ "$6" != "-noexecute" ]; then
            echo "Executing files of $substring"
        fi
        mkdir ../$2/Java/$substring
        find "$search_dir" -type f -name "*.java" -exec mv {} "../$2/Java/$substring/Main.java" \;
        
        if [ "$6" != "-noexecute" ]; then
            #EXECUTION BEGINS
            javac -d "../$2/Java/$substring" "../$2/Java/$substring/Main.java"
            
            i=1
            folder="../$3"
            for testfile in "$folder"/*
            do
                java "../$2/Java/$substring/Main.java" < "$testfile" > "../$2/Java/$substring/out$i.txt"
                i=`expr $i + 1`
            done

            folder="../$2/Java/$substring"
            unmatched=0
            matched=0
            i=1

            folder1="../$2/Java/$substring"
            folder2="../$4/"
            file_extension=".txt"  # Change the extension to the desired file type

            anspattern="[0-9]"
            # Find the files with the same extension in folder1
            files_folder1=$(find "$folder1" -type f -name "*$file_extension")

            # Iterate over the files in folder1 and compare with files in folder2
            for file1 in $files_folder1; do
                # Extract the filename
                filename=$(basename "$file1")
                substr=$(echo "$filename" | grep -oE "$anspattern")
                
                # Find the corresponding file in folder2
                file2=$(find "$folder2" -type f -name "ans$i.txt")
                
                # # Compare the files if found
                if [ -n "$(echo "$ans$i.txt" | grep "$substr")" ]; then
                #if [[ $filename == *"$substr"* ]]; then
                    output=$(diff "$file1" "$file2")
                fi

                if [ -z "$output" ]; then
                    matched=`expr $matched + 1`
                else
                    unmatched=`expr $unmatched + 1`
                fi
                i=`expr $i + 1`
            done

            # echo "type = $type"
            # echo "matched = $matched"
            # echo "unmatched = $unmatched"
        
            echo "$substring","$type","$matched","$unmatched" >> "../$2/result.csv"
        fi
        

    elif find "$search_dir" -type f -name "*.py" | grep -q .; then
        type=Python
        if [ "$5" = "-v" ] && [ "$6" != "-noexecute" ]; then
            echo "Executing files of $substring"
        fi
        mkdir ../$2/Python/$substring
        find "$search_dir" -type f -name "*.py" -exec mv {} "../$2/Python/$substring/main.py" \;

        if [ "$6" != "-noexecute" ]; then
            #EXECUTION BEGINS
            i=1
            folder="../$3"
            for testfile in "$folder"/*
            do
                python "../$2/Python/$substring/main.py" < "$testfile" >"../$2/Python/$substring/out$i.txt"
                i=`expr $i + 1`
            done   

            folder="../$2/Python/$substring"
            unmatched=0
            matched=0
            i=1

            folder1="../$2/Python/$substring"
            folder2="../$4/"
            file_extension=".txt"  # Change the extension to the desired file type

            anspattern="[0-9]"
            # Find the files with the same extension in folder1
            files_folder1=$(find "$folder1" -type f -name "*$file_extension")

            # Iterate over the files in folder1 and compare with files in folder2
            for file1 in $files_folder1; do
                # Extract the filename
                filename=$(basename "$file1")
                substr=$(echo "$filename" | grep -oE "$anspattern")
                
                # Find the corresponding file in folder2
                file2=$(find "$folder2" -type f -name "ans$i.txt")
                
                # # Compare the files if found
                if [ -n "$(echo "$ans$i.txt" | grep "$substr")" ]; then
                #if [[ $filename == *"$substr"* ]]; then
                    output=$(diff "$file1" "$file2")
                fi

                if [ -z "$output" ]; then
                    matched=`expr $matched + 1`
                else
                    unmatched=`expr $unmatched + 1`
                fi
                i=`expr $i + 1`
            done

            echo "$substring","$type","$matched","$unmatched" >> "../$2/result.csv"
        fi
    fi

    if [ -d "$substring" ]; then
        # Remove the existing directory
        rm -rf "$substring"
    fi
done
