# Mockwebs


This utility is specifically designed to bypass the STOMP network layer entirely. Here is the breakdown of how it works:

Reflective Routing: It scans the ApplicationContext for @Controller beans and builds an in-memory routing table of @MessageMapping and @SubscribeMapping endpoints.

Direct Invocation: When you call send(), it uses standard Java reflection to invoke the controller method directly.

Security Simulation: It manually sets the SecurityContextHolder with the provided principal and triggers a PreAuthorizeAuthorizationManager check before the method runs.

Mocked Messaging: It relies on a Mockito mock or spy of the SimpMessagingTemplate to capture outbound broadcasts for verification.