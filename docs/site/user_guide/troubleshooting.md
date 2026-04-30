# Troubleshooting

TODO

## Placeholder syntax in Java exception messages

Example
```txt
Caused by: com.fasterxml.jackson.databind.exc.InvalidFormatException: Cannot deserialize value of type `com.acme.service.authorization.enums.Rights` from String "${rights}": not one of the values accepted for Enum class: [...
```

- **Reason**: This means your variable (here,  `${rights}`) was not properly interpolated
- **How to solve**: TODO