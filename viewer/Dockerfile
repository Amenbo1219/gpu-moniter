# ベースイメージとしてnvidia/cudaを使用
FROM python:3.9.19-alpine3.20

# Flaskをインストール
RUN pip3 install flask

# 作業ディレクトリを設定
WORKDIR /app

# アプリケーションファイルをコピー
COPY . /app

# Flaskアプリケーションを起動
CMD ["/bin/bash"]
