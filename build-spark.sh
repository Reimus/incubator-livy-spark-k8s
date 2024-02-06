#!/bin/sh
docker build -t lreimus/livy-spark:3.3.4-1 -f Dockerfile-spark .
docker push lreimus/livy-spark:3.3.4-1

