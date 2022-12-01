---
export_on_save:
    puppeteer: ["pdf"]
puppeteer:
    height: "2.8in"
    pageRanges: "1"
---

```puml
@startuml

component (1)  #Yellow
component (3)  #Yellow
component (5)  #Yellow
component (7)  #Yellow
component (9)  #Yellow
component (10)  #Yellow
component (11)  #Yellow
component (12)  #Yellow

(7) -> (1) : 1    
(2) -> (8) : 2    
(8) -> (4) : 3    
(3) -> (7) : 4    
(11) -> (12) : 5  
(9) -> (10) : 6   
(4) -> (5) : 7    
(12) -> (9) : 8   
(1) -> (3) : 9    
(10) -> (11) : 10  
(6) -down-> (7) : 11    
(0)

@enduml
```