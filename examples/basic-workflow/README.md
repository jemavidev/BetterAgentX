# 🎯 Example: Basic Workflow with AgentX

This example demonstrates how **AgentX** orchestrates a complete workflow to build a feature from start to finish.

## 📋 Scenario

You need to build a simple REST API endpoint for user registration.

## 🎯 The AgentX Way

With AgentX, you don't need to know which agent to use. Just describe what you need!

### Initial Request (No Agent Prefix!)

```
Necesito crear un endpoint de registro de usuarios para mi API REST.

Requisitos:
- Aceptar email y contraseña
- Validar formato de email
- Hashear contraseña antes de guardar
- Retornar ID de usuario en éxito
- Manejar errores apropiadamente
```

### What Happens Next

AgentX will:
1. **Analyze** the request (4-D Methodology)
2. **Determine** this needs multiple agents
3. **Plan** a multi-agent workflow
4. **Execute** phase by phase
5. **Document** everything in memory

---

## 🔄 AgentX Orchestrated Workflow

### Phase 1: Requirements Definition

**AgentX Routes to:** Product Manager

```markdown
---
🧠 AgentX
🔀 Routing to: Product-Manager
---

## 📋 Analysis
Request Type: Feature Requirements
Complexity: Medium
Domain: Product Management

## 🎯 Routing Decision
Target Agent: Product-Manager
Reason: Need to formalize requirements into user stories

## 📝 Refined Prompt for Product-Manager
[Detailed prompt with context]
```

**Product Manager Output:**
- User story with acceptance criteria
- Definition of done
- Success metrics

**AgentX Memory Update:**
```markdown
💾 Memory Update: active-context.json
Added: New feature - User Registration API
```

---

### Phase 2: Architecture Design

**AgentX Routes to:** Architect

```markdown
---
🧠 AgentX
🔀 Routing to: Architect
---

## 📋 Analysis
Request Type: System Design
Complexity: Medium
Domain: Architecture

## 🎯 Routing Decision
Target Agent: Architect
Reason: Need technical architecture for the endpoint

## 📝 Refined Prompt for Architect
Based on the requirements from Product Manager, design the registration endpoint architecture.

Consider:
- API structure (REST)
- Data validation
- Security (password hashing)
- Error handling
- Database schema
```

**Architect Output:**
- API endpoint design
- Request/response format
- Database schema
- Security considerations
- Technology recommendations

**AgentX Memory Update:**
```markdown
💾 Memory Update: decision-log.json
Decision #001: Use bcrypt for password hashing
Decision #002: PostgreSQL for user storage
```

---

### Phase 3: Critical Review

**AgentX Routes to:** Critic

```markdown
---
🧠 AgentX
🔀 Routing to: Critic
---

## 📋 Analysis
Request Type: Design Review
Complexity: Medium
Domain: Critical Analysis

## 🎯 Routing Decision
Target Agent: Critic
Reason: Apply Tenth Man Rule to identify risks

## 📝 Refined Prompt for Critic
Review the architecture design above. Apply the Tenth Man Rule.

Focus on:
- What could go wrong?
- What are we missing?
- Edge cases to consider
- Alternative approaches
- Risk assessment
```

**Critic Output:**
- Potential issues identified
- Edge cases to consider
- Alternative approaches
- Risk assessment
- Recommendations

**AgentX Memory Update:**
```markdown
💾 Memory Update: patterns.json
Pattern: Always validate email uniqueness before hashing password
```

---

### Phase 4: Security Analysis

**AgentX Routes to:** Security

```markdown
---
🧠 AgentX
🔀 Routing to: Security
---

## 📋 Analysis
Request Type: Security Review
Complexity: High
Domain: Security

## 🎯 Routing Decision
Target Agent: Security
Reason: Critical security analysis needed for authentication

## 📝 Refined Prompt for Security
Analyze the registration endpoint design for security vulnerabilities.

Focus on:
- Password handling (bcrypt usage)
- Input validation
- SQL injection prevention
- Rate limiting needs
- OWASP Top 10 compliance
```

**Security Output:**
- Security vulnerabilities identified
- Mitigation strategies
- Best practices recommendations
- Compliance considerations

