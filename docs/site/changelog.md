


### 2026.04.17 - v0.9.1

Added support for extracting variables out of the broadcasted message

```YAML
    expect:  # expect the return to be...
      broadcast:
        ...
        save:  # save a global context var for possible further assertion on Java side
          content: $   # saves the whole raw return in variable 'content'
          msg    : $.msg   # assumes the return is JSon under the hood, attempts to set the
                           # variable with the provided JSonPath, issues a warning otherwise
```