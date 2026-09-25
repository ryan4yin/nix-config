# RustFS

RustFS replaced the retired MinIO at `s3.writefor.fun` (console: `s3-console.writefor.fun`). The
service is declared in nix-config on the youko host; this directory manages its buckets/lifecycle
and documents the IAM setup.

## Credentials

RustFS has no separate "root user" name: the root **access key** acts as the user and the **secret
key** acts as the password. They live in agenix as a single dotenv secret; on youko it is decrypted
to `/run/agenix/rustfs.env` (variables `RUSTFS_ACCESS_KEY` / `RUSTFS_SECRET_KEY`):

```bash
set -a; . <(sudo cat /run/agenix/rustfs.env); set +a
rc alias set rustfs https://s3.writefor.fun "$RUSTFS_ACCESS_KEY" "$RUSTFS_SECRET_KEY"
```

## Buckets

```bash
rc mb rustfs/tf-s3-backend
rc mb rustfs/k3s-test-1-loki-chunks
rc mb rustfs/k3s-test-1-loki-ruler
rc mb rustfs/k3s-test-1-loki-admin

# 7-day expiry safety net on Loki chunks
rc ilm rule add rustfs/k3s-test-1-loki-chunks --expiry-days 7
```

If the buckets were carried over from MinIO (S3-level copy), they already exist; import them into
Terraform instead (`terraform import`, see the workspace READMEs).

## IAM

### Loki user

`rc admin user add <alias>/ <accessKey> <secretKey>` creates a user whose access key is the given
name. Generate a strong secret and reuse it when encrypting the k8s-gitops SOPS values.

```bash
LOKI_SECRET="$(openssl rand -hex 20)"
rc admin user add rustfs/ loki "$LOKI_SECRET"

cat > /tmp/loki-policy.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ObjectFullAccess",
      "Action": ["s3:PutObject", "s3:GetObject", "s3:ListBucket", "s3:DeleteObject"],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::k3s-test-1-loki-chunks",
        "arn:aws:s3:::k3s-test-1-loki-chunks/*",
        "arn:aws:s3:::k3s-test-1-loki-ruler",
        "arn:aws:s3:::k3s-test-1-loki-ruler/*",
        "arn:aws:s3:::k3s-test-1-loki-admin",
        "arn:aws:s3:::k3s-test-1-loki-admin/*"
      ]
    }
  ]
}
EOF
rc admin policy create rustfs/ loki /tmp/loki-policy.json
rc admin policy attach rustfs/ loki --user loki
```

The k8s-gitops Loki values use access key `loki` and `$LOKI_SECRET`.

### Terraform credentials

Terraform runs with the RustFS root credentials; on youko export them before running it:

```bash
set -a; . <(sudo cat /run/agenix/rustfs.env); set +a
export AWS_ACCESS_KEY_ID="$RUSTFS_ACCESS_KEY" AWS_SECRET_ACCESS_KEY="$RUSTFS_SECRET_KEY"
```

Optionally, replace that with a dedicated account limited to the state bucket:

```bash
TF_SECRET="$(openssl rand -hex 20)"
rc admin user add rustfs/ tf-s3-backend "$TF_SECRET"

cat > /tmp/tf-s3-policy.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::tf-s3-backend"
    },
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
      "Resource": "arn:aws:s3:::tf-s3-backend/*"
    }
  ]
}
EOF
rc admin policy create rustfs/ tf-s3-backend /tmp/tf-s3-policy.json
rc admin policy attach rustfs/ tf-s3-backend --user tf-s3-backend
```

Then export that account's keys as `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` instead.

## Carrying over the old MinIO data

The old tree is at `/data/apps/minio/data` on youko and is left untouched as a rollback snapshot.
Serve it with a throwaway MinIO, then mirror with `rc`:

```bash
podman run -d --rm --name minio-migrate \
  -p 127.0.0.1:19000:9000 \
  -v /data/apps/minio/data:/data \
  minio/minio server /data

rc alias set old http://127.0.0.1:19000 <temp-access> <temp-secret>
rc mirror old/tf-s3-backend/ rustfs/tf-s3-backend/
rc mirror old/k3s-test-1-loki-chunks/ rustfs/k3s-test-1-loki-chunks/

# verify, then remove the temp server
podman rm -f minio-migrate
```

Object data is not bound to MinIO's root credentials (only the encrypted IAM metadata in
`.minio.sys` is), so a temporary credential works for the copy.
