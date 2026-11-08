<div class="moxter-title-with-image" markdown="1">
# Setting up
</div>

<div class="moxter-setting-up-intro" markdown="1">
![Moxter racing toward the finish line](img/moxter_racing.png) Getting Moxter up and running takes less time than mixing a proper martini. Follow these steps to run your first declarative API test.
</div>

## Prerequisite
Moxter requires Java 17+ and a Spring Boot 3.x environment.

## Add the Dependency
***Moxter*** is published on  [Maven Central](https://central.sonatype.com/artifact/dev.moxter/moxter/). <br />
Add it to your pom.xml. <br />
Since ***Moxter*** is designed for the test phase, ensure the scope is set to test.

```XML
<dependency>
    <groupId>dev.moxter</groupId>
    <artifactId>moxter</artifactId>
    <version>0.9.0</version>
    <scope>test</scope>
</dependency>
```
