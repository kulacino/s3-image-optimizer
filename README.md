# s3-image-optimizer

Bash script to recursively download images from S3 and optimize it, then upload it back into S3. **Note** that this bash script only works for JPEG, JPG, and PNG files only. I hadn't created another logic for BMP, GIF, etc.

# Quick Info

```
#!/bin/sh
# description: shell script to sync s3 to local directory
# created 2019-09-25
# last modified 2020-10-06
# github.com/kulacino/s3-image-optimizer | halo[at]ayuwelirang[dot]com
```

Created around 25 September 2019 as a part of my job in my company and then I start to modify it, so the script could be uploaded here as my personal portfolio.

# Requirement

To use this bash script, you need to use several tools in your localhost. Below is the list of that tools:

1. `jpegoptim` tools.
2. `optipng` tools.
3. `curl` tools _(optional)_.
4. Telegram CHAT_ID and API to use bot _(optional)_

# Tools Installation

This script only need `jpegoptim` to optimize jpg based image and `optipng` for PNG image. Below is the step-by-step to install those tools.

## jpegoptim

To install `jpegoptim` you could hit below command:

**In Debian and it's derivatives:**

```
# apt-get install jpegoptim

or

$ sudo apt-get install jpegoptim
```

**CentOS and RHEL:**

```
# yum install epel-release
# yum install jpegoptim
```

**Fedora 22+ versions:**

```
# dnf install epel-release
# dnf install jpegoptim
```

For more details in `jpegoptim` usage, just type: `man jpegoptim`. 

## optiPNG

To install `optipng` you could try below command:

**Debian and it's derivatives:**

```
apt-get install optipng (use sudo if you're not root)
```

**CentOS, RHEL Based and Fedora 22+**:

```
yum install optipng
dnf install optipng (Fedora 22+ version)
```

Fore more details in `optipng` usage, just type: `man optipng`.

# Script Explanation

I will explain what is inside the script. If you have any question, please contact me here at: halo(at)ayuwelirang(dot)com or simply drop a message via Github.

```
#!/bin/sh
# desc: shell script to sync s3 to local directory
# created 2019-09-25
# last modified 2020-10-06
# github.com/kulacino/s3-image-optimizer || halo[at]ayuwelirang[dot]com

# vars (you could also change it into $1 $2 etc)
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
```

**Explanation:**

Vars or variable could be used as string and you could call it without having to repeat the value you need inside the script. My variable consists of:
- `myprofile` is AWS profile in your local.
- `remote` is your S3 bucket with the content you need to optimize.
- `backupremote` is another S3 bucket to copy your original files, just in case there is an error, you could always roll back the original images.
- `localdir` is your local folder to download the image from `remote` S3.
- `reportdir` is your local folder where report text will be generated. It's also work as a log files. (optional)
- `date` is date format 1 without dash.
- `date2` is date format 2 with dash. (optional) you could choose one from above date formatting.
- `CHAT_ID` is the bot ID generated from Telegram BotFather. I use this CHAT_ID to notify my team when image optimizer is started and when it's finished. For personal usage, this one is optional.

And then, after the vars, below is the step or logic explanation. As you can see from above script example, I already give numbering in every step so it could be discovered easily.

1. Step 1 is to backup the original files into `backupremote` and create new prefix or directory with `date2` as its name.
2. Execute S3 synchronization, sync from `remote` into `localdir`.
3. List the files and directories inside `localdir` and send it as a log file.
4. Put the `localdir` content size listing result into log file.
5. Then, start to optimize JPEG and JPEG files above 100k into maximum 100k. I use 2 commands to differentiate between JPG and JPEG (based on its extension).
6. Optimize PNG files above 100k into maximum 100k.
7. Sync optimized images into S3 and apply cache-control.
8. Send message to my team Telegram Group once its done.

# License

This script is licensed under [MIT License](https://opensource.org/licenses/MIT).



