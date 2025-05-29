#!/bin/bash

# 🚀 n8n Job Automation System - Infrastructure Setup Script
# This script will be customized based on your specific requirements

set -e

echo "🤖 Setting up n8n Job Automation System..."

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# System Requirements Check
check_requirements() {
    print_status "Checking system requirements..."
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    # Check if Docker Compose is available
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not available. Please install Docker Compose."
        exit 1
    fi
    
    # Check available disk space (minimum 10GB)
    available_space=$(df . | tail -1 | awk '{print $4}')
    if [ "$available_space" -lt 10485760 ]; then
        print_warning "Less than 10GB disk space available. Consider freeing up space."
    fi
    
    print_status "System requirements check completed ✅"
}

# Environment Configuration
setup_environment() {
    print_status "Setting up environment configuration..."
    
    if [ ! -f .env ]; then
        print_status "Creating .env file from template..."
        cp .env.example .env
        
        print_warning "Please edit .env file with your API keys and credentials:"
        print_warning "- OPENAI_API_KEY (required for AI features)"
        print_warning "- POSTGRES_PASSWORD (set a secure password)"
        print_warning "- N8N_BASIC_AUTH_PASSWORD (set a secure password)"
        print_warning ""
        print_warning "Press Enter after editing .env file to continue..."
        read -r
    fi
    
    # Validate required environment variables
    source .env
    if [ -z "$OPENAI_API_KEY" ] || [ "$OPENAI_API_KEY" = "sk-your-openai-api-key-here" ]; then
        print_error "Please set your OpenAI API key in .env file"
        exit 1
    fi
    
    print_status "Environment configuration completed ✅"
}

# Generate Security Keys
generate_keys() {
    print_status "Generating security keys..."
    
    # Generate encryption key for n8n if not exists
    if [ ! -f .encryption_key ]; then
        openssl rand -hex 32 > .encryption_key
        print_status "Generated n8n encryption key"
    fi
    
    # Generate database password if default
    if grep -q "secure_postgres_password_here" .env; then
        new_password=$(openssl rand -base64 32)
        sed -i.bak "s/secure_postgres_password_here/$new_password/g" .env
        print_status "Generated secure database password"
    fi
    
    print_status "Security keys generation completed ✅"
}

# Create Required Directories
setup_directories() {
    print_status "Creating required directories..."
    
    directories=(
        "workflows"
        "credentials" 
        "scripts"
        "logs"
        "backups"
        "monitoring/prometheus"
        "monitoring/grafana/dashboards"
        "monitoring/grafana/datasources"
        "monitoring/alertmanager"
        "monitoring/loki"
        "monitoring/promtail"
    )
    
    for dir in "${directories[@]}"; do
        mkdir -p "$dir"
    done
    
    print_status "Directory structure created ✅"
}

