# aws-s3-cross-account-sync
Auto-creates bucket policy and performs sync

## Dependencies
envsubst, yq, aws-cli

## Running

Either export `AWS_PROFILE_SOURCE` and `AWS_PROFILE_TARGET` with the correct profile names, or create credentials profiles called `source` and `target` with the respective credentials.

```
./sync.sh <source-bucket> <target-bucket>
```
