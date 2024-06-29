# ベースイメージとしてnvidia/cudaを使用
FROM nvidia/cuda:11.7.1-base-ubuntu20.04

# 必要なパッケージをインストール
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Flaskをインストール
RUN pip3 install flask

# 作業ディレクトリを設定
WORKDIR /app

# アプリケーションファイルをコピー
COPY . /app

# Flaskアプリケーションを起動
CMD ["/bin/bash"]
