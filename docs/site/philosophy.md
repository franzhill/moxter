<div class="moxter-title-with-image" markdown="1">
# The philosophy behind Moxter

![Moxter dressed as a Greek philosopher, deep in thought](img/moxter_thinking.png)
</div>

## The state of unit testing

***Moxter*** was born out of one realization: while production code gets regular care, tests are often left untended until the suite becomes a tangled, hard-to-maintain place nobody wants to enter.

In many software projects, unit testing is the neglected stepchild of the development lifecycle. While production code is scrutinized for clean architecture, design patterns, and performance, the test concern, while proudly exposed through flattering metrics and indicators, is often left to grow wild, resulting in a "Big Tangled Ball of Spaghetti" that provides a false sense of safety and a long groan of dread whenever a developer has to "add test coverage".

Because good tests are actually -and surprisingly- difficult to craft, because they are tedious to write, and because nobody really cares as long as that pipeline turns green, they tend to evolve with a life of their own without any governance and direction.

Without a clear framework or strategy, developers copy-paste setup logic, hardcode magic strings, create deeply nested helper methods, Mockito everything away ending up testing nothing more than the bare metal of the underlying frameworks. As long as "the tests pass", everybody turns a blind eye.

Over the years, libraries have emerged to address parts of this problem.

The result? A big folder of tests that take longer to code and maintain than actually developing the feature, and where nobody truly knows what a specific test is actually verifying or why its setup context is as it is.


## The false sense of security

High test coverage percentages often act as a mask. You can have 90% coverage and still ship a critical bug because your mocks are "lying" to you. If you mock your service layer to return a success, your test will pass even if the real service would have crashed due to a database constraint or a null pointer.

"Testing with mocks is often just testing that your mocks work."

When tests are too isolated, they fail to catch State Corruptions. A unit test might prove that you can create a user, and another might prove you can delete a user, but they rarely prove that you can create, update, and then delete that same user in a single cohesive flow. This gap is where the most expensive production bugs hide.



## Where Moxter comes in

***Moxter*** was designed to disrupt this cycle by promoting business-focused testing at the application boundary and making test scenarios easier to organize, automate, and understand.

***Moxter*** encourages "Black Box" integration-style testing through your application's natural API interface rather than testing Java internal methods in isolation ( so-called 'unit' tests).

This approach builds on existing Spring testing tools: `@SpringBootTest` provides the Spring application context, and `MockMvc` exercises the application through Spring MVC without starting a real HTTP server.


 
***Moxter*** does not reinvent the wheel. Rather it seeks to make the most of what is already out there. By building on top of them, and providing the means to easily define test building bricks (so-called "moxtures"), ***Moxter*** allows developers to painlessly design and orchestrate larger, sleeker, more meaningful test scenarios.


## Why use Moxter?
- **The Sweet Spot**: sitting in between isolated unit tests and external API testing tools, ***Moxter*** allows you to test real-world scenarios during the standard mvn test phase.
- **Shorter, Cleaner, Meaningful Tests**: ***Moxter*** reduces repetitive `MockMvc` request boilerplate setup, letting JUnit tests focus more on scenario intent while retaining standard assertions.
- **Readability**: "Moxtures" (MockMvc calls) are configured in YAML files thus providing clean, human-readable and reusable bricks.
- **Maintainability**: When an API endpoint changes, you update the YAML "moxture" in one place rather than hunting through dozens of Java test files.
- **Reusability**: "Moxtures" can be shared across multiple test classes 
- **Buildability**: "Moxtures" serve as the fundamental building bricks for advanced test scenarios. You can group multiple moxtures to define new, higher-level moxtures which function just like a simple moxture. Moxtures can be chained together, with the output of one 'fed' into the input of the next one.




## Further resources on the subject of testing

* [TDD is Dead. Long live testing.](https://dhh.dk/2014/tdd-is-dead-long-live-testing.html) (DHH): A critique of how mock-heavy testing leads to "Test-Induced Design Damage," creating complex architectures just to satisfy isolation.
* [TDD, Where Did It All Go Wrong?](https://www.youtube.com/watch?v=EZ05e7EMOLM) (Ian Cooper): A seminal talk arguing that a "unit" should be a cohesive business behavior, not a single class.
* [Unit Test](https://martinfowler.com/bliki/UnitTest.html) (Martin Fowler): A breakdown of the "Sociable vs. Solitary" distinction, explaining why testing components together provides higher confidence.
* [Mocks Aren't Stubs](https://martinfowler.com/articles/mocksArentStubs.html) (Martin Fowler): An analysis of the "London School" (Mockist) versus the "Detroit School" (Classicist) and how they define test boundaries.
* [The Practical Test Pyramid](https://martinfowler.com/articles/practical-test-pyramid.html): Expert guidance on finding the "sweet spot" for integration tests to ensure your suite remains fast yet reliable.