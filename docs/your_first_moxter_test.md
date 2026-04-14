# Your first Moxter test



## Create your first "Moxture"
By default, Moxter looks for YAML files in `src/test/resources/moxtures`. Create a file there named `moxtures.yaml`:

```YAML
# src/test/resources/moxtures/moxtures.yaml
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

## Execute the test
Run your tests as you normally would.

```Bash
$ mvn test
```

or just this test:

```Bash
$ mvn test -Dtest="HelloWorldTest"
```
