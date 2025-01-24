provider "azurerm" {
  features {}

  subscription_id = "c1e31a18-848c-4197-9ac7-f919c1b1d131"
  client_id       = "068f3439-505f-4807-9f59-9748b899618e"
  client_secret   = var.Azure_appreg_secret
  tenant_id       = "3a663e17-ca5f-44c7-b385-8c074a12e91f"
}
