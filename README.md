# terraform-aws-controlshift-redshift-sync
Terraform module for synchronizing ControlShift data into your data warehouse

[Terraform Module Registry listing](https://registry.terraform.io/modules/controlshift/controlshift-redshift-sync/aws/)

## How-to create new releases

For generating new releases follow the steps below:

1. Commit your changes and push them to Github.
2. Create a tag in your local git repository (e.g.: `git tag 1.0.2`).
3. Push the tag to Github (e.g.: `git push origin 1.0.2`).
4. Go to the [Github Releases](https://github.com/controlshift/terraform-aws-controlshift-redshift-sync/releases) page and click on _Draft a new release_
5. Select the git tag you just created in the _tag_ field
6. Enter a title and a description of this release's changes.
7. Click on _Publish release_
8. Verify the new version is listed as the latest at [Terraform Module Registry listing](https://registry.terraform.io/modules/controlshift/controlshift-redshift-sync/aws/)
