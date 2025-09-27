# Лёгкий образ с nginx
FROM nginx:1.29-alpine

# Удаляем дефолтные html-файлы nginx
RUN rm -rf /usr/share/nginx/html/*

# Копируем наши файлы (index.html + assets/)
COPY pharma-mes-working/ /usr/share/nginx/html/

# Экспонируем порт
EXPOSE 80

# Запускаем nginx
CMD ["nginx", "-g", "daemon off;"]
