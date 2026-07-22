#!/bin/bash
NIFI_URL="https://localhost:9443/nifi-api"
CURL="curl -sk"

TOKEN=$($CURL -X POST "$NIFI_URL/access/token" \
  -d "username=admin&password=adminadminadmin" \
  -H "Content-Type: application/x-www-form-urlencoded")
AUTH="Authorization: Bearer $TOKEN"
ROOT_PG=$($CURL -H "$AUTH" "$NIFI_URL/flow/process-groups/root" | jq -r '.processGroupFlow.id')

echo "==> Stopping all processors..."
$CURL -X PUT "$NIFI_URL/flow/process-groups/$ROOT_PG" -H "$AUTH" -H "Content-Type: application/json" \
  -d "{\"id\":\"$ROOT_PG\",\"state\":\"STOPPED\"}" > /dev/null
sleep 2

echo "==> Deleting all connections..."
$CURL -H "$AUTH" "$NIFI_URL/process-groups/$ROOT_PG/connections" | jq -r '.connections[].id' | while read cid; do
  REV=$($CURL -H "$AUTH" "$NIFI_URL/connections/$cid" | jq -r '.revision.version')
  $CURL -X DELETE "$NIFI_URL/connections/$cid?version=$REV" -H "$AUTH" > /dev/null
  echo "  deleted connection $cid"
done

echo "==> Deleting all processors..."
$CURL -H "$AUTH" "$NIFI_URL/process-groups/$ROOT_PG/processors" | jq -r '.processors[].id' | while read pid; do
  REV=$($CURL -H "$AUTH" "$NIFI_URL/processors/$pid" | jq -r '.revision.version')
  $CURL -X DELETE "$NIFI_URL/processors/$pid?version=$REV" -H "$AUTH" > /dev/null
  echo "  deleted processor $pid"
done

echo "==> Flow cleared."
