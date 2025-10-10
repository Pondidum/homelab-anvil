resource "vault_approle_auth_backend_role" "app" {
  backend = var.backend
  role_name = var.app_name
  token_policies = var.policies
}

resource "vault_approle_auth_backend_role_secret_id" "app" {
  backend = var.backend
  role_name = vault_approle_auth_backend_role.app.role_name
}

resource "vault_approle_auth_backend_login" "app" {
  backend = var.backend
  role_id = vault_approle_auth_backend_role.app.role_id
  secret_id = vault_approle_auth_backend_role_secret_id.app.secret_id
}

output "token" {
  value = vault_approle_auth_backend_login.app.client_token
}
