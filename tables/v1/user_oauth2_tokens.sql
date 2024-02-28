CREATE TABLE v1.user_oauth2_tokens (
    username TEXT NOT NULL REFERENCES v1.users(username) ON DELETE RESTRICT ON UPDATE CASCADE,
    integration TEXT NOT NULL REFERENCES v1.oauth2_integrations(name) ON DELETE RESTRICT ON UPDATE CASCADE,
    external_id TEXT NOT NULL,
    access_token TEXT NOT NULL,
    refresh_token TEXT,
    id_token TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (integration, external_id)
);
