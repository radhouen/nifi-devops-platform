#!/bin/bash
set -e

NIFI_URL="https://localhost:9443/nifi-api"
CURL="curl -sk"

echo "==> Authenticating..."
TOKEN=$($CURL -X POST "$NIFI_URL/access/token" \
  -d "username=admin&password=adminadminadmin" \
  -H "Content-Type: application/x-www-form-urlencoded")
AUTH="Authorization: Bearer $TOKEN"

echo "==> Getting root process group..."
ROOT_PG=$($CURL -H "$AUTH" "$NIFI_URL/flow/process-groups/root" | jq -r '.processGroupFlow.id')
echo "Root PG: $ROOT_PG"

echo "==> Creating GenerateFlowFile..."
GFF=$($CURL -X POST "$NIFI_URL/process-groups/$ROOT_PG/processors" \
  -H "$AUTH" -H "Content-Type: application/json" \
  -d '{"revision":{"version":0},"component":{"type":"org.apache.nifi.processors.standard.GenerateFlowFile","name":"GenerateFlowFile","position":{"x":200,"y":100}}}')
GFF_ID=$(echo "$GFF" | jq -r '.id')
echo "GenerateFlowFile ID: $GFF_ID"

echo "==> Creating UpdateAttribute..."
UA=$($CURL -X POST "$NIFI_URL/process-groups/$ROOT_PG/processors" \
  -H "$AUTH" -H "Content-Type: application/json" \
  -d '{"revision":{"version":0},"component":{"type":"org.apache.nifi.processors.attributes.UpdateAttribute","name":"UpdateAttribute","position":{"x":200,"y":300}}}')
UA_ID=$(echo "$UA" | jq -r '.id')
echo "UpdateAttribute ID: $UA_ID"

echo "==> Creating PutFile..."
PF=$($CURL -X POST "$NIFI_URL/process-groups/$ROOT_PG/processors" \
  -H "$AUTH" -H "Content-Type: application/json" \
  -d '{"revision":{"version":0},"component":{"type":"org.apache.nifi.processors.standard.PutFile","name":"PutFile","position":{"x":200,"y":500}}}')
PF_ID=$(echo "$PF" | jq -r '.id')
echo "PutFile ID: $PF_ID"

echo "==> Configuring GenerateFlowFile scheduling (every 10s)..."
GFF_REV=$($CURL -H "$AUTH" "$NIFI_URL/processors/$GFF_ID" | jq -r '.revision.version')
$CURL -X PUT "$NIFI_URL/processors/$GFF_ID" -H "$AUTH" -H "Content-Type: application/json" \
  -d "{\"revision\":{\"version\":$GFF_REV},\"component\":{\"id\":\"$GFF_ID\",\"config\":{\"schedulingPeriod\":\"10 sec\"}}}" > /dev/null

echo "==> Configuring UpdateAttribute properties..."
UA_REV=$($CURL -H "$AUTH" "$NIFI_URL/processors/$UA_ID" | jq -r '.revision.version')
$CURL -X PUT "$NIFI_URL/processors/$UA_ID" -H "$AUTH" -H "Content-Type: application/json" \
  -d "{\"revision\":{\"version\":$UA_REV},\"component\":{\"id\":\"$UA_ID\",\"config\":{\"properties\":{\"region\":\"france\",\"target\":\"china\",\"sync.timestamp\":\"\${now()}\"}}}}" > /dev/null

echo "==> Configuring PutFile properties..."
PF_REV=$($CURL -H "$AUTH" "$NIFI_URL/processors/$PF_ID" | jq -r '.revision.version')
$CURL -X PUT "$NIFI_URL/processors/$PF_ID" -H "$AUTH" -H "Content-Type: application/json" \
  -d "{\"revision\":{\"version\":$PF_REV},\"component\":{\"id\":\"$PF_ID\",\"config\":{\"properties\":{\"Directory\":\"/tmp/cgx-sync-output\",\"Conflict Resolution Strategy\":\"replace\"}}}}" > /dev/null

echo "==> Connecting GenerateFlowFile -> UpdateAttribute..."
$CURL -X POST "$NIFI_URL/process-groups/$ROOT_PG/connections" -H "$AUTH" -H "Content-Type: application/json" \
  -d "{\"revision\":{\"version\":0},\"component\":{\"source\":{\"id\":\"$GFF_ID\",\"groupId\":\"$ROOT_PG\",\"type\":\"PROCESSOR\"},\"destination\":{\"id\":\"$UA_ID\",\"groupId\":\"$ROOT_PG\",\"type\":\"PROCESSOR\"},\"selectedRelationships\":[\"success\"]}}" > /dev/null

echo "==> Connecting UpdateAttribute -> PutFile..."
$CURL -X POST "$NIFI_URL/process-groups/$ROOT_PG/connections" -H "$AUTH" -H "Content-Type: application/json" \
  -d "{\"revision\":{\"version\":0},\"component\":{\"source\":{\"id\":\"$UA_ID\",\"groupId\":\"$ROOT_PG\",\"type\":\"PROCESSOR\"},\"destination\":{\"id\":\"$PF_ID\",\"groupId\":\"$ROOT_PG\",\"type\":\"PROCESSOR\"},\"selectedRelationships\":[\"success\"]}}" > /dev/null

start_processor() {
  local id=$1
  local rev=$($CURL -H "$AUTH" "$NIFI_URL/processors/$id" | jq -r '.revision.version')
  $CURL -X PUT "$NIFI_URL/processors/$id" -H "$AUTH" -H "Content-Type: application/json" \
    -d "{\"revision\":{\"version\":$rev},\"component\":{\"id\":\"$id\",\"state\":\"RUNNING\"}}" > /dev/null
}

echo "==> Starting all processors..."
start_processor "$GFF_ID"
start_processor "$UA_ID"
start_processor "$PF_ID"

echo "==> Done. Flow is running."
