---
title: "ConsenSys Quorum"
author: Andy Ledesma Garc&iacute;a
bibliography: bib/raw.bib
urlcolor: blue
header-includes: |
    \usepackage{caption}
    \usepackage{subcaption}
    \usepackage[spanish]{babel}
---

# ¿Qué es?
*ConsenSys Quorum* es un conjunto de protocolos de código abierto que posibilitan a las empresas  emplear Ethereum para sus aplicaciones *blockchain*, ya sean públicas o privadas. 

Consiste en dos proyectos. El primero de ellos es la unión de *Hyperledger Besu*, *Orion* y *EthSigner*: 

- **Hyperledger Besu:** cliente código abierto de Ethereum, compatible con la red principal y basado en Java.
- **Orion:** administrador de transacciones privadas para Hyperledger Besu. Escrito en Java.
- **EthSigner:** firmante de transacciones de Ethereum, escrito en Java. Es capaz de almacenar y administrar llaves privadas, así como validar transacciones.

El otro proyecto es la unión de *GoQuorum*, *Tessera* y *EthSigner*:

- **GoQuorum:** cliente código abierto de Ethereum, basado en Go.
- **Tessera:** administrador de transacciones privadas para GoQuorum. Escrito en Java.

# ¿Por qué Hacerlo en Quorum?
TO DO
<!-- @todo escoger uno d los 2 proyectos. explikr xq lo cogit -->

# Trabajos Relacionados  
Banco Santander, S.A. y Broadridge Financial Solutions, Inc. realizaron  en 2018 una votación de inversores en la reunión general anual (AGM, por sus siglas en inglés) de Santander. En este tipo de votaciones se suele emplear el voto por delegación (*proxy voting* en inglés), en el cual un inversor designa a otra persona para que vote en su lugar. 

Mientras la AGM se estaba realizando, se registraba todo el proceso en la *blockchain* de una plataforma Quorum. 

Los inversores pudieron observar cómo gracias a Quorum sus votos eran contados y confirmados inmediatamente. Téngase en cuenta que un conteo manual puede tardar hasta dos semanas [@broadridge].

# Referencias