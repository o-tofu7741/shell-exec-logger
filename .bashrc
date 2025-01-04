# ログファイルのパスを設定（JSON形式）
LOGFILE="$HOME/shell_logs/commands_log.json"

# ディレクトリが存在しない場合は作成
mkdir -p "$HOME/shell_logs"

# ローカルIPアドレスを取得
CLIENT_IP=$(hostname -I | awk '{print $1}')

# ロギングを有効化
LOGGING_ENABLED=1

# 不要なaliasを削除
if [ "$LOGGING_ENABLED" -eq 1 ]; then
    unalias ll 2>/dev/null
    unalias la 2>/dev/null
    unalias l 2>/dev/null
fi

# ログを記録する関数を定義
log_command() {
    # ロギングが無効の場合は何もしない
    if [ "$LOGGING_ENABLED" -eq 0 ]; then
        return
    fi

    if [ -z "$CMD_LOGGING" ]; then
        export CMD_LOGGING=1
        # 前回のコマンドを取得
        COMMAND=$(history 1 | sed "s/^ *[0-9]* *//")
        # インタラクティブなコマンドをスキップ
        skip_list=("vim" "nano" "less" "man")
        skip_command=0
        for skip in "${skip_list[@]}"; do
            if [[ "$COMMAND" == "$skip"* ]]; then
                skip_command=1
                break
            fi
        done

        # タイムスタンプを取得
        TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

        if [ "$skip_command" -eq 1 ]; then
            OUTPUT=""
        else
            # コマンドを実行し、出力を取得
            OUTPUT=$(script -q /dev/stdout -c "$COMMAND" 2>&1)
        fi

        # JSON 形式でログファイルに追記
        jq -n -c --arg timestamp "$TIMESTAMP" --arg client_ip "$CLIENT_IP" --arg command "$COMMAND" --arg output "$OUTPUT" \
            '{timestamp: $timestamp, client_ip: $client_ip, command: $command, output: $output}' >> "$LOGFILE"

        unset CMD_LOGGING
    fi
}

# PROMPT_COMMAND に関数を設定
PROMPT_COMMAND='log_command'
