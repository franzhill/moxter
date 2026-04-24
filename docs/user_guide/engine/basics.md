# Building the execution engine

To use ***Moxter***, you must instantiate the engine within your Spring Boot test classes. The engine acts as the coordinator between your YAML blueprints and the Spring *MockMvc* environment (or *MockWebs* for websocket interaction).

## Basic setup

The engine is constructed using a builder pattern. It is typically instantiated in a `@BeforeEach` method to ensure that each test starts with a clean, isolated variable state.

### Example

```java
@SpringBootTest
@AutoConfigureMockMvc
class PetApiTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    private Moxter mx;   //  <-- our Moxter engine

    @BeforeEach
    void setUp() {
        mx = Moxter.builder()
                .mockMvc(mockMvc)
                .objectMapper(objectMapper)
                .basePath("moxtures/petApi") // Root folder in src/test/resources
                .build();
    }

    @Test
    void should_create_new_pet() {
        // Execute the 'create_pet' moxture defined in your YAML
        mx.caller()
          .withVar("p.name", "Snowy")  // Override the local moxture variable's
                                       // value.
          .call("create_pet");

        // The engine automatically asserts the expectations defined in 
        // the YAML (e.g., status 201).

        // To verify the creation request has indeed been persisted, we could:
        mx.caller()
          .withVar("p.name", "Snowy")
          .call("get_pet");
        // Status 200 automatically checked by the engine.
    }
}
```




## Advanced setup
The builder provides additional methods for specialized requirements, which are explored in later chapters:

- Security: enabling automatic CSRF tokens or injecting global authentication headers for the Petclinic admin. See [Reference](user_guide/engine/reference.md).
- Global Variables: injecting default values (withVar) like a default owner_id available to every moxture call. See [Reference](user_guide/engine/reference.md).
- WebSocket Support: integrating with MockWebs to test real-time notifications.  See [MockWebs](user_guide/mockwebs.md).
- Lifecycle Optimization: see [Strategies for sharing an engine across multiple tests for faster suites](user_guide/cookbook/share_engine.md).