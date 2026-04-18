# Terraform Refresh

The `terraform refresh` command reconciles the Terraform state with the real-world infrastructure.

## Overview

When you run `terraform refresh`, Terraform:

1. Reads the current state of all tracked resources from the real infrastructure
2. Updates the state file to match the actual state (without making any changes to infrastructure)
3. Does **not** modify infrastructure — it only updates the state file

## Usage

```sh
terraform refresh
```

## Example

Given a configuration that manages an EC2 instance:

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "myec2" {
  ami           = "ami-00c39f71452c08778"
  instance_type = "t2.micro"
}
```

If someone manually changes the instance type in the AWS Console, running `terraform refresh` will update the state file to reflect that change — without reverting the manual modification.

## Important Notes

- As of Terraform v0.15.4+, `terraform refresh` is considered a **legacy command**.
- The `-refresh-only` flag with `terraform plan` and `terraform apply` is the recommended approach:
  ```sh
  terraform plan -refresh-only
  terraform apply -refresh-only
  ```
- Refresh does **not** update your `.tf` configuration files — only the state file.

## When to Use Terraform Refresh

- When infrastructure has been modified outside of Terraform (e.g., manual changes in the AWS Console)
- To detect configuration drift before planning changes
- To update output values that depend on current resource attributes
