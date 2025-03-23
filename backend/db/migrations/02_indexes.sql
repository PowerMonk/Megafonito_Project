-- Create indexes for improved performance
CREATE INDEX IF NOT EXISTS idx_users_control_number ON users(control_number);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role_id ON users(role_id);
CREATE INDEX IF NOT EXISTS idx_users_primary_group_id ON users(primary_group_id);

CREATE INDEX IF NOT EXISTS idx_user_groups_user_id ON user_groups(user_id);
CREATE INDEX IF NOT EXISTS idx_user_groups_group_id ON user_groups(group_id);

CREATE INDEX IF NOT EXISTS idx_classes_group_id ON classes(group_id);
CREATE INDEX IF NOT EXISTS idx_classes_code ON classes(code);

CREATE INDEX IF NOT EXISTS idx_user_classes_user_id ON user_classes(user_id);
CREATE INDEX IF NOT EXISTS idx_user_classes_class_id ON user_classes(class_id);

CREATE INDEX IF NOT EXISTS idx_notices_author_id ON notices(author_id);
CREATE INDEX IF NOT EXISTS idx_notices_category ON notices(category);
CREATE INDEX IF NOT EXISTS idx_notices_min_role_level ON notices(min_role_level);
CREATE INDEX IF NOT EXISTS idx_notices_publish_at ON notices(publish_at);
CREATE INDEX IF NOT EXISTS idx_notices_expiry_date ON notices(expiry_date);

CREATE INDEX IF NOT EXISTS idx_polls_author_id ON polls(author_id);
CREATE INDEX IF NOT EXISTS idx_polls_min_role_level ON polls(min_role_level);
CREATE INDEX IF NOT EXISTS idx_polls_expiry_date ON polls(expiry_date);

CREATE INDEX IF NOT EXISTS idx_resources_type ON resources(type);
CREATE INDEX IF NOT EXISTS idx_resources_min_role_level ON resources(min_role_level);
CREATE INDEX IF NOT EXISTS idx_resources_expiry_date ON resources(expiry_date);