docker build -t gpu-checker .
docker run -itd -v ./:/app/ -v /export/public:/export/public --gpus all -p 8080:5000 gpu-checker /bin/sh -c 'python3 /app/app.py'
