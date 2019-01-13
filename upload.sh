#!/bin/bash

sudo -s

hexo clean

hexo g

git pull origin master

hexo d

git add .

git commit -m "upload"

git push origin master



