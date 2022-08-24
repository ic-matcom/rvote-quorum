---
title: Estado del Arte del E-voting
author: Andy Ledesma Garc&iacute;a
bibliography: bib/raw.bib
urlcolor: blue
---

# Elecciones
Un sistema electoral o de votación es un conjunto de reglas que dictan cómo debe comportarse una elección y cómo son determinados sus resultados. Entre los aspectos que las reglas deciden están:

- cuándo ocurren las elecciones,
- a quién se le permite votar,
- quién puede ser un candidato,
- cómo las boletas son marcadas y emitidas,
- cómo los votos influyen en los resultados, y
- los límites de los gastos de las campañas.

Las elecciones tradicionales o basadas en papel son ampliamente utilizadas alrededor del mundo para la toma de decisiones. Su empleo destaca en el ámbito político, garantizando durante décadas la preservación de la democracia en muchos países. Sin embargo, este tipo de elecciones puede presentar diversos problemas que causan desconfianza en el electorado. Entre ellos se destacan: [@trustworthy_blockchain]

(@fraude-pre) **fraude pre-electoral:** un ejemplo de ello es cuando intencionalmente se manipulan las listas de candidatos para ocultar a ciertos partidos. Se han detectado también ilegalidades a la hora de confeccionar los distritos de votación, colocando el centro electoral en un  lugar tan distante que los votantes prefieren no ir a votar.
(@) **votos falsos:** en muchos centros electorales no existe una verificación biométrica de la identidad del votante, lo cual permite con relativa facilidad emitir votos en nombre de personas que no han votado. 
(@) **abuso de poder:** las recompensas y las amenazas son empleadas por personas con poder, con el objetivo de coaccionar al votante   para que elija una opción específica.
(@unsupervised-counting) **conteo de votos sin supervisión:** cuando el conteo no es supervisado adecuadamente, es muy probable que no sean contados los votos de algunos partidos.
(@) **falta de auditorías y apelaciones:** las apelaciones y solicitudes de auditorías son procesos tan lentos que difícilmente suceden antes de las elecciones siguientes. Los candidatos afectados suelen entonces llamar a su electorado a protestar y causar disturbios, lo cual provoca inestabilidad política.   

Todas estas situaciones, y otras que se pueden dar en una elección convencional, crean descontento y desconfianza entre los votantes.   

Un sistema de votación electrónico es capaz de  minimizar o solucionar algunos de los problemas mencionados anteriormente. En un sistema *online*, por ejemplo,  no es necesaria la presencia del votante en un lugar específico. Luego, la distancia del votante al centro electoral deja de ser relevante, porque cualquier dispositivo con conexión a Internet es un "centro electoral" y puede estar fácilmente al alcance del elector. Esto minimiza el problema (@fraude-pre). 

Diversas formas de verificación biométrica pueden ser logradas mediante elecciones electrónicas. La verificación de la huella digital y el escáner ocular son ejemplos de ello. 

Mediante un sistema electrónico se pueden contar los votos de manera eficiente mientras se van realizando y se  pueden publicar en vivo los resultados. Esto mitiga el problema (@unsupervised-counting).

Otras bondades poseen los sistemas electrónicos, como son la flexibilidad, lo fácil que pueden ser de usar y lo baratos que son con respecto a los sistemas tradicionales. Sin embargo, muchos de los sistemas electrónicos existentes son centralizados, esto es, dependen de que una agencia central se encargue de registrar, manejar, calcular y revisar los votos. Toda la confianza debe entonces ser depositada en esa agencia, lo cual hace vulnerable al sistema.

Un sistema descentralizado de votación resuelve ese problema. Entre las tecnologías descentralizadas más empleadas actualmente se encuentra *blockchain*. <!--@todo explikr lo q es blockchain --> Existen algunos sistemas de votación electrónicos que emplean *blockchain*, como es *Agora* [@agora],  y muchas propuestas como son   *Open Vote Network* [@ovn] y la de @borda_count. Para poder comparar cada una de esas propuestas, a continuación se muestran los tipos de sistemas electorales que existen y los requisitos que debe cumplir todo sistema de votación electrónico. 

## Tipos

### Sistemas de Pluralidad
Son sistemas donde gana el candidato con el mayor número de votos. En caso de que solo se esté eligiendo un puesto, se conocen como *votación de pluralidad de un solo miembro* (SMP, por sus siglas en inglés) o *first-past-the-post* (FPTP o FPP, por sus siglas en inglés). Si en cambio, se eligen varios puestos, un sistema de pluralidad se conoce como *votación en bloque*, *voto múltiple no transferible* o *pluralidad a gran escala* ("plurality-at-large" en inglés). La votación en bloque puede adoptar dos formas, en dependencia de si se puede votar por miembros de cualquier partido o no.

