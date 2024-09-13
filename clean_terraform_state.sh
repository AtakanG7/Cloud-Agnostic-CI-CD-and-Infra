find . -type f -name "*.terraform.lock.hcl" -o -name "*.terraform.tfstate*" -o -name ".terraform" -exec rm -rf {} +
