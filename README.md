# kipu-bank
TP Módulo 4

Descripción:
Esta nueva versión del KipuBank opera únicamente con USDC como su activo de reserva. Los usuarios pueden depositar casi cualquier activo (ETH u otros tokens ERC-20), y el contrato los convierte automáticamente a USDC usando Uniswap V2, acreditando el saldo final en la cuenta del usuario.
Las mejoras respecto a la versión anterior incluyen:
- Integración DeFi (Swap Automático): en la versión anterior el banco solo guardaba ETH y ERC20s; y el usuario tenía múltiples balances separados. Ahora el banco intercambia activamente (ETH/ERC20 --> USDC) usando Uniswap V2.
- Contabilidad Simplificada (Solo-USDC): En la versión anterior se requerían mappings anidados para rastrear los balances de cada token (s_tokenBalances) además de un mapping para el valor total en USD (s_totalDepositedUSD). Ahora la contabilidad es mucho más limpia. Solo existe s_balancesUSD, que representa el saldo real y retirable del usuario.
- Depósito Universal: El usuario ya no necesita tener USDC para depositar. Puede depositar el ETH que tiene en su billetera, y el contrato hace la conversión.
- Retiros Simplificados: Los retiros ahora son predecibles y se realizan únicamente en USDC, el activo de reserva del banco.

Respecto a las desiciones de diseño (trade-off): 
Se tomaron varias decisiones de diseño para priorizar la seguridad y la funcionalidad:
- El revert en la función receive (seguridad): En la versión anterior, la función receive() era una forma cómoda de depositar ETH (simplemente enviando fondos al contrato). Ahora, esto se ha deshabilitado a propósito (revert()). Se sacrificó la "conveniencia" del depósito simple por la seguridad absoluta del usuario. La nueva función depositEthAndSwap requiere el parámetro _amountOutMin para proteger al usuario del slippage (deslizamiento de precio) y ataques sándwich. La función receive(), por definición, no puede aceptar parámetros. Si aceptara el ETH, se intercambiaría sin protección ante las fluctuaciones de los precios de los tokens.
- Verificación de Límites ( eficiencia Pre-Swap vs Post-Swap ): El BANK_CAP_USD (límite global) debe respetarse siempre, por lo tanto para depósitos de ETH se usa el oráculo de Chainlink para hacer un "pre-check". Se estimaa el valor antes de gastar gas en el swap. Si la estimación supera el límite, revertimos inmediatamente.
Para depósitos de ERC-20, no se puede tener un oráculo para "cualquier token". Para estos tokens, realizamos un "post-check". El contrato swapea primero, y luego comprueba si el amountReceivedUSD supera el límite. Si lo supera, toda la transacción (incluido el swap) se revierte. Es menos eficiente en gas si falla, pero es la única forma de soportar "cualquier token" de forma segura.
- Uso de approve estándar en _executeSwap (robustez): Aunque SafeERC20 (y safeApprove) es la mejor práctica, el compilador de Remix no lograba vincular la librería estáticamente, por lo tanto se uso el approve estándar de ERC-20 en lugar de safeApprove. Para este particular caso esto es seguro porque  el riesgo de approve (race condition) no aplica aquí. El approve y el pair.swap ocurren dentro de la misma transacción (atómica). El contrato del Par consume la aprobación inmediatamente. Se sigue usando SafeERC20 para safeTransferFrom y safeTransfer, que son más críticos para prevenir errores en tokens no estandar.

DESPLIEGUE EN REMIX
Para desplegar el contrato en el entorno Remix, primero se debe compilar el contrato en la seccion "Solidity Compiler". Luego se debe deployar desde la seccion "Deploy & run transactions", configurando la wallet a utilizar y seteando los parametros de su constructor, correspondiente a la direccion del propietario (owner), la dirección del oráculo de Chainlink, que permite consultar el precio del ETH en USD; la dirección del contrato "Factory" de Uniswap V2 para que el contrato pueda encontrar la dirección del pool de liquidez (el "par") para cualquier swap (ejemplo WETH/USDC), la dirección del contrato del token USDC para que el contrato sepa cuál es su activo de reserva y para medir el resultado de los swaps y para procesar los retiros; y la dirección del contrato del token WETH (Wrapped ETH), lo cual es un paso necesario para el swap de ETH. El contrato toma el ETH, lo "envuelve" en WETH, y luego intercambia ese WETH por USDC. Por último, luego del deploy, se obtiene la direccion del contrato y se puede interactuar con el mismo.

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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
