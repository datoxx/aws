#!/bin/bash
sudo apt update -y

sudo apt install nginx -y 

cd /var/www/html

echo "<html><h1>Hello</h1></html>" > index.html

sudo systemctl reload nginx




