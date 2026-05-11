#!/bin/sh
# SCRIPT QUE CORRE POSTERIOR AL DOCKER COMPOSE LO EJECUTA EL SERVICIO, Y SE EJECUTA TRAS CORRER EL COMPOSE O EL 
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
  -d '{
    "jsonrpc": "2.0",
    "method": "hostgroup.get",
    "params": {"filter": {"name": ["$HOST_GROUP"]}},
    "id": 5
  }' | grep -o '"groupid":"[^"]*"' | head -1 | cut -d'"' -f4)
if [ -z "$GROUP_ID" ]; then
  echo "📁 Creando grupo: $HOST_GROUP"
  GROUP_ID=$(curl -sf -X POST "$API" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d "{
      "jsonrpc": "2.0",
      "method": "hostgroup.create",
      "params": {"name": "$HOST_GROUP"},
      "id": 3
    }" | grep -o '"groupids":\["[^"]*"' | cut -d'"' -f3)
fi
echo "📁 Group ID: $GROUP_ID"

# ── 3. Obtener Template ID ─────────────────────────────────────────────────────
TEMPLATE_ID=$(curl -sf -X POST "$API" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN"
  -d "{
    \"jsonrpc\": \"2.0\",
    \"method\": \"template.get\",
    \"params\": {\"filter\": {\"host\": [\"$HOST_TEMPLATE\"]}},
    \"id\": 4
  }" | grep -o '"templateid":"[^"]*"' | head -1 | cut -d'"' -f4)

echo "📋 Template ID: $TEMPLATE_ID"

# ── 4. Verificar si el host ya existe ─────────────────────────────────────────
HOST_ID=$(curl -sf -X POST "$API" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN"
  -d "{
    \"jsonrpc\": \"2.0\",
    \"method\": \"host.get\",
    \"params\": {\"filter\": {\"host\": [\"$HOST_NAME\"]}},
    \"id\": 5
  }" | grep -o '"hostid":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -n "$HOST_ID" ]; then
  echo "🔄 Host ya existe (ID: $HOST_ID), actualizando interfaz..."

  # Obtener interfaz actual
  IFACE_ID=$(curl -sf -X POST "$API" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN"
    -d "{
      \"jsonrpc\": \"2.0\",
      \"method\": \"hostinterface.get\",
      \"params\": {\"hostids\": \"$HOST_ID\"},
      \"id\": 6
    }" | grep -o '"interfaceid":"[^"]*"' | head -1 | cut -d'"' -f4)

  # Actualizar interfaz a DNS
  curl -sf -X POST "$API" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN"
    -d "{
      \"jsonrpc\": \"2.0\",
      \"method\": \"hostinterface.update\",
      \"params\": {
        \"interfaceid\": \"$IFACE_ID\",
        \"type\": 1,
        \"useip\": 0,
        \"dns\": \"$HOST_DNS\",
        \"ip\": \"\",
        \"port\": \"$HOST_PORT\",
        \"main\": 1
      },
      \"id\": 7
    }"
  echo "✅ Interfaz actualizada a DNS: $HOST_DNS:$HOST_PORT"

else
  echo "➕ Creando host: $HOST_NAME"
  curl -sf -X POST "$API" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN"
    -d "{
      \"jsonrpc\": \"2.0\",
      \"method\": \"host.create\",
      \"params\": {
        \"host\": \"$HOST_NAME\",
        \"interfaces\": [{
          \"type\": 1,
          \"main\": 1,
          \"useip\": 0,
          \"ip\": \"\",
          \"dns\": \"$HOST_DNS\",
          \"port\": \"$HOST_PORT\"
        }],
        \"groups\": [{\"groupid\": \"$GROUP_ID\"}],
        \"templates\": [{\"templateid\": \"$TEMPLATE_ID\"}]
      },
      \"id\": 8
    }"
  echo "✅ Host creado con DNS: $HOST_DNS:$HOST_PORT"
fi

echo "🎉 Inicialización completa"