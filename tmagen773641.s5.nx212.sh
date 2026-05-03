#!/bin/bash
function ROOTCHECK()
{
  USER1=$(whoami)
  
if [ "$USER1" == "root" ]
then
echo "The user is ROOT, CONTINUING"
else
echo "The user is not ROOT, EXITING..."
sleep 3
exit
fi
}
ROOTCHECK
# Here we are checking to see if the user is root, and if not exiting .

function TOOLCHECK()
{
echo "Preparing to install the requierd tools, it might take some time.."
sudo apt-get update &> /dev/null
echo "If you need to install STRINGS type S, if not type N"
read STRINGS
if [ "$STRINGS" == "S" ]
then
sudo apt-get install strings -y &> /dev/null
else 
echo "Strings is already installed ."
fi

echo "If you need to install FOREMOST type F, if not type N"
read FOR
if [ "$FOR" == "F" ] 
then 
sudo apt-get install foremost -y &> /dev/null
else 
echo "Foremost is already installed ."
fi

echo "If you need to install BULK type B, if not type N"
read BUL
if [ "$BUL" == "B" ] 
then 
sudo apt-get install bulk_extractor -y &> /dev/null
else 
echo "BULK is already installed ."
fi

echo "If you need to install BINWALK type B, if not type N"
read BIN
if [ "$BIN" == "B" ] 
then 
sudo apt-get install binwalk -y &> /dev/null
else 
echo "BIN is already installed ."
fi

echo "If you need to install TSHARK type T, if not type N"
read TSH
if [ "$TSH" == "T" ]
then
sudo apt-get install tshark -y &> /dev/null
else
echo "Tshark is already installed ."
fi

}
TOOLCHECK
#Here we are checking availibilty of our needed tools, and downloading them if needed .

function FILECHECK()
{
	echo "Insert a file to analyze"
	read FILE 
	if [ -f "$FILE" ]
	then
	echo "The file exists ."
	else 
	echo "The file does not exists ."
	sleep 3
	clear
	FILECHECK
	fi
}
FILECHECK
#A quick check of file existence .

function CARVING()
{
	read -p "Choose a name for a new folder for all the extracted data :" NEW_FOLDER
	mkdir "$NEW_FOLDER" #This is the folder all the data gonna be saved .
	bulk_extractor $FILE -o "$NEW_FOLDER/bulk_data" &> /dev/null
	foremost $FILE -o "$NEW_FOLDER/fore_data" &> /dev/null
	#binwalk -e --run-as=root $FILE -C "$NEW_FOLDER/bin_data" &> /dev/null
    mkdir -p "$NEW_FOLDER/strings_data"
    strings $FILE | grep -i password > "$NEW_FOLDER/strings_data/pass.txt"
    strings $FILE | grep -i exe > "$NEW_FOLDER/strings_data/exe.txt"
    strings $FILE | grep -i user > "$NEW_FOLDER/strings_data/user.txt"
    strings $FILE | grep -i root > "$NEW_FOLDER/strings_data/root.txt"
    strings $FILE | grep -i error > "$NEW_FOLDER/strings_data/error.txt"
    strings $FILE | grep -i valid > "$NEW_FOLDER/strings_data/valid.txt"
    strings $FILE | grep -i system > "$NEW_FOLDER/strings_data/system.txt"
    strings $FILE | grep -i http > "$NEW_FOLDER/strings_data/http.txt"
}
CARVING
# Here we're creating a directory for all the data we want to carve,
#afetr that the carving begin with all of the requierd tools,
#plus another directory for all the "STRINGS" data .

function PCAPCHECK()
{
	   echo "Searching for pcap files"
    PCAP=$(find "$NEW_FOLDER" -type f -name "*.pcap")
    
    if [ -z "$PCAP" ]
    then
        echo "There is no pcap file available"
    else
        echo "------------------------------"
        echo "Pcap file found!"
        echo "------------------------------"
        echo "The location to the pcap file :"
        echo "$PCAP"
        sleep 1
        echo "------------------------------"
        echo "Present TSHARK output in a structured format :"
        sleep 1
        tshark -r "$PCAP" -c 10 2>/dev/null
    fi
}
PCAPCHECK
# An quick check for a pcap file, plus a small presenting of the traffic with TSHARK . 

