/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {
  /**
   * @notice Get configuration relevant for making requests
   * @return minimumRequestConfirmations global min for request confirmations
   * @return maxGasLimit global max for request gas limit
   * @return s_provingKeyHashes list of registered key hashes
   */
  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );

  /**
   * @notice Request a set of random words.
   * @param keyHash - Corresponds to a particular oracle job which uses
   * that key for generating the VRF proof. Different keyHash's have different gas price
   * ceilings, so you can select a specific one to bound your maximum per request cost.
   * @param subId  - The ID of the VRF subscription. Must be funded
   * with the minimum subscription balance required for the selected keyHash.
   * @param minimumRequestConfirmations - How many blocks you'd like the
   * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
   * for why you may want to request more. The acceptable range is
   * [minimumRequestBlockConfirmations, 200].
   * @param callbackGasLimit - How much gas you'd like to receive in your
   * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
   * may be slightly less than this amount because of gas used calling the function
   * (argument decoding etc.), so you may need to request slightly more than you expect
   * to have inside fulfillRandomWords. The acceptable range is
   * [0, maxGasLimit]
   * @param numWords - The number of uint256 random values you'd like to receive
   * in your fulfillRandomWords callback. Note these numbers are expanded in a
   * secure way by the VRFCoordinator from a single random value supplied by the oracle.
   * @return requestId - A unique identifier of the request. Can be used to match
   * a request to a response in fulfillRandomWords.
   */
  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);

  /**
   * @notice Create a VRF subscription.
   * @return subId - A unique subscription id.
   * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
   * @dev Note to fund the subscription, use transferAndCall. For example
   * @dev  LINKTOKEN.transferAndCall(
   * @dev    address(COORDINATOR),
   * @dev    amount,
   * @dev    abi.encode(subId));
   */
  function createSubscription() external returns (uint64 subId);

  /**
   * @notice Get a VRF subscription.
   * @param subId - ID of the subscription
   * @return balance - LINK balance of the subscription in juels.
   * @return reqCount - number of requests for this subscription, determines fee tier.
   * @return owner - owner of the subscription.
   * @return consumers - list of consumer address which are able to use this subscription.
   */
  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @param newOwner - proposed new owner of the subscription
   */
  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @dev will revert if original owner of subId has
   * not requested that msg.sender become the new owner.
   */
  function acceptSubscriptionOwnerTransfer(uint64 subId) external;

  /**
   * @notice Add a consumer to a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - New consumer which can use the subscription
   */
  function addConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Remove a consumer from a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - Consumer to remove from the subscription
   */
  function removeConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Cancel a subscription
   * @param subId - ID of the subscription
   * @param to - Where to send the remaining LINK to
   */
  function cancelSubscription(uint64 subId, address to) external;
}

pragma solidity ^0.8.4;

/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness. It ensures 2 things:
 * @dev 1. The fulfillment came from the VRFCoordinator
 * @dev 2. The consumer contract implements fulfillRandomWords.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constructor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash). Create subscription, fund it
 * @dev and your consumer contract as a consumer of it (see VRFCoordinatorInterface
 * @dev subscription management functions).
 * @dev Call requestRandomWords(keyHash, subId, minimumRequestConfirmations,
 * @dev callbackGasLimit, numWords),
 * @dev see (VRFCoordinatorInterface for a description of the arguments).
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomWords method.
 *
 * @dev The randomness argument to fulfillRandomWords is a set of random words
 * @dev generated from your requestId and the blockHash of the request.
 *
 * @dev If your contract could have concurrent requests open, you can use the
 * @dev requestId returned from requestRandomWords to track which response is associated
 * @dev with which randomness request.
 * @dev See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ.
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request. It is for this reason that
 * @dev that you can signal to an oracle you'd like them to wait longer before
 * @dev responding to the request (however this is not enforced in the contract
 * @dev and so remains effective only in the case of unmodified oracle software).
 */
abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   */
  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBaseV2 expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomWords the VRF output expanded to the requested number of words
   */
  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
  }
}

pragma solidity ^0.8.0;

