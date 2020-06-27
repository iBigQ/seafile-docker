#!/bin/bash

file="$1"; shift
wait_seconds="${1:-10}"; shift # 10 seconds as default timeout

until test $((wait_seconds--)) -eq 0 -o -e "$file" ; do sleep 1; done

((++wait_seconds))
