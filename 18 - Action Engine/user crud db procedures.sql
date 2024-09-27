CREATE OR REPLACE FUNCTION create_user(
    p_username varchar,
    p_email varchar,
    p_password_hash varchar,
    p_role_id int
) RETURNS void AS $$
BEGIN
    INSERT INTO kenya_portfolio.ae_users (username, email, password_hash, role_id)
    VALUES (p_username, p_email, p_password_hash, p_role_id);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION get_user(p_user_id int)
RETURNS TABLE (
    user_id int,
    username varchar,
    email varchar,
    password_hash varchar,
    role_id int,
    created_at timestamptz,
    updated_at timestamptz,
    last_login_at timestamptz
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM kenya_portfolio.ae_users
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION update_user(
    p_user_id int,
    p_username varchar,
    p_email varchar,
    p_password_hash varchar,
    p_role_id int
) RETURNS void AS $$
BEGIN
    UPDATE kenya_portfolio.ae_users
    SET username = p_username,
        email = p_email,
        password_hash = p_password_hash,
        role_id = p_role_id,
        updated_at = CURRENT_TIMESTAMP
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION delete_user(p_user_id int) RETURNS void AS $$
BEGIN
    DELETE FROM kenya_portfolio.ae_users
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;
