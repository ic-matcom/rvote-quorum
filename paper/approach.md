---
header-includes: |
    \usepackage{caption}
    \usepackage{subcaption}
    \usepackage[spanish]{babel}
title: "Primer Enfoque a la Implementación de un Sistema de Votación Representativa sobre Quorum"
author: Andy Ledesma Garc&iacute;a
---

# El problema
La manera en la que el banco decide el otorgamiento de préstamos y el valor del interés a cobrar, es mediante una subasta. Durante este proceso se realiza una elección representativa. En una elección representativa, una persona puede transferir los votos depositados en ella, mediante la emisión de un voto, esto es, si una persona `A` vota por una persona `B` y esta, a su vez, vota por  `C`, entonces el voto de `A` se transfiere a `C`. Además, cada individuo puede votar por a lo sumo otra persona. 

La figura \ref{fig:r-voting} ilustra un ejemplo de votación en el que `A` votó por `B`, `B` y `E` votaron por `C` y `C` votó por `D`. `B` obtiene solamente el voto de `A`, mientras que `C` obtiene los votos de `A`, `B` y `E`. `D` recibe el voto directo de `C` y, con este,  los votos indirectos de los restantes participantes.

![Conteo de votos en votación representativa.\label{fig:r-voting}](rsrcs/rep-voting.pdf)

<!-- @todo qué hacer cuan2 tol mun2 se abstiene? -->

En un proceso electoral de este tipo pueden surgir ciclos de votación, como el que se muestra en la figura \ref{fig:voting-cycle}, donde el voto emitido por `D` hacia `B` forma un ciclo que los involucra a ambos y a `C`.

![Ciclo de votación.\label{fig:voting-cycle}](rsrcs/voting-cycle.pdf)

El presente trabajo de diploma\footnote{El tratamiento de este documento como si fuera el trabajo de diploma se hace con toda intención, ya que se pretende que lo que aquí se dice se encuentre plasmado en el documento de tesis.} tiene como objetivo principal darle respuesta a las interrogantes:

- ¿cómo contar los votos de personas involucradas en un ciclo?
- ¿cómo determinar el ganador cuando hay más de una persona con la mayor cantidad de votos?

teniendo en cuenta que las respuestas serán empleadas en una implementación en *Consensys Quorum*\footnote{Se asume que previamente se explicó lo que es \textit{Consensys Quorum}.} del sistema electoral representativo descrito anteriormente.

## La relación *votar*
Para entender mejor el voto representativo, a continuación se define formalmente la relación *votar* en un sistema de ese tipo, además de mencionar y argumentar el cumplimiento o no de algunas características por parte de la relación. 

Sea $f \in D \times D$ una relación, donde $D$ es el conjunto de los participantes en el proceso electoral, de manera tal que

$$
\langle x, y \rangle \in f \; \Leftrightarrow \; x \text{ votó por } y. 
$$

La figura \ref{fig:voting-relation} representa gráficamente a la relación cuando $f = \{ \langle x, y \rangle, \langle y, z \rangle, \langle z, y \rangle \}$ y $D = \{ w, x, y, z \}$. 

![Representación gráfica de la relación *votar* para $f = \{ \langle x, y \rangle, \langle y, z \rangle, \langle z, y \rangle \}$ y $D = \{ w, x, y, z \}$.\label{fig:voting-relation}](rsrcs/voting-relation.pdf)

$f$ posee las siguientes características:

- **función:** a lo sumo un voto puede ser emitido por una persona. 
- **no es función total:** una persona $w$ puede abstenerse de votar. 
- **no inyectiva:** dos personas $x$ y $z$ ($x \neq z$) pueden votar por la misma persona $y$.
- **no sobreyectiva:** puede existir una persona $x$ por la que nadie vote. 
- **irreflexiva:** una persona no puede votar por ella misma.
- **no simétrica:** una persona $x$ puede votar por $y$, sin ser necesario que $y$ vote por $x$.
- **no asimétrica:** $y$ puede votar por $z$ si $z$ vota por $y$.

## Digrafo de votación
Se pueden modelar los votos emitidos mediante un digrafo $G   = \langle D, f \rangle$, esto es, un grafo dirigido donde los vértices sean los participantes del proceso electoral y los vínculos entre los vértices estén determinados por la relación *votar*. Es exactamente esto lo que se representa en la figura \ref{fig:voting-relation}. $G$ posee dos propiedades relevantes:

1. $out(v) \leq 1, \forall v \in D$, ya que $f$ es función. \label{prop:out-deg-1} <!-- @audit mira a ver si out es la notación correcta pa grado d salida -->
2. **si $v$ es un vértice de un ciclo $c$, entonces $\langle v, f(v) \rangle$ es un arco de $c$**. Esto se debe   a que si $v$ pertenece a un ciclo, entonces $out(v) \geq 1$, y por la propiedad \ref{prop:out-deg-1} se cumple que $out(v) = 1$. Luego, $v \in Dom(f)$ y el arco $\langle v, f(v) \rangle$ es el único arco de salida de $v$ y, por ende, pertenece a $c$. \label{prop:v-fv-cycle}

# Implementación
A continuación se presenta una implementación en *Python* de las funcionalidades principales que debe proveer un sistema electrónico de votación representativa. Los votantes son tratados como números enteros en el rango $[0, |D| - 1]$, de manera tal que a cada votante se le asocia un entero único a modo de identificador. En un arreglo global `vote`, inicializado con todos sus valores en $-1$, se registra el voto de cada participante, tal que al culminar la votación se cumpla que 

