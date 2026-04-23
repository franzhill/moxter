# Setting up


Getting Moxter up and running takes less time than mixing a proper martini. Follow these three steps to run your first declarative API test.

## Prerequisite
Moxter requires Java 17+ and a Spring Boot 3.x environment.

## Add the Dependency
Add Moxter to your pom.xml. Since Moxter is designed for the test phase, ensure the scope is set to test.

```XML
<dependency>
    <groupId>dev.moxter</groupId>
    <artifactId>moxter</artifactId>
    <version>0.9.0</version>
    <scope>test</scope>
</dependency>
```

