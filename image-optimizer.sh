#!/bin/sh
# desc: shell script to sync s3 to local directory
# created 2019-09-25
# last modified 2020-10-06
# github.com/kulacino/s3-image-optimizer || halo[at]ayuwelirang[dot]com

# vars (you could also change it into $1 $2 etc and value will be stated from your shell)
myprofile="default"
remote="s3://your-S3-bucket"
backupremote="s3://your-S3-bucket-forbackup"
localdir="/home/user/your-S3-bucket-downloaded"
reportdir="/home/user/imagesoptimizer_report"
date=`date +"%Y%m%d"`
date2=`date +"%Y-%m-%d"`
CHAT_ID="-100xxxxxxxxx2" ## chat_id generated from your Telegram BotFather

# send message to telegram
# curl execution starts
curl -s -X POST https://api.telegram.org/botXXXXXXXXX:XXXXXXXX-XXXXXXXX_xxxxxxxxxxxx_XX/sendMessage \
     -d chat_id=$CHAT_ID \
     -d text="#Optimize image from $remote bucket is started."

# Script starts from here!
#
# 1. Backup the original first
# 1a. Add date vars after backupremote 2019-10-05
aws s3 sync $remote/ $backupremote/$date2/ --profile=$myprofile

# 2. Execute s3sync
cd $localdir && aws s3 sync $remote . --profile=$myprofile

# 3. Put listing result into log txt
cd $reportdir && tree -pugh $localdir -o $date"_images_listing_report.txt"

# 4. Put size listing result into log txt
cd $localdir && du -hs * | sort -rh >> $reportdir/$date"_images_folder_size_report.txt"

# 5. Optimize JPEG above 100k
cd $localdir && find . -iname "*.jpg" -size +100k -exec jpegoptim --size=100k -o -p {} \;
cd $localdir && find . -iname "*.jpeg" -size +100k -exec jpegoptim --size=100k -o -p {} \;

# 6. Optimize png above 100k
cd $localdir && find . -iname "*.png" -size +100k -exec optipng {} \;

# 7. Send optimized images back into s3
cd $localdir && aws s3 cp . $remote --profile=$myprofile --recursive --acl public-read --cache-control max-age=604800,s-maxage=2592000 --expires 2030-12-31T05:59:00Z

# 8. Send message to telegram
# curl execution finish
curl -s -X POST https://api.telegram.org/botXXXXXXXXX:XXXXXXXX-XXXXXXXX_xxxxxxxxxxxx_XX/sendMessage \
     -d chat_id=$CHAT_ID \
     -d text="S3 image from $remote bucket is successfully #optimized."

# eof
