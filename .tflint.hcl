plugin "azurerm" {
    enabled = true
    version = "0.27.0"
    source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

rule "terraform_documented_variables" {
    enabled = true
}

rule "azurerm_resource_missing_tags" {
    enabled = true
    tags    = ["CostCenter", "Project"]
}

rule "terraform_named_values_disallowed" {
    enabled = true
    variable_names = ["password", "secret", "aws_access_key"]
}
