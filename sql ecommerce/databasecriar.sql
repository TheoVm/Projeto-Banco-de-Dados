CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;

CREATE USER IF NOT EXISTS 'app_user'@'localhost' IDENTIFIED BY 'AppSenha123';
GRANT ALL PRIVILEGES ON ecommerce.* TO 'app_user'@'localhost';
FLUSH PRIVILEGES;