#!/bin/sh

#set applicaition name
appname="Firefox"

#set database variable
db="$appname.db"

#if database file do not exist then create one
if [ ! -f "$db" ]; then
  touch "$db"
fi

#set download link
download=$(echo "https://www.mozilla.org/en-US/firefox/all/")

#set language
lang=$(echo "en-US")

#download all links and put every link in the loop
wget -qO- "$download" | sed "s/http/\nhttp/g;s/\"/\n/g" | \
grep "^http.*win.*lang.*`echo $lang`" | \
sort | uniq | \
while IFS= read -r link; do

#check what is in the other side of link
wget -S --spider -o dl.log "$link"

#get direct url
url=$(sed "s/http/\nhttp/g;s/\.exe/\.exe\n/g" dl.log | grep -m1 "^http.*\.exe$")

#calculate file identificator which will be used as uniq ID for this file
id=$(echo "$link" | sed "s/^.*\///g")

#look if this filename is in database
grep "$id" $db > /dev/null
if [ $? -ne 0 ]; then

#get the filename 
filename=$(echo "$url" | sed "s/\//\n/g" | grep "exe")

#extract version number from URL
version=$(echo "$url" | sed "s/\//\n/g" | grep -v "[b-zA-Z]" | grep "[0-9]\+")

#show details on the screen
echo $id
echo $url
echo $filename
echo $version
echo

#put all information in the database
echo $id>> $db
echo $url>> $db
echo $filename>> $db
echo $version>> $db
echo >> $db

else
  echo $id is already in the database
fi

done