**AgentX Memory Update:**
```markdown
💾 Memory Update: decision-log.json
Decision #003: Implement rate limiting (5 attempts/minute)
Decision #004: Use parameterized queries to prevent SQL injection
```

---

### Phase 5: Implementation

**AgentX Routes to:** Coder

```markdown
---
🧠 AgentX
🔀 Routing to: Coder
---

## 📋 Analysis
Request Type: Implementation
Complexity: Medium
Domain: Coding

## 🎯 Routing Decision
Target Agent: Coder
Reason: Ready to implement with approved design and security review

## 📝 Refined Prompt for Coder
Implement the user registration endpoint in Node.js with Express.

Use the approved design and security recommendations:
- Input validation (email format, password length)
- Password hashing with bcrypt (10 salt rounds)
- Error handling with proper HTTP status codes
- Rate limiting middleware
- Parameterized queries

Include:
- Clean, readable code
- Proper error handling
- Security best practices
- Comments for complex logic
```

**Coder Output:**
- Complete implementation code
- Proper error handling
- Security best practices applied
- Clean, readable code

**AgentX Memory Update:**
```markdown
💾 Memory Update: progress.json
✅ Task Completed: User Registration Endpoint Implementation
Agent: Coder
Files: routes/auth.js, middleware/rateLimit.js, utils/validation.js
```

---

### Phase 6: Testing

**AgentX Routes to:** Tester

```markdown
---
🧠 AgentX
🔀 Routing to: Tester
---

## 📋 Analysis
Request Type: Test Strategy
Complexity: Medium
Domain: Testing

## 🎯 Routing Decision
Target Agent: Tester
Reason: Need comprehensive test coverage

## 📝 Refined Prompt for Tester
Create comprehensive tests for the registration endpoint.

Include:
- Unit tests for validation functions
- Integration tests for the endpoint
- Edge cases (invalid email, short password, duplicate user)
- Error scenarios (DB errors, validation failures)
- Security tests (SQL injection attempts, rate limiting)

Use Jest and Supertest.
```

**Tester Output:**
- Test cases
- Test implementation
- Coverage report
- Edge cases identified

**AgentX Memory Update:**
```markdown
💾 Memory Update: progress.json
✅ Task Completed: Test Suite for Registration Endpoint
Agent: Tester
Coverage: 95%
Files: tests/auth.test.js
```

---

### Phase 7: Documentation

**AgentX Routes to:** Writer

```markdown
---
🧠 AgentX
🔀 Routing to: Writer
---

## 📋 Analysis
Request Type: API Documentation
Complexity: Low
Domain: Technical Writing

## 🎯 Routing Decision
Target Agent: Writer
Reason: Need clear API documentation

## 📝 Refined Prompt for Writer
Create API documentation for the registration endpoint.

Include:
- Endpoint description
- Request format with examples
- Response format (success and errors)
- Error codes and meanings
- Security notes
- Code examples in JavaScript
```

**Writer Output:**
- Complete API documentation
- Code examples
- Error handling guide
- Security notes

**AgentX Memory Update:**
```markdown
💾 Memory Update: progress.json
✅ Task Completed: API Documentation
Agent: Writer
Files: docs/api/auth.md
```

---

## 📊 Complete Example with Memory

### Final Implementation

