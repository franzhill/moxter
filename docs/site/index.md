<section class="moxter-hero" aria-labelledby="moxter-hero-title">
  <div class="moxter-hero__content">
    <p class="moxter-hero__eyebrow">Java · Spring · JUnit · MockMvc</p>
    <h1 id="moxter-hero-title">YAML-ize. Chain. Scenarize.</h1>
    <p class="moxter-hero__lead">Forget the pain. Ditch the boilerplate. Harness the power of YAML and bullet-proof your project with great test scenarios.</p>
    <div class="moxter-hero__actions">
      <a class="md-button md-button--primary" href="setting_up/">Get started</a>
      <a class="md-button" href="user_guide/moxture/moxture_file/">Explore the reference</a>
    </div>
  </div>
  <div class="moxter-hero__art">
    <img src="img/logo.png" alt="Moxter logo">
  </div>
</section>

<div class="moxter-features" aria-label="Moxter features">
  <div class="moxter-feature-card">
    <!--<span class="moxter-feature-card__number">01</span>-->
    <p class="moxter-feature-card__title">Reusable API test calls</p>
    <p>Define requests and expected results once in readable YAML.</p>
  </div>
  <div class="moxter-feature-card">
    <!--<span class="moxter-feature-card__number">02</span>-->
    <p class="moxter-feature-card__title">Use-case scenarios</p>
    <p>Chain calls together and build meaningful business test scenarios.</p>
  </div>
  <div class="moxter-feature-card">
    <!--<span class="moxter-feature-card__number">03</span>-->
    <p class="moxter-feature-card__title">Best of both worlds</p>
    <p>Retain the power of JUnit/AssertJ assertions where needed.</p>
  </div>
</div>

<p class="moxter-note">Moxter runs inside the Spring test context through <code>MockMvc</code>. It is intended for application integration tests, not for sending requests to a deployed service.</p>

## A first simple example

### The YAML definition
Place a file named  `moxtures.yaml` in your test resources (e.g., 
`src/test/resources/moxtures/`). This file describes HTTP calls to your API backend.

=== "Lean"
    ```yaml
    moxtures:
      - name: create_pet
        method: POST
        endpoint: /api/pets
        body: |
          { "firstName": "Thomas ",
            "lastName" : "O'Malley",
            "address"  : "Alleyways and rooftops",
            "age"      : 13
          }
        save:
          petId  : $.id
          petName: $.name 
        expect:
          status: 201


      - name: apply_shampoo
        method: POST
        endpoint: /api/pet/${petId}/shampoo
        vars:
          p.type     : "herbal type 3"
          p.duration : "5 min"
        body:
          type    : ${p.type}
          strength: "mild"
          duration: ${p.duration}
          rinse   : "warm"
        save:
          petVitals: $.vitals
        expect:
          status: 2xx

    
      - name: all_in_one_shampoo_test
        moxtures:
          - create_pet
          - apply_shampoo
          - dry_pet
          - return_pet_to_owner
          - generate_invoice
    ```

=== "With comments"
    ```yaml
    moxtures:
      - name: create_pet
        method: POST
        endpoint: /api/pets
        body: |          # Body given in JSON format
          { "firstName": "Thomas ",
            "lastName" : "O'Malley",
            "address"  : "Alleyways and rooftops",
            "age"      : 13
          }
        save:
          petId  : $.id  # Capture the 'id' field from the JSON response body
                         # (using JSonPath syntax) so it can be used either in 
                         # another moxture, or inside the JUnit test.
          petName: $.name 
        expect:          # Section for assertions that will be automatically 
                         # checked by Moxter.
          status: 201    # Test will fail in case of a different return status code.


      - name: apply_shampoo
        method: POST
        endpoint: /api/pet/${petId}/shampoo   # We're re-using the petId variable 
                                              # recorded in the moxture above. 
        vars:
          p.type     : "herbal type 3"   # defines a local variable usable 
                                         # in the moxture
          p.duration : "5 min"
        body:                   # Body given in YAML format
          type    : ${p.type}   # local variable used here.
          strength: "mild"
          duration: ${p.duration}
          rinse   : "warm"
        save:
          petVitals: $.vitals   # Info on how the pet responds to the shampoo
                                # We can perform further assertions on these
                                # inside the JUnit code.
        expect:
          status: 2xx     # Flexible status matching (200, 201, 204)
                          # Shampooing the pet should not raise any problem.


      # Grouping (chaining) moxtures to create a scenario
      - name: all_in_one_shampoo_test
        moxtures:     # Calling this group moxture will result in the chained 
                      # execution of the programmed moxtures, in the given order:
          - create_pet
          - apply_shampoo
          - dry_pet
          - return_pet_to_owner
          - generate_invoice
          # ... add any other desired moxture
    ```


### The Java JUnit test
In your *JUnit* test, call any moxture, grab portions from its return payload, enforce any kind of good old *JUnit/AssertJ* assertion or just let the moxture's own assertions do the work. ***Moxter*** handles the *MockMvc* execution, JSON serialization, variable extraction and configured assertions, automatically.

