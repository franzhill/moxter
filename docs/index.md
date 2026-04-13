# Orchestrate, stop writing boilerplate!



Moxter turns verbose MockMvc boilerplate into declarative, reusable API calls. Define 
your API interactions in YAML, orchestrate them in Java/JUnit, and keep your test intent 
light and crystal clear. 



## A first simple test example with Moxter

The following example demonstrates writing a simple test scenario querying a succession of API 
REST endpoints.

### The YAML definition
Place a file named  `moxtures.yaml` in your test resources (e.g., 
`src/test/resources/moxter/simple/`). 
This file describes HTTP calls to your API backend.

```yaml
moxtures:
  - name: create_pet
    method: POST
    endpoint: /api/pets
    body:
      firstName: "Thomas "
      lastName : "O'Malley"
      address  : "Alleyways and rooftops"
      city     : "Paris"
    save:
      petId: $.id    # Capture the 'id' field from the JSON response body
                     # (using JSonPath syntax) so it can be used either in 
                     # another moxture, or inside the JUnit test.
      petName: $.name 
    expect:          # Section for assertions that will be automatically checked by Moxter.
      status: 201    # Test will fail in case of a different return status code.


  - name: apply_shampoo
    method: POST
    endpoint: /api/pet/${petId}/shampoo   # We're re-using the petId variable recorded in 
                                          # the moxture above. 
    vars:
      p.type     : "herbal type 3"   # defines a local variable usable in the moxture
      p.duration : "5 min"
    body:
      type    : ${p.type}            # local variable used here.
      strength: "mild"
      duration: ${p.duration}
      rinse   : "warm"
    save:
      petVitals: $.vitals    # Info on how the pet responds to the shampoo
                             # We can perform further assertions on these
                             # inside the JUnit code.
    expect:
      status: 2xx     # Flexible status matching (200, 201, 204)
                      # Shampooing the pet should not raise any problem.


  # Orchestrating a scenario by grouping moxtures
  - name: all_in_one_shampoo_test
    moxtures:      # Calling this 'group' moxture will result in the chained 
                   # execution of the programmed moxtures, in the given order:
       - create_pet
       - apply_shampoo
       - dry_pet
       - return_pet_to_owner
       - generate_invoice
       # ... add any other desired moxture

```

<br /> 

### The Java JUnit test
In your JUnit test, you build the engine and call the moxture by its symbolic name. Moxter handles the MockMvc execution, JSON serialization, and status assertions automatically.

```Java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.MOCK)
@AutoConfigureMockMvc
class PetIntegrationTest {

    @Autowired
    private MockMvc mockMvc; // Injected by the Spring Test context

    private static Moxter mx;  // Our moxture engine

    @BeforeAll
    static void setup(@Autowired MockMvc mockMvc) {
        // Build the engine for this test class
        mx = Moxter.forTestClass(PetIntegrationTest.class)  
                    // (this will let Moxter know which moxture file(s) to load)
                   .mockMvc(mockMvc)
                   // The mockMvc instace Moxter will be using to submit requests
                   .build();
    }

    @Test
    @DisplayName("Make sure shampoo is safe for the pet")
    void testShampooOnPet() {

        // 1. First we'll need a pet => execute the dedicated moxture defined in the moxture file: 
        mx.call("create_pet")
          .assertBody("$.id").isNotNull().and()         // Directly chain some simple assertions
          .assertBody("$.status").isEqualTo("ACTIVE");

        // (The return status code has automatically been asserted by Moxter.)

        // 2. Then we'll apply the shampoo on the created pet.
        //    Thanks to chaining, the pet id is automatically passed to 
        //    the 'shampoo' moxture.
        mx.caller()
          .withVar("p.type", "tropical blossom")  // Override the moxture default variable
          .call("apply_shampoo")
          .assertVar("petVitals")   // assertion made on a saved variable
             .isNotNull().and()
          .assertBody("$.message")  // assertion made on the response body using JSonPath
             .isEqualToInterpolated("Shampoo applied to ${petName}").and()
          .assertBody("$.vitals.heartRate").asString().contains("bpm").and()
          .assertBody("$.isClean").asBoolean().isTrue();

        // 3. Further possibly more complex assertions can be performed with standard JUnit/AssertJ:
        // - Retrieve the extracted data captured by Moxter:
        var vitals = mx.vars().read("petVitals").asType(Map.class);
        // - Perform assertions:
        assert(vitals.get("temperature")).inBetween("35").and("40");
        assertThat(vitals.get("heartRate")).inBetween("50").and("150");
        assert(vitals.get("fur")) ... ;

        ...
    }
}
```
<br />


