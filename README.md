
ENV vars:

```bash

export TF_VAR_s3_bucket_name=oracle-linux-image     # s3 bucket for ami
export TF_VAR_region=eu-central-1                   # region for ami
export TF_VAR_access_key=
export TF_VAR_secret_key=
export TF_VAR_owners=                               # account id (owner of ami)


```

BUILD:

```bash

packer build -force -only=qemu.oraclelinux-8-aws ./oraclelinux-8-aws.pkr.hcl

packer build -force -only=amazon-ebs.oraclelinux-8-latest-UEK ./oraclelinux-8-aws.pkr.hcl

```

TEST:

```bash

terraform init ./terraform-oraclelinux8/

terraform apply -auto-approve ./terraform-oraclelinux8/

terraform destroy -auto-approve ./terraform-oraclelinux8/

```