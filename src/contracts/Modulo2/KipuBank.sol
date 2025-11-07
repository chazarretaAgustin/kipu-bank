// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title KipuBank
 * @author Chazarreta Agustin
 * @notice TP Modulo 2
 */

contract KipuBank {
    /* ///// Variables ///// */

    ///@notice map para vincular cada usuario con su ETH depositado
    mapping(address => uint256) private usuarios;

    ///@notice Limite global de deposito en ETH
    uint256 public immutable bankCap;

    ///@notice cantidad total de ETH acumulado en el contrato
    uint256 private ethTotAcum;

    ///@notice Limite de ETH que un usuario puede retirar
    uint256 public immutable limiteRetiro;

    ///@notice Contador de depositor realizados
    uint256 public cantDepositos;

    ///@notice Contador de retiros realizados
    uint256 public cantRetiros;

    /* ///// Eventos ///// */

    ///@notice evento que ocurre cuando se realiza un deposito
    event DepositoRealizado();

    ///@notice evento que ocurre cuando se realiza un retiro
    event RetiroRealizado();

    /* ///// Errores ///// */

    ///@notice error por superar el limite global de depositos
    error LimiteDepositoGlobalSuperado();

    ///@notice error por depositar o retirar unac antidad menor o igual a cero
    error CantidadCero();

    ///@notice error por superar el limite de retiro
    error LimiteRetiroSuperado();

    ///@notice error por intentar retirar mas ETH del disponible
    error SaldoInsuficiente();

    /**
     * @notice error por falla en el retiro de ETH
     * @param error error personalizado
     */
    error RetiroFallido(bytes error);

    /*///// Modificadores /////*/

    /**
     * @notice modificador para verificar que la cantidad a depositar o retirar sea mayor a cero. Se ejecuta antes de la funcion que la llama
     * @param _cant cantidad a retirar o depositar
     */
    modifier cantidadCero(uint256 _cant) {
        if (_cant <= 0) {
            revert CantidadCero();
        }
        _;
    }
    
    /**
     * @notice modificador para verificar que el deposito a realizar mas lo acumulado, no supere el limite global
     * @param _cant cantidad a depositar
     */
    modifier limiteSuperado(uint256 _cant) {
        if (ethTotAcum + _cant > bankCap) {
            revert LimiteDepositoGlobalSuperado();
        }
        _;
    }

    /**
     * @notice modificador para verificar que la cantidad a retirar no supere el limite de retiro
     * @param _cant a retirar
     */
    modifier limite_retiro(uint256 _cant) {
        if (_cant > limiteRetiro) {
            revert LimiteRetiroSuperado();
        }
        _;
    }

    /**
     * @notice modificador para verificar que la cantidad a retirar no supere al saldo disponible
     * @param _cant cantidad a retirar
     */
    modifier SinSaldo(uint256 _cant) {
        if (_cant > usuarios[msg.sender]) {
            revert SaldoInsuficiente();
        }
        _;
    }

    /* ///// Funciones ///// */

    /**
     * @notice constructor
     * @param _bankCap limite global de depositos
     * @param _limiteRetiro monto limite de retiro
     */
    constructor(uint256 _bankCap, uint256 _limiteRetiro) {
        bankCap = _bankCap;
        limiteRetiro = _limiteRetiro;
    }

    /**
     * @notice funcion para depositar
     * @param _cant cantidad a depositar
     */
    function Depositar(uint256 _cant) external payable cantidadCero(_cant) limiteSuperado(_cant) {
        //Actualizo
        usuarios[msg.sender] += _cant;
        ethTotAcum += _cant;
        cantDepositos++;

        //Disparo evento al realizar el deposito
        emit DepositoRealizado();
    }

    /**
     * @notice funcion que verifica que el retiro se realice con exito. Private por lo que no es accesible desde afuera del contrato
     * @param _cant cantidad a retirar
     */
    function EfectuarRetiro(uint256 _cant) private {
        (bool ok, bytes memory error) = msg.sender.call{value: _cant}("");
        if (!ok) {
            revert RetiroFallido(error);
        }
    }

    /**
     * @notice funcion para retirar ETH
     * @param _cant cantidad a retirar
     */
    function Retirar(uint256 _cant) external cantidadCero(_cant) limite_retiro(_cant) SinSaldo(_cant) {
        //Actualizo
        usuarios[msg.sender] -= _cant;
        ethTotAcum -= _cant;
        cantRetiros++;

        EfectuarRetiro(_cant);
        
        //Disparo evento al realizar el retiro
        emit RetiroRealizado();
    }

    ///@notice funcion external view que devuelve el saldo del usuario que la llama
    function getSaldo() external view returns (uint256) {
        return usuarios[msg.sender];
    }
}
