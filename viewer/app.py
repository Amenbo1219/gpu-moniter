from flask import Flask, render_template_string
import csv
import os

app = Flask(__name__)

# CSVファイルのディレクトリ
CSV_DIR = './data/'

# HTMLテンプレート
HTML_TEMPLATE = '''
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>サーバー使用率</title>
    <style>
        table { border-collapse: collapse; width: 100%; margin-bottom: 20px; }
        th, td { border: 1px solid black; padding: 8px; text-align: center; }
        th { background-color: #f2f2f2; }
    </style>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        function updateData() {
            $.ajax({
                url: '/data',
                success: function(data) {
                    $('#data-container').html(data);
                }
            });
        }

        $(document).ready(function() {
            updateData();
            setInterval(updateData, 1000);
        });
    </script>
</head>
<body>
    <h1>サーバー使用率</h1>
    <div id="data-container"></div>
</body>
</html>
'''

DATA_TEMPLATE = '''
<table>
    <tr>
        <th>ホスト名</th>
        <th>CPU使用率</th>
        <th>メモリ使用率</th>
        <th>メモリ使用量</th>
        <th>GPU ID</th>
        <th>GPU使用率</th>
        <th>GPUメモリ使用率</th>
        <th>GPUメモリ使用量</th>
    </tr>
    {% for server in servers %}
    <tr>
        <td>{{ server['hostname'] }}</td>
        <td>{{ server['cpu_usage'] }}</td>
        <td>{{ server['mem_usage'] }}</td>
        <td>{{ server['mem_used'] }}</td>
        <td>{{ server['gpu_id'] }}</td>
        <td>{{ server['gpu_util'] }}</td>
        <td>{{ server['gpu_mem_usage'] }}</td>
        <td>{{ server['gpu_mem'] }}</td>
    </tr>
    {% endfor %}
</table>
'''

def read_csv_files():
    servers = []
    for root, dirs, files in os.walk(CSV_DIR):
        for filename in files:
            if filename.endswith('.csv'):
                with open(os.path.join(root, filename), 'r') as csvfile:
                    reader = csv.DictReader(csvfile)
                    rows = list(reader)
                    if rows:  # ファイルが空でない場合
                        last_row = rows[-1]  # 最後の行を取得
                        servers.append({
                            'hostname': last_row['ホスト名'],
                            'cpu_usage': last_row['CPU使用率'],
                            'mem_usage': last_row['メモリ使用率'],
                            'mem_used': last_row['メモリ使用量'],
                            'gpu_id': last_row['GPU ID'],
                            'gpu_util': last_row['GPU使用率'],
                            'gpu_mem_usage': last_row['GPUメモリ使用率'],
                            'gpu_mem': last_row['GPUメモリ使用量']
                        })
    
    # サーバーの種類とGPU IDでソート
    servers.sort(key=lambda x: (x['hostname'].split('-')[0], int(x['gpu_id'])))
    return servers

@app.route('/')
def index():
    return render_template_string(HTML_TEMPLATE)

@app.route('/data')
def data():
    servers = read_csv_files()
    return render_template_string(DATA_TEMPLATE, servers=servers)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
