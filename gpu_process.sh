#!/bin/bash

while true; do
    # 現在の日時を取得
    current_time=$(date "+%Y-%m-%d %H:%M:%S")

    # 基本的な出力ディレクトリを設定
    output_dir="/home/path"

    # ホスト名を取得
    hostname=$(hostname)

    # CPU使用率を取得
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')

    # メモリ使用率と保有量を取得
    mem_info=$(free -m | awk 'NR==2{printf "%.2f %d %d", $3*100/$2, $3, $2}')
    mem_usage=$(echo $mem_info | awk '{print $1}')
    mem_used=$(echo $mem_info | awk '{print $2}')
    mem_total=$(echo $mem_info | awk '{print $3}')

    # GPU情報を取得
    gpu_info=$(nvidia-smi --query-gpu=index,utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits)

    # GPU情報を処理してCSVに書き出し
    IFS=$'\n'
    for gpu in $gpu_info
    do
        IFS=',' read -r gpu_id gpu_util gpu_mem_used gpu_mem_total <<< "$gpu"
        gpu_mem_usage=$(awk "BEGIN {printf \"%.2f\", $gpu_mem_used/$gpu_mem_total*100}")
        
        # GPU毎の出力ファイル名を設定
        output_file="${output_dir}/system_resources_gpu${gpu_id}.csv"
        
        # CSVヘッダーを書き出し（ファイルが存在しない場合のみ）
        if [ ! -f "$output_file" ]; then
            echo "記録時間,ホスト名,CPU使用率,メモリ使用率,メモリ使用量,GPU ID,GPU使用率,GPUメモリ使用率,GPUメモリ使用量" > $output_file
        fi
        
        # データを書き出し
        echo "${current_time},${hostname},${cpu_usage}%,${mem_usage}%,${mem_used}/${mem_total}MB,${gpu_id},${gpu_util}%,${gpu_mem_usage}%,${gpu_mem_used}/${gpu_mem_total} MiB" >> $output_file
    done

    # echo "Data recorded at: $current_time"

    # 7秒間待機
    sleep 60
done
