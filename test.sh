#!/bin/bash
#Creating Distelli PUSH event
echo "Creating Distelli PUSH Event"

API_JSON=$(printf '{"commit_url":"%s", "author_username":"%s", "author_name":"%s", "commit_msg":"%s", "commit_id":"%s", "branch":"%s", "repo_url":"%s"}' $CHANGE_URL $CHANGE_AUTHOR $CHANGE_AUTHOR_DISPLAY_NAME $CHANGE_TITLE $CHANGE_ID $BRANCH_NAME $CHANGE_TARGET)
response=$(curl -s -k -X PUT -H "Content-Type: application/json" "https://api-beta.distelli.com/bmcgehee2/apps/example-jenkins/events/pushEvent?apiToken=$DISTELLI_TOKEN" -d "$API_JSON")
push_event_id=$(echo $response | jq .event_id)

echo "response: $response"
echo "push_event_id: $push_event_id"

echo "Getting date"
now=$(date --utc +%FT%TZ)

echo "building json"
API_JSON=$(printf '{"build_status":"Running", "build_start":"%s", "build_id":"%s", "build_provider":"jenkins", "build_url":"%s", "repo_url":"%s", "commit_url":"%s", "author_username":"%s", "author_name":"%s", "commit_msg":"%s", "commit_id":"%s", "branch":"%s", "parent_id":"%s"}' $now $BUILD_ID $BUILD_URL $CHANGE_TARGET $CHANGE_URL $CHANGE_AUTHOR $CHANGE_AUTHOR_DISPLAY_NAME $CHANGE_TITLE $CHANGE_ID $BRANCH_NAME $push_event_id)

echo "checking json"
echo $API_JSON | jq .

response=$(curl -s -k -H "Content-Type: application/json" -X PUT "https://api-beta.distelli.com/bmcgehee2/apps/example-node/events/buildEvent?apiToken=$DISTELLI_TOKEN" -d "$aAPI_JSON")
build_event_id=$(echo $response | jq .event_id)

echo "response: $response"
echo "build_event_id: $build_event_id"

