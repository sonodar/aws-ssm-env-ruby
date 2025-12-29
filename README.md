# aws-ssm-env

A library that retrieves parameters from AWS EC2 Parameter Store (Systems Manager Parameter Store) and sets them as environment variables.

## Use Cases

This library is useful in environments where native integration with Parameter Store is not provided:

- **AWS Lambda Function** - When configuration exceeds the 4KB environment variable limit
- **Amazon SageMaker Processing Job** - When handling secrets within processing jobs
- **EC2 Instances** - When dynamically loading configuration at application startup
- **On-premises environments** - When accessing Parameter Store from environments with AWS credentials

## Background

This library was developed before Amazon ECS implemented native integration with Parameter Store via the `secrets` directive. At that time, a mechanism was needed to securely handle secrets in ECS tasks by retrieving parameters from Parameter Store and setting them as environment variables at application startup.

Currently, ECS/Fargate has native integration with Parameter Store and Secrets Manager, so there is no need to use this library for container workloads.

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

- Retrieve parameters by hierarchy (path) or prefix (begins_with)
- Automatic decryption of SecureString parameters
- Flexible environment variable naming strategies

## Quick Links

- [Ruby gem documentation](./ruby/README.md)
- [Ruby gem (Japanese)](./ruby/README_ja.md)
- [Japanese README](./README_ja.md)

## License

Apache License 2.0 - see [LICENSE](./LICENSE)
