#!/bin/bash

# 🚀 n8n Job Automation System - Development Setup Script
# This script runs automatically when the Dev Container is created

echo "🔧 Setting up n8n Job Automation development environment..."

# Create necessary directories
mkdir -p workflows templates docs/workflows examples

# Copy environment template if .env doesn't exist
if [ ! -f .env ]; then
    echo "📋 Creating development environment configuration..."
    cp .env.example .env
    echo "✅ Created .env file from template"
else
    echo "✅ Environment file already exists"
fi

# Install Node.js dependencies if package.json exists
if [ -f package.json ]; then
    echo "📦 Installing Node.js dependencies..."
    npm install
fi

# Set up Git hooks if directory exists
if [ -d .git ]; then
    echo "🔗 Setting up Git hooks..."
    # Pre-commit hook to validate workflows
    cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
echo "🔍 Validating workflows before commit..."
if [ -f scripts/validate-workflows.js ]; then
    node scripts/validate-workflows.js
    if [ $? -ne 0 ]; then
        echo "❌ Workflow validation failed. Fix errors before committing."
        exit 1
    fi
fi
echo "✅ Pre-commit validation passed"
EOF
    chmod +x .git/hooks/pre-commit
    echo "✅ Git hooks configured"
fi

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 10

# Check if services are running
if command -v docker-compose &> /dev/null; then
    echo "🔍 Checking service health..."
    
    # Check PostgreSQL
    if docker-compose ps postgres | grep -q "Up"; then
        echo "✅ PostgreSQL is running"
    else
        echo "⚠️  PostgreSQL may not be ready yet"
    fi
    
    # Check Redis
    if docker-compose ps redis | grep -q "Up"; then
        echo "✅ Redis is running"
    else
        echo "⚠️  Redis may not be ready yet"
    fi
    
    # Check n8n
    if docker-compose ps n8n | grep -q "Up"; then
        echo "✅ n8n is running"
    else
        echo "⚠️  n8n may not be ready yet"
    fi
fi

# Create example files if they don't exist
if [ ! -f examples/job-search-config.json ]; then
    echo "📄 Creating example configuration files..."
    cat > examples/job-search-config.json << 'EOF'
{
  "searchParams": {
    "keywords": ["Software Engineer", "Full Stack Developer", "Backend Developer"],
    "locations": ["San Francisco", "New York", "Remote", "Seattle"],
    "experienceLevels": ["mid", "senior"],
    "jobTypes": ["fulltime"],
    "salaryMin": 80000,
    "maxAgesDays": 1
  },
  "userProfile": {
    "skills": {
      "programming": ["JavaScript", "Python", "TypeScript", "Java"],
      "frameworks": ["React", "Node.js", "Express", "Django"],
      "databases": ["PostgreSQL", "MongoDB", "Redis"],
      "cloud": ["AWS", "Docker", "Kubernetes"]
    },
    "experienceYears": 5,
    "preferredRemote": true,
    "salaryExpectations": {
      "min": 90000,
      "max": 130000
    }
  }
}
EOF
    echo "✅ Created example configuration"
fi

echo ""
echo "🎉 Development environment setup complete!"
echo ""
echo "🔗 Quick Links:"
echo "   n8n Interface: http://localhost:5678"
echo "   PostgreSQL: localhost:5432"
echo "   Redis: localhost:6379"
echo ""
echo "📚 Next Steps:"
echo "   1. Open http://localhost:5678 to access n8n"
echo "   2. Configure your API credentials in n8n"
echo "   3. Import workflows from the /workflows directory"
echo "   4. Check out the documentation in /docs"
echo ""
echo "💡 Need help? Check the README.md or open an issue on GitHub"
echo ""