CREATE DATABASE IF NOT EXISTS meubanco;
USE meubanco;

CREATE TABLE IF NOT EXISTS mensagens (
    id INT NOT NULL PRIMARY KEY,
    nome VARCHAR(100),
    email VARCHAR(100),
    comentario VARCHAR(500)
);
