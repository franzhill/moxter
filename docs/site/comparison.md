

# Moxter in the testing landscape

<div class="moxter-comparison" markdown="1">

| | Mockito | MockMvc | Moxter | Rest Assured | Postman / Newman and clones |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Testing Level** | Unit (Isolation) | Integration | Integration | Integration | End To End / System |
| **Test "Border"** | Internal Logic | API Border | API Border | API Border | API Border |
| **Main rationale** | Automated proof of internal logic | Automated proof of the API contract | Automated proof of the API contract and end-user scenarios| Automated proof of the API contract | Manual/Automated proof and exploration of the API contract in 'real-life' |
| **Covers**        | 🔴 Small portion of code | 🟢 Controller, Service, Repo | 🟢 Controller, Service, Repo | 🟢 Controller, Service, Repo | ⭐ Controller, Service, Repo, non-test DB | 
| **Environment**   |Test | Test | Test | Any | Any (inc. Prod) | 
| **Requires HTTP server** | 🟢 No | 🟢 No | 🟢 No | 🔴 Yes (🟢 No with MockMvc extension) | 🔴 Yes |
| **Close to Real-life?** | 🔴 No | 🟢 Closer  | 🟢 Closer | ⭐ Closest | ⭐ Closest |
| **Stage in dev cycle** | ⭐ Early | ⭐ Early  | ⭐ Early | 🟡 Later | 🔴 Late (Post-Deployment) |
| **Execution Speed** | ⭐ Instant | 🟢 Fast | 🟢 Fast | 🟡 Moderate | 🔴 Slow (Needs Server) |
| **CI/CD Integration** | ⭐ Native | ⭐ Native | ⭐ Native | ⭐ Native | 🟡 Needs CLI/Wrappers |
| **Real-life test scenarios?**| 🔴 No | 🟡 Manual | ⭐ Good (chaining) | 🟢 Good  | ⭐ Good (may need writing JS) |
| **Checks (assertions)** | 🟢 Powerful (code) | 🟢 Powerful (code) | ⭐ Powerful (code) and easy (YAML) | ⭐ Powerful (DSL/Code) | 🟡 Requires writing JS |
| **Ease of Creation** | 🟡 Tedious | 🟡 Tedious (Boilerplate) | 🟢 Easy | 🟡 Moderate | ⭐ Easy (GUI) |
| **Reuse** | N/A | 🟡 through functions | 🟢 Good (YAML config, inheritance, variable overloading) | 🟡 through functions | 🟢 Good (Collections/Scripts ... if not too complex) |
| **Cost of Maintenance** | 🟡 Moderate | 🟡 Low (only if API contract changes) | 🟢 Lower (only if API contract changes) | 🟡 Low (only if API contract changes) | 🟢 Lower (only if API contract changes) |
| **Where Tests Live** | Alongside Code | Alongside Code | Alongside Code | Alongside Code | External Tool |
| **Who can write tests?** | 🔴 Devs | 🔴 Devs | 🟡 Devs and QA (YAML) | 🔴 Devs | ⭐ Devs/External (QA, users...) |
| **Who can run tests?** | 🔴 Devs | 🔴 Devs | 🟡 Devs and QA | 🔴 Devs | ⭐ Anybody (users, POs...) |
| **Documentation value** | Poor (Code only) | Poor (Code only) | 🟢 **Good (Readable)** | 🟡 Moderate (DSL) | ⭐ Very good (JSON/GUI) |

</div>

![Alt text describing the image](/../../img/test_pyramid.png "Optional hover title")
