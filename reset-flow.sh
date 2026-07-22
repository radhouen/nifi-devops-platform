#!/bin/bash
NIFI_URL="https://localhost:9443/nifi-api"
CURL="curl -sk"
TOKEN=$($CURL -X POST "$NIFI_URL/access/token" \
  -d "username=admin&password=adminadminadmin" \
  -H "Content-Type: application/x-www-form-urlencoded")
AUTH="Authorization: Bearer $TOKEN"
ROOT_PG=$($CURL -H "$AUTH" "$NIFI_URL/flow/process-groups/root" | jq -r '.processGroupFlow.id')

echo "==> Stopping process group..."
$CURL -X PUT "$NIFI_URL/flow/process-groups/$ROOT_PG" -H "$AUTH" -H "Content-Type: application/json" \
  -d "{\"id\":\"$ROOT_PG\",\"state\":\"STOPPED\"}" > /dev/null
sleep 3

drop_queue() {
  local cid=$1
  local drop=$($CURL -X POST "$NIFI_URL/flowfile-queues/$cid/drop-requests" -H "$AUTH")
  local drop_id=$(echo "$drop" | jq -r '.dropRequest.id')
  if [ "$drop_id" = "null" ] || [ -z "$drop_id" ]; then
    echo "  could not create drop-request for $cid"
    return
  fi
  for i in 1 2 3 4 5 6 7 8; do
    local status=$($CURL -H "$AUTH" "$NIFI_URL/flowfile-queues/$cid/drop-requests/$drop_id" | jq -r '.dropRequest.finished')
    if [ "$status" = "true" ]; then
      echo "  drained queue $cid"
      $CURL -X DELETE "$NIFI_URL/flowfile-queues/$cid/drop-requests/$drop_id" -H "$AUTH" > /dev/null
      return
    fi
    sleep 1
  done
  echo "  drain timed out for $cid"
}

delete_with_retry() {
  local kind=$1
  local id=$2
  for attempt in 1 2 3 4 5; do
    REV=$($CURL -H "$AUTH" "$NIFI_URL/$kind/$id" | jq -r '.revision.version')
    CODE=$($CURL -w "%{http_code}" -o /tmp/del_resp.json -X DELETE "$NIFI_URL/$kind/$id?version=$REV" -H "$AUTH")
    if [ "$CODE" = "200" ]; then
      echo "  deleted $kind $id (attempt $attempt)"
      return 0
    fi
    sleep 1
  done
  echo "  FAILED to delete $kind $id after 5 attempts, last code=$CODE"
  cat /tmp/del_resp.json
  return 1
}

echo "==> Draining all connection queues..."
$CURL -H "$AUTH" "$NIFI_URL/process-groups/$ROOT_PG/connections" | jq -r '.connections[].id' | while read cid; do
  drop_queue "$cid"
done

echo "==> Deleting connections..."
$CURL -H "$AUTH" "$NIFI_URL/process-groups/$ROOT_PG/connections" | jq -r '.connections[].id' | while read cid; do
  delete_with_retry "connections" "$cid"
done

echo "==> Deleting processors..."
$CURL -H "$AUTH" "$NIFI_URL/process-groups/$ROOT_PG/processors" | jq -r '.processors[].id' | while read pid; do
  delete_with_retry "processors" "$pid"
done

echo "==> Remaining processor count:"
$CURL -H "$AUTH" "$NIFI_URL/process-groups/$ROOT_PG/processors" | jq '.processors | length'
echo "==> Remaining connection count:"
$CURL -H "$AUTH" "$NIFI_URL/process-groups/$ROOT_PG/connections" | jq '.connections | length'
