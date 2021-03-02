# 第一階段產生dist資料夾
FROM node:14.13.0 as builder
# 指定預設/工作資料夾
WORKDIR /usr/app
# 只copy package.json檔案
COPY ./package*.json ./
# 安裝dependencies
RUN npm install
# copy其餘目錄及檔案
COPY ./ ./
COPY src src
# 指定建立build output資料夾，--prod為Production Mode, my-app 為專案名稱依照各自的專案變更
RUN npm run build --output-path=/usr/app/dist/my-app --prod

# pull nginx image
FROM nginx:alpine

RUN chgrp -R 0 /var/cache/nginx /var/run /var/log/nginx && \
    chmod -R g+rwX /etc/nginx/ /var/cache/nginx /var/run /var/log/nginx
RUN sed -i.bak 's/listen\(.*\)80;/listen 8081;/' /etc/nginx/conf.d/default.conf
RUN sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf

# 從第一階段的檔案copy
COPY --from=builder /usr/app/dist/my-app /usr/share/nginx/html
# 覆蓋image裡的設定檔
COPY ./nginx-custom.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080