# Release Process

The code uses Terraform with a combination of YAML, TF and other files to coordinate the provisioning and setup of the
relevant infrastrucutre.

Once a release is identified, the following steps are taken.

1. Update to the latest `main` branch `git checkout main; git pull`
2. Run [`terraform-docs`](https://github.com/terraform-docs/terraform-docs) and ensure it's cleanly presented.

```
terraform-docs markdown table .
```

3. Tag the `main` branch `git tag v0.0.1`
4. Push tags `git push --tags`
5. Update the Release Notes to indicate the changes made since the prior release.

These should be selected from the commits:

```
    feat: A new feature
    fix: A bug fix
    docs: Documentation only changes
    style: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
    refactor: A code change that neither fixes a bug or adds a feature
    perf: A code change that improves performance
    test: Adding missing tests
    chore: Changes to the build process or auxiliary tools and libraries such as documentation generation
```

The release notes should include features and fixes and detailing any backward breaking changes.