$$
\texttt{vote[x]} = \begin{cases}
   f(x) & \text{si } x \in Dom(f) \\
   -1 & \text{en otro caso}
\end{cases}.
$$ 

En un arreglo global `indeg0`, inicializado con todos sus valores en `True`, se marcan como `False` a  aquellos participantes por los que han votado al menos una vez, de manera tal que al culminar la votación se cumpla que $\texttt{indeg0[x]} = \texttt{True} \Leftrightarrow in(x) > 0$. 

Para registrar un voto emitido por `x` para `y`, se propone la función `make_vote()`, la cual realiza las modificaciones pertinentes en los arreglos `indeg0` y `vote`.

~~~{.python .numberLines}
def make_vote(x, y):
    indeg0[y] = False
    vote[x] = y
~~~

Para contar los votos una vez haya culminado el proceso de votación, se propone la función `count_votes()`. Esta se encarga de ejecutar un BFS sobre aquellos vértices con grado de entrada mayor que 0. La búsqueda calcula correctamente los votos recibidos por los participantes accesibles en el grafo, ya que para calcular los votos asociados a un vértice $y$, basta con tener calculados los votos de todo vértice $x$, tal que $\langle x, y \rangle \in f$; y BFS garantiza que $x$ se visite antes que $y$. Luego de esos primeros recorridos, pueden quedar sin visitar algunos vértices, a saber, aquellos que se encuentran en ciclos no accesibles desde algún vértice con grado de entrada igual a 0. Esos vértices son visitados  en el ciclo de las líneas 9-11. En el arreglo `count` se almacena la cantidad de votos obtenidos por cada participante.

~~~{.python .numberLines}
def count_votes():
    starters = [x for x in range(n) if indeg0[x]]
    color = [WHITE] * n
    count = [0] * n

    if starters:
        bfs(starters, color, count)

    for v in range(n):
        if not color[v]:  
            bfs([v], color, count)

    return count
~~~

La implementación de BFS empleada acepta un conjunto de vértices iniciales. El algoritmo los pinta de gris y los añade a la cola. Se pudiera lograr el mismo recorrido si en lugar de lo anterior, se añadiera un vértice ficticio con arcos salientes a cada uno de los vértices dados y se ejecutara el algoritmo original de BFS. Este último enfoque no se adoptó porque implica violar la propiedad \ref{prop:out-deg-1} del digrafo. El enfoque empleado se muestra a continuación en la función `bfs()`. 

~~~{.python .numberLines}
def bfs(starters, color, count):
    queue = starters[:]
    for u in queue:
        color[u] = GRAY

    for u in queue:
        v = vote[u]
        if v != -1:
            if not color[v]:
                color[v] = GRAY
                count[v] += count[u] + 1
                queue.append(v)
            elif color[v] == GRAY:
                count[v] += count[u] + 1
            elif color[v] == BLACK:
                cycle_found(v, count)
        
        color[u] = BLACK
~~~

Como sólo puede existir un arco saliente de $u$, entonces basta con chequear en la línea 8 si $\texttt{vote[u]} \neq -1$ para saber si tal arco existe. Si $v$ es blanco o gris, entonces se actualiza su número de votos. Si $v$ es negro, entonces se ha detectado un ciclo y se llama a la función `cycle_found()`.

La función `cycle_found()` se encarga de obtener todos los vértices del ciclo al que pertenece un vértice $u$, luego, invoca a la función `notify_cycle()` para que le asigne un valor al `count` de cada uno de los vértices del ciclo. De la propiedad \ref{prop:v-fv-cycle} del digrafo de votación se deduce que el ciclo encontrado es $\langle u, f(u), f^2(u), ..., f^k(u), u \rangle$ con $k \geq 1$. En esto se basa `cycle_found()` para obtener todos los vértices del ciclo.

~~~{.python .numberLines}
def cycle_found(u, count):
    cycle = [u]
    v = vote[u]
    while v != u:
        cycle.append(v)
        v = vote[v]

    notify_cycle(cycle, count)
~~~

En el caso de los vértices pertenecientes a un ciclo, se propone asignarles la mayor cantidad de votos obtenidos por alguno de ellos al realizar el BFS. Es precisamente esa la implementación de `notify_cycle()`.

~~~{.python .numberLines}
def notify_cycle(cycle, count):
    m = max((count[u] for u in cycle))
    for u in cycle:
        count[u] = m
~~~

La idea está basada en el pensamiento intuitivo de que como todos los participantes de un ciclo confían dos a dos entre ellos, sea directa o indirectamente, entonces a todos se les debe asignar la misma cantidad de votos y resulta justo que esa cantidad sea la mayor obtenida por alguno de ellos.

## Consideraciones
Entre algunos aspectos a señalar de la implementación están:

- se permite la abstención. 
- no se calculan los resultados hasta el fin de la votación. Esta característica es conocida como **justeza**. La implementación no considera modificaciones en el grafo luego del conteo.

## Pendientes
Queda pendiente:

- ¿cómo decidir ganador cuando hay más de una persona con la mayor cantidad de votos?
- escoger entre *Hyperledger Besu* o *GoQuorum* para la implementación.
