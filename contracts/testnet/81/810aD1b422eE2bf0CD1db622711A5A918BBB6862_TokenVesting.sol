// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

//import "./SafeERC20.sol";
//import "./Ownable.sol";
//import "./SafeMath.sol";

/**
 * @title TokenVesting
 * @dev A token holders contract that can release its token balance gradually like a
 * typical vesting scheme for several users, with a cliff and vesting period. Optionally revocable by the
 * owner.
 */

contract TokenVesting is Ownable, ReentrancyGuard, Pausable {
    // The vesting schedule is time-based (i.e. using block timestamps as opposed to e.g. block numbers), and is
    // therefore sensitive to timestamp manipulation (which is something miners can do, to a certain degree). Therefore,
    // it is recommended to avoid using short time durations (less than a minute). Typical vesting schemes, with a
    // cliff period of a year and a duration of four years, are safe to use.
    // solhint-disable not-rely-on-time

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 private TokenSmartContract; // Address of the token used in Vesting

    // ESTO LUEGO DEBERIA SER EL BALANCE, TEnemos que decidir que preferimos
    // SI LO USAMOS, podemos dejar dos variables seguidas, facil para comprobar si el balance es suficiente para esto
    // O podemos poner una función que calcule si el balance restante , es suficiente para cubrir el total de tokens que ya están asignados==????
    //uint256 public totalTokensAvailableToAssign = 1000000000;
    uint256 public totalTokensAvailableToAssign;

    // ESTO NO SE ESTA ASIGNANDO EN NINGÚN SITIO, he de arreglarlo

    uint256 public totalTokensAssigned; // Suma de Tokens totales asignados a todas las wallets

    uint256 public tokensRestantes; // Total de Tokens restantes que pueden asignarse a wallets

    uint256 private fechaInicioClaimFinal;

    //uint256 public frequency = 4; // Cantidad de Claims que tendrá el vesting  ------ Esta por ahora no se usa, en principio la frecuencia va a ser por wallet para que sea indpenendiente
    uint256 public frequency; // Cantidad de Claims que tendrá el vesting  ------ Esta por ahora no se usa, en principio la frecuencia va a ser por wallet para que sea indpenendiente

    address public tokenAddress; // Address of Token´s Smart Contract

    /* Mappings */
    mapping(address => uint256) public balanceBeneficiary; // Balance de los tokens asignados a la persona
    mapping(address => uint256) public totalTokensClaim; // Total de tokens disponibles para el próximo claim de una wallet
    //mapping(address => uint256) public firstClaimDate; // Fecha en que se realiza el primer claim de los 4 que hay
    mapping(address => uint256) public cooldownTimePerWallet; // Tiempo de cooldown que va a tener el claim. Desde el momento actual para cada User hasta el siguiente claim

    //REALMENTE ES EL MISMO QUE EL ANTERIOR, NO NECESITO 2
    //mapping(address => uint256) public timeBetweenClaims; // Tiempo entre cada uno de los 4 claims

    mapping(address => uint256) public nextClaimDate; // Fecha en la que el usuario podrá hacer su próximo claim.

    // estas podrían ser fijas en vez de un mapping.
    // ejemplo, que sean siempre 4 claims. Que haya una diferencia de 1 semana entre cada claim y que sean 4 en total

    //mapping(address => uint256) public frequencyOfClaims; // Cantidad de Claims que tendrá el vesting por usuario, no se si aplicarlo

    /* Eventos */
    event Claim(address wallet, uint256 cantidad);
    event Asignar(address wallet, uint256 cantidad);

    event TokensReleased(address token, uint256 amount);
    event TokenVestingRevoked(address token);

    /*
     * Contract Address BBCN en testnet: 0xa92Ff8Be97d9946C52cb341B8e048e6Ed8f986eD
     */

    constructor(
        address _tokenAddress // Address of Token´s Smart Contract
    ) public {
        tokenAddress = _tokenAddress; // Asignamos Address del token
        TokenSmartContract = IERC20(address(tokenAddress)); // Instanciamos el Smart Contract del Token

        //Aquí asignamos el total de tokens para asignar una vez que se contruye el contrato
        totalTokensAvailableToAssign = 1000000000 * 10**18;

        //Aquí asignamos el la frecuencia que se tendrá en cuenta en el claim
        frequency = 4;
    }

    // Funciones

    /**
     * @notice Función que permite cambiar la fecha del próximo Claim de una Wallet
     */
    function setWalletVestingTime(uint256 _nextClaimDate, address userWallet)
        public
        onlyOwner
    {
        nextClaimDate[userWallet] = _nextClaimDate;
    }

    function setTokenVestingContract(address _tokenAddress) public onlyOwner {
        // Cambiar el token usado en el Vesting
        tokenAddress = _tokenAddress;

        TokenSmartContract = IERC20(address(tokenAddress)); // Instanciamos el Smart Contract del Token
    }

    /**
     * @notice Función que permite cambiar la cantidad de tokens para hacer la asignación total
     */
    function setTotalTokensToAssign(uint256 _totalTokensAvailableToAssign)
        public
        onlyOwner
    {
        totalTokensAvailableToAssign = _totalTokensAvailableToAssign;
    }

    /**
     * @notice Función que permite cambiar la frecuencia del claim
     */
    function setFrequency(uint256 _frequency) public onlyOwner {
        frequency = _frequency;
    }

    /**
     * @notice Función que permite cambiar la fecha Claim en que se activará la posibilidad de hacer Claim
     * Para desactivar el claim temporalmente, debemos poner una fecha futura
     */
    function setFechaInicioClaimFinal(uint256 _fechaInicioClaimFinal)
        public
        onlyOwner
    {
        fechaInicioClaimFinal = _fechaInicioClaimFinal;
    }

    /*
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */

    /**
     * @notice Función que permite conocer el balance de los Tokens Bbcn que hay dentro del contrato.
     */
    function balanceBbcnDelContrato() public view returns (uint256) {
        return TokenSmartContract.balanceOf(address(this));
    }

    //COMO ES UNA FUNCIÓN QUE APARECE EN READ---- cuando estás en read, no estás conectado, con lo que el msg.sender, no sabe quién es
    //Debería de quitarla o sirve para usarse desde el front-end?
    /**
     * @notice Función que permite conocer la cantidad de tokens Bbcn asignados a la wallet conectada
     */
    function cantidadTokensAsignadosPorWallet() public view returns (uint256) {
        return balanceBeneficiary[msg.sender];
    }

    /**
     * @notice Función que permite al dueño del contrato hacer el withdraw de todos los Tokens Bbcn que hay dentro del mismo.
     */
    function withdrawAllTokensBbcnFromContract() public onlyOwner {
        uint256 _bbcnAmount = balanceBbcnDelContrato();
        require(_bbcnAmount > 0, "There is not enough liquidity");
        TokenSmartContract.transfer(owner(), _bbcnAmount);
    }

    /*
     * @notice Función que activa el cooldown para poder hacer el claim. Asigna a nextClaimDate, la próxima fecha de claim que será la actual más el tiempo: _cooldownTimePerWallet
     * @param _investorWallet Dirección del inversor.
     * @param _cooldownTimePerWallet Time to stop between claims, per Wallet.
     */
    function _triggerCooldown(address _investorWallet)
        internal
    // uint256 _cooldownTimePerWallet
    {
        // nextClaimDate[_investorWallet] =
        //     block.timestamp +
        //     cooldownTimePerWallet[_investorWallet];

        // PROBAR QUE ASIGNE EL CLAIMDATE TIENIENDO EN CUENTA EL PRIMER CLAIMDATE
        nextClaimDate[_investorWallet] =
            nextClaimDate[_investorWallet] +
            cooldownTimePerWallet[_investorWallet];
    }

    //// Data for the arrays in function assignTokensToWallet():

    //// cantidadesBBCNAAsignar:

    //[40,50]

    //// Wallets:

    //[0x7aB5342586b13C0BC600158cFf12d883BDDe012a,0x7771147211076883ad1C479a5b56EeF959103621]

    //// _firstClaimDates:

    //[1664575200,1664575200]

    //// _cooldownTimePerWallets:

    //[7889229,7889229]

    //(esta sería la fecha de arranque, la primera vez que la persona hace claim, desde este claim, habrá 3 claims más (4 en total).
    //Conversor:
    // https://www.epochconverter.com/
    // https://www.unixtimestamp.com/index.php
    // frequency: 45 minutes

    /*
     * @notice Función que asigna un número de tokens determinado a una wallet concreta, guardando la fecha de cuando podrán reclamarse los tokens por primera vez y el tiempo a esperar entre cada claim.
     * @param cantidadBBCNAAsignar Cantidad de Bbcn que se asignaran.
     * @param walletUsuario Wallet del usuario al que se asignan.
     * @param _firstClaimDate Primera fecha de Claim. Se pasa en formato UNIX.
     */

    function assignTokensToWallet(
        uint256[] calldata cantidadesBBCNAAsignar, // Cantidad de tokens que se le asignarán a una wallet
        address[] calldata walletsUsuarios, // Wallet en que se asignarán los tokens
        uint256[] calldata _firstClaimDates, // Fecha en que se realizará el primer Claim (UNIX TIMESTAMP)
        uint256[] calldata _cooldownTimePerWallets // Tiempo que transcurrirá entre Claims (UNIX TIMESTAMP)
    ) external onlyOwner nonReentrant {
        uint256 actualdate = block.timestamp;

        address walletUsuario;
        uint256 cantidadBBCNAAsignar;
        uint256 _firstClaimDate;
        uint256 _cooldownTimePerWallet;
        uint256 balanceBeneficiary18;

        // ESTO ESTA MAL. SI MANDO MAS TOKENS NO LO TENDRA EN CUENTA
        // HAY QUE HACER EL CALCULO DE totalTokensAssigned en el momento en que se use
        //uint256 tokensRestantes = balanceBbcnDelContrato() - totalTokensAssigned;

        //HAY UN CASO QUE PUEDE TENER PROBLEMAS
        // en el caso de que el admin extraiga tokens del contrato y dejen de haber suficientes para asignar

        // ASI SABEMOS EL TOTAL DE TOKENS RESTANTES QUE HAY DISPONIBLES PARA ASIGNAR
        tokensRestantes = totalTokensAvailableToAssign - totalTokensAssigned;

        // AQUI ESTABAN LOS REQUIRE, HABRIA QUE METERLOS EN EL FOR

        for (uint256 i; i < walletsUsuarios.length; ++i) {
            // Como las siguientes variables se reutilizan, las asigno para no tener que recorrer el array
            walletUsuario = walletsUsuarios[i];
            cantidadBBCNAAsignar = cantidadesBBCNAAsignar[i];
            _firstClaimDate = _firstClaimDates[i];
            _cooldownTimePerWallet = _cooldownTimePerWallets[i];

            // ESTE REQUIRE es para ver si quedan tokens para asignar, pero PARA CALCULARLO BIEN, DEBEMOS SUMAR EL TOTAL EN EL FOR O QUITAR ESTE REQUIRE
            require(
                tokensRestantes > cantidadBBCNAAsignar,
                "Not enough tokens left to assign"
            );

            //DECIDIR CUAL DE LAS DOS SIGUIENTES USAMOS

            //require(cantidadBBCNAAsignar > 0, "We need a quantity to assign");
            require(cantidadBBCNAAsignar >= 0, "We need a quantity to assign");

            require(
                _cooldownTimePerWallet > 0,
                "We need the time for Cooldown between Claims"
            );

            // //La fecha de fin de vesting debe estar en el futuro
            require(
                _firstClaimDate > actualdate,
                "Ending Date needs to be in the future"
            );

            // Asignamos el primer tiempo de claim en la variable de nextClaimDate
            nextClaimDate[walletUsuario] = _firstClaimDate;

            // Asignamos el nuevo tiempo de Cooldown (tiempo entre claims)
            cooldownTimePerWallet[walletUsuario] = _cooldownTimePerWallet;

            //Asignamos la nueva cantidad de tokens
            balanceBeneficiary[walletUsuario] += cantidadBBCNAAsignar;

            // Para no tener que tocar el front-end
            // Convierto balanceBeneficiary[walletUsuario] en base 18, luego lo divido por la frecuencia
            // Y finalmente lo vuelvo a convertir en base 10
            balanceBeneficiary18 = balanceBeneficiary[walletUsuario] * 10**18;

            totalTokensClaim[walletUsuario] = balanceBeneficiary18 / frequency;

            // totalTokensClaim[walletUsuario] = totalTokensClaim[walletUsuario] / 10**18;

            //BORRAR DESPUES DE ACTIVAR EL ANTERIOR
            // totalTokensClaim[walletUsuario] = balanceBeneficiary[walletUsuario];

            // Asi sabemos la cantidad de tokens asignados hasta ahora a las distintas Wallets
            totalTokensAssigned += cantidadBBCNAAsignar;

            // ASI SABEMOS EL TOTAL DE TOKENS RESTANTES QUE HAY DISPONIBLES PARA ASIGNAR
            tokensRestantes =
                totalTokensAvailableToAssign -
                totalTokensAssigned;
        }
    }

    /*
     * @notice Función que elimina la asignación de tokens de una wallet concreta.
     */

    function cancelVesting(
        address walletUsuario // Wallet en que se asignarán los tokens
    ) external onlyOwner nonReentrant {
        tokensRestantes = tokensRestantes + balanceBeneficiary[walletUsuario];
        totalTokensAssigned =
            totalTokensAssigned -
            balanceBeneficiary[walletUsuario];

        balanceBeneficiary[walletUsuario] = 0;
        nextClaimDate[walletUsuario] = 0;
        cooldownTimePerWallet[walletUsuario] = 0;
        totalTokensClaim[walletUsuario] = 0;
    }

    /*
     * @notice Función que analiza si el claim está activado.
     */
    function claimActivo() public view returns (bool) {
        return block.timestamp >= fechaInicioClaimFinal;
    }

    /*
     * @notice Función que reclama los tokens correspondientes a la wallet que lanza la llamada.
     */
    function claim(
        //uint256[] calldata fechasClaim,
        // uint256 fechaClaim,
        // uint256 tokensFromOneClaim,
        // uint256 tokensLiberados
    ) external nonReentrant {

        uint256 fechaClaim;
        uint256 tokensFromOneClaim;
        uint256 tokensLiberados;

        uint256 balanceBeneficiary18;
        address _investor = msg.sender;

        // Para no tener que tocar el front-end
        // Convierto balanceBeneficiary[walletUsuario] en base 18, luego lo divido por la frecuencia
        // Y finalmente lo vuelvo a convertir en base 10
        balanceBeneficiary18 = balanceBeneficiary[_investor] * 10**18;

        tokensFromOneClaim = balanceBeneficiary18 / frequency;

        // AQUI ME ESTOY CARGANDO LOS DECIMALES -- HACE EL REDONDEO PORQUE QUE TE LO CARGAS
        //tokensFromOneClaim = tokensFromOneClaim / 10**18;

        // Esto se podría quitar, la asignación, me refiero.
        // Se puede usar para hacer el primer require, y así no se entra en el for, y luego ya entramos en el for y si hay más reasignamos
        uint256 tokensToClaim = totalTokensClaim[_investor];

        require(claimActivo(), "Claim not enabled");

        require(
            balanceBeneficiary[_investor] > 0,
            "You have no tokens to claim"
        );

        // Si la cantidad de tokens para reclamar es inferior a los disponibles en el contrato no permitirá reclarmar tokens
        //require(TokenSmartContract.balanceOf(address(this)) >= balanceBeneficiary[_investor], 'There is not enough liquidity');
        require(
            TokenSmartContract.balanceOf(address(this)) >= tokensToClaim,
            "There is not enough liquidity"
        );
        // nextClaimDate te devuelve la fecha siguiente en la que el usuario puede reclamar tokens
        // Si la fecha de claim es posterior a la fecha de bloque podrá pasar el require
        require(
            nextClaimDate[_investor] <= block.timestamp,
            "Claim not possible yet."
        ); // Comprueba fechas

        fechaClaim = nextClaimDate[_investor];

        for (uint256 i; i < (frequency); ++i) {
            // Asigno la siguiente fecha de claim a la variable
            //fechaClaim = nextClaimDate[_investor] + cooldownTimePerWallet[_investor];

            // POR AHORA, Para ahorrarme el else, lo que hago es que en el 0, me lo asigna y reasigna, esto debería pasarlo a limpio
            //if (i== 0) fechaClaim = nextClaimDate[_investor];

            if (i != 0) fechaClaim += cooldownTimePerWallet[_investor];

            // Añado los tokens (1/4 en principio) cada vez que da una vuelta
            if (fechaClaim >= block.timestamp)
                tokensLiberados += tokensFromOneClaim;
        }

        require(tokensLiberados > 0, "There are no tokens to claim.");

        // POR AHORA LO HAGO ASí, convierto tokensToClaim y le asigno el resultado que viene del for
        tokensToClaim = tokensLiberados;

        //Llamada al transfer para enviar la cantidad de tokens correspondiente a la wallet que nos ocupa
        TokenSmartContract.transfer(_investor, tokensToClaim);

        //Se restan los tokens reclamados
        balanceBeneficiary[_investor] -= tokensToClaim;

        // Asi sabemos la cantidad de tokens asignados hasta ahora a las distintas Wallets, restando los que cogen del claim
        totalTokensAssigned -= tokensToClaim;

        // Ponemos a cero nextClaimDate cuando se han claimeado todos
        // ESTO HEMOS decidido quitarlo para que la gráfica no falle en el front, porque esta variable se usa en varios sitios
        // if (totalTokensAssigned== 0) nextClaimDate[_investor] = 0;

        // Ponemos a cero totalTokensClaim cuando se han claimeado todos
        // ESTO HEMOS decidido quitarlo para que la gráfica no falle en el front, porque esta variable se usa en varios sitios
        // if (totalTokensAssigned== 0) totalTokensClaim[_investor] = 0;

        _triggerCooldown(_investor); // Se vuelve a inicializar el cooldown.

        //REVISAR ESTA EMISION DE EVENTO
        emit Claim(msg.sender, tokensToClaim);
    }

    function isOwner() private view {
        require(msg.sender == owner(), "You don't have access");
    }

    function pause() public {
        isOwner();
        if (!paused()) _pause();
    }

    function unpause() public {
        isOwner();
        if (paused()) _unpause();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}