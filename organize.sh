#!bin/bash/sh

if [ -d "targets/" ]; then
    rm -rf "targets/"
fi
mkdir targets
cd targets/

csv_file="result.csv"
echo "student_id, type, matched, not_matched" > "$csv_file"

mkdir C
mkdir Python
mkdir Java

cd ..
cd submissions/

search_dir=$PWD
output_dir=$PWD

i=0
        folder="../tests"
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
        find "$search_dir" -type f -name "*.c" -exec mv {} "../targets/C/$substring/main.c" \;
        
        if [ "$6" != "-noexecute" ]; then
            #EXECUTION BEGINS
            
            gcc "../targets/C/$substring/main.c" -o "../targets/C/$substring/main.out"

            i=1
            folder="../tests"
            for testfile in "$folder"/*
            do
                # echo $i
                # echo $testfile
                "../targets/C/$substring/main.out" < "$testfile" > "../targets/C/$substring/out$i.txt"
                i=`expr $i + 1`
            done    

            #anspattern="[0-9]"
            folder="../targets/C/$substring"
            unmatched=0
            matched=0
            i=1

            folder1="../targets/C/$substring"
            folder2="../answers/"
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
        
            echo "$substring","$type","$matched","$unmatched" >> "../targets/result.csv"
        fi


    elif find "$search_dir" -type f -name "*.java" | grep -q .; then
        type=Java
        if [ "$5" = "-v" ] && [ "$6" != "-noexecute" ]; then
            echo "Executing files of $substring"
        fi
        mkdir ../targets/Java/$substring
        find "$search_dir" -type f -name "*.java" -exec mv {} "../targets/Java/$substring/Main.java" \;
        
        if [ "$6" != "-noexecute" ]; then
            #EXECUTION BEGINS
            javac -d "../targets/Java/$substring" "../targets/Java/$substring/Main.java"
            
            i=1
            folder="../tests"
            for testfile in "$folder"/*
            do
                java "../targets/Java/$substring/Main.java" < "$testfile" > "../targets/Java/$substring/out$i.txt"
                i=`expr $i + 1`
            done

            folder="../targets/Java/$substring"
            unmatched=0
            matched=0
            i=1

            folder1="../targets/Java/$substring"
            folder2="../answers/"
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
        
            echo "$substring","$type","$matched","$unmatched" >> "../targets/result.csv"
        fi
        

    elif find "$search_dir" -type f -name "*.py" | grep -q .; then
        type=Python
        if [ "$5" = "-v" ] && [ "$6" != "-noexecute" ]; then
            echo "Executing files of $substring"
        fi
        mkdir ../targets/Python/$substring
        find "$search_dir" -type f -name "*.py" -exec mv {} "../targets/Python/$substring/main.py" \;

        if [ "$6" != "-noexecute" ]; then
            #EXECUTION BEGINS
            i=1
            folder="../tests"
            for testfile in "$folder"/*
            do
                python "../targets/Python/$substring/main.py" < "$testfile" >"../targets/Python/$substring/out$i.txt"
                i=`expr $i + 1`
            done   

            folder="../targets/Python/$substring"
            unmatched=0
            matched=0
            i=1

            folder1="../targets/Python/$substring"
            folder2="../answers/"
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

            echo "$substring","$type","$matched","$unmatched" >> "../targets/result.csv"
        fi
    fi

    if [ -d "$substring" ]; then
        # Remove the existing directory
        rm -rf "$substring"
    fi
done