=== "Lean"

    ```Java
    ...

    @SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.MOCK)
    @AutoConfigureMockMvc
    class ShampooIntegrationTest {

        private Moxter mx;

        @BeforeEach
        void setup(@Autowired MockMvc mockMvc) {
            mx = Moxter.forTestClass(getClass())
                       .mockMvc(mockMvc)
                       .build();
        }

        @Test
        @DisplayName("Make sure shampoo is safe for the pet")
        void testShampooOnPet() {
            mx.call("create_pet")
              .assertBody("$.id").isNotNull().and()
              .assertBody("$.status").isEqualTo("ACTIVE");

            mx.caller()
              .withVar("p.type", "tropical blossom")
              .call("apply_shampoo")
              .assertVar("petVitals")
                .isNotNull().and()
              .assertBody("$.message")
                .isEqualToInterpolated("Shampoo applied to ${petName}").and()
              .assertBody("$.vitals.heartRate").asString().contains("bpm").and()
              .assertBody("$.isClean").asBoolean().isTrue();

            var vitals = mx.vars().read("petVitals").asType(Map.class);

            assert(vitals.get("temperature")).inBetween("35").and("40");
            assertThat(vitals.get("heartRate")).inBetween("50").and("150");
            assert(vitals.get("fur")) ... ;

            ...
        }
    }
    ```

=== "With comments"

    ```Java
    ...
    
    @SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.MOCK)
    @AutoConfigureMockMvc
    class ShampooIntegrationTest {

        private Moxter mx;  // Our moxture engine

        @BeforeEach
        void setup(@Autowired MockMvc mockMvc) {
            // Build the engine for this test class
            mx = Moxter.forTestClass(getClass())  
                        // (this will let Moxter know which moxture file(s) to load)
                       .mockMvc(mockMvc)
                        // The mockMvc instance Moxter will be using to submit requests
                       .build();
        }

        @Test
        @DisplayName("Make sure shampoo is safe for the pet")
        void testShampooOnPet() {

            // 1. First we'll need a pet 
            //    => call the dedicated moxture defined in the moxture file:
            mx.call("create_pet")
              // We can directly chain some simple assertions on the return body,
              // using jpath:
              .assertBody("$.id").isNotNull().and()
              .assertBody("$.status").isEqualTo("ACTIVE");

            // Note that we don't need to assert the return status code. 
            // That has automatically been asserted by Moxter.

            // 2. Then we'll apply the shampoo on the created pet.
            //    Thanks to chaining, the pet id is automatically passed to 
            //    the 'apply_shampoo' moxture.
            mx.caller()
              // Here, we override the default value defined in the moxture:
              .withVar("p.type", "tropical blossom")
              .call("apply_shampoo")
              .assertVar("petVitals")   // assertion made on a saved variable
                .isNotNull().and()
              .assertBody("$.message")  // assertion made on the response body
                // Here we recall a variable defined in the moxture
                // (either a default, or an extracted) 
                .isEqualToInterpolated("Shampoo applied to ${petName}").and()
              // Typed assertions:
              .assertBody("$.vitals.heartRate").asString().contains("bpm").and()
              .assertBody("$.isClean").asBoolean().isTrue();

            // 3. Further possibly more complex assertions can be performed with 
            //    standard JUnit/AssertJ:
            // - First retrieve the extracted data captured by Moxter:
            var vitals = mx.vars().read("petVitals").asType(Map.class);
            // - Then perform assertions:
            assert(vitals.get("temperature")).inBetween("35").and("40");
            assertThat(vitals.get("heartRate")).inBetween("50").and("150");
            assert(vitals.get("fur")) ... ;
            ...
        }
    }
    ```



### Run your Moxter test

Run it like any other JUnit integration test:

```bash
$ mvn test  -Dtest=ShampooIntegrationTest
```



## How it works

### Under the hood

***Moxter*** is designed to test a stateful *Spring* API during the `mvn test` phase. Statefulness (or 'persistence') means that application context is retained between test calls thus allowing chaining calls into more complex stateful scenarios. <!--During the test phase statefulness is often achieved by using in-memory state mechanisms like a H2 dtabase.-->

Under the hood, ***Moxter*** works with or relies on:

- **@SpringBootTest** annotated *JUnit* tests
- **MockMvc**
- A test **persistence** setup (a common setup is e.g. an in-memory database such as *H2*)


***Moxter***:

- leverages *MockMvc* to perform the actual **REST requests**
- requests go through the **full Spring stack**, hitting your actual Controllers, Services, and Repositories, providing excellent coverage in the process
- accomplishes YAML configured **assertions**.


### The Moxter value

What ***Moxter*** brings on top of that:

- **Organize** your API calls in reusable, highly tunable YAML moxtures, inside YAML config files
- **Chain** API calls to build scenarios
- **Extend** a moxture to avoid duplicating it when slight variations are needed
- **Override** moxture defaults at call time from the JUnit test
- Easily **extract** and **reuse** data from the response body across all moxtures
- **Bake simple assertions** into the actual YAML moxture
- Keep more complex assertions on the **Java side**
- **STOMP/WebSocket** support for event-driven testing




## Without Moxter


### Boilerplate and mixing concerns

Without ***Moxter***, our test would have looked like follows, heavily mixing 
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

By extracting the configuration details of the REST request into a YAML configuration, we have made it easy for tests to call that request again and again, while at the same time giving them the possibility of overriding some of its configurations at call time.

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

If an endpoint URL changes (e.g., adding `/v2/`), no need to go hunting for the calls in dozens of Java files. Just update the moxture in the YAML file, and you're good to go.
