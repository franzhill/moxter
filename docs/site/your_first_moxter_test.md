# Your first Moxter test



## Create your first "Moxture"
By default, Moxter looks for YAML files in `src/test/resources/moxtures`. Create a file there named `moxtures.yaml`.

Let's say we want to verify the health check endpoint of your API.
We'll create a moxture representing a call to that endpoint, assert it should return a 200 status, and extract the returned version from the return body.

```YAML
# src/test/resources/moxtures/moxtures.yaml
moxtures:
  - name: "health_check"
    method: GET
    endpoint: /api/v1/status    # an endpoint of your API
    save:
      version: "$.version"     # extract version from the JSON response body using jsonpath
    expect:
      status: 200
```

## Call the moxture in a JUnit test

Now, in the JUnit we just need to call the moxture. We'll then assert the returned version is as expected.

```Java
... // imports

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.MOCK)
@AutoConfigureMockMvc
class HelloWorldTest {

  private Moxter mx;

  @BeforeEach
  void setup(@Autowired MockMvc mockMvc) {
    mx = Moxter.forTestClass(getClass())
                    .mockMvc(mockMvc)
                    .build();
    }

    @Test
    void shouldReturnHealthyStatus() {
      mx.caller()
        .call("health_check");
      // Perform assertions...  
      assertThat(mx.vars().read("version").asString()).isEqualTo("v1");
    }
  }
```

## Execute the test
Run your tests as you normally would:

```Bash
$ mvn test
```

or run 
just this test:

```Bash
$ mvn test -Dtest="HelloWorldTest"
```
