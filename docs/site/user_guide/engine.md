<div class="moxter-userguide-title" markdown="1">
# ![](../../img/moxter_userguide.png) Building the execution engine
</div>

To use ***Moxter***, you must instantiate the engine within your *Spring Boot* test classes. The engine acts as the coordinator between your YAML moxtures and the Spring *MockMvc* environment (or *MockWebs* for websocket interaction).

## Recommended setup

The engine is typically instantiated in a `@BeforeEach` method. By using `forTestClass(getClass())`, ***Moxter*** uses the test class for hierarchical moxture lookup: it searches from the class's package toward the shared `moxtures` root (See chapter [The Moxture File](../moxture/moxture_file.md)).

### Example

```java
@SpringBootTest
@AutoConfigureMockMvc
class PetApiTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private MockWebs mockWebs;  // if performing STOMP tests

    @Autowired
    private ObjectMapper objectMapper;

    private Moxter mx;   //  <-- our Moxter engine

    @BeforeEach
    void setUp() {
        mx = Moxter.forTestClass(getClass())  // uses this class to start the
                                              // hierarchical moxture lookup.
                   .mockMvc(mockMvc)
                   .mockWebs(mockWebs)  // if performing STOMP tests
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

This is the preferred entry point.  Statically called on the `Moxter` object, it uses the provided test class as the base path for  the hierarchical moxture loader. Standard practice is to pass `getClass()`. The loader searches from the test class's package and walks up toward the shared `moxtures` root, allowing package-specific moxtures to override shared definitions. 
See chapter [The Moxture File](../moxture/moxture_file.md).



## Building

Once the builder is instantiated, you must provide the necessary dependencies (like MockMvc) and any global configuration.

See chapter [Builder Reference](../../user_guide/engine/reference.md) for a deep dive into available methods.


## Advanced setup
The builder provides additional methods for specialized requirements, which are explored in later chapters:

- Security: enabling automatic CSRF tokens or injecting global authentication headers for the PetClinic admin. See [Reference](../../user_guide/engine/reference.md).
- Global Variables: injecting default values (withVar) like a default owner_id available to every moxture call. See [Reference](../../user_guide/engine/reference.md).
- WebSocket Support: integrating with MockWebs to test real-time notifications.  See [MockWebs](../../user_guide/mockwebs.md).
- Lifecycle Optimization: instead of instantiating the engine before each test, share the same instance for all your tests: see [Strategies for sharing an engine across multiple tests for faster suites](../../user_guide/cookbook/share_engine.md).
