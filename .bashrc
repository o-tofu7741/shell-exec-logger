# ログファイルのパスを設定（JSON形式）
LOGFILE="$HOME/shell_logs/commands_log.json"

# ディレクトリが存在しない場合は作成
mkdir -p "$HOME/shell_logs"

# 一時的なファイルを設定
LOG_TEMP_FILE="/tmp/cmd_output_$$.log"

# DEBUG トラップでコマンド実行前に情報を取得
trap 'CMD_START_TIME=$(date +"%Y-%m-%d %H:%M:%S"); CMD_COMMAND=$BASH_COMMAND; exec 3>&1 4>&2 >"$LOG_TEMP_FILE" 2>&1' DEBUG

# RETURN トラップでコマンド実行後に情報を保存
trap 'CMD_EXIT_STATUS=$?; exec 1>&3 2>&4; CMD_OUTPUT=$(cat "$LOG_TEMP_FILE"); jq -n --arg timestamp "$CMD_START_TIME" --arg command "$CMD_COMMAND" --arg output "$CMD_OUTPUT" --arg status "$CMD_EXIT_STATUS" "{timestamp: \$timestamp, command: \$command, output: \$output, exit_status: \$status}" >> "$LOGFILE"; rm -f "$LOG_TEMP_FILE"' RETURN
