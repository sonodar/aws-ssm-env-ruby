# aws-ssm-env

AWS EC2 Parameter Store (Systems Manager Parameter Store) から
パラメータを取得し、環境変数として設定するライブラリ。

## Use Cases

このライブラリは、Parameter Store とのネイティブ統合が提供されていない以下のような環境で有用です：

- **AWS Lambda Function** - 環境変数の4KB制限を超える設定が必要な場合
- **Amazon SageMaker Processing Job** - 処理ジョブ内で秘密情報を扱う場合
- **EC2 インスタンス** - アプリケーション起動時に動的に設定を読み込む場合
- **オンプレミス環境** - AWS 認証情報を持つ環境から Parameter Store にアクセスする場合

## Background

このライブラリは、Amazon ECS が `secrets` ディレクティブで Parameter Store とのネイティブ統合を実装する以前に開発されました。当時は ECS タスクで秘密情報を安全に扱うために、アプリケーション起動時に Parameter Store からパラメータを取得して環境変数に設定する仕組みが必要でした。

現在では ECS/Fargate は Parameter Store および Secrets Manager とネイティブ統合されているため、コンテナワークロードでこのライブラリを使用する必要はありません。

## Supported Languages

| Language | Directory | Status |
|----------|-----------|--------|
| Ruby | [ruby/](./ruby/) | Available |
| Python | python/ | Coming Soon |
| Go | go/ | Coming Soon |
| Node.js | nodejs/ | Coming Soon |
| Rust | rust/ | Coming Soon |
| Java | java/ | Coming Soon |
| .NET | dotnet/ | Coming Soon |

## Features

- パラメータ階層（path）またはプレフィックス（begins_with）による取得
- SecureStringパラメータの自動復号化
- 柔軟な環境変数命名戦略

## Quick Links

- [Ruby gem ドキュメント](./ruby/README.md)
- [Ruby gem ドキュメント (日本語)](./ruby/README_ja.md)
- [English README](./README.md)

## License

Apache License 2.0 - see [LICENSE](./LICENSE)
