server {
  listen 80;
  listen [::]:80;
  server_name nessus.testing.io www.nessus.testing.io;
  return 301 https://$server_name$request_uri;
}
server {
  listen 443 ssl;
  listen [::]:443 ssl;
  include snippets/ssl-params.conf;
  client_max_body_size 20M;
  server_name nessus.testing.io;
  ssl_certificate /etc/ssl/certs/nessus.testing.io.crt;
  ssl_certificate_key /etc/ssl/private/nessus.testing.io.key;
  access_log /var/log/nginx/nessus.access.log;
  location / {
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-SSL on;
    proxy_set_header X-Forwarded-Host $host;
    proxy_pass https://nessus.testing.io:8834;
    proxy_max_temp_file_size 0;
    proxy_connect_timeout 120;
    proxy_send_timeout 90;
    proxy_read_timeout 90;
    proxy_buffer_size 8k;
    proxy_buffers 4 32k;
    proxy_busy_buffers_size 64k;
    proxy_temp_file_write_size 64k;
    client_body_buffer_size 1K;
    client_header_buffer_size 1k;
    client_max_body_size 1k;
    large_client_header_buffers 2 1k;
  }
}
