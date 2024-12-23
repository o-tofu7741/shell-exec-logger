# ログファイルのパスを設定（JSON形式）
LOGFILE="$HOME/shell_logs/commands_log.json"

# ディレクトリが存在しない場合は作成
mkdir -p "$HOME/shell_logs"

# ローカルIPアドレスを取得
CLIENT_IP=$(hostname -I | awk '{print $1}')

# ログを記録する関数を定義
log_command() {
    if [ -z "$CMD_LOGGING" ]; then
        export CMD_LOGGING=1
        # 前回のコマンドを取得
        COMMAND=$(history 1 | sed "s/^ *[0-9]* *//")
        # インタラクティブなコマンドをスキップ
        skip_list=("vim" "nano" "less" "man")
        skip_command=false
        for skip in "${skip_list[@]}"; do
            if [[ "$COMMAND" == "$skip"* ]]; then
                skip_command=true
                break
            fi
        done

        # タイムスタンプを取得
        TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

        if $skip_command; then
            OUTPUT=""
            EXIT_STATUS=0
        else
            # コマンドを実行し、出力を取得
            OUTPUT=$(script -q -c "$COMMAND" /dev/null 2>&1)
            EXIT_STATUS=$?
            # コマンドの結果を表示
            echo "$OUTPUT"
        fi

        # JSON 形式でログファイルに追記
        jq -n --arg timestamp "$TIMESTAMP" --arg client_ip "$CLIENT_IP" --arg command "$COMMAND" --arg output "$OUTPUT" --arg status "$EXIT_STATUS" \
            '{timestamp: $timestamp, client_ip: $client_ip, command: $command, output: $output, exit_status: $status}' >> "$LOGFILE"

        unset CMD_LOGGING
        return $EXIT_STATUS
    fi
}

# PROMPT_COMMAND に関数を設定
PROMPT_COMMAND='log_command'