interface KeeperCompatibleInterface {
  /**
   * @notice method that is simulated by the keepers to see if any work actually
   * needs to be performed. This method does does not actually need to be
   * executable, and since it is only ever simulated it can consume lots of gas.
   * @dev To ensure that it is never called, you may want to add the
   * cannotExecute modifier from KeeperBase to your implementation of this
   * method.
   * @param checkData specified in the upkeep registration so it is always the
   * same for a registered upkeep. This can easily be broken down into specific
   * arguments using `abi.decode`, so multiple upkeeps can be registered on the
   * same contract and easily differentiated by the contract.
   * @return upkeepNeeded boolean to indicate whether the keeper should call
   * performUpkeep or not.
   * @return performData bytes that the keeper should call performUpkeep with, if
   * upkeep is needed. If you would like to encode data to decode later, try
   * `abi.encode`.
   */
  function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);

  /**
   * @notice method that is actually executed by the keepers, via the registry.
   * The data returned by the checkUpkeep simulation will be passed into
   * this method to actually be executed.
   * @dev The input to this method should not be trusted, and the caller of the
   * method should not even be restricted to any single registry. Anyone should
   * be able call it, and the input should be validated, there is no guarantee
   * that the data passed in is the performData returned from checkUpkeep. This
   * could happen due to malicious keepers, racing keepers, or simply a state
   * change while the performUpkeep transaction is waiting for confirmation.
   * Always validate the data passed in.
   * @param performData is the data which was passed back from the checkData
   * simulation. If it is encoded, it can easily be decoded into other types by
   * calling `abi.decode`. This data should not be trusted, and should be
   * validated against the contract's current state.
   */
  function performUpkeep(bytes calldata performData) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
error Donaciones__UpkeepNoNecesario(uint256 donadoActual, uint256 numDonadores, uint256 donacionesEstado);
error Donaciones__NecesarioDonarMas();
error Donaciones__DonacionesEstaPremiando();
error Donaciones__PagoFallido();

/* @titulo Donaciones con Premio tipo sorteo
    @autor MrCryptoDK
    @notice Este contrato es para recibir Donaciones de una manera descentralizada y autonoma
    @dev Esto implementa tecnologia de Chainlink VRFv2 y Chainlink Keepers
*/