### Sistemas Mayoritarios
En estos sistemas es necesario que un candidato alcance la mayoría de votos (un determinado porcentaje de los votos) para obtener la victoria. Si esto no sucede, entonces se decide el ganador mediante un *ranking* o en posteriores rondas de votación.

En los sistemas de *ranking*, los electores deben otorgarle un puesto a cada candidato (primero, segundo, tercero, etc.). En las siguientes imágenes 
<!-- En las figuras \ref{fig:rank-oval}, \ref{fig:rank-names} y \ref{fig:rank-nums} -->
extraídas de [Wikipedia](https://en.wikipedia.org/wiki/Ranked_voting) <!--@audit no c si c puede poner el enlace asi' o si hay q ponerlo en las refs--> se muestran ejemplos de boletas de estos sistemas.

![Boleta para votación por *ranking* empleando óvalos. \label{fig:rank-oval}](rsrcs/rank-ballot-oval.gif){ width=33% }
![Boleta para votación por *ranking* empleando nombres. \label{fig:rank-names}](rsrcs/rank-ballot-names.gif){ width=33% }
![Boleta para votación por *ranking* empleando números. \label{fig:rank-nums}](rsrcs/rank-ballot-numbers.png){ width=33% }

<!-- @audit no salen las imgs en li'nea con sus captions, asi' q no c ven las referencias-->

Para determinar el ganador, se utilizan métodos como el *desempate instantáneo* (IRV, por "instant-runoff voting" en inglés) o la *votación contingente*. 

En IRV se cuentan los votos de la primera elección de cada votante. Si un candidato posee más de la mitad de  los votos, entonces gana la elección. En otro caso, se elimina al candidato con menos votos y se le aumenta un voto a la siguiente opción disponible de todos aquellos que hayan elegido al candidato eliminado en primera opción. Esto último puede ser visto como que en toda boleta donde el $i$-ésimo candidato sea el eliminado, el *ranking* se desplaza, esto es, el $(i+1)$-ésimo pasa a ser el $i$-ésimo, el $(i+2)$-ésimo pasa a ser el $(i+1)$-ésimo, etcétera. El proceso continúa hasta que algún candidato obtenga más de la mitad de los votos. 

La figura \ref{fig:irv} muestra el diagrama de flujo de IRV.

![Diagrama de flujo del método de desempate instantáneo. \label{fig:irv}](rsrcs/irv.pdf){ width=80% }

El método de  votación contingente es similar a IRV, pero posee a lo sumo dos rondas de conteo. En la primera ronda se cuentan los votos de las primeras opciones de todos los votantes. Si algún candidato obtiene más del 50% de los votos, se declara ganador. En otro caso, se eliminan todos los candidatos excepto los dos que más votos tienen en el conteo. Si una primera opción ha sido eliminada de una boleta, entonces los votos de ese votante pasan al candidato disponible (solo hay dos) que más arriba se encuentre en el *ranking* de esa boleta.

En la figura \ref{fig:conting} se muestra el diagrama de flujo del método de votación contingente.

![Diagrama de flujo del método de votación contingente. \label{fig:conting}](rsrcs/conting.pdf){ width=60% }

A pesar  de lo eficiente que puede resultar emplear un sistema de *ranking*, en la mayoría de los sistemas electorales mayoritarios se realiza una segunda ronda de votación cuando ningún candidato obtuvo el porcentaje acordado en la primera ronda.

Cuando a lo sumo se realizan dos rondas de votación, se conoce como *sistema de dos rondas* (TRS, por "two-round system" en inglés). A la segunda ronda pasan los dos candidatos con más votos y el ganador se decide como en un sistema de pluralidad. Las rondas son independientes una de otras, o sea, un elector pudo haber votado por el candidato $A$ en la primera ronda y luego haber votado por $B$ en la segunda, aún cuando $A$ haya pasado a la segunda ronda también.

Existen sistemas donde en cada ronda se elimina al candidato con menos votos y se realizan rondas hasta que solo quede un candidato, el cual se proclama vencedor. A estos se le conocen como *sistemas exhaustivos*. 

### Representación Proporcional
En los *sistemas de representación proporcional* (conocidos como PR) varios candidatos se proclaman ganadores. La proporción del poder de cada candidato vencedor es igual a la proporción de los votos que el candidato obtuvo. Por ejemplo, si los partidos $A_1$, $A_2$, ..., $A_n$ se están disputando los $N$ puestos de un parlamento, entonces

$$
{v(A_i) \over V} = {s(A_i) \over N}, \quad i = 1, 2, ..., n
$$

donde $v(A_i)$ es la cantidad de votos obtenidos por el partido $A_i$, $V$ es el total de votos y $s(A_i)$ es la cantidad de puestos del partido $A_i$ en el parlamento.

En la variante *party list PR*, cada partido coloca a sus candidatos en orden en una lista y los  "puestos" se asignan respetando ese orden. Si el orden de los candidatos en los partidos es decidido por los propios votantes, entonces se dice que la lista es *abierta*. En otro caso, si el orden es decidido a lo interno del partido, se dice que la lista es *cerrada*. 

Existe otra variante llamada *voto único transferible* (STV, por sus siglas en Inglés). Es un sistema de *ranking* donde los electores votan por candidatos de cualquier partido. El voto de un elector se le asigna a la primera opción de su lista. 

En cada ronda se elimina al candidato con menos votos, pero los votos asociados a ese candidato no se pierden: si un elector depositó su voto en ese candidato entonces el voto se transfiere al próximo candidato en su lista que no se ha eliminado. Si no existe un próximo candidato, entonces el voto desaparece. 

Antes de comenzar el proceso, se designa una *cuota*. Cuando los votos de un candidato sean mayores o iguales que dicha cuota, entonces se considera elegido y los votos sobrantes (el excedente) se distribuyen de manera similar a cuando se elimina un candidato, con la diferencia de que los votos que no se pueden distribuir no desaparecen. Si   los votos que se pueden transferir superan al excedente, entonces se debe considerar un método que permita distribuir el excedente  proporcionalmente.

El proceso termina cuando los $N$ asientos han sido ocupados por candidatos elegidos o cuando la cantidad de asientos libres iguala al número de candidatos todavía en disputa, en cuyo caso se declaran electos a esos candidatos.

Con una cuota justa, mientras más grande sea $N$, más proporcional será la distribución de los $N$ asientos en un STV.<!--@audit justifica o pon ref--> Las cuotas de [Hare](https://en.wikipedia.org/wiki/Hare_quota) y de [Droop](https://en.wikipedia.org/wiki/Droop_quota) <!--@audit enlaces a wikipedia, eso creo q es malo--> son las más usadas. 

###  Sistemas Mixtos
La *votación paralela* es un ejemplo de sistema mixto. En él se eligen una parte de los asientos mediante un método de votación y la otra parte, empleando otro método; por ejemplo, FPTP para una parte y *party-list PR* para la otra. Ambas votaciones se pueden realizar en paralelo porque no deben estar conectadas en ningún sentido.

Otro sistema mixto es el *mixed-member proportional representation*, en el cual cada elector emite dos votos: uno por un candidato para que represente a su distrito electoral y otro por un partido para que lo represente al nivel más alto. Los puestos son asignados primero a los ganadores de cada distrito y luego a los miembros de los partidos, de manera proporcional con respecto a la cantidad de votos. De esta forma, se ejecutan dos tipos de votaciones: una donde gana un solo candidato (generalmente una votación de pluralidad) y otra donde se utiliza un método de representación proporcional.

En un sistema de *voto único mixto* (MSV) también se vota por un candidato para el distrito y por un partido para un nivel más alto, pero cada elector sólo emite un voto. Dicho voto va primeramente para el candidato que el votante desea que lo represente a nivel de distrito. Si ese voto es "malgastado", esto es, el voto pertenece a un candidato que pierde o forma parte del excedente de un candidato que gana, entonces el voto va para un partido afiliado a ese candidato. Un sistema MSV está compuesto entonces por un sistema de representación proporcional que se alimenta (sus votos provienen) de un sistema de pluralidad o mayoritario. Los puestos son asignados como en los *mixed-member PR*.


<!--@remind gui'at x [sensors](sensors-21-05874-v4.pdf). Ahi' tambie'n c habla d las ventajas d hacerlo con blockchain y eso. Ahi' hay una pila d cosas, es el lugar q tienes q mirar ahora -->


## Requisitos 
En la siguiente sección se muestran los requisitos principales  que debe cumplir todo sistema de votación electrónico. Adicionalmente, se presentan otros requisitos opcionales que contribuyen a aumentar la calidad del sistema [@wang2017review].

### Principales 
- Correctitud: los votos deben ser contados correctamente. Para ello, dos propiedades deben satisfacerse:
    - totalidad: todos los votos v&aacute;lidos deben ser contados.
    -  robustez: los votos no autorizados o inv&aacute;lidos no deben ser contados.
    
- Privacidad: no se conoce la decisi&oacute;n del votante.
- Prevenci&oacute;n del doble voto.
- Elegibilidad: solo los votantes autorizados pueden votar.
- Robustez: poder lidiar con una cierta cantidad de comportamientos incorrectos por parte de los votantes o con una falla parcial del sistema (un sistema distribuido resiste mejor este tipo de fallas). 
- Verificabilidad: alguien puede verificar que un voto haya sido contado. La verificabilidad puede ser de tres tipos: 
    - individual: el propio votante puede verificarlo.
    - universal: todos pueden verificar que el resultado final sea correcto.
    - E2E (*end-to-end*): al votante se le entrega un recibo que demuestra que votó, pero no indica cuál fue su decisión. <!--@audit agora es e2e-verificable sin embargo no entrega recibo-->
- Usabilidad

### Adicionales
- Justeza: no se calculan los resultados hasta el fin de la votaci&oacute;n.
- Incoercibilidad: evitar la coerción (e.g. votación en cadena o *chain voting* [@chain-voting]).
- Eficiencia: el sistema debe responder con rapidez ante una gran cantidad de votantes y elecciones.
- Movilidad: se puede votar desde dispositivos móviles.
- *Vote-and-Go:* que se pueda votar *offline* una vez la boleta haya sido emitida.
- Verificabilidad Universal.
- Verificabilidad de extremo a extremo (E2E).
<!-- @todo ver tambie'n estos arti'culos
https://www.mdpi.com/2073-8994/12/8/1328
https://ieeexplore.ieee.org/abstract/document/8405627
https://ieeexplore.ieee.org/abstract/document/8457919
http://ijair.id/index.php/ijair/article/view/173
 -->

# Agora
Agora es un sistema de votación basado en *blockchain* desarrollado por la compañía homónima con sede en Suiza. Está destinado a gobiernos e instituciones [@agora].

En él se pueden realizar elecciones mayoritarias y STV.

<!-- arquitectura skipchain desarollada x ellos mismos. el bulletin board es como le llaman a su blockchain y la info d ahi' esta' atada a la blockchain d btc a trave's de la capa Cotena -->

Las boletas se encriptan con el umbral de ElGamal [@elgamal-threshold] <!--@todo ta denso lo q dice ese paper, verifica si esta' bien--> para garantizar la **privacidad**. Ni siquiera Agora tiene acceso a la información del usuario, mucho menos al contenido de la boleta. Cuando terminan las votaciones, todas las boletas se pasan por una **red de mezcla** (*mixing network*) para hacerlas anónimas, al punto de que es despreciable la probabilidad de que alguien sepa qué votante emitió un voto particular. Al votante no se le entrega un recibo, por lo que no  puede probarle a un tercero cuál fue su elección [@agora].

Agora no posee un mecanismo propio para autenticar los votos, en cambio, depende de que los administradores de la red seleccionen un sistema de manejo de identidades. <!--@note esto es eligibilidad-->

Debido a su transparencia, cualquiera puede detectar errores en el sistema. Agora los reporta a los auditores y los almacena en el propio sistema. Cuando los auditores <!--@audit seri'a bueno decir kie'nes son los auditores-->resuelven el conflicto publican el resultado en el boletín [@agora]. Por otro lado, no existe un solo punto de fallas. Todo esto contribuye a la  **robustez** del sistema. 

Agora posee **verificabilidad individual**, ya que el votante puede verificar que su boleta encriptada refleja su intención de voto, mediante una validación *cast-or-challenge* [@agora]. Los votantes también pueden  verificar que su voto ha sido registrado correctamente (*collected-as-cast validation*). El sistema también posee **verificabilidad universal** y de **extremo a extremo**, mediante la aplicación Audit. Una vez  se descarga la información del *bulletin board*\footnote{Así Agora llama a su \textit{blockchain}.}, se puede inspeccionar la elección totalmente **offline**. Un dispositivo no necesita muchos recursos para validar.

Con respecto a la **usabilidad**: cualquier votante sin conocimientos técnicos puede emitir y verificar un voto.

Además de poder votar desde una PC o una máquina de votación, también se puede votar desde un dispositivo móvil.








<!-- los logs c mandan a la blockchain d btc. Estos logs son snapshots del bulletin board -->


# Referencias
