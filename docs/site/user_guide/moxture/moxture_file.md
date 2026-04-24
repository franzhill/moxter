# YAML Moxture files

A **moxture file** is a YAML-based collection of `moxtures` i.e. descriptions of tailored API calls with added capabilities that can be executed directly from a *JUnit* test or chained together to form more elaborate business test scenarios.

Moxture files are named `moxtures.yaml`. While you can start with a single file, Moxter allows you to create several to keep your testing logic modular.

## The `moxtures.yaml` file structure

Moxtures are introduced at the top-level with the `moxtures:` key. This key acts as a container for all the individual `moxtures` defined within that file.

```YAML
moxtures:
  # This is a moxture (a single API call):
  - name: create_pet:
    method: POST
    endpoint: /api/pets
    # ... (details)

  # This is another moxture:
  - name: assign_owner:
    method: POST
    endoint: /api/pet/{id}/owner
    # ... (details)

  # This is a group moxture:
  # (Executes the given moxtures as a sequence)
  - name: scenario_pet_and_owner
    moxtures:
      - create_pet
      - assign_owner
...
```

> 💡 
> Note on groups: a moxture is considered a group moxture if it defines a list of moxtures. This is the configuration-first way to build multi-step scenarios.


## How to organise your `moxtures.yaml` files

***Moxter*** expects your `moxtures.yaml` files to be placed somewhere under the Moxture Root Folder `src/test/resources/moxtures/`. Depending on your project size, you can choose between a simple setup or a hierarchical one.


### One moxture file

If you are just starting or have a small project, place a single `moxtures.yaml` directly inside the Moxture Root Folder:  
`src/test/resources/moxtures/moxtures.yaml`.

Moxtures in this file will be available to every test in your suite.


### Several moxture files: unleashing the power of the hierarchy

***Moxter*** is designed to be modular. Instead of one single moxture file concentrating all moxtures for the project, moxtures can be distributed into multiple files.

#### Follow the package structure

`moxtures.yaml` files are still placed under the Moxture Root Folder, but inside a further subfolder structure that mirrors the Java package folder structure of your *JUnit* tests. 


#### The "walk-Up" visibility
When a *JUnit* test references a moxture, ***Moxter*** performs a hierarchical search:
- It looks for a moxture file inside a folder mirroring you test class' package folder
- If it doesn't find the requested moxture inside that file, or if the file does not exist, it will check the parent package folder.
- It continues walking up the tree until it reaches the Moxture Root Folder.


#### Example

```txt
src/test/resources/moxtures/
├── moxtures.yaml                 <-- [ROOT] Global moxtures, available to 
|                                      all tests. 
└── com/
    └── petclinic/
        ├── moxtures.yaml         <-- [PACKAGE] Available to all 
        |                             com.petclinic.*Test.java tests
        └── PetCreationTest/
            └── moxtures.yaml     <-- [CLASS] Only available to 
                                      PetCreationTest.java. Can shadow (redefine)
                                      moxtures from higher levels.
```


#### Key benefits 
- **Shadowing and Precedence**: this hierarchy allows you to provide a Library of common moxtures at a high level while allowing specific tests to redefine (shadow) them at a lower level. The file closest to your test class always takes precedence.
- The "anti-zombie" effect: this on-demand loading means ***Moxter*** only reads files relevant to your specific test's hierarchy. If a "zombie" (a broken or invalid YAML file) exists in an unrelated package, it will not crash your test suite because the engine never attempts to load it.
- This hierarchical foundation also comes into play in advanced features like **variable shadowing** or **moxture inheritance** that we will be exploring in the upcoming chapters.