# Initialize Database
init_database() {
    print_status "Preparing database initialization..."
    
    cat > scripts/init-db.sql << 'EOF'
-- n8n Job Automation System Database Initialization

-- Create additional databases for analytics
CREATE DATABASE IF NOT EXISTS n8n_analytics;
CREATE DATABASE IF NOT EXISTS n8n_testing;

-- Create job automation specific tables
\c n8n;

-- Jobs table for discovered opportunities
CREATE TABLE IF NOT EXISTS jobs (
    id SERIAL PRIMARY KEY,
    external_id VARCHAR(255) UNIQUE NOT NULL,
    title VARCHAR(500) NOT NULL,
    company VARCHAR(255) NOT NULL,
    location VARCHAR(255),
    job_url TEXT NOT NULL,
    description TEXT,
    requirements TEXT[],
    benefits TEXT[],
    salary_min INTEGER,
    salary_max INTEGER,
    salary_currency VARCHAR(10) DEFAULT 'USD',
    job_type VARCHAR(50),
    remote_policy VARCHAR(50),
    posted_date DATE,
    discovered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source VARCHAR(50) NOT NULL,
    easy_apply BOOLEAN DEFAULT FALSE,
    applicant_count INTEGER,
    company_logo TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Applications table for tracking submissions
CREATE TABLE IF NOT EXISTS applications (
    id SERIAL PRIMARY KEY,
    job_id INTEGER REFERENCES jobs(id),
    application_method VARCHAR(50) NOT NULL,
    status VARCHAR(50) DEFAULT 'submitted',
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    response_received_at TIMESTAMP,
    response_type VARCHAR(50),
    confirmation_number VARCHAR(255),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Job analysis table for AI-powered insights
CREATE TABLE IF NOT EXISTS job_analysis (
    id SERIAL PRIMARY KEY,
    job_id INTEGER REFERENCES jobs(id),
    required_skills TEXT[],
    preferred_skills TEXT[],
    experience_level VARCHAR(50),
    industry VARCHAR(100),
    company_culture_indicators TEXT[],
    match_score INTEGER,
    ai_analysis_data JSONB,
    analyzed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_jobs_source ON jobs(source);
CREATE INDEX IF NOT EXISTS idx_jobs_posted_date ON jobs(posted_date);
CREATE INDEX IF NOT EXISTS idx_jobs_company ON jobs(company);
CREATE INDEX IF NOT EXISTS idx_applications_job_id ON applications(job_id);
CREATE INDEX IF NOT EXISTS idx_applications_status ON applications(status);
CREATE INDEX IF NOT EXISTS idx_job_analysis_job_id ON job_analysis(job_id);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to tables
CREATE TRIGGER update_jobs_updated_at BEFORE UPDATE ON jobs FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_applications_updated_at BEFORE UPDATE ON applications FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMIT;
EOF
    
    print_status "Database initialization script created ✅"
}

# Setup Monitoring Configuration
setup_monitoring() {
    print_status "Setting up monitoring configuration..."
    
    # Prometheus configuration
    cat > monitoring/prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "rules/*.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'n8n'
    static_configs:
      - targets: ['n8n:5678']
    metrics_path: '/metrics'

  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres-exporter:9187']

  - job_name: 'redis'
    static_configs:
      - targets: ['redis-exporter:9121']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']
EOF

    # Grafana datasource configuration
    cat > monitoring/grafana/datasources/prometheus.yml << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
EOF

    print_status "Monitoring configuration created ✅"
}

# Start Services
start_services() {
    print_status "Starting core services..."
    
    # Pull latest images
    docker-compose pull
    
    # Start core services
    docker-compose up -d
    
    # Wait for services to be ready
    print_status "Waiting for services to start..."
    sleep 30
    
    # Check service health
    if docker-compose ps | grep -q "Exit"; then
        print_error "Some services failed to start. Check logs with: docker-compose logs"
        exit 1
    fi
    
    print_status "Core services started successfully ✅"
    
    # Optional monitoring stack
    read -p "Do you want to start the monitoring stack? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Starting monitoring stack..."
        docker-compose -f docker-compose.monitoring.yml up -d
        sleep 15
        print_status "Monitoring stack started ✅"
    fi
}

# Display Access Information
show_access_info() {
    print_status "🎉 Setup completed successfully!"
    print_status ""
    print_status "Access your services at:"
    print_status "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_status "🤖 n8n Interface:      http://localhost:5678"
    print_status "🗄️  Database Admin:     http://localhost:8080"
    print_status "🔴 Redis Commander:    http://localhost:8081"
    
    if docker-compose -f docker-compose.monitoring.yml ps | grep -q "Up"; then
        print_status "📊 Grafana Dashboard:  http://localhost:3000"
        print_status "📈 Prometheus:         http://localhost:9090"
        print_status "🔔 Alertmanager:       http://localhost:9093"
    fi
    
    print_status "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_status ""
    print_status "Default Credentials:"
    print_status "n8n: admin / (check your .env file)"
    print_status "pgAdmin: admin@n8n-automation.local / admin123"
    print_status "Redis Commander: admin / admin123"
    print_status "Grafana: admin / admin123"
    print_status ""
    print_status "🔐 Remember to change default passwords in production!"
    print_status ""
    print_status "Next steps:"
    print_status "1. Open n8n and create your first workflow"
    print_status "2. Configure your OpenAI integration"
    print_status "3. Set up job discovery workflows"
    print_status ""
    print_status "📚 Check the documentation for detailed setup guides!"
}

# Main execution
main() {
    echo "🚀 n8n Job Automation System Setup"
    echo "====================================="
    echo ""
    
    check_requirements
    setup_environment
    generate_keys
    setup_directories
    init_database
    setup_monitoring
    start_services
    show_access_info
}

# Run main function
main "$@"
