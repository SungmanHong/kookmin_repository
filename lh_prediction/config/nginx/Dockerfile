FROM nginx

# nginx.conf 파일을 설정했다면 기존 default.conf는 무조건 제거
COPY nginx.conf /etc/nginx/conf.d/nginx.conf
RUN rm /etc/nginx/conf.d/default.conf