# Building the execution engine

To use ***Moxter***, you must instantiate the engine within your *Spring Boot* test classes. The engine acts as the coordinator between your YAML blueprints and the Spring *MockMvc* environment (or *MockWebs* for websocket interaction).

## Recommended setup

The engine is typically instantiated in a `@BeforeEach` method. By using `forTestClass(getClass())`, ***Moxter*** automatically returns a builder that sets the moxture base path to match your test class's package and therefore activating the moxture file hierarchy mechanism.

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
        mx = Moxter.forTestClass(getClass())  // sets the "walk-up" base path 
                                              // for moxture files to mirror
                                              // this class' package hierarchy.
                   .mockMvc(mockMvc)
                   .mockWebs(mockWebs)  // if testing STOMP interaction
                   .authentication(getTestAuthentication())
                   .build();
    }

    /**
     * Standard approach to get an authentication object.
     * Creates a "real" authentication object that Spring Security filters will
     * recognize, complete with a username and a list of roles/authorities.
     */
    private Authentication getTestAuthentication() {
        return new UsernamePasswordAuthenticationToken(
                "testUser", 
                "password", 
                AuthorityUtils.createAuthorityList("ROLE_USER", "ROLE_ADMIN")
        );
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


## Instantiating the Builder

### .forTestClass()
- **Argument Type**: `Class<?>`
- **Returns**: a Moxter builder

This is the preferred entry point. Statically called on the `Moxter` object, it initializes the builder and automatically sets the base path to match the package of the provided class (standard practice is to pass `getClass()`).  
***Moxter*** uses this package as the starting point for its "walk-up" lookup strategy. It begins the search in the specific package folder and, if the moxture is not found, recursively "walks up" the package hierarchy toward the root.  
See chapter [The Moxture File](../moxture/moxture_file.md).

### .builder()
- **Argument Type**: no argument
- **Returns**: a Moxter builder

The manual entry point for initializing the engine. Unlike `forTestClass()`, this method does not perform any package inference. It is ideal for non-standard project structures or scenarios where all moxtures are stored in a single, flat directory (e.g., a central `src/test/resources/moxtures` folder).

When using the raw builder, the search path defaults to the Moxture Root Folder unless explicitly overridden using the .basePath(String) method.


## Building

Once the builder is instantiated, you must provide the necessary dependencies (like MockMvc) and any global configuration.

See chapter [Builder Reference](../engine/reference.md) for a deep dive into available methods.


## Advanced setup
The builder provides additional methods for specialized requirements, which are explored in later chapters:

- Security: enabling automatic CSRF tokens or injecting global authentication headers for the Petclinic admin. See [Reference](../engine/reference.md).
- Global Variables: injecting default values (withVar) like a default owner_id available to every moxture call. See [Reference](../engine/reference.md).
- WebSocket Support: integrating with MockWebs to test real-time notifications.  See [MockWebs](../mockwebs.md).
- Lifecycle Optimization: instead of instatiating the engine before each test, share the same instance for all your tests: see [Strategies for sharing an engine across multiple tests for faster suites](../cookbook/share_engine.md).