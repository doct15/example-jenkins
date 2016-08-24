#!/bin/bash
# This script will update the Build status

# Push the release to Distelli with the Distelli CLI
echo -e "\n\nPushing the Distelli release\n"
DISTELLI_RESPONSE=$(distelli push)
DISTELLI_RELEASE_VERSION=${DISTELLI_RESPONSE:(-22)}
echo -e "Distelli Release Version: $DISTELLI_RELEASE_VERSION\n"

# Setting global Distelli Env Variables
echo -e "\nSetting global Distelli environment variables\n"
DISTELLI_CI_PROVIDER="jenkins"
DISTELLI_BUILD_STATUS="Success"

# Setting repo specific Env Variables
echo -e "Setting repository specific environment variables\n"
if [ -z "$GIT_COMMIT" ]; then
  echo -e "No GIT variables available. Using standard Jenkins variables.\n"
  DISTELLI_BUILD_ID=$BUILD_NUMBER
  DISTELLI_BUILD_URL=$BUILD_URL
  DISTELLI_CHANGE_URL="NoChangeURL"
  DISTELLI_CHANGE_AUTHOR="NoChangeAuthor"
  DISTELLI_CHANGE_AUTHOR_DISPLAY_NAME="NoChangeAuthorName"
  DISTELLI_CHANGE_TITLE="NoChangeMessage"
  DISTELLI_CHANGE_ID="NoChangeID"
  DISTELLI_BRANCH_NAME="NoChangeBranch"
  DISTELLI_CHANGE_TARGET="NoChangeTarget"
else
  echo -e "Using GIT variables.\n"
  DISTELLI_BUILD_ID=$BUILD_NUMBER
  DISTELLI_BUILD_URL=$BUILD_URL
  DISTELLI_CHANGE_URL=$GIT_URL
  DISTELLI_CHANGE_AUTHOR=$GIT_AUTHOR_NAME
  DISTELLI_CHANGE_AUTHOR_DISPLAY_NAME=$GIT_AUTHOR_NAME
  DISTELLI_CHANGE_TITLE="NoChangeMessage"
  DISTELLI_CHANGE_ID=$GIT_COMMIT
  DISTELLI_BRANCH_NAME=$GIT_BRANCH
  DISTELLI_CHANGE_TARGET=$GIT_URL
fi

# Preparing to update the build event with "Success" and build end time
echo -e "\nPreparing to update build event in Distelli\n"
DISTELLI_NOW=$(date -u +%Y-%m-%dT%H:%M:%S.0Z)
DISTELLI_TMP_FILENAME="DISTELLI.$JOB_NAME.$BUILD_NMUBER.tmp"
DISTELLI_BUILD_EVENT_ID=$(cat "$DISTELLI_TMP_FILENAME")
DISTELLI_RESPONSE=$(rm "$DISTELLI_TMP_FILENAME")

echo -e "Updating build event in Distelli\n"
# Updating build event with "Success" and build end time
API_JSON=$(printf '{"build_status":"%s", "build_end":"%s", "release_version":"%s"}' $DISTELLI_BUILD_STATUS $DISTELLI_NOW $DISTELLI_RELEASE_VERSION)
DISTELLI_RESPONSE=$(curl -s -k -H "Content-Type: application/json" -X POST "https://api-beta.distelli.com/bmcgehee2/apps/example-jenkins/events/$DISTELLI_BUILD_EVENT_ID?apiToken=$DISTELLI_API_TOKEN" -d "$API_JSON")
echo -e "Distelli Build Update Response:\n $DISTELLI_RESPONSE\n\n"