```javascript
// routes/auth.js
const express = require('express');
const bcrypt = require('bcrypt');
const { body, validationResult } = require('express-validator');
const rateLimit = require('express-rate-limit');
const router = express.Router();

// Rate limiting middleware (AgentX documented this decision)
const registerLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 5, // 5 requests per minute
  message: 'Too many registration attempts, please try again later'
});

/**
 * POST /api/auth/register
 * Register a new user
 * 
 * Security: bcrypt hashing, input validation, rate limiting
 * Documented in: .claude/memory/decision-log.json
 */
router.post('/register',
  registerLimiter,
  
  // Validation middleware
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 8 }),
  
  async (req, res) => {
    try {
      // Validate input
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ 
          error: 'Validation failed',
          details: errors.array() 
        });
      }

      const { email, password } = req.body;

      // Check if user exists (parameterized query for SQL injection prevention)
      const existingUser = await User.findOne({ email });
      if (existingUser) {
        return res.status(409).json({ 
          error: 'User already exists' 
        });
      }

      // Hash password (10 salt rounds as per security review)
      const saltRounds = 10;
      const hashedPassword = await bcrypt.hash(password, saltRounds);

      // Create user
      const user = await User.create({
        email,
        password: hashedPassword
      });

      // Return success (don't expose password hash)
      res.status(201).json({
        id: user.id,
        email: user.email,
        createdAt: user.createdAt
      });

    } catch (error) {
      console.error('Registration error:', error);
      res.status(500).json({ 
        error: 'Internal server error' 
      });
    }
  }
);

module.exports = router;
```

### Tests (by Tester)

```javascript
// tests/auth.test.js
const request = require('supertest');
const app = require('../app');

describe('POST /api/auth/register', () => {
  test('should register new user with valid data', async () => {
    const response = await request(app)
      .post('/api/auth/register')
      .send({
        email: 'test@example.com',
        password: 'SecurePass123!'
      });

    expect(response.status).toBe(201);
    expect(response.body).toHaveProperty('id');
    expect(response.body.email).toBe('test@example.com');
    expect(response.body).not.toHaveProperty('password');
  });

  test('should reject invalid email', async () => {
    const response = await request(app)
      .post('/api/auth/register')
      .send({
        email: 'invalid-email',
        password: 'SecurePass123!'
      });

    expect(response.status).toBe(400);
    expect(response.body.error).toBe('Validation failed');
  });

  test('should reject short password', async () => {
    const response = await request(app)
      .post('/api/auth/register')
      .send({
        email: 'test@example.com',
        password: 'short'
      });

    expect(response.status).toBe(400);
  });

  test('should reject duplicate email', async () => {
    // First registration
    await request(app)
      .post('/api/auth/register')
      .send({
        email: 'test@example.com',
        password: 'SecurePass123!'
      });

    // Duplicate registration
    const response = await request(app)
      .post('/api/auth/register')
      .send({
        email: 'test@example.com',
        password: 'SecurePass123!'
      });

    expect(response.status).toBe(409);
    expect(response.body.error).toBe('User already exists');
  });

  test('should enforce rate limiting', async () => {
    // Make 6 requests (limit is 5)
    for (let i = 0; i < 6; i++) {
      const response = await request(app)
        .post('/api/auth/register')
        .send({
          email: `test${i}@example.com`,
          password: 'SecurePass123!'
        });

      if (i < 5) {
        expect(response.status).not.toBe(429);
      } else {
        expect(response.status).toBe(429);
      }
    }
  });
});
```

### API Documentation (by Writer)

```markdown
## POST /api/auth/register

Register a new user account.

### Request

**Endpoint:** `POST /api/auth/register`

**Headers:**
```http
Content-Type: application/json
```

**Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!"
}
```

**Parameters:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| email | string | Yes | Valid email address |
| password | string | Yes | Minimum 8 characters |

### Response

**Success (201 Created):**
```json
{
  "id": "user_123",
  "email": "user@example.com",
  "createdAt": "2026-02-12T10:00:00Z"
}
```

**Error (400 Bad Request):**
```json
{
  "error": "Validation failed",
  "details": [
    {
      "field": "email",
      "message": "Invalid email format"
    }
  ]
}
```

**Error (409 Conflict):**
```json
{
  "error": "User already exists"
}
```

**Error (429 Too Many Requests):**
```json
{
  "error": "Too many registration attempts, please try again later"
}
```

**Error (500 Internal Server Error):**
```json
{
  "error": "Internal server error"
}
```

### Security Notes

- Passwords are hashed using bcrypt with 10 salt rounds
- Email addresses are normalized before storage
- Rate limiting: 5 requests per minute per IP
- Parameterized queries prevent SQL injection
- HTTPS should be used in production
- Password is never returned in responses

### Example Usage

