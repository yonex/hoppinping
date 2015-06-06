# hoppinping
[こころぴょんぴょんドットコム](http://こころぴょんぴょん.com)

### nginx.conf
```
server {
  server_name xn--28ja3ha8gb2b0cc.com; # こころぴょんぴょん
  location / {
    proxy_pass http://127.0.0.1:好きなポート番号;
  }
}
```

### 起動
```
bundle install --path vender/bundle
bundle exec rackup -p 好きなポート番号 -D -Eproduction
```
