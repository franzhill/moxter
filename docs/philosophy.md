# The philosophy behind Moxter

## The state of unit testing

Moxter was born from one realization: on any given project, unit tests are usually a mess.

In many software projects, unit testing is the neglected stepchild of the development lifecycle. While production code is scrutinized for clean architecture, design patterns, and performance, the test concern, while proudly exposed through flattering metrics and indicators, is often left to grow wild, resulting in a "Big Tangled Ball of Spaghetti" that provides a false sense of safety and a long groan of dread whenever a developer has to "add test coverage".

Because good tests are actually -and surprisingly- difficult to craft, because they are tedious to write, and because nobody really cares as long as that pipeline turns green, they tend to evolve with a life of their own without any governance and direction.

Without a clear framework or strategy, developers copy-paste setup logic, hardcode magic strings, create deeply nested helper methods, Mockito everything away ending up testing nothing more than the raw metal of the underlying frameworks. As long as "the tests pass", everybody turns a blind eye.

The result? A big folder of tests that take longer to code and maintain than actually developing the feature, and where nobody truly knows what a specific test is actually verifying or why its setup context is as it is.


## The false sense of security
 ???



## Where Moxter comes in

**Moxter** was designed disrupt this cycle, by promoting real business value testing from "further up", and helping organize, automate, and build better, understandable and meaningful tests.

**Moxter** is built on a "Black Box" testing philosophy. Rather than testing individual Java methods in isolation (standard unit tests), it encourages testing through the application's "natural" interface: the REST API (integration-style testing).

Such a testing approach is achieved by leveraging the `@SpringBootTest` mechanism, allowing `JUnit` tests to be performed against a full `Spring` Application Context without the overhead of spinning up a real HTTP server. This makes them a powerful, yet still efficient, alternative to pure isolated unit tests all within the standard `mvn test` phase.

TBy providing the means to easily define the building bricks (so-called "moxtures"), **Moxter** allows developers to painlessly design and orchestrate larger, more meaningful test scenarios, while keeping their test intent clear and devoid of boilerplate code.



## Why use Moxter?
- **The Sweet Spot**: sitting in between isolated unit tests and external API testing tools, **Moxter** allows you to test real-world scenarios during the standard mvn test phase.
- **Shorter, Cleaner, Meaningful Tests**: **Moxter** will hide all the boilerplate involved in performing MockMVC calls to your application API, letting Your JUnit tests focus purely on the cinematics of the test scenarios and still exerting standard assertions at will.
- **Readability**: "Moxtures" (MockMvc calls) are configured in YAML files thus providing clean, human-readable and reusable bricks.
- **Maintainability**: When an API endpoint changes, you update the YAML "moxture" in one place rather than hunting through dozens of Java test files.
- **Reusability**: "Moxtures" can be shared across multiple test classes 
- **Buildability**: "Moxtures" serve as the fundamental building bricks for advanced test scenarios. You can group multiple moxtures to define new, higher-level moxtures which function just like a simple moxture. Moxtures can be chained together, with the output of one 'fed' into the input of the next one.



## Where Moxter sits in the testing landscape
<br />

| Feature | JUnit + Mockito | JUnit + MockMvc | JUnit + **Moxter** | **Rest Assured** | Postman / Newman and clones |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Testing Level** | Unit (Isolated) | Web Slice/ Integration | **Web Slice / Integration** | Integration / E2E | E2E / System |
| **Test "Border"** | Internal Logic | API Border | **API Border & Internal** | API Border | API Border |
| **Main rationale** | Prove complex internal logic | Prove the API contract | **Prove the API contract** | Prove the API contract over the network | Prove the API contract in 'real-life' |
| **Requires running HTTP server** | 🟢 No | 🟢 No (Mock Servlet) | 🟢 **No (Mock Servlet)** | 🔴 Yes (🟢 No with MockMvc extension) | 🔴 Yes |
| **Close to Real-life?** | 🔴 No | 🟢 Closer  | 🟢 **Closer** | ⭐ Closest | ⭐ Closest |
| **Testing stage** | ⭐ Early (Coding) | ⭐ Early (Coding) | ⭐ **Early (Coding)** | ⭐ Early (Coding) | 🔴 Late (Post-Deployment) |
| **Execution Speed** | ⭐ Instant | 🟢 Fast | 🟢 **Fast** | 🟢 Fast to 🟡 Moderate | 🔴 Slow (Needs Server) |
| **CI/CD Integration** | ⭐ Native | ⭐ Native | ⭐ **Native** | ⭐ Native | 🟡 Needs CLI/Wrappers |
| **Real-life test scenarios?**| 🔴 No | 🟡 Manual | ⭐ **Good (chaining)** | 🟢 Good (Fluent API) | ⭐ Good (may need writing JS) |
| **Checks (assertions)** | 🟢 Powerful (code) | 🟢 Powerful (code) | ⭐ **Powerful (code) and easy (YAML)** | ⭐ Powerful (DSL/Code) | 🟡 Requires writing JS |
| **Reuse** | N/A | 🟡 through functions | 🟢 **Good (inheritance, variable overloading)** | 🟡 through functions | 🟢 Good (Collections/Scripts ... if not too complex) |
| **Where Tests Live** | Alongside Code | Alongside Code | **Alongside Code** | Alongside Code | External Tool |
| **Who can write tests?** | 🔴 Devs | 🔴 Devs | 🟡 **Devs and QA (YAML)** | 🔴 Devs | ⭐ Devs/External (QA, users...) |
| **Who can run tests?** | 🔴 Devs | 🔴 Devs | 🟡 **Devs and QA** | 🔴 Devs | ⭐ Anybody (users, POs...) |
| **Ease of Creation** | 🟡 Moderate | 🟡 Moderate (Boilerplate) | 🟢 **Easier** | 🟡 Moderate | ⭐ Easy (GUI) |
| **Cost of Maintenance** | 🟡 Moderate | 🟡 Low (only if API contract changes) | 🟢 **Lower (only if API contract changes)** | 🟡 Low (only if API contract changes) | 🟢 Lower (only if API contract changes) |
| **Documentation value** | Poor (Code only) | Poor (Code only) | 🟢 **Good (Readable)** | 🟡 Moderate (DSL) | ⭐ Very good (JSON/GUI) |


![Alt text describing the image](/docs/img/test_pyramid.png "Optional hover title")

