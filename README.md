# Shell Command Logger

このプロジェクトは、シェルコマンドの実行履歴をJSON形式でログファイルに記録するためのスクリプトを提供します。

## セットアップ

1. `.bashrc`ファイルをホームディレクトリに配置します。
2. 必要に応じて、ログファイルのパスやその他の設定を変更します。

## 使用方法

`.bashrc`ファイルには、以下の設定と関数が含まれています。

### ログファイルのパス設定

```bash
LOGFILE="$HOME/shell_logs/commands_log.json"
```

ログファイルのパスを設定します。デフォルトでは、ホームディレクトリの`shell_logs`ディレクトリに`commands_log.json`という名前で保存されます。

### ディレクトリの作成

```bash
mkdir -p "$HOME/shell_logs"
```

ログファイルを保存するディレクトリが存在しない場合は作成します。

### ローカルIPアドレスの取得

```bash
CLIENT_IP=$(hostname -I | awk '{print $1}')
```

ローカルIPアドレスを取得します。

### ロギングの有効化

```bash
LOGGING_ENABLED=1
```

ロギングを有効化します。`0`に設定するとロギングが無効になります。

### 不要なaliasの削除

```bash
if [ "$LOGGING_ENABLED" -eq 1 ]; then
    unalias ll 2>/dev/null
    unalias la 2>/dev/null
    unalias l 2>/dev/null
fi
```

不要なaliasを削除します。

### ログを記録する関数

```bash
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
            OUTPUT=$(script -q -c "$COMMAND" /dev/null 2>&1)
        fi

        # JSON 形式でログファイルに追記
        jq -n -c \
        --arg timestamp "$TIMESTAMP" \
        --arg client_ip "$CLIENT_IP" \
        --arg command "$COMMAND" \
        --arg output "$OUTPUT" \
        '{timestamp: $timestamp, client_ip: $client_ip, command: $command, output: $output}' >> "$LOGFILE"

        unset CMD_LOGGING
    fi
}
```

この関数は、シェルコマンドの実行履歴を取得し、JSON形式でログファイルに記録します。

### PROMPT_COMMANDに関数を設定

```bash
PROMPT_COMMAND='log_command'
```

`PROMPT_COMMAND`に`log_command`関数を設定し、各コマンド実行後にログを記録します。

## 注意事項

- このスクリプトは、`jq`コマンドがインストールされていることを前提としています。
- インタラクティブなコマンド（`vim`, `nano`, `less`, `man`など）はログに記録されません。

以上でセットアップは完了です。シェルを再起動するか、`.bashrc`ファイルを再読み込みしてスクリプトを有効にしてください。

```bash
source ~/.bashrc
```
