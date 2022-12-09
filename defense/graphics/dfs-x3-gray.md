---
export_on_save:
    puppeteer: ["pdf"]
puppeteer:
    width: "4in"
    height: "2.9in"
    pageRanges: "1"
---

```puml
@startuml
skinparam actorStyle awesome

skinparam usecase {
    ArrowColor green
}

:x1: <.u. :y:
:x2: <.u. :y:
:x3: <.u. :y:
:x4: <.u. :y:

component :y: #Gray
component :x1: #Black
component :x2: #Black
component :x3: #Gray
component :x4: #White

@enduml
```