-- Initialize Nacos namespaces for different environments
-- Run this after nacos schema is created

USE nacos;

-- Dev namespace
INSERT IGNORE INTO tenant_info (id, kp, tenant_id, tenant_name, tenant_desc, create_source, gmt_create, gmt_modified)
VALUES (1, '1', 'dev', 'dev', 'Development environment', 'init-script', NOW(), NOW());

-- Staging namespace
INSERT IGNORE INTO tenant_info (id, kp, tenant_id, tenant_name, tenant_desc, create_source, gmt_create, gmt_modified)
VALUES (2, '1', 'staging', 'staging', 'Staging environment', 'init-script', NOW(), NOW());

-- Prod namespace
INSERT IGNORE INTO tenant_info (id, kp, tenant_id, tenant_name, tenant_desc, create_source, gmt_create, gmt_modified)
VALUES (3, '1', 'prod', 'prod', 'Production environment', 'init-script', NOW(), NOW());
