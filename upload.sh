#!/bin/bash


sudo hexo clean

sudo hexo g

sudo git pull origin master

sudo hexo d

sudo git add .

sudo git commit -m "upload"

sudo git push origin master



