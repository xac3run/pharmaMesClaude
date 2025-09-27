#!/bin/bash
set -e

echo "🔄 Updating Pharmaceutical MES UI..."

# Путь к проекту
PROJECT_DIR="/home/haspotc/pharmaMesClaude/pharma-mes-working"
CONTAINER_NAME="pharma-mes-ui"   # 👈 исправил имя контейнера

# Проверка файла
if [ ! -f "$PROJECT_DIR/index.html" ]; then
  echo "❌ index.html не найден в $PROJECT_DIR"
  exit 1
fi

# Проверяем, существует ли контейнер
if ! sudo docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "❌ Контейнер ${CONTAINER_NAME} не найден. Запусти: sudo docker-compose up -d"
  exit 1
fi

# Перезапуск контейнера
echo "📦 Restarting container ${CONTAINER_NAME}..."
sudo docker restart ${CONTAINER_NAME}

# Проверка, что работает
sleep 3
if curl -s http://localhost:3000 | grep -q "Nobilis.Tech MES"; then
  echo "✅ UI обновлён и работает на http://<IP>:3000"
else
  echo "⚠️ Проверь логи контейнера:"
  echo "   sudo docker logs ${CONTAINER_NAME} --tail 20"
fi

