# YAML Validation & Autocomplete

To improve the development experience, ***Moxter*** provides a JSON schema. Configuring this in your IDE enables:

- **Autocompletion**: Suggestions for valid YAML keys (e.g., expect, save, options).
- **Validation**: Detection of typos or incorrect data types.
- **Documentation**: Tooltips describing the purpose of each field.

## Schema URL
Configure your IDE to fetch the schema from:
`https://franzhill.github.io/moxter/schema/moxture.schema.json`

Alternatively, the file is located within the ***Moxter*** library JAR as `moxture.schema.json`.

## Configuration
### IntelliJ IDEA
IntelliJ provides native support for YAML schema mapping:

- Open Settings (`Ctrl+Alt+S`) and navigate to `Languages & Frameworks > Schemas and DTDs > JSON Schema Mappings`.  
- Click `+` to add a new mapping and name it "Moxter".
- Paste the URL above into the `URL` field.
- Set the `JSON Schema Version` to `JSON Schema version 7`.
- In the `Files` section, add a path pattern to match your moxture files, such as:
  - `src/test/resources/moxtures/*.yaml`
  - `*moxtures.yaml`

### VS Code
Using the Red Hat YAML extension, update your `settings.json` file:

```JSON
"yaml.schemas": {
    "https://franzhill.github.io/moxter/schema/moxture.schema.json": ["*moxtures.yaml", "moxtures/*.yaml"]
}
```

## Verification
After configuration, opening a `.yaml` moxture file should enable suggestions via `Ctrl + Space`. Any invalid keys or structure will be highlighted as errors.