#!/bin/bash
# Quick workaround if you need a cronjob to run every second

i=0

until [ $i -eq 60 ]; do
  sleep 1
  statement;
  statement;
  ((i=i+1))
done
