#!/bin/bash
set -e
NIFI_URL="https://localhost:9443/nifi-api"
CURL="curl -sk"

TOKEN=$($CURL -X POST "$NIFI_URL/access/token" \
  -d "username=admin&password=adminadminadmin" \
  -H "Content-Type: application/x-www-form-urlencoded")
AUTH="Authorization: Bearer $TOKEN"

ROOT_PG=$($CURL -H "$AUTH" "$NIFI_URL/flow/process-groups/root" | jq -r '.processGroupFlow.id')
echo "ROOT_PG=$ROOT_PG"

echo "==> Creating 'CGX-France-Sync' process group..."
NEW_PG=$($CURL -X POST "$NIFI_URL/process-groups/$ROOT_PG/process-groups" -H "$AUTH" -H "Content-Type: application/json" \
  -d '{"revision":{"version":0},"component":{"name":"CGX-France-Sync","position":{"x":600,"y":100}}}')
NEW_PG_ID=$(echo "$NEW_PG" | jq -r '.id')
echo "New PG ID: $NEW_PG_ID"

echo "==> Gathering processor and connection IDs to move..."
PROC_IDS=$($CURL -H "$AUTH" "$NIFI_URL/process-groups/$ROOT_PG/processors" | jq -r '.processors[].id')
CONN_IDS=$($CURL -H "$AUTH" "$NIFI_URL/process-groups/$ROOT_PG/connections" | jq -r '.connections[].id')

PROC_JSON="{}"
for id in $PROC_IDS; do
  PROC_JSON=$(echo "$PROC_JSON" | jq --arg id "$id" '. + {($id): {}}')
done

CONN_JSON="{}"
for id in $CONN_IDS; do
  CONN_JSON=$(echo "$CONN_JSON" | jq --arg id "$id" '. + {($id): {}}')
done

echo "==> Creating snippet..."
SNIPPET=$($CURL -X POST "$NIFI_URL/snippets" -H "$AUTH" -H "Content-Type: application/json" \
  -d "{\"snippet\":{\"parentGroupId\":\"$ROOT_PG\",\"processors\":$PROC_JSON,\"connections\":$CONN_JSON}}")
SNIPPET_ID=$(echo "$SNIPPET" | jq -r '.snippet.id')
echo "Snippet ID: $SNIPPET_ID"

echo "==> Moving snippet into new process group..."
MOVE_RESP=$($CURL -w "\nHTTP_CODE:%{http_code}" -X PUT "$NIFI_URL/snippets/$SNIPPET_ID" -H "$AUTH" -H "Content-Type: application/json" \
  -d "{\"snippet\":{\"id\":\"$SNIPPET_ID\",\"parentGroupId\":\"$NEW_PG_ID\"}}")
echo "$MOVE_RESP"

echo "==> Verifying contents of new PG..."
$CURL -H "$AUTH" "$NIFI_URL/process-groups/$NEW_PG_ID/processors" | jq '.processors[] | {name: .component.name, state: .status.runStatus}'
$CURL -H "$AUTH" "$NIFI_URL/process-groups/$NEW_PG_ID/connections" | jq '.connections | length'

echo "$NEW_PG_ID" > /tmp/cgx_france_sync_pg_id.txt
echo "==> Done. PG ID saved to /tmp/cgx_france_sync_pg_id.txt"
