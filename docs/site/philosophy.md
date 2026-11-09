<div class="moxter-title-with-image" markdown="1">
# The philosophy behind Moxter

![Moxter dressed as a Greek philosopher, deep in thought](img/moxter_thinking.png)
</div>

## The usual state of project tests

***Moxter*** was born out of one observation: while production code gets regular care, test suites can become difficult to understand and maintain.

In many a software project, testing is the ugly little duckling in the project family. While production code gets all the attention and scrutiny for architecture, design and performance, test suites are often left to grow without so much supervision. 
As a result, they usually become prone to a number of familiar bad habits:

- rushing to get tests to pass, as they usually are the last hurdle to clear before delivery,
- heavy copy-pasting all around,
- scattered and repeated hard-coded values,
- layers of unfettered helpers or abstractions,
- cramming in tests with no clear intent or business-case value, just to clear code coverage thresholds.

Add to this that good, meaningful tests can be surprisingly difficult to craft.

All this makes tests increasingly harder to maintain over time, a chore to work with, and reduces confidence in what they actually verify.

## A note on terminology before moving on

The exact definitions and boundaries of these notions are subject to constant heated debates. For this document, though, we’ll use them as follows:

- **Unit test**: Tests a piece of behavior in isolation, with possible mocks.
- **Integration test**: Tests how application components work together, in the Spring application context, run with JUnit  during Maven’s test phase.
- **End-to-end (E2E) test**: Tests a complete flow against a running, deployed application through its external interface.


## The bias towards unit vs other forms of automated testing

Over the years, multiple incentives pushed the industry in the direction of favouring unit testing over all other types of automated tests. That bias has proved hard to break.

Unit tests are cheap to run and expensive to question. A mocked unit test runs in milliseconds, needs no database or test environment, and is deterministic. By contrast, integration tests are slow, require more complicated setup and may hit environment issues. Back in the day they were notorioulsy difficult to setup.

Many testing practices that still hold today were shaped by these conditions back then, when spinning up a database was painful, frameworks lacked features, Docker did not exist, CI resources were expensive, and integration environments fragile. Under those conditions, mocked unit tests thrived. Test Driven Development became an ideology (write unit tests for every single function), code coverage became a sacred cow on which managers and QA fixated, incentivizing developers to add ever more costless and painless empty unit tests.

Today, frameworks offer powerful features for testing their whole stack, Docker and Devops have made provisioning environments and resources easier, and CI is cheaper. Integration tests still do take more time and setup, but the technical barriers have never been lower.

Yet old habits die hard. The industry has become very good at measuring what is easy to measure—coverage, test count, and execution speed—rather. Those metrics are convenient, reassuring, and pleasing to management.

Integration tests can also expose architectural problems or problems with the tooling. If an integration test is difficult to write, it may point to hidden dependencies, global state, tight coupling, bad configuration, or poor deployment and test infrastructure. That is not proof of bad architecture, but it is a signal worth investigating. Instead of addressing the underlying problem, teams may mock more aggressively. Mocking can become a mechanism for avoiding reality.

So what does integration testing bring over unit testing? This is not to say that unit testing is inherently bad. But for glorified CRUD web apps (which most Spring projects are, let’s face it), favouring unit testing over integration testing hardly makes sense when the technical barriers are no longer prohibitive. Integration tests can:

- Exercise application wiring and framework behavior, including transactions that isolated tests may bypass.
- Verify complete workflows across components and persistence, rather than testing each method in isolation.
- Reduce reliance on mocks that can make tests pass while hiding failures in the real application.
- Focus on observable business behavior, allowing internal implementation details to change without rewriting tests tied to them.


## Where Moxter comes in

***Moxter*** was designed to counter this bias by promoting higher-level, business-focused testing of the application's API, while still staying within the simplicity of the application’s own test workflow (think *JUnit* and maven test phase).

This is actually made possible by building on the power of existing tools within the *Spring* ecosystem: `@SpringBootTest` provides the full Spring application context at test time, `MockMvc` queries the application's REST interface without the need of a live HTTP server, and `H2` as an in-memory database.

Alongside your other Junit unit tests geared towards testing smaller chunks of business logic computations, ***Moxter*** tests will help test your application like a black-box, and build real use-case scenarios in a way that is easy to organize and understand.


## Why use Moxter?

- **The Sweet Spot**: sitting in between isolated unit tests and external API testing tools (or yet even E2E tests), ***Moxter*** allows you to test real-world scenarios during the standard mvn test phase.
- **Shorter, Cleaner, Meaningful Tests**: ***Moxter*** reduces repetitive `MockMvc` request boilerplate setup, letting JUnit tests focus more on scenario intent while retaining standard assertions.
- **Readability**: "Moxtures" (MockMvc calls) are configured in YAML files thus providing clean, human-readable and reusable bricks.
- **Maintainability**: When an API endpoint changes, you update the YAML "moxture" in one place rather than hunting through dozens of Java test files.
- **Reusability**: "Moxtures" can be shared across multiple test classes .
- **Buildability**: "Moxtures" serve as the fundamental building bricks for advanced test scenarios. You can group multiple moxtures to define new, higher-level moxtures which function just like a simple moxture. Moxtures can be chained together, with the output of one 'fed' into the input of the next one.


## Further resources on the subject of testing

* [TDD is Dead. Long live testing.](https://dhh.dk/2014/tdd-is-dead-long-live-testing.html) (DHH): A critique of how mock-heavy testing leads to "Test-Induced Design Damage," creating complex architectures just to satisfy isolation.
* [TDD, Where Did It All Go Wrong?](https://www.youtube.com/watch?v=EZ05e7EMOLM) (Ian Cooper): A seminal talk arguing that a "unit" should be a cohesive business behavior, not a single class.
* [Unit Test](https://martinfowler.com/bliki/UnitTest.html) (Martin Fowler): A breakdown of the "Sociable vs. Solitary" distinction, explaining why testing components together provides higher confidence.
* [Mocks Aren't Stubs](https://martinfowler.com/articles/mocksArentStubs.html) (Martin Fowler): An analysis of the "London School" (Mockist) versus the "Detroit School" (Classicist) and how they define test boundaries.
* [The Practical Test Pyramid](https://martinfowler.com/articles/practical-test-pyramid.html): Expert guidance on finding the "sweet spot" for integration tests to ensure your suite remains fast yet reliable.