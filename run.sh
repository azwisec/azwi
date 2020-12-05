#!/bin/bash


url=$1

if [ ! -d "/root/recon/$url" ];then
        mkdir /root/recon/$url
fi
if [ ! -d "/root/recon/$url/recon" ];then
        mkdir /root/recon/$url/recon
fi


echo "[+]Finding the Subdomains with asset finder-->"
assetfinder $url >> /root/recon/$url/recon/assets.txt
cat /root/recon/$url/recon/assets.txt | grep $1 >> /root/recon/$url/recon/final.txt
rm /root/recon/$url/recon/assets.txt


echo "[+]Finding the Subdomains with Amass--->"
amass enum -d $url >> /root/recon/$url/recon/f.txt
sort -u /root/recon/$url/recon/f.txt >> /root/recon/$url/recon/final.txt
rm /root/recon/$url/recon/f.txt

echo "[+]Finding the Subdomain with subfinder--->"
subfinder -d $url -o /root/recon/$url/doamins.txt
sort -u /root/recon/$url/domains.txt >> /root/recon/$url/recon/final.txt
rm /root/recon/$url/domains.txt

echo "[+]Testing Live website using HTTROBE"
cat /root/recon/$url/recon/final.txt | sort -u | httprobe -s -p https:443 |sed 's/https\?:\/\///' | tr -d ':443' >> /root/recon/$url/recon/alive.txt

echo "[+]Testing statuns codes httpx"
cat /root/recon/$url/recon/alive.txt | httpx -status-code | grep 200 | cut -d " " -f1 >> /root/recon/$url/recon/status.txt
