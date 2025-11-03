-- ==========================
-- CRIAÇÃO DE TIPOS (ENUMs)
-- ==========================
CREATE TYPE user_role AS ENUM ('admin', 'funcionario');

-- ==========================
-- TABELA: USERS Testando
-- (Deve ser criada primeiro, pois outras tabelas dependem dela)
-- ==========================
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(80) NOT NULL UNIQUE,
    email VARCHAR(120) UNIQUE,
    password_hash VARCHAR(128) NOT NULL,
    salt VARCHAR(32) NOT NULL,
    role user_role NOT NULL DEFAULT 'funcionario',
    needs_password_reset BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    job_title VARCHAR(100) DEFAULT 'Funcionário' -- Coluna do ALTER TABLE já incluída
);

-- ==========================
-- TABELA: ACTIVITY_LOG
-- ==========================
CREATE TABLE activity_log (
    id SERIAL PRIMARY KEY,
    user_id INT,
    action_text VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- ==========================
-- TABELA: TASKS
-- ==========================
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    priority INT NOT NULL DEFAULT 2,
    due_date DATE,
    completed BOOLEAN NOT NULL DEFAULT FALSE,
    creator_id INT NOT NULL,
    assigned_to_id INT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Removido "ON UPDATE"
    FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_to_id) REFERENCES users(id) ON DELETE SET NULL
);

-- ==========================
-- FUNÇÃO DE TRIGGER para "updated_at"
-- (Substitui o "ON UPDATE CURRENT_TIMESTAMP" do MySQL)
-- ==========================
CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ==========================
-- CRIAÇÃO DO TRIGGER
-- Associa a função acima à tabela "tasks"
-- ==========================
CREATE TRIGGER set_timestamp
BEFORE UPDATE ON tasks
FOR EACH ROW
EXECUTE PROCEDURE trigger_set_timestamp();

-- ==========================
-- TABELA: TASK_COMMENTS
-- ==========================
CREATE TABLE task_comments (
    id SERIAL PRIMARY KEY,
    task_id INT NOT NULL,
    user_id INT NOT NULL,
    text TEXT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ==========================
-- TABELA: CHAT_MESSAGES
-- ==========================
CREATE TABLE chat_messages (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    text TEXT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ==========================
-- INSERÇÃO DE USUÁRIO ADMIN INICIAL
-- ==========================
-- (opcional, para login inicial com a chave 'admin-secret-key')
-- SELECT * FROM users;
-- Crie manualmente depois se desejar um admin inicial, ex:
-- INSERT INTO users (username, email, password_hash, salt, role)
-- VALUES ('admin', 'admin@email.com', '<hash>', '<salt>', 'admin');

-- O "ALTER TABLE" do script original foi incorporado diretamente

-- na criação da tabela "users" (coluna "job_title").
