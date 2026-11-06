# YAML Validation & Autocomplete

To improve the development experience, ***Moxter*** provides a JSON schema. Configuring this in your IDE enables:

- **Autocompletion**: Suggestions for valid YAML keys (e.g., `expect`, `save`, `options`).
- **Validation**: Detection of typos or incorrect data types.
- **Documentation**: Tooltips describing the purpose of each field.

## 1. Schema
This is the schema that needs to be configured in your IDE: [Schema]({{ schema_path }}).

Alternatively, you can retrieve it from the ***Moxter*** library JAR (`moxture-schema.json` at the root of the package).


## 2. Configuration
### IntelliJ IDEA
IntelliJ provides native support for YAML schema mapping:

- Open Settings (`Ctrl+Alt+S`) and navigate to `Languages & Frameworks > Schemas and DTDs > JSON Schema Mappings`.  
- Click `+` to add a new mapping and name it "Moxter".
- Paste the schema URL above into the `URL` field or provide it directly.
- Set the `JSON Schema Version` to `JSON Schema version 7`.
- In the `Files` section, add a path pattern to match your moxture files, such as:
  - `src/test/resources/moxtures/*.yaml`
  - `*moxtures.yaml`

### VSCode
Using the Red Hat YAML extension (Identifier: `redhat.vscode-yaml`), update your `settings.json` file:

```JSON
"yaml.schemas": {
  "{{ schema_url }}": ["*moxtures.yaml", "moxtures/*.yaml"]
}
```

## 3. Verification
After configuration, opening a `.yaml` moxture file should enable suggestions via `Ctrl + Space`. Any invalid keys or structure will be highlighted as errors.