function VOL3CHECK()
{
    read -p "Is the file you selected a memory file? (y/n) " CHOICE
    if [ "$CHOICE" != "y" ]; then
        echo "Skipping memory analysis..."
        return
    fi
    
    # Install and setup volatility3
    pip install volatility3 --break-system-packages &>/dev/null
    VOL=$(which vol)
    sudo mv $VOL "$VOL"3 &>/dev/null
    echo "[*] Analyzing memory dump..."
    
    # Try each OS type until one works
    for os in mac linux windows; do
        if vol3 -f $FILE ${os}.pslist 2>/dev/null | grep -q "Unsatisfied"; then
            echo "[-] ${os^} format incompatible"
        else
        mkdir "$NEW_FOLDER/VOL_data"
        # Making a new directory for the VOLATITILTY data .
            echo "[+] ${os^} format detected! Extracting process list..."
            vol3 -f $FILE ${os}.pslist 2>/dev/null > "$NEW_FOLDER/VOL_data/pslist.txt"
            vol3 -f $FILE ${os}.pstree 2>/dev/null > "$NEW_FOLDER/VOL_data/pstree.txt"
            vol3 -f $FILE ${os}.netstat 2>/dev/null > "$NEW_FOLDER/VOL_data/netstat.txt"
            return
        fi
    done
    
    echo "[!] No compatible OS format found"
}
VOL3CHECK

function REPORT()
{
    echo "Date of the scan: $(date)" | tee -a "$NEW_FOLDER/report.txt"
    echo "----------------------------------------" | tee -a "$NEW_FOLDER/report.txt"
    echo "The main folders are:" | tee -a "$NEW_FOLDER/report.txt"
    find "$NEW_FOLDER" -maxdepth 1 -type d | tee -a "$NEW_FOLDER/report.txt"
    echo "----------------------------------------" | tee -a "$NEW_FOLDER/report.txt"
    echo "The number of files in the bulk_data folder:" | tee -a "$NEW_FOLDER/report.txt"
    find "$NEW_FOLDER/bulk_data" | wc -l | tee -a "$NEW_FOLDER/report.txt"
    echo "The number of files in the fore_data folder:" | tee -a "$NEW_FOLDER/report.txt"
    find "$NEW_FOLDER/fore_data" | wc -l | tee -a "$NEW_FOLDER/report.txt"
    #echo "The number of files in the bin_data folder:" | tee -a "$NEW_FOLDER/report.txt"
    #find "$NEW_FOLDER/bin_data" | wc -l | tee -a "$NEW_FOLDER/report.txt"
    echo "The number of files in the strings_data folder:" | tee -a "$NEW_FOLDER/report.txt"
    find "$NEW_FOLDER/strings_data" | wc -l | tee -a "$NEW_FOLDER/report.txt"
    echo "----------------------------------------" | tee -a "$NEW_FOLDER/report.txt"
    echo "Total executable files carved:" | tee -a "$NEW_FOLDER/report.txt"
    find "$NEW_FOLDER" -name "*.exe" | wc -l | tee -a "$NEW_FOLDER/report.txt"
    echo "----------------------------------------"
    echo "PCAP file exists . "
    echo "Path :  $PCAP"
    echo "----------------------------------------"
    # A quick report with a few details of the script execution .
    echo "Creating zip .."
    # Creating a ZIP for everything we did
    zip -r "$NEW_FOLDER.zip" "$NEW_FOLDER" &>/dev/null
    echo "Zip file created successfully : $NEW_FOLDER.zip"
    # Deleting temporary folder, keeping zip file
    sudo rm -rf "$NEW_FOLDER"
    echo "Done! Your results are in: $NEW_FOLDER.zip"
}
REPORT