```javascript
const response = await fetch('/api/auth/register', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    email: 'user@example.com',
    password: 'SecurePassword123!'
  })
});

const data = await response.json();
console.log(data.id); // user_123
```
```

### Memory Files Generated

**`.claude/memory/active-context.json`** — Updated automatically by `on-file-change.sh`

**`.claude/memory/decision-log.json`** — Updated via `add-decision.sh`:
```bash
bash .claude/scripts/add-decision.sh DEC-01 "Use bcrypt for password hashing" \
  "Robust security, resistant to brute-force attacks" architect implemented "security,auth"
bash .claude/scripts/add-decision.sh DEC-02 "PostgreSQL for user storage" \
  "ACID compliance, relational data, JSON support" architect implemented "database"
bash .claude/scripts/add-decision.sh DEC-03 "Rate limiting (5/min)" \
  "Prevent brute-force registration attacks" security implemented "security"
```

**`.claude/memory/progress.json`** — Updated via `add-task.sh`:
```bash
bash .claude/scripts/add-task.sh TASK-01 "Implement registration endpoint" \
  completed coder "routes/auth.js, middleware/rateLimit.js created" high "auth,api" 30
bash .claude/scripts/add-task.sh TASK-02 "Test suite for registration" \
  completed tester "95% coverage, tests/auth.test.js created" high "testing" 20
bash .claude/scripts/add-task.sh TASK-03 "API documentation" \
  completed writer "docs/api/auth.md created" medium "docs" 15
```

**`.claude/memory/patterns.json`** — Updated via `add-pattern.sh`:
```bash
bash .claude/scripts/add-pattern.sh "validate-before-hash" security \
  "Check email uniqueness before bcrypt to save CPU on duplicates" coder \
  "Query user by email first; only hash password if email is unique" "auth,performance"
```

---

### Final Implementation

```javascript
// routes/auth.js
const express = require('express');
const bcrypt = require('bcrypt');
const { body, validationResult } = require('express-validator');
const router = express.Router();

/**
 * POST /api/auth/register
 * Register a new user
 */
router.post('/register',
  // Validation middleware
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 8 }),
  
  async (req, res) => {
    try {
      // Validate input
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ 
          error: 'Validation failed',
          details: errors.array() 
        });
      }

      const { email, password } = req.body;

      // Check if user exists
      const existingUser = await User.findOne({ email });
      if (existingUser) {
        return res.status(409).json({ 
          error: 'User already exists' 
        });
      }

      // Hash password
      const saltRounds = 10;
      const hashedPassword = await bcrypt.hash(password, saltRounds);

      // Create user
      const user = await User.create({
        email,
        password: hashedPassword
      });

      // Return success
      res.status(201).json({
        id: user.id,
        email: user.email,
        createdAt: user.createdAt
      });

    } catch (error) {
      console.error('Registration error:', error);
      res.status(500).json({ 
        error: 'Internal server error' 
      });
    }
  }
);

module.exports = router;
```

### Tests

```javascript
// tests/auth.test.js
const request = require('supertest');
const app = require('../app');

describe('POST /api/auth/register', () => {
  test('should register new user with valid data', async () => {
    const response = await request(app)
      .post('/api/auth/register')
      .send({
        email: 'test@example.com',
        password: 'SecurePass123!'
      });

    expect(response.status).toBe(201);
    expect(response.body).toHaveProperty('id');
    expect(response.body.email).toBe('test@example.com');
  });

  test('should reject invalid email', async () => {
    const response = await request(app)
      .post('/api/auth/register')
      .send({
        email: 'invalid-email',
        password: 'SecurePass123!'
      });

    expect(response.status).toBe(400);
    expect(response.body.error).toBe('Validation failed');
  });

  test('should reject short password', async () => {
    const response = await request(app)
      .post('/api/auth/register')
      .send({
        email: 'test@example.com',
        password: 'short'
      });

    expect(response.status).toBe(400);
  });

  test('should reject duplicate email', async () => {
    // First registration
    await request(app)
      .post('/api/auth/register')
      .send({
        email: 'test@example.com',
        password: 'SecurePass123!'
      });

    // Duplicate registration
    const response = await request(app)
      .post('/api/auth/register')
      .send({
        email: 'test@example.com',
        password: 'SecurePass123!'
      });

    expect(response.status).toBe(409);
    expect(response.body.error).toBe('User already exists');
  });
});
```

### API Documentation

```markdown
## POST /api/auth/register

