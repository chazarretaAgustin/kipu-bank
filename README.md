# kipu-bank
TP Módulo 3

IMPORTANTE:

Se hizo un cambio de último momento en las funciones para depositar por lo cual se recompiló y deployo el contrato, y se volvió a verificar. La dirección del contrato verificado NO es la que esta en el campus, sino la que esta en el documento de texto en la carpeta Modulo 3 (el documento se llama Modulo 3.txt).
Address: [0xD96192607d3EDDAb64bC8Ff1f587b39C771F2Fa3]

DESCRIPCIÓN:
Este contrato es una mejora de la versión anterior de KipuBank. Implementa un sistema bancario descentralizado con soporte para múltiples tokens, contabilidad interna estandarizada en USD, y oráculos de Chainlink. Esta segunda version del kipubank implementa, entre otras cosas, soporte multi-token, contabilidad estandarizada, uso del patron checks-effects-interactions, uso de librerias seguras como SafeERC20 de OpenZeppelin para transferencias seguras de tokens, control de acceso, manejo de eventos y errores, etc. Respecto al soporte multitoken, se utilizó la interfaz IERC20 y la librería SafeERC20, lo cual permite interactuar con tokens fungibles (intercambiables) bajo el estándar ERC-20. Respecto a la contabilidad interna, se utilizaron 6 decimales para establecer un valor unificado entre el ETH, cuyo precio fluctúa y tiene 18 decimales, y los diferentes tokens, los cuales son estables. 

DESPLIEGUE EN REMIX
Para desplegar el contrato en el entorno Remix, primero se debe compilar el contrato en la seccion "Solidity Compiler". Luego se debe deployar desde la seccion "Deploy & run transactions", configurando la wallet a utilizar y seteando los parametros de su constructor, correspondiente a la direccion del propietario (owner), y la dirección del oráculo de Chainlink ETH/USD Data Feed, que permite consultar el precio del ETH en USD. Por último, luego del deploy, se obtiene la direccion del contrato y se puede interactuar con el mismo.

ACLARACIONES:

En esta segunda versión del kipu-bank, se incluyen correcciones respecto a la versión anterior. Se modificó el estilo de desarrollo, el cual ahora se encuentra en inglés tanto en variables y funciones como en documentacion, a fin de seguir los estándares del ecosistema. Se incluyó el uso de funciones especiales como receive y fallback. Respecto a los modificadores, en esta versión solo se usaron en aquellas validaciones/verificaciones que son comunes a varias funciones, dejando las verificaciones/validaciones específicas de una función, en la propia función.


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
TP Modulo 2

DESCRIPCIÓN DEL CONTRATO
Este contrato simula ser un banco donde los usuarios pueden depositar y retirar ether de sus cuentas. KipuBank realiza validaciones sobre las cantidades a depositar y/o retirar, notifica al realizar exitosamente un deposito y/o retiro de ether, lleva registro de la cantidad de depositos y retiros realizados y gestiona errores de manera personalizada. Además cuenta con limitaciones en la cantidad de ether que el contrato puede almacenar y la cantidad de ether que un usuario puede retirar.

DESPLIEGUE EN REMIX
Para desplegar el contrato en el entorno Remix, primero se debe compilar el contrato en la seccion "Solidity Compiler". Luego se debe deployar desde la seccion "Deploy & run transactions", configurando la wallet a utilizar y seteando los parametros de su constructor, correspondiente al limite de depositos global y el limite de retiro. Por último, luego del deploy, se obtiene la direccion del contrato y se puede interactuar con el mismo.

INTERACCIÓN
Para interactuar con el contrato se debe contar con la direccion del mismo y se debe especificar la cantidad de ether a depositar y/o retirar.