contract Donaciones is VRFConsumerBaseV2, KeeperCompatibleInterface {
    /* Tipos de estados del contrato Donaciones*/
    enum DonacionesEstado {
        ABIERTO,
        PREMIANDO
    }
    /* Variables y constantes de estado */
    // Chainlink VRF Variables
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint64 private immutable i_subscriptionId;
    bytes32 private immutable i_gasLane;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant NUM_CONFIRMACIONES = 3;
    uint32 private constant NUM_ALE = 1;

    // Donaciones Variables
    uint256 private immutable i_intervalo;
    uint256 private s_ultimoTimeStamp;
    address private s_ultimoGanador;
    uint256 private s_donacionesId;
    uint256 private s_totalDonaciones;
    uint256 private s_totalDonado;
    uint256 private s_totalToken;
    uint256 private s_totalPremios;
    uint256 private immutable i_donacionMinima;
    address payable[] private s_donadores;
    DonacionesEstado private s_donacionesEstado;
    address private immutable i_caridad;
    address private immutable i_token;
    mapping(address => uint256) private s_donadorCantidadDonada;
    mapping(uint256 => address payable) private s_listaGanadores;

    /* Eventos */
    event SeleccionandoGanador(uint256 indexed nuevoId);
    event NuevaDonacion(address indexed donador);
    event PremioEntregado(address indexed donador);

    /* Funciones */
    constructor(
        address vrfCoordinatorV2,
        address caridad,
        address token,
        uint64 subscriptionId,
        bytes32 gasLane,
        uint256 intervalo,
        uint256 donacionMinima,
        uint32 callbackGasLimit,
        uint256 donacionesId
    ) VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane;
        i_intervalo = intervalo;
        i_subscriptionId = subscriptionId;
        i_donacionMinima = donacionMinima;
        s_donacionesEstado = DonacionesEstado.ABIERTO;
        s_ultimoTimeStamp = block.timestamp;
        s_donacionesId = donacionesId;
        s_totalDonaciones = 0;
        s_totalDonado = 0;
        s_totalToken = 0;
        s_totalPremios = 0;
        i_callbackGasLimit = callbackGasLimit;
        i_caridad = caridad;
        i_token = token;
    }

    receive() external payable {
        donacion();
    }

    fallback() external payable {
        donacion();
    }

    function donacion() public payable {
        if (msg.value < i_donacionMinima) {
            revert Donaciones__NecesarioDonarMas();
        }
        if (s_donacionesEstado != DonacionesEstado.ABIERTO) {
            revert Donaciones__DonacionesEstaPremiando();
        }
        s_totalDonaciones++;
        s_donadorCantidadDonada[msg.sender] += msg.value;
        s_donadores.push(payable(msg.sender));
        emit NuevaDonacion(msg.sender);
    }

    // Escoger el ganador del premio de manera automatica con Chainlink
    // Se genera un ganador realmente aleatorio VRF v2
    // 1. Keepers sera verdadero despues de un intervalo de tiempo
    // 2. El contrato de Donaciones tiene que estar abierto
    // 3. El contrato tiene que tener fondos
    // Esta es la funcion que realiza el chequeo automatico y llaman los nodos de Chainlink cuando se cumple las condiciones
    // En este caso el premio se debe ejecutar cada semana automaticamente
    function checkUpkeep(
        bytes memory /* checkData */
    )
        public
        view
        override
        returns (
            bool upkeepNeeded,
            bytes memory /* performData */
        )
    {
        bool donacionesAbierto = DonacionesEstado.ABIERTO == s_donacionesEstado;
        bool tiempoActual = ((block.timestamp - s_ultimoTimeStamp) > i_intervalo);
        bool hayDonadores = s_donadores.length > 3;
        bool hayFondos = address(this).balance > 0;
        upkeepNeeded = (tiempoActual && donacionesAbierto && hayFondos && hayDonadores);
    }

    function performUpkeep(
        bytes calldata /* performData */
    ) external override {
        (bool upkeepNeeded, ) = checkUpkeep("");
        if (!upkeepNeeded) {
            revert Donaciones__UpkeepNoNecesario(
                address(this).balance,
                s_donadores.length,
                uint256(s_donacionesEstado)
            );
        }
        s_donacionesEstado = DonacionesEstado.PREMIANDO;
        uint256 nuevoId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            NUM_CONFIRMACIONES,
            i_callbackGasLimit,
            NUM_ALE
        );
        emit SeleccionandoGanador(nuevoId);
    }

    /**
     * Esta es la funcion donde Chainlink VRFv2
     * Genera el pago automatico al ganador aleatorio.
     */
    function fulfillRandomWords(
        uint256, /* nuevoId */
        uint256[] memory numerosAle
    ) internal override {
        uint256 ganador = numerosAle[0] % s_donadores.length;
        s_listaGanadores[s_donacionesId - 14000000001] = s_donadores[ganador];
        s_donacionesId++;
        s_totalPremios += ((address(this).balance * 5) / 100);
        s_totalDonado += (((address(this).balance - s_totalPremios) * 90) / 100);
        s_totalToken += (((address(this).balance - s_totalPremios) * 10) / 100);
        address payable nuevoGanador = s_donadores[ganador];
        s_ultimoGanador = nuevoGanador;
        s_donadores = new address payable[](0);
        s_donacionesEstado = DonacionesEstado.ABIERTO;
        s_ultimoTimeStamp = block.timestamp;
        (bool success, ) = nuevoGanador.call{value: (address(this).balance * 5) / 100}("");
        if (!success) {
            revert Donaciones__PagoFallido();
        }
        payable(i_caridad).transfer((address(this).balance * 90) / 100);
        payable(i_token).transfer(address(this).balance);
        emit PremioEntregado(nuevoGanador);
    }

    /** Funciones view y pure para ver datos */

    function ganadorDelPremio(uint256 premioNum) public view returns (address payable) {
        return s_listaGanadores[premioNum];
    }

    function verCantidadDonada(address direccionDonador) public view returns (uint256) {
        return s_donadorCantidadDonada[direccionDonador];
    }

    function verEstadoDonaciones() public view returns (DonacionesEstado) {
        return s_donacionesEstado;
    }

    function ultimoGanador() public view returns (address) {
        return s_ultimoGanador;
    }

    function verDonador(uint256 numDonador) public view returns (address) {
        return s_donadores[numDonador];
    }

    function listaDonadores() public view returns (address payable[] memory) {
        return s_donadores;
    }

    function verTimeStamp() public view returns (uint256) {
        return s_ultimoTimeStamp;
    }

    function verIntervalo() public view returns (uint256) {
        return i_intervalo;
    }

    function verDonacionMinima() public view returns (uint256) {
        return i_donacionMinima;
    }

    function donadoresActuales() public view returns (uint256) {
        return s_donadores.length;
    }

    function verDonadoActual() public view returns (uint256) {
        return address(this).balance;
    }

    function verDonacionesId() public view returns (uint256) {
        return s_donacionesId;
    }

    function totalDonaciones() public view returns (uint256) {
        return s_totalDonaciones;
    }

    function totalDonado() public view returns (uint256) {
        return s_totalDonado;
    }

    function totalRepartido() public view returns (uint256) {
        return s_totalPremios;
    }

    function totalToken() public view returns (uint256) {
        return s_totalToken;
    }

    function verCaridad() public view returns (address) {
        return i_caridad;
    }
}