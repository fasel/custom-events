#!/bin/bash

# reads EWH RSS and put out enriched csv to be imported into events manager
# easy mass import
# probably you want to manually filter the csv before import

TEMPDIR=$(mktemp -d)
RSS="http://www.einewelthaus.de/veranstaltungen/aktuelle-veranstaltungen/rss/"
echo $(date) -- getting RSS
if [[ $1 ]]; then
	# you can call with single URL
	echo $1 > ${TEMPDIR}/RSS
else
	# grep for raw event links
	wget --quiet "${RSS}" -O - | grep link | grep events | grep -oP "(?<=>).*?(?=<)" > ${TEMPDIR}/RSS
fi
OUTFILE=/tmp/ewh.csv

getinfo () {
	HTML="${F}"
	ICAL="${F}ical/"

	# get corresponding HTML page
	echo $(date) -- getting HTML
	HTMLOUT=$(wget --quiet "${HTML}" -O "${TEMPDIR}/HTML")

	# parse content
	# replace comma and windows newlines
	echo $(date) -- parsing
	TITLE=$(grep '<title>' "${TEMPDIR}/HTML" | grep -oP "(?<=>).*?(?=›)" | php -R 'echo html_entity_decode($argn);' | sed -e $'s/,/\&#44;/g') 
	CONTENT=$(awk '/entry-title-event/,/event-categories/' "${TEMPDIR}/HTML" | sed -e $'s///g' | tr '\n' ' ' | sed -e $'s/,/\&#44;/g')
	#PLACE=$(grep 'Veranstaltungsort:' "${TEMPDIR}/HTML" | grep -oP "(?<=:).*?(?=<)" | sed -e $'s///g' | tr '\n' ' ' | sed -e $'s/,/\&#44;/g') 
	ROOM=$(grep 'Raum:' "${TEMPDIR}/HTML" | grep -oP "(?<=:).*?(?=<)" | sed -e $'s///g' | tr '\n' ' ' | sed -e $'s/,/\&#44;/g') 
	DATE=$(grep -A 1 singlebalken "${TEMPDIR}/HTML" | tail -n 1 | sed -e $'s///g' | tr '\n' ' ' | sed -e $'s/,/\&#44;/g')
	TIME=$(grep -A 1 singletime "${TEMPDIR}/HTML" | grep "Uhr" | sed -e $'s///g' | tr '\n' ' ' | sed -e $'s/,/\&#44;/g')
	CATEGORIES=$(grep '/categories/' "${TEMPDIR}/HTML" | sed -e $'s///g' | tr '\n' ' ' | sed -e $'s/,/\&#44;/g')
	EINTRITT=$(grep 'Eintritt:' "${TEMPDIR}/HTML" | grep -oP "(?<=:).*?(?=<)" | sed -e $'s///g' | tr '\n' ' ' | sed -e $'s/,/\&#44;/g')

	# CSV content
	echo "$TITLE","$DATE" "$TIME" "$CONTENT" "$CATEGORIES","$ROOM","$HTML","$EINTRITT" >> $OUTFILE
	

}

# CSV header
echo titel,content,raum,link,eintritt > $OUTFILE

while read F; do
	getinfo
done <"${TEMPDIR}/RSS"

echo $(date) -- done

