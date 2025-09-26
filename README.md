# kipu-bank
TP Modulo 2

DESCRIPCIÓN DEL CONTRATO
Este contrato simula ser un banco donde los usuarios pueden depositar y retirar ether de sus cuentas. KipuBank realiza validaciones sobre las cantidades a depositar y/o retirar, notifica al realizar exitosamente un deposito y/o retiro de ether, lleva registro de la cantidad de depositos y retiros realizados y gestiona errores de manera personalizada. Además cuenta con limitaciones en la cantidad de ether que el contrato puede almacenar y la cantidad de ether que un usuario puede retirar.

DESPLIEGUE EN REMIX
Para desplegar el contrato en el entorno Remix, primero se debe compilar el contrato en la seccion "Solidity Compiler". Luego se debe deployar desde la seccion "Deploy & run transactions", configurando la wallet a utilizar y seteando los parametros de su constructor, correspondiente al limite de depositos global y el limite de retiro. Por último, luego del deploy, se obtiene la direccion del contrato y se puede interactuar con el mismo.

INTERACCIÓN
Para interactuar con el contrato se debe contar con la direccion del mismo y se debe especificar la cantidad de ether a depositar y/o retirar.
