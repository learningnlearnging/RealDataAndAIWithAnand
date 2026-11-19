   -- 1. Create consumer role and grant necessary permissions
    USE ROLE ACCOUNTADMIN;
    CREATE OR REPLACE ROLE customer_insights_role;
    GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE customer_insights_role;
    SET my_user = CURRENT_USER();
    GRANT ROLE customer_insights_role to user IDENTIFIER($my_user);

    -- 2. Create database, schema, and warehouse
    CREATE OR REPLACE DATABASE customer_insights;
    CREATE OR REPLACE SCHEMA customer_insights.data;
    GRANT USAGE ON DATABASE customer_insights TO ROLE customer_insights_role;
    GRANT USAGE ON SCHEMA customer_insights.data TO ROLE customer_insights_role;

    CREATE DATABASE IF NOT EXISTS snowflake_intelligence;
    CREATE SCHEMA IF NOT EXISTS snowflake_intelligence.agents;
    GRANT USAGE ON DATABASE snowflake_intelligence TO ROLE customer_insights_role;
    GRANT USAGE ON SCHEMA snowflake_intelligence.agents TO ROLE customer_insights_role;
    GRANT CREATE AGENT ON SCHEMA snowflake_intelligence.agents TO ROLE customer_insights_role;

    -- Grant Cortex Search Service creation
    GRANT CREATE CORTEX SEARCH SERVICE ON SCHEMA customer_insights.data TO ROLE customer_insights_role;

    CREATE OR REPLACE WAREHOUSE customer_insights_wh
    WITH
        WAREHOUSE_SIZE = 'SMALL'
        AUTO_SUSPEND = 3600
        AUTO_RESUME = TRUE
        INITIALLY_SUSPENDED = FALSE
    COMMENT = 'Sales intelligence warehouse with 1-hour auto-suspend policy';
    GRANT USAGE, OPERATE ON WAREHOUSE customer_insights_wh TO ROLE customer_insights_role;
    GRANT SELECT ON ALL TABLES IN SCHEMA CUSTOMER_INSIGHTS.DATA TO ROLE customer_insights_role;
    GRANT SELECT ON FUTURE TABLES IN SCHEMA CUSTOMER_INSIGHTS.DATA TO ROLE customer_insights_role;

    -- Warehouse usage
    GRANT USAGE ON WAREHOUSE CUSTOMER_INSIGHTS_WH TO ROLE CUSTOMER_INSIGHTS_ROLE;

    ALTER USER IDENTIFIER($my_user) SET DEFAULT_ROLE = CUSTOMER_INSIGHTS_ROLE;

-- 3. Create tables for sales data
USE DATABASE customer_insights;
USE SCHEMA data;

CREATE TABLE customer_interactions (
    interaction_id VARCHAR,
    interaction_text TEXT,
    account_name VARCHAR,
    journey_stage VARCHAR,
    account_manager VARCHAR,
    interaction_date TIMESTAMP,
    opportunity_value FLOAT,
    solution_area VARCHAR
);
GRANT SELECT ON TABLE customer_interactions TO ROLE customer_insights_role;

CREATE TABLE customer_metrics (
    opportunity_id VARCHAR,
    account_name VARCHAR,
    opportunity_value FLOAT,
    target_close_date DATE,
    opportunity_stage VARCHAR,
    won_flag BOOLEAN,
    account_manager VARCHAR,
    solution_area VARCHAR
);
GRANT SELECT ON TABLE customer_metrics TO ROLE customer_insights_role;

