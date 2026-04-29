
# CHANGELOG

## v0.9.1


### MockWebs: authentication session in Spring session registry

2026.04.27 

MockWebs: when providing an authentication, publish a SessionConnectedEvent to "trick" the Spring context into saving the session in its session registry.

### Added support for extracting variables out of the broadcasted message
2026.04.17

```YAML
    expect:  # expect the return to be...
      broadcast:
        ...
        save:  # save a global context var for possible further assertion on Java side
          content: $   # saves the whole raw return in variable 'content'
          msg    : $.msg   # assumes the return is JSon under the hood, attempts to set the
                           # variable with the provided JSonPath, issues a warning otherwise
```