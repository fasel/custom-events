#!/bin/bash

# reads EWH RSS and put out enriched csv to be imported into events manager
# easy mass import
# probably you want to manually filter the csv before import

TEMPDIR=$(mktemp -d)
RSS="http://www.einewelthaus.de/veranstaltungen/aktuelle-veranstaltungen/rss/"
OUTFILE=~/incoming/ewh.csv
echo $(date) -- getting RSS
if [[ $1 ]]; then
	# you can call with single URL
	echo $1 > ${TEMPDIR}/RSS
else
	# grep for raw event links
	wget --quiet "${RSS}" -O - | grep link | grep events | grep -oP "(?<=>).*?(?=<)" > ${TEMPDIR}/RSS
fi

getinfo () {
	HTML="${F}"
	ICAL="${F}ical/"

	# get corresponding HTML page
	echo $(date) -- getting HTML
	HTMLOUT=$(wget --quiet "${HTML}" -O "${TEMPDIR}/HTML" --header="User-Agent: Mozilla/5.0 (Windows NT 5.1; rv:23.0) Gecko/20100101 Firefox/23.0")

	# parse content
	# replace comma and windows newlines
	echo $(date) -- parsing
	# EWH
	if [[ ${F} == *"einewelthaus.de"* ]]; then
		TITLE=$(grep '<title>' "${TEMPDIR}/HTML" | grep -oP "(?<=>).*?(?=›)" | php -R 'echo html_entity_decode($argn);' | sed -e $'s/,/\&#44;/g') 
		CONTENT=$(awk '/entry-title-event/,/event-categories/' "${TEMPDIR}/HTML" | sed -e $'s///g' | tr '\n' ' ' | sed -e $'s/,/\&#44;/g')
		#PLACE=$(grep 'Veranstaltungsort:' "${TEMPDIR}/HTML" | grep -oP "(?<=:).*?(?=<)" | sed -e $'s///g' | tr '\n' ' ' | sed -e $'s/,/\&#44;/g') 
		ROOM=$(grep 'Raum:' "${TEMPDIR}/HTML" | grep -oP "(?<=:).*?(?=<)" | sed -e $'s///g' | tr '\n' ' ' | sed -e $'s/,/\&#44;/g') 
		DATE=$(grep -A 1 singlebalken "${TEMPDIR}/HTML" | tail -n 1 | sed -e $'s///g' | tr '\n' ' ' | sed -e $'s/,/\&#44;/g')
		TIME=$(grep -A 1 singletime "${TEMPDIR}/HTML" | grep "Uhr" | sed -e $'s///g' | tr '\n' ' ' | sed -e $'s/,/\&#44;/g')
		CATEGORIES=$(grep '/categories/' "${TEMPDIR}/HTML" | sed -e $'s///g' | tr '\n' ' ' | sed -e $'s/,/\&#44;/g')
		EINTRITT=$(grep 'Eintritt:' "${TEMPDIR}/HTML" | grep -oP "(?<=:).*?(?=<)" | sed -e $'s///g' | tr '\n' ' ' | sed -e $'s/,/\&#44;/g')
	# Facebook
	else
		TITLE=$(grep -o -E '<title.*|' "${TEMPDIR}/HTML" | grep -oP "(?<=>).*?(?= \|)" | php -R 'echo html_entity_decode($argn);' | sed -e $'s/,/\&#44;/g')
		CONTENT=$(grep -o -E '<span class="fsl">.*</span>' "${TEMPDIR}/HTML" | grep -oP "(?<=>).*?(?=<)" | sed -e $'s/^M//g' | tr '\n' ' ' | sed -e $'s/,/\&#44;/g')
		PLACE=$(grep -o -E '<a class="_5xhk".*_4-u2' "${TEMPDIR}/HTML" | grep -oP "(?<=>).*?(?=<)" | sed -e $'s/^M//g' | tr '\n' ' ' | sed -e $'s/,/\&#44;/g')
		PLACE=$(grep -o -E 'class="_5xhk".*_' "${TEMPDIR}/HTML" | grep -oP '(?<=>).*?(?=<)' | sed -e 's/^M//g' | sed ':a;N;$!ba;s/\n//g' | sed -e $'s/,/\&#44;/g')
		#ROOM=$(grep 'Raum:' "${TEMPDIR}/HTML" | grep -oP "(?<=:).*?(?=<)" | sed -e $'s///g' | tr '\n' ' ' | sed -e $'s/,/\&#44;/g') 
		DATE=$(grep -o -E '<span itemprop="startDate".*' "${TEMPDIR}/HTML" | grep -oP "(?<=content=\").*?(?=\")" | head -n 1 | xargs date --date)
		#TIME=$(grep -A 1 singletime "${TEMPDIR}/HTML" | grep "Uhr" | sed -e $'s///g' | tr '\n' ' ' | sed -e $'s/,/\&#44;/g')
		#CATEGORIES=$(grep '/categories/' "${TEMPDIR}/HTML" | sed -e $'s///g' | tr '\n' ' ' | sed -e $'s/,/\&#44;/g')
		#EINTRITT=$(grep 'Eintritt:' "${TEMPDIR}/HTML" | grep -oP "(?<=:).*?(?=<)" | sed -e $'s///g' | tr '\n' ' ' | sed -e $'s/,/\&#44;/g')
	fi

	# CSV content
	echo "$TITLE","$DATE" "$TIME <br>" "$CONTENT" "$CATEGORIES <br>" "$PLACE","$ROOM","$HTML","$EINTRITT" >> $OUTFILE
	

}

# CSV header
if [[ $2 != "add" ]]; then
	echo titel,content,raum,link,eintritt > ${OUTFILE}
fi

while read F; do
	getinfo
done <"${TEMPDIR}/RSS"

echo $(date) -- done

