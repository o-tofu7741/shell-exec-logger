# ログファイルのパスを設定（日時を含める）
LOGFILE="$HOME/shell_logs/commands_log.json"

# ディレクトリが存在しない場合は作成
mkdir -p "$HOME/shell_logs"

# コマンド実行ごとに時刻とコマンドを記録し、入出力を記録する
PROMPT_COMMAND='
{
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    COMMAND=$(history 1 | sed "s/^ *[0-9]* *//")
    OUTPUT=$(script -q -c "$COMMAND" /dev/null 2>&1)
    jq -n --arg timestamp "$TIMESTAMP" --arg command "$COMMAND" --arg output "$OUTPUT" \
        "{timestamp: \$timestamp, command: \$command, output: \$output}" >> $LOGFILE
}'
