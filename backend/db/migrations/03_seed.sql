-- Insert user roles
INSERT INTO user_roles (name, reach_level) VALUES
  ('Admin', 10),
  ('Teacher', 5),
  ('Student', 1)
ON CONFLICT (name) DO NOTHING;

-- Insert initial groups
INSERT INTO groups (name, type) VALUES
  ('Super Usuarios', 'devs'),
  ('Direccion general', 'departmento'),
  ('Control escolar', 'departmento'),
  ('Ingenieria en Sistemas Computacionales', 'academia')
ON CONFLICT (name, type) DO NOTHING;

-- Insert admin users
INSERT INTO users (control_number, email, name, role_id, primary_group_id)
VALUES 
  ('ADMIN001', 'admin@megafonito.com', 'Super User', 
   (SELECT id FROM user_roles WHERE name = 'Admin'),
   (SELECT id FROM groups WHERE name = 'Direccion general')),
  ('23040061', 'karol@megafonito.com', 'Karol', 
   (SELECT id FROM user_roles WHERE name = 'Admin'),
   (SELECT id FROM groups WHERE name = 'Super Usuarios'))
-- Associate admin users with their groups
ON CONFLICT (control_number) DO NOTHING;

-- Associate admin users with their groups
INSERT INTO user_groups (user_id, group_id)
SELECT u.id, g.id
FROM users u, groups g
WHERE u.control_number IN ('ADMIN001', '23040061') 
  AND g.name = 'Super Usuarios'
ON CONFLICT (user_id, group_id) DO NOTHING;