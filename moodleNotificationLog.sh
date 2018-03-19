#!/bin/bash

PW=Sputnik78**
SQL=nosrebob
DATE=1520
MAILTO=acuteguy@150.252.118.143

apt-get update
apt-get upgrade

touch moodleLog.txt

# The chat feature does not seem to be enabled with Moodle 3.14.
# However, the 'message' table holds chat-like messages between students
# Students cannot send or receive group chats, so everyone is a unique recipient
echo "Number of messages sent : " >> moodleLog.txt
echo $SQL | mysql -u root -p -e "select count(*) from mdl_message where timecreated regexp '^$DATE';" moodle >> moodleLog.txt

# Anouncements are always sent to all students
echo "Number of anouncements sent: " >> moodleLog.txt
echo $SQL | mysql -u root -p -e "select count(*) from mdl_forum_discussions where timecreated regexp '^$DATE';" moodle >> moodleLog.txt

echo "Total number of unique recipients: " >> moodleLog.txt
echo $SQL | mysql -u root -p -e "select distinct count(*) from mdl_message where timecreated regexp '^$DATE';" moodle >> moodleLog.txt

#Send contents of moodleLog.txt to Dr. Byrd
cat ~/moodleLog.txt | mail -s "Number Moodle Messages and Recipients" $MAILTO

# cron job with cron -e. Runs moodleDataReport script everyday at 8:01 am
# 08 01 * * * ~/moodleDataReport.sh
