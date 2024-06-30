while ($true) {
    # 現在の日時を取得
    $current_time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # 基本的な出力ディレクトリを設定
    $output_dir = "C:\path"

    # ホスト名を取得
    $hostname = $env:COMPUTERNAME

    # CPU使用率を取得
    $cpu_usage = (Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average

    # メモリ使用率と保有量を取得
    $mem_info = Get-WmiObject Win32_OperatingSystem
    $mem_usage = [math]::Round(($mem_info.TotalVisibleMemorySize - $mem_info.FreePhysicalMemory) / $mem_info.TotalVisibleMemorySize * 100, 2)
    $mem_used = [math]::Round(($mem_info.TotalVisibleMemorySize - $mem_info.FreePhysicalMemory) / 1KB, 0)
    $mem_total = [math]::Round($mem_info.TotalVisibleMemorySize / 1KB,0)
    # GPU情報を取得（nvidia-smiが利用可能な場合）
    $gpu_info = nvidia-smi --query-gpu=index,utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits

    # GPU情報を処理してCSVに書き出し
    $gpu_info -split "`n" | ForEach-Object {
        $gpu = $_ -split ','
        $gpu_id = $gpu[0].Trim()
        $gpu_util = $gpu[1].Trim()
        $gpu_mem_used = $gpu[2].Trim()
        $gpu_mem_total = $gpu[3].Trim()
        $gpu_mem_usage = [math]::Round([double]$gpu_mem_used / [double]$gpu_mem_total * 100, 2)

        # GPU毎の出力ファイル名を設定
        $output_file = Join-Path $output_dir "system_resources_gpu$gpu_id.csv"

        # CSVヘッダーを書き出し（ファイルが存在しない場合のみ）
        if (-not (Test-Path $output_file)) {
            "記録時間,ホスト名,CPU使用率,メモリ使用率,メモリ使用量,GPU ID,GPU使用率,GPUメモリ使用率,GPUメモリ使用量" | Out-File $output_file -Encoding utf8
        }
        # データを書き出し
	"$($current_time),$($hostname),$($cpu_usage)%,$($mem_usage)%,$($mem_used)/$($mem_total) MB,$($gpu_id),$($gpu_util)%,$($gpu_mem_usage)%,$($gpu_mem_used)/$($gpu_mem_total) MiB" | 
	Out-File $output_file -Append -Encoding utf8

    }

    # 30秒間待機
    Start-Sleep -Seconds 30
}