## How it works
**Moxter** acts as a coordination layer between your declarative YAML files and the `Spring MockMvc` framework.

- **Discovery**: The engine finds the moxtures.yaml based on your test's package name.
- **Resolution**: Any placeholders like `${var}` in the YAML are replaced by values currently in the engine's memory.
- **Assertion**: If the server returns anything other than the expected status (e.g. 201 ), the test fails immediately with a descriptive error message showing the response body.
- **Persistence**: The save block extracts the ID from the response and stores it in the engine's shared memory, making it available for any subsequent moxture calls or Java assertions.




<br />


## Without Moxter

With just a simple test like this one, we already have saved ourselves tedious boilerplate code, while conveying clarity, separation of concern and reusability.

### Boilerplate and mixing concerns

Without Moxter, our test would have looked like follows, heavily mixing 
test **configuration** with test **intent**:

```java
@Test
void testShampooOnPet_MANUAL() throws Exception {
    // CONFIGURATION
    String createPetJson = """
        {
            "firstName": "Thomas ",
            "lastName" : "O'Malley",
            "address"  : "Alleyways and rooftops",
            "city"     : "Paris"
        }
    """;

    // INTENT
    MvcResult result1 = mockMvc.perform(post("/api/pets")
            .contentType(MediaType.APPLICATION_JSON)
            .content(createPetJson))
            .andExpect(status().isCreated()) // Manual status check
            .andReturn();

    // BOILERPLATE
    String response1 = result1.getResponse().getContentAsString();
    Integer petId = JsonPath.read(response1, "$.id");
    String petName = JsonPath.read(response1, "$.name");

    // INTENT
    assertThat(petId).isNotNull();
    assertThat(JsonPath.<String>read(response1, "$.status")).isEqualTo("ACTIVE");

    // CONFIGURATION
    String shampooJson = """
        {
            "type"    : "herbal type 3",
            "strength": "mild",
            "duration": "5 min"
        }
    """;

    // INTENT
    MvcResult result2 = mockMvc.perform(post("/api/pet/" + petId + "/shampoo") // Manual path building
            .contentType(MediaType.APPLICATION_JSON)
            .content(shampooJson))
            .andExpect(status().isOk())
            .andReturn();

    // BOILERPLATE
    // Complex Manual Assertions & Casting
    String response2 = result2.getResponse().getContentAsString();
    Map<String, Object> vitals = JsonPath.read(response2, "$.vitals");
    String message = JsonPath.read(response2, "$.message");

    // INTENT
    assertThat(vitals).isNotNull();
    assertThat(message).isEqualTo("Shampoo applied to " + petName);
    assertThat(JsonPath.<String>read(response2, "$.vitals.heartRate")).contains("bpm");
    assertThat(JsonPath.<Boolean>read(response2, "$.isClean")).isTrue();
    
    assertThat(vitals.get("temperature")).isEqualTo("38 °C");
}
```


### Reusability

By extracting the configuration details of the REST request into a YAML configuration, we have 
made it easy for tests to call that request again and again, while at the same time giving them
the possibility of overriding some of its configurations at call time.

```java
    
    void testExperimentalShampooOnPet() {

        mx.call("create_pet")
          .assertBody("$.id").isNotNull().and()
          .assertBody("$.status").isEqualTo("ACTIVE");

        mx.caller()
          .withVar("p.type"    , "experimental")  // Override the moxture default variable
          .withVar("p.duration", "1 min")         // Override the moxture default variable
          .call("apply_shampoo")
          .assertVar("petVitals")
             .isNotNull().and()
          .assertBody("$.vitals.heartRate").asString().contains("bpm").and()
          .assertBody("$.isClean").asBoolean().isTrue();
```


### Maintenance

If an endpoint URL changes (e.g., adding /v2/), no need to go hunting for the calls in dozens of 
Java files. Just update the moxture in the YAML file, and you're good to go.