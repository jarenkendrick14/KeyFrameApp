-- 10. FEEDBACK
CREATE TABLE feedback (
    feedback_id     INT IDENTITY(1,1) PRIMARY KEY,
    user_id         INT             NOT NULL,
    message         TEXT            NOT NULL,
    status          VARCHAR(20)     DEFAULT 'PENDING',
    created_at      DATETIME        DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 11. ISSUE REPORTS
CREATE TABLE issue_reports (
    report_id       INT IDENTITY(1,1) PRIMARY KEY,
    user_id         INT             NOT NULL,
    issue_type      VARCHAR(30)     NOT NULL,
    details         TEXT            NOT NULL,
    screenshot_url  VARCHAR(255)    DEFAULT NULL,
    status          VARCHAR(20)     DEFAULT 'OPEN',
    created_at      DATETIME        DEFAULT GETDATE(),
    updated_at      DATETIME        DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);