#!/bin/bash

echo "🔧 Перезапуск React MES (Fixed Build)"
echo "====================================="

cd pharma-mes-working

echo "✅ Используем index.html из папки (без генерации внутри .sh)"

echo "Пересоздание контейнера..."
sudo docker-compose down
sudo docker-compose up -d --build

echo ""
echo "Ожидание запуска..."
sleep 10

echo ""
echo "Проверка..."
if curl -s http://localhost:3000 | grep -q "React Fixed"; then
    echo "🎉 SUCCESS! React запустился!"
    echo "🌐 Откройте: http://localhost:3000"
else
    echo "❌ Ошибка запуска, смотрим логи..."
    sudo docker logs pharma-mes-working --tail 20
fi