INSERT INTO customer_interactions 
(interaction_id, interaction_text, account_name, journey_stage, account_manager, interaction_date, opportunity_value, solution_area)
VALUES
('INT001', 'Initial discovery call with Northstar Technologies''s IT Director and Solutions Architect. Client showed strong interest in our enterprise solution features, particularly the automated workflow capabilities. The main discussion centered around integration timeline and complexity. They currently use Legacy Platform A for their core operations and expressed concerns about potential disruption during migration. The team asked detailed questions about API compatibility and data migration tools.

Action items include providing a detailed integration timeline document, scheduling a technical deep-dive with their infrastructure team, and sharing case studies of similar Legacy Platform A migrations. The client mentioned a Q2 budget allocation for digital transformation initiatives. Overall, it was a positive engagement with clear next steps.', 'Northstar Technologies', 'Discovery', 'Priya Nair', '2025-01-15 10:30:00', 75000, 'Business Platform'),

('INT002', 'Follow-up call with BluePeak Retail'' Operations Manager and Finance Director. The primary focus was on pricing structure and ROI timeline. They compared our Starter Platform pricing with Competitor B''s small business offering. Key discussion points included monthly vs. annual billing options, user license limitations, and potential cost savings from process automation.

The client requested a detailed ROI analysis focusing on time saved in daily operations, resource allocation improvements, and projected efficiency gains. Budget constraints were clearly communicated, with a maximum budget of $30K for this year. They showed interest in starting with the basic package with room for a potential upgrade in Q4. Next steps include providing a competitive analysis and a customized ROI calculator by next week.', 'BluePeak Retail', 'Negotiation', 'Daniel Lee', '2025-01-16 14:45:00', 25000, 'Starter Platform'),

('INT003', 'Strategy session with Crestline Bank''s CISO and Security Operations team. Extremely positive 90-minute deep dive into our Secure Platform package. Customer emphasized immediate need for implementation due to recent industry compliance updates. Our advanced security features, especially multi-factor authentication and encryption protocols, were identified as perfect fits for their requirements. Technical team was particularly impressed with our zero-trust architecture approach and real-time threat monitoring capabilities. They''ve already secured budget approval and have executive buy-in. Compliance documentation is ready for review. Action items include: finalizing implementation timeline, scheduling security audit, and preparing necessary documentation for their risk assessment team. Client ready to move forward with contract discussions.', 'Crestline Bank', 'Closing', 'Aisha Khan', '2025-01-17 11:20:00', 150000, 'Secure Platform'),

('INT004', 'Comprehensive discovery call with Vertex Global''s CTO and Department Heads. Team of 500+ employees across 3 continents discussed current challenges with their existing solution. Major pain points identified: system crashes during peak usage, limited cross-department reporting capabilities, and poor scalability for remote teams. Deep dive into their current workflow revealed bottlenecks in data sharing and collaboration. Technical requirements gathered for each department. Platform demo focused on scalability features and global team management capabilities. Client particularly interested in our API ecosystem and custom reporting engine. Next steps: schedule department-specific workflow analysis and prepare detailed platform migration plan.', 'Vertex Global', 'Discovery', 'Priya Nair', '2025-01-18 09:15:00', 100000, 'Business Platform'),

('INT005', 'In-depth demo session with InsightWorks''s Analytics team and Business Intelligence managers. Showcase focused on advanced analytics capabilities, custom dashboard creation, and real-time data processing features. Team was particularly impressed with our machine learning integration and predictive analytics models. Competitor comparison requested specifically against Market Leader Q and Emerging Vendor R. Price point falls within their allocated budget range, but team expressed interest in multi-year commitment with corresponding discount structure. Technical questions centered around data warehouse integration and custom visualization capabilities. Action items: prepare detailed competitor feature comparison matrix and draft multi-year pricing proposals with various discount scenarios.', 'InsightWorks', 'Demo', 'Vikram Shah', '2025-01-19 13:30:00', 85000, 'Analytics Platform'),

('INT006', 'Extended technical deep dive with MediCore Systems'' IT Security team, Compliance Officer, and System Architects. Four-hour session focused on API infrastructure, data security protocols, and compliance requirements. Team raised specific concerns about HIPAA compliance, data encryption standards, and API rate limiting. Detailed discussion of our security architecture, including: end-to-end encryption, audit logging, and disaster recovery protocols. Client requires extensive documentation on compliance certifications, particularly SOC 2 and HITRUST. Security team performed initial architecture review and requested additional information about: database segregation, backup procedures, and incident response protocols. Follow-up session scheduled with their compliance team next week.', 'MediCore Systems', 'Technical Review', 'Aisha Khan', '2025-01-20 15:45:00', 120000, 'Secure Platform'),

('INT007', 'Contract review meeting with ContractWorks''s General Counsel, Procurement Director, and IT Manager. Detailed analysis of SLA terms, focusing on uptime guarantees and support response times. Legal team requested specific modifications to liability clauses and data handling agreements. Procurement raised questions about payment terms and service credit structure. Key discussion points included: disaster recovery commitments, data retention policies, and exit clause specifications. IT Manager confirmed technical requirements are met pending final security assessment. Agreement reached on most terms, with only SLA modifications remaining for discussion. Legal team to provide revised contract language by end of week. Overall positive session with clear path to closing.', 'ContractWorks', 'Negotiation', 'Daniel Lee', '2025-01-21 10:00:00', 95000, 'Business Platform'),

('INT008', 'Quarterly business review with HarborTrade''s current implementation team and potential expansion stakeholders. Current implementation in Finance department showcasing strong adoption rates and 40% improvement in processing times. Discussion focused on expanding solution to Operations and HR departments. Users highlighted positive experiences with customer support and platform stability. Challenges identified in current usage: need for additional custom reports and increased automation in workflow processes. Expansion requirements gathered from Operations Director: inventory management integration, supplier portal access, and enhanced tracking capabilities. HR team interested in recruitment and onboarding workflow automation. Next steps: prepare department-specific implementation plans and ROI analysis for expansion.', 'HarborTrade', 'Expansion', 'Vikram Shah', '2025-01-22 14:20:00', 45000, 'Starter Platform'),

('INT009', 'Emergency planning session with RapidRoute Logistics''s Executive team and Project Managers. Critical need for rapid implementation due to current system failure. Team willing to pay premium for expedited deployment and dedicated support team. Detailed discussion of accelerated implementation timeline and resource requirements. Key requirements: minimal disruption to operations, phased data migration, and emergency support protocols. Technical team confident in meeting aggressive timeline with additional resources. Executive sponsor emphasized importance of going live within 30 days. Immediate next steps: finalize expedited implementation plan, assign dedicated support team, and begin emergency onboarding procedures. Team to reconvene daily for progress updates.', 'RapidRoute Logistics', 'Closing', 'Priya Nair', '2025-01-23 16:30:00', 180000, 'Secure Platform'),

('INT010', 'Quarterly strategic review with SummitWorks''s Department Heads and Analytics team. Current implementation meeting basic needs but team requiring more sophisticated analytics capabilities. Deep dive into current usage patterns revealed opportunities for workflow optimization and advanced reporting needs. Users expressed strong satisfaction with platform stability and basic features, but requiring enhanced data visualization and predictive analytics capabilities. Analytics team presented specific requirements: custom dashboard creation, advanced data modeling tools, and integrated BI features. Discussion about upgrade path from current package to Analytics Platform tier. ROI analysis presented showing potential 60% improvement in reporting efficiency. Team to present upgrade proposal to executive committee next month.', 'SummitWorks', 'Expansion', 'Aisha Khan', '2025-01-24 11:45:00', 65000, 'Analytics Platform');

INSERT INTO customer_metrics
(opportunity_id, account_name, opportunity_value, target_close_date, opportunity_stage, won_flag, account_manager, solution_area)
VALUES
('OPP001', 'Northstar Technologies', 75000, '2025-02-15', 'Closed', true, 'Priya Nair', 'Business Platform'),

('OPP002', 'BluePeak Retail', 25000, '2025-02-01', 'Lost', false, 'Daniel Lee', 'Starter Platform'),

('OPP003', 'Crestline Bank', 150000, '2025-01-30', 'Closed', true, 'Aisha Khan', 'Secure Platform'),

('OPP004', 'Vertex Global', 100000, '2025-02-10', 'Pending', false, 'Priya Nair', 'Business Platform'),

('OPP005', 'InsightWorks', 85000, '2025-02-05', 'Closed', true, 'Vikram Shah', 'Analytics Platform'),

('OPP006', 'MediCore Systems', 120000, '2025-02-20', 'Pending', false, 'Aisha Khan', 'Secure Platform'),

('OPP007', 'ContractWorks', 95000, '2025-01-25', 'Closed', true, 'Daniel Lee', 'Business Platform'),

('OPP008', 'HarborTrade', 45000, '2025-02-08', 'Closed', true, 'Vikram Shah', 'Starter Platform'),

('OPP009', 'RapidRoute Logistics', 180000, '2025-02-12', 'Closed', true, 'Priya Nair', 'Secure Platform'),

('OPP010', 'SummitWorks', 65000, '2025-02-18', 'Pending', false, 'Aisha Khan', 'Analytics Platform');

ALTER TABLE customer_interactions SET CHANGE_TRACKING = TRUE;

-- 4. Create Stage
CREATE OR REPLACE STAGE models DIRECTORY = (ENABLE = TRUE);
GRANT READ ON STAGE models TO ROLE customer_insights_role;

-- 5. Enable cross region inference (required to use claude-4-sonnet)
ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'AWS_US';