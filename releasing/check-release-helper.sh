#!/usr/bin/env bash

declare PATCH=false
declare MINOR=false
declare MAJOR=false
declare rc=0

git log $(git describe --tags --abbrev=0)..HEAD --oneline | tee /tmp/release-changelogs.txt

count=$(cat /tmp/release-changelogs.txt | wc -l)

if [[ $(cat /tmp/release-changelogs.txt | grep fix) || $(cat /tmp/release-changelogs.txt | grep patch) || $(cat /tmp/release-changelogs.txt | grep chore) ]]; then
    PATCH=true
fi

if [[ $(cat /tmp/release-changelogs.txt | grep feat) ]]; then
    MINOR=true
fi

for f in $(find api); do
    git diff --exit-code "${f}"
    if [ $? -eq 1 ]; then
        echo "Found changes on api dir at ${f}"
        MAJOR=true
    fi
done

echo -e "\n"
echo -e "================================================================================="
echo "Change counter: $(echo $count | tr -s ' ')"
if [[ $MAJOR == false && $MINOR == false ]]; then
    echo "Recommended release type: patch"
elif [[ $MAJOR == false && $MINOR == true ]]; then
    echo "Recommended release type: minor"
else
    echo "Recommended release type: major"
fi