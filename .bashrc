# ログファイルのパスを設定（日時を含める）
LOGFILE="$HOME/shell_logs/$(date '+%Y-%m-%d_%H-%M-%S').log"

# ディレクトリが存在しない場合は作成
mkdir -p "$HOME/shell_logs"

# コマンド実行ごとに時刻とコマンドを記録し、入出力を記録する
PROMPT_COMMAND='
{
    echo -e "\n\n### Command Executed: $(date +"%Y-%m-%d %H:%M:%S")"
    history 1 | sed "s/^ *[0-9]* *//"
    script -q -c "$(history 1 | sed "s/^ *[0-9]* *//")" /dev/null 2>&1
} >> $LOGFILE'
