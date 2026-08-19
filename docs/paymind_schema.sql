-- =========================================================
-- PayMind AI - Phase 2: Core Database Schema (MySQL 8)
-- =========================================================

USE paymind_db;

-- ---------------------------------------------------------
-- ROLES
-- ---------------------------------------------------------
CREATE TABLE roles (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(50) NOT NULL UNIQUE,   -- e.g. ROLE_ADMIN, ROLE_USER
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------------------------------------
-- USERS
-- ---------------------------------------------------------
CREATE TABLE users (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    full_name       VARCHAR(120) NOT NULL,
    email           VARCHAR(150) NOT NULL UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,       -- BCrypt hash, never plain text
    role_id         BIGINT NOT NULL,
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_users_role FOREIGN KEY (role_id) REFERENCES roles(id),
    INDEX idx_users_email (email)
);

-- ---------------------------------------------------------
-- ACCOUNTS
-- ---------------------------------------------------------
CREATE TABLE accounts (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id         BIGINT NOT NULL,
    account_number  VARCHAR(30) NOT NULL UNIQUE,   -- simulated, not a real bank number
    account_type    VARCHAR(30) NOT NULL,           -- CHECKING, SAVINGS
    balance         DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    currency        VARCHAR(10) NOT NULL DEFAULT 'USD',
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_accounts_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_accounts_user (user_id)
);

-- ---------------------------------------------------------
-- CATEGORIES
-- ---------------------------------------------------------
CREATE TABLE categories (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(60) NOT NULL UNIQUE,   -- e.g. Food, Rent, Travel, Entertainment
    description VARCHAR(255),
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------------------------------------
-- TRANSACTIONS
-- ---------------------------------------------------------
CREATE TABLE transactions (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    account_id      BIGINT NOT NULL,
    category_id     BIGINT,
    amount          DECIMAL(15,2) NOT NULL,
    transaction_type VARCHAR(20) NOT NULL,   -- DEBIT, CREDIT
    merchant_name   VARCHAR(150),
    description     VARCHAR(255),
    status          VARCHAR(20) NOT NULL DEFAULT 'PENDING',  -- PENDING, COMPLETED, FAILED
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_txn_account FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE,
    CONSTRAINT fk_txn_category FOREIGN KEY (category_id) REFERENCES categories(id),
    INDEX idx_txn_account (account_id),
    INDEX idx_txn_date (transaction_date),
    INDEX idx_txn_category (category_id)
);

-- ---------------------------------------------------------
-- PAYMENTS
-- ---------------------------------------------------------
CREATE TABLE payments (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    transaction_id  BIGINT NOT NULL,
    payment_method  VARCHAR(30) NOT NULL,   -- CARD, BANK_TRANSFER, WALLET (simulated)
    payment_status  VARCHAR(20) NOT NULL DEFAULT 'INITIATED', -- INITIATED, COMPLETED, FAILED
    reference_code  VARCHAR(50) NOT NULL UNIQUE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_payment_txn FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE,
    INDEX idx_payment_txn (transaction_id)
);

-- ---------------------------------------------------------
-- BUDGETS
-- ---------------------------------------------------------
CREATE TABLE budgets (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id         BIGINT NOT NULL,
    category_id     BIGINT NOT NULL,
    monthly_limit   DECIMAL(15,2) NOT NULL,
    month           TINYINT NOT NULL,   -- 1-12
    year            SMALLINT NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_budget_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_budget_category FOREIGN KEY (category_id) REFERENCES categories(id),
    UNIQUE KEY uq_budget_user_cat_month (user_id, category_id, month, year)
);

-- ---------------------------------------------------------
-- RISK_ANALYSIS  (AI-generated, one per transaction)
-- ---------------------------------------------------------
CREATE TABLE risk_analysis (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    transaction_id  BIGINT NOT NULL UNIQUE,
    risk_score      TINYINT NOT NULL,      -- 0-100
    risk_level      VARCHAR(20) NOT NULL,  -- LOW, MEDIUM, HIGH
    reasons         TEXT,                  -- AI-generated explanation, comma or JSON list
    analyzed_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_risk_txn FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE
);

-- ---------------------------------------------------------
-- NOTIFICATIONS
-- ---------------------------------------------------------
CREATE TABLE notifications (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT NOT NULL,
    title       VARCHAR(150) NOT NULL,
    message     VARCHAR(500) NOT NULL,
    is_read     BOOLEAN DEFAULT FALSE,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notif_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_notif_user (user_id)
);

-- ---------------------------------------------------------
-- AUDIT_LOGS  (immutable, no updates/deletes expected)
-- ---------------------------------------------------------
CREATE TABLE audit_logs (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT,
    action      VARCHAR(100) NOT NULL,   -- e.g. LOGIN, PASSWORD_CHANGE, TRANSACTION_CREATED
    details     TEXT,
    ip_address  VARCHAR(45),
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_audit_user (user_id),
    INDEX idx_audit_created (created_at)
);

-- ---------------------------------------------------------
-- SEED DATA (minimal, for initial testing)
-- ---------------------------------------------------------
INSERT INTO roles (name) VALUES ('ROLE_ADMIN'), ('ROLE_USER');

INSERT INTO categories (name, description) VALUES
 ('Food', 'Groceries and dining'),
 ('Rent', 'Housing payments'),
 ('Travel', 'Transport and trips'),
 ('Entertainment', 'Leisure and subscriptions'),
 ('Utilities', 'Electricity, water, internet'),
 ('Shopping', 'General retail purchases');
