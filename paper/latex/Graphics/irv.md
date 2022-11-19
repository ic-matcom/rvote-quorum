---
puppeteer:
    height: "4.4in"
    width: "3in"
    pageRanges: "1"
---

```puml
@startuml
start

repeat
    :contar primeras opciones de los votantes;

    if (algún candidato ""x"" tiene más del 50%?) then (sí)
        :reportar a ""x"" como ganador;
        stop
    endif

    ->no;

    :eliminar candidato con menos votos;
    :desplazar rankings;


@enduml
```