#!/bin/bash
# This script creates a PUSH event in Distelli for the commit
# This script also creates a BUILD event setting the build as "Running"

# Setting global Distelli Env Variables
echo -e "\nSetting global Distelli environment variables\n"
DISTELLI_CI_PROVIDER="jenkins"
DISTELLI_BUILD_STATUS="Running"

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

# Creating Distelli PUSH event
echo -e "\nCreating Distelli PUSH Event\n"

API_JSON=$(printf '{"commit_url":"%s", "author_username":"%s", "author_name":"%s", "commit_msg":"%s", "commit_id":"%s", "branch":"%s", "repo_url":"%s"}' $DISTELLI_CHANGE_URL $DISTELLI_CHANGE_AUTHOR $DISTELLI_CHANGE_AUTHOR_DISPLAY_NAME $DISTELLI_CHANGE_TITLE $DISTELLI_CHANGE_ID $DISTELLI_BRANCH_NAME $DISTELLI_CHANGE_TARGET)
DISTELLI_RESPONSE=$(curl -s -k -X PUT -H "Content-Type: application/json" "https://api-beta.distelli.com/bmcgehee2/apps/example-jenkins/events/pushEvent?apiToken=$DISTELLI_API_TOKEN" -d "$API_JSON")
DISTELLI_PUSH_EVENT_ID=$(echo $DISTELLI_RESPONSE | jq .event_id | tr -d '"')
echo -e "push_event_id: $DISTELLI_PUSH_EVENT_ID\n"


# Creating Distelli BUILD event
echo -e "\nCreating Distelli BUILD Event\n"

DISTELLI_NOW=$(date -u +%Y-%m-%dT%H:%M:%S.0Z)
API_JSON=$(printf '{"build_status":"%s", "build_start":"%s", "build_id":"%s", "build_provider":"%s", "build_url":"%s", "repo_url":"%s", "commit_url":"%s", "author_username":"%s", "author_name":"%s", "commit_msg":"%s", "commit_id":"%s", "branch":"%s", "parent_event_id":"%s"}' $DISTELLI_BUILD_STATUS $DISTELLI_NOW $DISTELLI_BUILD_ID $DISTELLI_CI_PROVIDER $DISTELLI_BUILD_URL $DISTELLI_CHANGE_TARGET $DISTELLI_CHANGE_URL $DISTELLI_CHANGE_AUTHOR $DISTELLI_CHANGE_AUTHOR_DISPLAY_NAME $DISTELLI_CHANGE_TITLE $DISTELLI_CHANGE_ID $DISTELLI_BRANCH_NAME $DISTELLI_PUSH_EVENT_ID)
DISTELLI_RESPONSE=$(curl -s -k -H "Content-Type: application/json" -X PUT "https://api-beta.distelli.com/bmcgehee2/apps/example-jenkins/events/buildEvent?apiToken=$DISTELLI_API_TOKEN" -d "$API_JSON")
DISTELLI_BUILD_EVENT_ID=$(echo $DISTELLI_RESPONSE | jq .event_id | tr -d '"')
echo -e "build_event_id: $DISTELLI_BUILD_EVENT_ID\n\n"

# Saving build event id
DISTELLI_TMP_FILENAME="DISTELLI.$JOB_NAME.$BUILD_NMUBER.tmp"
echo "$DISTELLI_BUILD_EVENT_ID" > "$DISTELLI_TMP_FILENAME"

