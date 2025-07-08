--- A small utility to fetch secrets from the 1Password CLI
local M = {}

--- Fetches a secret from a 1Password secret reference URI.
-- @param secret_uri (string) The op://... URI of the secret.
-- @return (string|nil) The secret if found, otherwise nil.
function M.get_secret(secret_uri)
  -- Construct the command to securely read the secret
  -- The --no-newline flag is important to prevent trailing characters
  local command = "op read --no-newline " .. vim.fn.shellescape(secret_uri)

  -- Execute the command and capture the output
  local secret = vim.fn.system(command)

  -- vim.v.shell_error is non-zero if the command fails
  if vim.v.shell_error ~= 0 then
    vim.notify(
      "1Password: Failed to fetch secret for " .. secret_uri .. ". Is `op` installed and are you logged in?",
      vim.log.levels.ERROR
    )
    return nil
  end

  -- Return the secret if the command was successful
  if secret and #secret > 0 then
    return secret
  else
    vim.notify("1Password: Secret not found or is empty for " .. secret_uri, vim.log.levels.WARN)
    return nil
  end
end

return M
