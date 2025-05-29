# 🤝 Contributing to n8n Job Automation System

We love your input! We want to make contributing to this project as easy and transparent as possible.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Documentation](#documentation)

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md).

## Getting Started

### Prerequisites
- Docker and Docker Compose
- Node.js 18+ (for testing)
- Git
- Basic knowledge of n8n workflows

### Development Setup

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/your-username/n8n-job-automation-system.git
   cd n8n-job-automation-system
   ```
3. Set up development environment:
   ```bash
   cp .env.example .env.dev
   docker-compose -f docker-compose.dev.yml up -d
   ```
4. Create a feature branch:
   ```bash
   git checkout -b feature/amazing-feature
   ```

## How to Contribute

### 🐛 Reporting Bugs

1. Check existing issues first
2. Use the bug report template
3. Include:
   - Clear description
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment details
   - Screenshots if applicable

### 💡 Suggesting Features

1. Check existing feature requests
2. Use the feature request template
3. Explain:
   - The problem you're solving
   - Your proposed solution
   - Alternative solutions considered
   - Additional context

### 🔧 Contributing Code

1. **Workflow Improvements**
   - Optimize existing workflows
   - Add new job site integrations
   - Improve error handling

2. **Documentation**
   - Fix typos and improve clarity
   - Add examples and tutorials
   - Translate documentation

3. **Testing**
   - Add test cases
   - Improve test coverage
   - Add integration tests

## Development Workflow

### Workflow Development

1. Create workflows in n8n interface
2. Export workflow JSON
3. Save to appropriate `/workflows` directory
4. Add documentation to `/docs/workflows/`
5. Test thoroughly

### Code Changes

1. Make changes in feature branch
2. Follow coding standards
3. Add/update tests
4. Update documentation
5. Test changes locally
6. Create pull request

### Pull Request Process

1. **Before Submitting**
   - Ensure tests pass
   - Update documentation
   - Follow commit message conventions
   - Rebase on latest main branch

2. **Pull Request Template**
   - Clear title and description
   - Link related issues
   - List changes made
   - Include testing steps
   - Add screenshots if applicable

3. **Review Process**
   - Automated checks must pass
   - At least one maintainer review
   - Address review feedback
   - Maintain clean commit history

## Coding Standards

### Workflow Standards

```json
{
  "name": "Clear_Descriptive_Name",
  "nodes": [
    {
      "name": "Descriptive Node Name",
      "type": "n8n-nodes-base.httpRequest",
      "parameters": {
        // Well-organized parameters
      },
      "notes": "Clear explanation of what this node does"
    }
  ]
}
```

### JavaScript Standards

```javascript
// Use clear variable names
const jobApplicationData = {
  title: 'Software Engineer',
  company: 'TechCorp',
  matchScore: 85
};

// Add comments for complex logic
function calculateMatchScore(jobRequirements, userSkills) {
  // Implementation with clear comments
}

// Handle errors gracefully
try {
  const result = await processJobApplication(data);
  return { success: true, data: result };
} catch (error) {
  console.error('Application processing failed:', error);
  return { success: false, error: error.message };
}
```

### Documentation Standards

- Use clear, concise language
- Include code examples
- Add screenshots for UI steps
- Keep README files up to date
- Document all configuration options

## Testing

### Workflow Testing

1. **Manual Testing**
   - Test each workflow end-to-end
   - Verify error handling
   - Check rate limiting
   - Validate output format

2. **Integration Testing**
   ```bash
   # Run integration tests
   npm run test:integration
   ```

3. **Security Testing**
   - Test credential handling
   - Verify rate limiting
   - Check for data leaks

### Test Data

- Use mock data for testing
- Don't commit real credentials
- Create test job postings
- Use test email accounts

## Documentation

### Required Documentation

- Update README for new features
- Add workflow documentation
- Include configuration examples
- Write troubleshooting guides

### Documentation Style

- Use clear headings
- Include code examples
- Add links to relevant resources
- Keep language simple and accessible

## Issue Labels

- `bug` - Something isn't working
- `enhancement` - New feature or request
- `documentation` - Improvements to docs
- `good first issue` - Good for newcomers
- `help wanted` - Extra attention needed
- `security` - Security-related issues
- `workflow` - Workflow-specific changes
- `infrastructure` - Infrastructure changes

## Recognition

Contributors are recognized in:
- README contributors section
- Release notes
- Project documentation

## Getting Help

- Check existing documentation
- Search closed issues
- Join community discussions
- Ask questions in issues

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for making this project better! 🙏**