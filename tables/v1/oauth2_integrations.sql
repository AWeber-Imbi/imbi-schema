SET SEARCH_PATH TO v1;

CREATE TABLE IF NOT EXISTS oauth2_integrations (
    name                   TEXT    NOT NULL PRIMARY KEY,
    api_endpoint           TEXT    NOT NULL,
    callback_url           TEXT,
    authorization_endpoint TEXT    NOT NULL,
    token_endpoint         TEXT    NOT NULL,
    revoke_endpoint        TEXT,
    client_id              TEXT    NOT NULL,
    client_secret          TEXT,
    public_client          BOOLEAN NOT NULL
);

COMMENT ON TABLE oauth2_integrations IS 'Table of OAuth2 connection details for integrations.';
COMMENT ON COLUMN oauth2_integrations.name IS 'Unique display name for the integrated application.';
COMMENT ON COLUMN oauth2_integrations.api_endpoint IS 'Root URL for the application HTTP API.';
COMMENT ON COLUMN oauth2_integrations.callback_url IS 'URL to include as the redirect_uri in the OAuth 2 authorization flow.';
COMMENT ON COLUMN oauth2_integrations.authorization_endpoint IS 'URL used to initiate the OAuth 2 authorization flow.';
COMMENT ON COLUMN oauth2_integrations.token_endpoint IS 'URL used to redeem an OAuth 2 authorization code.';
COMMENT ON COLUMN oauth2_integrations.revoke_endpoint IS 'URL used to revoke an OAuth 2 token if supported.';
COMMENT ON COLUMN oauth2_integrations.client_id IS 'Public OAuth 2 client ID used to for OAuth 2 authorization.';
COMMENT ON COLUMN oauth2_integrations.client_secret IS 'OAuth 2 client secret used for Oauth 2 authorization.';
COMMENT ON COLUMN oauth2_integrations.public_client IS 'If TRUE, then the OAuth 2 authorization flow requires PKCE.';

GRANT SELECT ON oauth2_integrations TO reader;
GRANT SELECT, INSERT, UPDATE, DELETE ON oauth2_integrations TO admin;
