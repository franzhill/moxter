<div class="moxter-userguide-title" markdown="1">
# ![](../img/moxter_reference.png) Moxter Engine Reference
</div>



## `Moxter.forTestClass(Class<?>)`

- **Return**: `MoxBuilder`
- **Required**: yes
- **Applicable**: all moxtures

Initiates a ***Moxter*** engine for a test class.
Subsequently chain-call configurations and finalize the engine with `.build()` :

```java
Moxter mx = Moxter.forTestClass(MyTest.class)
        // configurations
        .mockMvc(mockMvc)
        ...
        .build();
```


## `.mockMvc(MockMvc)`

- **Called on**: `MoxBuilder`
- **Return**: `MoxBuilder`
- **Required**: yes if executing HTTP moxtures
- **Applicable**: HTTP moxtures

Configures the Spring `MockMvc` instance used to execute HTTP moxtures.

## `.mockWebs(MockWebs)`

- **Called on**: `MoxBuilder`
- **Return**: `MoxBuilder`
- **Required**: yes if executing STOMP moxtures
- **Applicable**: STOMP moxtures

Configures the `MockWebs` instance used to execute STOMP moxtures and assert outbound messages.

See [MockWebs](../../user_guide/mockwebs.md).

## `.authentication(org.springframework.security.core.Authentication)`
- **Called on**: `MoxBuilder`
- **Return**: `MoxBuilder`
- **Required**: only when STOMP moxtures need an authenticated principal not available from the default security context
- **Applicable**: HTTP and STOMP moxtures

Sets a fixed Spring Security authentication for the engine. For HTTP, this is equivalent to applying `.with(authentication(...))` to each `MockMvc` request made by the engine. If none is configured, Moxter resolves authentication from Spring Security's `SecurityContextHolder`. Authentication supplied for an individual call takes precedence over the engine default. For STOMP, the authentication associates the socket handshake and subsequent messages with the corresponding user principal.

Beyond the `UsernamePasswordAuthenticationToken` used in the setup chapter, here are two other ways to create an `Authentication` object to pass to this function. Choose an approach that fits the Spring Security filters used by your application:

```java
// A simple test-dedicated authentication.
// Use when your tests work with test-specific credentials.
private Authentication getTestAuthentication() {
    return new TestingAuthenticationToken("admin", "principal", "ROLE_ADMIN");
}

// A mocked authentication.
// This mock only provides the behavior stubbed below. Stub any additional
// methods your code or security configuration relies on.
private Authentication getMockAuthentication() {
    Authentication auth = Mockito.mock(Authentication.class);
    Mockito.when(auth.getName()).thenReturn("mockUser");
    Mockito.when(auth.isAuthenticated()).thenReturn(true);
    return auth;
}
```

## `.authenticationSupplier(Supplier<Authentication>)`

- **Called on**: `MoxBuilder`
- **Return**: `MoxBuilder`
- **Required**: no
- **Applicable**: HTTP and STOMP moxtures

Supplies authentication dynamically for engine requests. Use this when authentication should be resolved at request time rather than set to a fixed value.

## `.build()`

- **Called on**: `MoxBuilder`
- **Return**: `Moxter`

- **Required**: yes
- **Applicable**: all moxtures

Builds and returns the configured `Moxter` engine.

