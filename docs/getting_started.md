# Getting started


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



## Create your first "Moxture"
By default, Moxter looks for YAML files in src/test/resources/moxtures. Create a file named hello_world.yml:

```YAML
# src/test/resources/moxtures/hello_world.yml
moxture:
  name: "connectivity_check"
  method: GET
  endpoint: /api/v1/status
  save:
    version: "${app.version}"
  expect:
    status: 200
```

## Call the moxture in a JUnit test

Now, tell JUnit to execute that Moxture. You don't need to manually mock the MVC environment.

```Java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.MOCK)
@AutoConfigureMockMvc
class HelloWorldTest {

    @Autowired
    private MockMvc mockMvc;
    private static Moxter mx;

    @BeforeAll
    static void setup(@Autowired MockMvc mockMvc) {
        mx = Moxter.forTestClass(PetIntegrationTest.class)  
                    .mockMvc(mockMvc)
                    .build();
    }

    @Test
    void shouldReturnHealthyStatus() {
        mx.call("connectivity_check");

        // Perform assertions ...
        assertThat(mx.getVar("version")).isEqualTo("v1");
    }
```

## Execute
Run your tests as you normally would.

```Bash
$mvn test
````

or just this test:

```Bash
$mvn test -Dtest="HelloWorldTest"
````
