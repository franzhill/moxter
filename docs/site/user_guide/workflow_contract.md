# The problem of the missing workflow contract



It is a "Contract Gap" that exists in almost every modern enterprise.

We have spent a decade perfecting the Endpoint Contract (OpenAPI, Swagger, RAML), but we have almost entirely ignored the Workflow Contract.

## The Problem: The "Implicit" Sequence
Right now, the "exact sequence" required to achieve a business result (e.g., Register User -> Verify Email -> Create Workspace -> Invite Member) usually only exists in two places:

- The Developer's Head: (Tribal knowledge).
- Imperative Test Code: (Hidden inside 500 lines of JUnit or a Postman Collection).

Neither of these is a materialized contract. If the business logic changes—say, you now need to "Accept Terms" before "Creating a Workspace"—no schema validation will catch that the sequence is broken until a test fails or, worse, a user hits a bug.


## How Moxter can "Materialize" the Sequence Contract
Since Moxter is already declarative, it is uniquely positioned to bridge this gap. You aren't just writing tests; you are writing the Manifest of the Business Process.

To turn a sequence into a "contract," we need to move from "Call A, then Call B" to a State-Aware Workflow. Here is how that looks conceptually:

1. The Scenario Manifest
Instead of just "Moxtures" (the bricks), we introduce a Scenario YAML (the blueprint). This file defines the contract of the sequence itself.

```YAML
scenario:
  name: "New Member Onboarding"
  participants: [Identity-Service, Workspace-Service]
  
  workflow:
    - step: "User Registration"
      uses: "moxtures/auth/register.yml"
      out: [userId, emailToken] # Materializing the output contract
      
    - step: "Verify Email"
      uses: "moxtures/auth/verify.yml"
      in: [emailToken] # Materializing the input requirement
      
    - step: "Setup Workspace"
      uses: "moxtures/workspaces/create.yml"
      in: [userId]
```


2. Input/Output "Handshake"
In a single API contract, you validate the JSON. In a Sequence Contract, you validate the Handshake.

The Contract Rule: Step 2 cannot execute unless Step 1 provides a valid emailToken.

Moxter's Role: Moxter becomes the "Contract Enforcer," ensuring that data flows between endpoints exactly as the business logic dictates.

3. Sequence Visualization (The "Auto-Doc")
If the sequence is materialized in YAML, the documentation can visualize it. Imagine your moxter.dev site automatically generating a Sequence Diagram for every test scenario.

This turns the test into a "Living Specification" that product owners and architects can actually read.



Why this is the "Moxter" Edge
Postman tries to do this with "Collections," but those are often just a list of saved requests with hidden JavaScript snippets. By materializing the sequence in a structured YAML format:

It is Versionable: The sequence contract lives in Git alongside the code.

It is Auditable: Security teams can see the exact flow of data through the system.

It is Predictive: You can run "Dry Runs" to see if a sequence is even possible based on the underlying OpenAPI specs.

💡 Proactive Thought: "Choreography Validation"
In 2026, with microservices, the sequence is often asynchronous (Event A triggers Event B). If Moxter can materialize these sequences, it moves from being a "Testing Tool" to a "Distributed Systems Orchestrator."