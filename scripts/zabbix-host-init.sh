#!/bin/sh
# SCRIPT QUE CORRE POSTERIOR AL DOCKER COMPOSE LO EJECUTA EL SERVICIO zabbix-init, Y SE EJECUTA TRAS CORRER EL COMPOSE O EL
# SCRIPT PRINCIPAL zabbix-dev.sh Y MODIFICA LA INTERFAZ DEL AGENTE Y OTROS VALORES POS-INSTALACION

set -e

API="${ZBX_API_URL}"
USER="${ZBX_API_USER}"
PASS="${ZBX_API_PASS}"

echo "⏳ Esperando que Zabbix API esté disponible..."
until curl -sf -o /dev/null -X POST "$API" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"apiinfo.version","params":{},"id":1}'; do
  sleep 5
done
echo "✅ API disponible"

# ── 1. Autenticar ──────────────────────────────────────────────────────────────
TOKEN=$(curl -sf -X POST "$API" \
  -H "Content-Type: application/json" \
  -d "{
    \"jsonrpc\": \"2.0\",
    \"method\": \"user.login\",
    \"params\": {\"username\": \"$USER\", \"password\": \"$PASS\"},
    \"id\": 1
  }" | grep -o '"result":"[^"]*"' | cut -d'"' -f4)

echo "🔑 Token obtenido: $TOKEN"

# ── 2. Obtener o crear Host Group ──────────────────────────────────────────────

GROUP_ID=$(curl -s -X POST "$API" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"jsonrpc\":\"2.0\",\"method\":\"hostgroup.get\",\"params\":{\"filter\":{\"name\":[\"$HOST_GROUP\"]}},\"id\":5}" \
  | grep -o '"groupid":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$GROUP_ID" ]; then
  echo "📁 Creando grupo: $HOST_GROUP"
  GROUP_ID=$(curl -sf -X POST "$API" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d "{\"jsonrpc\":\"2.0\",\"method\":\"hostgroup.create\",\"params\":{\"name\":\"$HOST_GROUP\"},\"id\":3}" \
    | grep -o '"groupids":\["[^"]*"' | cut -d'"' -f3)
else
  echo "📁 El grupo \"$HOST_GROUP\" ya existe."
fi

GROUP_ID=$(curl -s -X POST "$API" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"jsonrpc\":\"2.0\",\"method\":\"hostgroup.get\",\"params\":{\"filter\":{\"name\":[\"$HOST_GROUP\"]}},\"id\":5}" \
  | grep -o '"groupid":"[^"]*"' | head -1 | cut -d'"' -f4)

echo "📁 Groupname: $HOST_GROUP ID: $GROUP_ID"

# ── 3. Obtener Template ID ─────────────────────────────────────────────────────

TEMPLATE_ID=$(curl -sf -X POST "$API" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"jsonrpc\":\"2.0\",\"method\":\"template.get\",\"params\":{\"filter\":{\"host\":[\"$HOST_TEMPLATE\"]}},\"id\":4}" \
  | grep -o '"templateid":"[^"]*"' | head -1 | cut -d'"' -f4)
echo "📋 Template ID: $TEMPLATE_ID"

# ── 4. Verificar si el host ya existe ─────────────────────────────────────────

HOST_ID=$(curl -sf -X POST "$API" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"jsonrpc\":\"2.0\",\"method\":\"host.get\",\"params\":{\"filter\":{\"host\":[\"$HOST_NAME\"]}},\"id\":5}" \
  | grep -o '"hostid":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -n "$HOST_ID" ]; then
  echo "🔄 Host ya existe (ID: $HOST_ID), actualizando interfaz..."

# ── 5. Obtener interfaz actual ─────────────────────────────────────────

  IFACE_ID=$(curl -sf -X POST "$API" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d "{\"jsonrpc\":\"2.0\",\"method\":\"hostinterface.get\",\"params\":{\"hostids\":\"$HOST_ID\"},\"id\":6}" \
    | grep -o '"interfaceid":"[^"]*"' | head -1 | cut -d'"' -f4)

# ── 6. Actualizar interfaz a DNS ─────────────────────────────────────────

  curl -sf -X POST "$API" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d "{\"jsonrpc\":\"2.0\",\"method\":\"hostinterface.update\",\"params\":{\"interfaceid\":\"$IFACE_ID\",\"type\":1,\"useip\":0,\"dns\":\"$HOST_DNS\",\"ip\":\"\",\"port\":\"$HOST_PORT\",\"main\":1},\"id\":7}"
  echo ""
  echo "✅ Interfaz actualizada a DNS: $HOST_DNS:$HOST_PORT"

else

  echo "➕ Creando host: $HOST_NAME"
  curl -sf -X POST "$API" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d "{\"jsonrpc\":\"2.0\",\"method\":\"host.create\",\"params\":{\"host\":\"$HOST_NAME\",\"interfaces\":[{\"type\":1,\"main\":1,\"useip\":0,\"ip\":\"\",\"dns\":\"$HOST_DNS\",\"port\":\"$HOST_PORT\"}],\"groups\":[{\"groupid\":\"$GROUP_ID\"}],\"templates\":[{\"templateid\":\"$TEMPLATE_ID\"}]},\"id\":8}"

  echo "✅ Host creado con DNS: $HOST_DNS:$HOST_PORT"
fi

  echo "ℹ️ Creando la accion de autoregistro para los agentes remotos"

# ── 7. Obtener los ID de los Grupos ─────────────────────────────────────────────────
GROUP_ADD_ID=$(curl -s -X POST "$API" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"jsonrpc\":\"2.0\",\"method\":\"hostgroup.get\",\"params\":{\"filter\":{\"name\":[\"$HOST_GROUP\"]},\"output\":[\"groupid\"]},\"id\":1}" \
  | grep -o '"groupid":"[^"]*"' | head -1 | cut -d'"' -f4)

GROUP_REMOVE_ID=$(curl -s -X POST "$API" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"jsonrpc\":\"2.0\",\"method\":\"hostgroup.get\",\"params\":{\"filter\":{\"name\":[\"Discovered hosts\"]},\"output\":[\"groupid\"]},\"id\":1}" \
  | grep -o '"groupid":"[^"]*"' | head -1 | cut -d'"' -f4)

# ── 8. Obtener los ID de los Templates ──────────────────────────────────────────────
TMPL_DOCKER_ID=$(curl -s -X POST "$API" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"jsonrpc\":\"2.0\",\"method\":\"template.get\",\"params\":{\"filter\":{\"name\":[\"Docker by Zabbix agent 2\"]},\"output\":[\"templateid\"]},\"id\":1}" \
  | grep -o '"templateid":"[^"]*"' | head -1 | cut -d'"' -f4)

TMPL_LINUX_ID=$(curl -s -X POST "$API" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"jsonrpc\":\"2.0\",\"method\":\"template.get\",\"params\":{\"filter\":{\"name\":[\"Linux by Zabbix agent active\"]},\"output\":[\"templateid\"]},\"id\":1}" \
  | grep -o '"templateid":"[^"]*"' | head -1 | cut -d'"' -f4)

echo "📁 Grupo agregar : $GROUP_ADD_ID"
echo "📁 Grupo remover : $GROUP_REMOVE_ID"
echo "📋 Template Docker: $TMPL_DOCKER_ID"
echo "📋 Template Linux : $TMPL_LINUX_ID"

# ── 9. Crear Action ───────────────────────────────────────────
curl -s -X POST "$API" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"jsonrpc\":\"2.0\",\"method\":\"action.create\",\"params\":{\"name\":\"Autoregistro-agentes-simovilab\",\"eventsource\":2,\"status\":0,\"filter\":{\"evaltype\":0,\"conditions\":[{\"conditiontype\":24,\"operator\":2,\"value\":\"docker-autoreg\"}]},\"operations\":[{\"operationtype\":2},{\"operationtype\":4,\"opgroup\":[{\"groupid\":\"$GROUP_ADD_ID\"}]},{\"operationtype\":5,\"opgroup\":[{\"groupid\":\"$GROUP_REMOVE_ID\"}]},{\"operationtype\":6,\"optemplate\":[{\"templateid\":\"$TMPL_DOCKER_ID\"},{\"templateid\":\"$TMPL_LINUX_ID\"}]}]},\"id\":1}"

echo ""
echo "✅ Action de autoregistro creada"


echo "🎉 Inicialización completa"
