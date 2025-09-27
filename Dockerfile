# Dockerfile для Pharmaceutical MES System
FROM node:18-alpine AS build

# Установка рабочей директории
WORKDIR /app

# Создание package.json для React приложения
COPY <<EOF package.json
{
  "name": "pharmaceutical-mes",
  "version": "1.0.0",
  "description": "Pharmaceutical Manufacturing Execution System",
  "private": true,
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-scripts": "5.0.1",
    "lucide-react": "^0.263.1",
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
  "eslintConfig": {
    "extends": [
      "react-app"
    ]
  },
  "browserslist": {
    "production": [
      ">0.2%",
      "not dead",
      "not op_mini all"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  }
}
EOF

# Установка зависимостей
ENV NPM_CONFIG_REGISTRY=https://registry.npmmirror.com
RUN npm install

# Создание структуры приложения
RUN mkdir -p src public

# Создание index.html
COPY <<EOF public/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="theme-color" content="#000000" />
    <meta name="description" content="Pharmaceutical Manufacturing Execution System" />
    <title>Pharmaceutical MES</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body>
    <noscript>You need to enable JavaScript to run this app.</noscript>
    <div id="root"></div>
</body>
</html>
EOF

# Создание главного компонента (скопировать из artifact)
COPY <<EOF src/App.js
import React, { useState, useEffect } from 'react';
import { 
  Plus, Minus, Edit3, Save, Eye, Lock, Unlock, FileText, Settings, 
  Users, Clock, Database, AlertTriangle, CheckCircle, XCircle, 
  ArrowRight, ArrowDown, ArrowUp, Trash2, Copy, Upload, Download,
  Shield, Zap, ChevronDown, ChevronRight, Play, Pause, RotateCcw
} from 'lucide-react';

// Здесь должен быть весь код компонента EBRTemplateConfigurator
// Скопированный из созданного ранее artifact

const App = () => {
  return (
    <div className="min-h-screen bg-gray-50">
      <EBRTemplateConfigurator />
    </div>
  );
};

export default App;
EOF

# Создание index.js
COPY <<EOF src/index.js
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF

# Сборка приложения
RUN npm run build

# Второй этап - NGINX для сервинга
FROM nginx:alpine

# Копирование собранного приложения
COPY --from=build /app/build /usr/share/nginx/html

# Конфигурация NGINX
COPY <<EOF /etc/nginx/conf.d/default.conf
server {
    listen 80;
    server_name localhost;
    
    location / {
        root /usr/share/nginx/html;
        index index.html index.htm;
        try_files \$uri \$uri/ /index.html;
        
        # Добавление заголовков безопасности
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header Referrer-Policy "no-referrer-when-downgrade" always;
        add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    }
    
    # Кэширование статических файлов
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Компрессия
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
}
EOF

# Экспонирование порта
EXPOSE 80

# Метаданные
LABEL maintainer="Pharmaceutical MES Team"
LABEL description="Pharmaceutical Manufacturing Execution System"
LABEL version="1.0.0"

# Команда запуска
CMD ["nginx", "-g", "daemon off;"]
