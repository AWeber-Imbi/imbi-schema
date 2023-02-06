SET search_path = v1;

CREATE OR REPLACE FUNCTION upsert_user(
  in_username      TEXT,
  in_user_type     entity_type,
  in_external_id   TEXT,
  in_display_name  TEXT,
  in_email_address TEXT
) RETURNS TIMESTAMP WITH TIME ZONE
       LANGUAGE plpgsql
       SECURITY DEFINER AS $$
  DECLARE
    existing_username TEXT;
    last_seen_at      TIMESTAMP WITH TIME ZONE;
  BEGIN
    SELECT username INTO existing_username
      FROM v1.users
     WHERE username = in_username
        OR email_address = in_email_address;

    IF existing_username IS NULL THEN
      INSERT INTO v1.users (username, user_type, external_id,
                            display_name, email_address, last_seen_at)
      VALUES (in_username, in_user_type, in_external_id,
              in_display_name, in_email_address, CURRENT_TIMESTAMP)
      RETURNING v1.users.last_seen_at INTO last_seen_at;
    ELSE
      UPDATE v1.users
         SET username = in_username,
             user_type = in_user_type,
             external_id = in_external_id,
             email_address = in_email_address,
             display_name = in_display_name,
             password = NULL,
             last_seen_at = CURRENT_TIMESTAMP
      WHERE username = existing_username
      RETURNING v1.users.last_seen_at INTO last_seen_at;
    END IF;

    RETURN last_seen_at;
  END;
$$;