Register a new user account.

### Request

**Endpoint:** `POST /api/auth/register`

**Headers:**
```http
Content-Type: application/json
```

**Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!"
}
```

**Parameters:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| email | string | Yes | Valid email address |
| password | string | Yes | Minimum 8 characters |

### Response

**Success (201 Created):**
```json
{
  "id": "user_123",
  "email": "user@example.com",
  "createdAt": "2026-02-12T10:00:00Z"
}
```

**Error (400 Bad Request):**
```json
{
  "error": "Validation failed",
  "details": [
    {
      "field": "email",
      "message": "Invalid email format"
    }
  ]
}
```

**Error (409 Conflict):**
```json
{
  "error": "User already exists"
}
```

**Error (500 Internal Server Error):**
```json
{
  "error": "Internal server error"
}
```

### Security Notes

- Passwords are hashed using bcrypt with 10 salt rounds
- Email addresses are normalized before storage
- Rate limiting should be implemented (not shown in example)
- HTTPS should be used in production

### Example Usage

```javascript
const response = await fetch('/api/auth/register', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    email: 'user@example.com',
    password: 'SecurePassword123!'
  })
});

const data = await response.json();
console.log(data.id); // user_123
```
```

---

## 🎯 Key Takeaways

1. **Let AgentX Orchestrate** - No need to know which agent to use
2. **Natural Language** - Just describe what you need
3. **Automatic Routing** - AgentX determines the best workflow
4. **Memory Documentation** - Everything important is documented automatically
5. **Multi-Agent Collaboration** - Complex tasks handled seamlessly
6. **Quality Assurance** - Security, testing, and review built-in
7. **Complete Documentation** - API docs generated automatically

## 💡 Tips for Working with AgentX

1. **Be Specific** - More context = better routing
2. **Trust the Process** - AgentX knows which agents to use
3. **Review Memory** - Check `.claude/memory/` for documented decisions
4. **Use Dashboard** - Visual interface for memory management
5. **Let It Flow** - Don't interrupt the workflow
6. **Provide Feedback** - Help AgentX improve routing decisions

## 🔄 Workflow Comparison

### Without AgentX (Manual)
```
You: /product-manager [requirements]
You: /architect [design request]
You: /critic [review request]
You: /security [security review]
You: /coder [implementation]
You: /tester [test request]
You: /writer [documentation]
```
**7 manual steps, you decide routing**

### With AgentX (Automatic)
```
You: [Describe what you need]
AgentX: [Analyzes, plans, routes, orchestrates, documents]
```
**1 step, AgentX handles everything**

## 📊 View the Results

### Check Memory Dashboard

```bash
# Open dashboard (Node.js)
bash .claude/scripts/start-dashboard.sh
# Opens at http://localhost:3000
```

### View Memory Files

```bash
# See all decisions
cat .claude/memory/decision-log.json

# See progress
cat .claude/memory/progress.json

# See patterns learned
cat .claude/memory/patterns.json

# See current context
cat .claude/memory/active-context.json
```

## 🔄 Next Steps

Try modifying this workflow with AgentX:
- Add login endpoint
- Implement password reset
- Add email verification
- Include OAuth integration
- Add two-factor authentication

Just describe what you want, and let AgentX orchestrate!

## 📚 Related Examples

- [Agent Directory](../../docs/agents/README.md) - All 12 agents and their capabilities
- [Memory System](../../docs/memory/README.md) - Working with the memory system
- [Workflows Guide](../../docs/guides/workflows.md) - Multi-agent collaboration patterns

## 🎓 Learn More

- [AgentX Documentation](../../docs/agentx/README.md)
- [Memory System Guide](../../docs/memory/README.md)
- [Agent Directory](../../docs/agents/README.md)
- [Getting Started](../../docs/guides/getting-started.md)

---

**Ready to let AgentX orchestrate your next feature? Just ask! 🚀**
