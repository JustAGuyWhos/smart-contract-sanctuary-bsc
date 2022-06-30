// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT WHICH USES HARDCODED VALUES FOR CLARITY.
 * PLEASE DO NOT USE THIS CODE IN PRODUCTION.
 */

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
 */

/**
 * Skin Raririties id
6257c3e3d0dee4fedbc2db44- name : "Normal"
6257c3f4d0dee4fedbc2db46- name : "Rare",
6257c40cd0dee4fedbc2db48- "name" : "Mythic",
6257c420d0dee4fedbc2db4a-name : "Legendary",

 * hero rarities
6257bbb7b278b3e677e5ceff-"name" : "Common",
6257bd06b278b3e677e5cf01-"name" : "Rare",
6257bdd2b278b3e677e5cf03-"name" : "Epic",
6257be00b278b3e677e5cf05-"name" : "Legendary",

 * weapon rarity
6257ccd3f3d0559f9803f1e5-“name" : "Legendary",
6257cc78f3d0559f9803f1e1 -“name" : "Rare",
6257ccc4f3d0559f9803f1e3-“name" : "Epic",
1)“62bc1e2d84e4117a2d29b440” 
    "name" : "Rare",

2. “62bc1e4284e4117a2d29b442”
    "name" : "Epic", 

3) “62bc1e5e84e4117a2d29b444"
    "name" : "Legendary", 
 */

contract RandomNumberConsumer1 is VRFConsumerBase {
    bytes32 internal keyHash;
    uint256 internal fee;

    uint256 public randomTokenId;
    uint8 internal commonBoxHeroProbability;
    uint8 internal rareBoxHeroProbability;
    uint8 internal epicBoxHeroProbability;
    uint8 internal legendaryBoxHeroProbability;
    uint8 internal weaponBoxRarityDrop;

    //common box
    uint16 internal commonBoxCommonHeroSkinRarity;
    uint16 internal commonBoxRareHeroSkinRarity;

    //rare box
    uint16 internal rareBoxCommonHeroSkinRarity;
    uint16 internal rareBoxRareHeroSkinRarity;
    uint16 internal rareBoxEpicHeroSkinRarity;

    //epic box
    uint16 internal epicBoxCommonHeroSkinRarity;
    uint16 internal epicBoxRareHeroSkinRarity;
    uint16 internal epicBoxEpicHeroSkinRarity;
    uint16 internal epicBoxLegendarySkinRarity;

    //legendary box
    uint16 internal legendaryBoxRareSkinRarity;
    uint16 internal legendaryBoxEpicSkinRarity;
    uint16 internal legendaryBoxLegendarySkinRarity;

    address public admin;

    /**
     * Constructor inherits VRFConsumerBase
     *
     * Network: Kovan
     * Chainlink VRF Coordinator address: 0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9
     * LINK token address:                0xa36085F69e2889c224210F603D836748e7dC0088
     * Key Hash: 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4
     *
     * Network: BSC testnet
     * Chainlink VRF Coordinator address: 0xa555fC018435bef5A13C6c6870a9d4C11DEC329C
     * LINK token address:                0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06
     * Key Hash: 0xcaf3c3727e033261d383b315559476f48034c13b18f8cafed4d871abe5049186
     *
     * Links
     * https://docs.chain.link/docs/get-a-random-number/v1/
     * https://docs.chain.link/docs/vrf-contracts/v1/
     */
    constructor()
        VRFConsumerBase(
            0xa555fC018435bef5A13C6c6870a9d4C11DEC329C, // VRF Coordinator
            0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06 // LINK Token
        )
    {
        keyHash = 0xcaf3c3727e033261d383b315559476f48034c13b18f8cafed4d871abe5049186;
        fee = 0.1 * 10**18; // 0.1 LINK (Varies by network)
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can access this");
        _;
    }

    function updateAdmin(address _admin) public onlyAdmin {
        admin = _admin;
    }

    /**
     * Requests randomness
     */
    function getRandomNumber() public onlyAdmin returns (bytes32 requestId) {
        require(
            LINK.balanceOf(address(this)) >= fee,
            "Not enough LINK - fill contract with faucet"
        );
        return requestRandomness(keyHash, fee);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        internal
        override
    {
        randomTokenId = (randomness % 1000000000000000);
        commonBoxHeroProbability = uint8(randomness % 2);
        rareBoxHeroProbability = uint8(randomness % 3);
        epicBoxHeroProbability = uint8(randomness % 4);
        legendaryBoxHeroProbability = uint8(randomness % 3) + 1;
        weaponBoxRarityDrop = uint8(randomness % 100);

        //common box
        commonBoxCommonHeroSkinRarity = uint16(randomness % 9310);
        commonBoxRareHeroSkinRarity = uint16(randomness % 690);

        //rare box
        rareBoxCommonHeroSkinRarity = uint16(randomness % 1005);
        rareBoxRareHeroSkinRarity = uint16(randomness % 8910);
        rareBoxEpicHeroSkinRarity = uint16(randomness % 85);

        //epic box
        epicBoxCommonHeroSkinRarity = uint16(randomness % 505);
        epicBoxRareHeroSkinRarity = uint16(randomness % 940);
        epicBoxEpicHeroSkinRarity = uint16(randomness % 8115);
        epicBoxLegendarySkinRarity = uint16(randomness % 440);

        //legendary box
        legendaryBoxRareSkinRarity = uint16(randomness % 440);
        legendaryBoxEpicSkinRarity = uint16(randomness % 2020);
        legendaryBoxLegendarySkinRarity = uint16(randomness % 7540);
        // randomResult = (randomness%1000);
        // randomResult
        // 0: uint256: 873
        // 0x58dc868A54D09e8E15e6352e331682a817e1f0B3 kovan network (%1000)
        // 0x6f0eBEd8C6c6e09eEaE9f01A5C7a62c16aF5f552 BSC testnet (%1000)
        // probability
        // 0: uint8: 44
        // randomTokenId
        // 0: uint256: 7638892244
        // 0x47D2EA3828633F28048a7dBC179D78C38A0d6a20 BSC testnet (probability and randomTokenId)
    }

    // function withdrawLink() external {} - Implement a withdraw function to avoid locking your LINK in the contract

    function getCommonBoxSkin() public view returns (string memory) {
        if (commonBoxHeroProbability == 0) {
            if (
                commonBoxCommonHeroSkinRarity >= 0 &&
                commonBoxCommonHeroSkinRarity < 3995
            ) {
                return "6257c3e3d0dee4fedbc2db44";
            } else if (
                commonBoxCommonHeroSkinRarity >= 3995 &&
                commonBoxCommonHeroSkinRarity < 6845
            ) {
                return "6257c3f4d0dee4fedbc2db46";
            } else if (
                commonBoxCommonHeroSkinRarity >= 6845 &&
                commonBoxCommonHeroSkinRarity < 8440
            ) {
                return "6257c40cd0dee4fedbc2db48";
            } else if (
                commonBoxCommonHeroSkinRarity >= 8440 &&
                commonBoxCommonHeroSkinRarity < 9310
            ) {
                return "6257c420d0dee4fedbc2db4a";
            }
        } else if (commonBoxHeroProbability == 1) {
            if (
                commonBoxRareHeroSkinRarity >= 0 &&
                commonBoxRareHeroSkinRarity < 365
            ) {
                return "6257c3e3d0dee4fedbc2db44";
            } else if (
                commonBoxRareHeroSkinRarity >= 365 &&
                commonBoxRareHeroSkinRarity < 540
            ) {
                return "6257c3f4d0dee4fedbc2db46";
            } else if (
                commonBoxRareHeroSkinRarity >= 540 &&
                commonBoxRareHeroSkinRarity < 640
            ) {
                return "6257c40cd0dee4fedbc2db48";
            } else if (
                commonBoxRareHeroSkinRarity >= 640 &&
                commonBoxRareHeroSkinRarity < 690
            ) {
                return "6257c420d0dee4fedbc2db4a";
            }
        }
    }

    function getRareBoxSkin() public view returns (string memory) {
        if (rareBoxHeroProbability == 0) {
            if (
                rareBoxCommonHeroSkinRarity >= 0 &&
                rareBoxCommonHeroSkinRarity < 435
            ) {
                return "6257c3e3d0dee4fedbc2db44";
            } else if (
                rareBoxCommonHeroSkinRarity >= 435 &&
                rareBoxCommonHeroSkinRarity < 705
            ) {
                return "6257c3f4d0dee4fedbc2db46";
            } else if (
                rareBoxCommonHeroSkinRarity >= 705 &&
                rareBoxCommonHeroSkinRarity < 905
            ) {
                return "6257c40cd0dee4fedbc2db48";
            } else if (
                rareBoxCommonHeroSkinRarity >= 905 &&
                rareBoxCommonHeroSkinRarity < 1005
            ) {
                return "6257c420d0dee4fedbc2db4a";
            }
        } else if (rareBoxHeroProbability == 1) {
            if (
                rareBoxRareHeroSkinRarity >= 0 &&
                rareBoxRareHeroSkinRarity < 3445
            ) {
                return "6257c3e3d0dee4fedbc2db44";
            } else if (
                rareBoxRareHeroSkinRarity >= 3445 &&
                rareBoxRareHeroSkinRarity < 5960
            ) {
                return "6257c3f4d0dee4fedbc2db46";
            } else if (
                rareBoxRareHeroSkinRarity >= 5960 &&
                rareBoxRareHeroSkinRarity < 7810
            ) {
                return "6257c40cd0dee4fedbc2db48";
            } else if (
                rareBoxRareHeroSkinRarity >= 7810 &&
                rareBoxRareHeroSkinRarity < 8910
            ) {
                return "6257c420d0dee4fedbc2db4a";
            }
        } else if (rareBoxHeroProbability == 2) {
            if (
                rareBoxEpicHeroSkinRarity >= 0 && rareBoxEpicHeroSkinRarity < 50
            ) {
                return "6257c3e3d0dee4fedbc2db44";
            } else if (
                rareBoxEpicHeroSkinRarity >= 50 &&
                rareBoxEpicHeroSkinRarity < 70
            ) {
                return "6257c3f4d0dee4fedbc2db46";
            } else if (
                rareBoxEpicHeroSkinRarity >= 70 &&
                rareBoxEpicHeroSkinRarity < 80
            ) {
                return "6257c40cd0dee4fedbc2db48";
            } else if (
                rareBoxEpicHeroSkinRarity >= 80 &&
                rareBoxEpicHeroSkinRarity < 85
            ) {
                return "6257c420d0dee4fedbc2db4a";
            }
        }
    }

    function getEpicBoxSkin() public view returns (string memory) {
        if (epicBoxHeroProbability == 0) {
            if (
                epicBoxCommonHeroSkinRarity >= 0 &&
                epicBoxCommonHeroSkinRarity < 15
            ) {
                return "6257c3e3d0dee4fedbc2db44";
            } else if (
                epicBoxCommonHeroSkinRarity >= 15 &&
                epicBoxCommonHeroSkinRarity < 40
            ) {
                return "6257c3f4d0dee4fedbc2db46";
            } else if (
                epicBoxCommonHeroSkinRarity >= 40 &&
                epicBoxCommonHeroSkinRarity < 240
            ) {
                return "6257c40cd0dee4fedbc2db48";
            } else if (
                epicBoxCommonHeroSkinRarity >= 240 &&
                epicBoxCommonHeroSkinRarity < 505
            ) {
                return "6257c420d0dee4fedbc2db4a";
            }
        } else if (epicBoxHeroProbability == 1) {
            if (
                epicBoxRareHeroSkinRarity >= 0 &&
                epicBoxRareHeroSkinRarity < 515
            ) {
                return "6257c3e3d0dee4fedbc2db44";
            } else if (
                epicBoxRareHeroSkinRarity >= 515 &&
                epicBoxRareHeroSkinRarity < 730
            ) {
                return "6257c3f4d0dee4fedbc2db46";
            } else if (
                epicBoxRareHeroSkinRarity >= 730 &&
                epicBoxRareHeroSkinRarity < 855
            ) {
                return "6257c40cd0dee4fedbc2db48";
            } else if (
                epicBoxRareHeroSkinRarity >= 855 &&
                epicBoxRareHeroSkinRarity < 940
            ) {
                return "6257c420d0dee4fedbc2db4a";
            }
        } else if (epicBoxHeroProbability == 2) {
            if (
                epicBoxEpicHeroSkinRarity >= 0 &&
                epicBoxEpicHeroSkinRarity < 3295
            ) {
                return "6257c3e3d0dee4fedbc2db44";
            } else if (
                epicBoxEpicHeroSkinRarity >= 3295 &&
                epicBoxEpicHeroSkinRarity < 5645
            ) {
                return "6257c3f4d0dee4fedbc2db46";
            } else if (
                epicBoxEpicHeroSkinRarity >= 5645 &&
                epicBoxEpicHeroSkinRarity < 7150
            ) {
                return "6257c40cd0dee4fedbc2db48";
            } else if (
                epicBoxEpicHeroSkinRarity >= 7150 &&
                epicBoxEpicHeroSkinRarity < 8115
            ) {
                return "6257c420d0dee4fedbc2db4a";
            }
        } else if (epicBoxHeroProbability == 3) {
            if (
                epicBoxLegendarySkinRarity >= 0 &&
                epicBoxLegendarySkinRarity < 225
            ) {
                return "6257c3e3d0dee4fedbc2db44";
            } else if (
                epicBoxLegendarySkinRarity >= 225 &&
                epicBoxLegendarySkinRarity < 400
            ) {
                return "6257c3f4d0dee4fedbc2db46";
            } else if (
                epicBoxLegendarySkinRarity >= 400 &&
                epicBoxLegendarySkinRarity < 435
            ) {
                return "6257c40cd0dee4fedbc2db48";
            } else if (
                epicBoxLegendarySkinRarity >= 435 &&
                epicBoxLegendarySkinRarity < 440
            ) {
                return "6257c420d0dee4fedbc2db4a";
            }
        }
    }

    function getLegendaryBoxSkin() public view returns (string memory) {
        if (legendaryBoxHeroProbability == 1) {
            if (
                legendaryBoxRareSkinRarity >= 0 &&
                legendaryBoxRareSkinRarity < 55
            ) {
                return "6257c3e3d0dee4fedbc2db44";
            } else if (
                legendaryBoxRareSkinRarity >= 55 &&
                legendaryBoxRareSkinRarity < 140
            ) {
                return "6257c3f4d0dee4fedbc2db46";
            } else if (
                legendaryBoxRareSkinRarity >= 140 &&
                legendaryBoxRareSkinRarity < 265
            ) {
                return "6257c40cd0dee4fedbc2db48";
            } else if (
                legendaryBoxRareSkinRarity >= 265 &&
                legendaryBoxRareSkinRarity < 440
            ) {
                return "6257c420d0dee4fedbc2db4a";
            }
        } else if (legendaryBoxHeroProbability == 2) {
            if (
                legendaryBoxEpicSkinRarity >= 0 &&
                legendaryBoxEpicSkinRarity < 235
            ) {
                return "6257c3e3d0dee4fedbc2db44";
            } else if (
                legendaryBoxEpicSkinRarity >= 235 &&
                legendaryBoxEpicSkinRarity < 600
            ) {
                return "6257c3f4d0dee4fedbc2db46";
            } else if (
                legendaryBoxEpicSkinRarity >= 600 &&
                legendaryBoxEpicSkinRarity < 1195
            ) {
                return "6257c40cd0dee4fedbc2db48";
            } else if (
                legendaryBoxEpicSkinRarity >= 1195 &&
                legendaryBoxEpicSkinRarity < 2020
            ) {
                return "6257c420d0dee4fedbc2db4a";
            }
        } else if (legendaryBoxHeroProbability == 3) {
            if (
                legendaryBoxLegendarySkinRarity >= 0 &&
                legendaryBoxLegendarySkinRarity < 3295
            ) {
                return "6257c3e3d0dee4fedbc2db44";
            } else if (
                legendaryBoxLegendarySkinRarity >= 3295 &&
                legendaryBoxLegendarySkinRarity < 5510
            ) {
                return "6257c3f4d0dee4fedbc2db46";
            } else if (
                legendaryBoxLegendarySkinRarity >= 5510 &&
                legendaryBoxLegendarySkinRarity < 7185
            ) {
                return "6257c40cd0dee4fedbc2db48";
            } else if (
                legendaryBoxLegendarySkinRarity >= 7185 &&
                legendaryBoxLegendarySkinRarity < 7540
            ) {
                return "6257c420d0dee4fedbc2db4a";
            }
        }
    }

    function getWeaponBoxRarityDrop() public view returns (string memory) {
        if (weaponBoxRarityDrop >= 0 && weaponBoxRarityDrop < 78) {
            return "62bc1e2d84e4117a2d29b440";
        } else if (weaponBoxRarityDrop >= 78 && weaponBoxRarityDrop < 98) {
            return "62bc1e4284e4117a2d29b442";
        } else if (weaponBoxRarityDrop >= 98 && weaponBoxRarityDrop < 100) {
            return "62bc1e5e84e4117a2d29b444";
        }
    }

    function getCommonBoxHero() public view returns (string memory) {
        if (commonBoxHeroProbability == 0) {
            return "6257bbb7b278b3e677e5ceff";
        } else if (commonBoxHeroProbability == 1) {
            return "6257bd06b278b3e677e5cf01";
        }
    }

    function getRareBoxHero() public view returns (string memory) {
        if (rareBoxHeroProbability == 0) {
            return "6257bbb7b278b3e677e5ceff";
        } else if (rareBoxHeroProbability == 1) {
            return "6257bd06b278b3e677e5cf01";
        } else if (rareBoxHeroProbability == 2) {
            return "6257bdd2b278b3e677e5cf03";
        }
    }

    function getEpicBoxHero() public view returns (string memory) {
        if (epicBoxHeroProbability == 0) {
            return "6257bbb7b278b3e677e5ceff";
        } else if (epicBoxHeroProbability == 1) {
            return "6257bd06b278b3e677e5cf01";
        } else if (epicBoxHeroProbability == 2) {
            return "6257bdd2b278b3e677e5cf03";
        } else if (epicBoxHeroProbability == 3) {
            return "6257be00b278b3e677e5cf05";
        }
    }

    function getLegendaryBoxHero() public view returns (string memory) {
        if (legendaryBoxHeroProbability == 1) {
            return "6257bd06b278b3e677e5cf01";
        } else if (legendaryBoxHeroProbability == 2) {
            return "6257bdd2b278b3e677e5cf03";
        } else if (legendaryBoxHeroProbability == 3) {
            return "6257be00b278b3e677e5cf05";
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VRFRequestIDBase {
  /**
   * @notice returns the seed which is actually input to the VRF coordinator
   *
   * @dev To prevent repetition of VRF output due to repetition of the
   * @dev user-supplied seed, that seed is combined in a hash with the
   * @dev user-specific nonce, and the address of the consuming contract. The
   * @dev risk of repetition is mostly mitigated by inclusion of a blockhash in
   * @dev the final seed, but the nonce does protect against repetition in
   * @dev requests which are included in a single block.
   *
   * @param _userSeed VRF seed input provided by user
   * @param _requester Address of the requesting contract
   * @param _nonce User-specific nonce at the time of the request
   */
  function makeVRFInputSeed(
    bytes32 _keyHash,
    uint256 _userSeed,
    address _requester,
    uint256 _nonce
  ) internal pure returns (uint256) {
    return uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

  /**
   * @notice Returns the id for this request
   * @param _keyHash The serviceAgreement ID to be used for this request
   * @param _vRFInputSeed The seed to be passed directly to the VRF
   * @return The id for this request
   *
   * @dev Note that _vRFInputSeed is not the seed passed by the consuming
   * @dev contract, but the one generated by makeVRFInputSeed
   */
  function makeRequestId(bytes32 _keyHash, uint256 _vRFInputSeed) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/LinkTokenInterface.sol";

import "./VRFRequestIDBase.sol";

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
 * @dev simple access to a verifiable source of randomness.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constructor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator, _link) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash), and have told you the minimum LINK
 * @dev price for VRF service. Make sure your contract has sufficient LINK, and
 * @dev call requestRandomness(keyHash, fee, seed), where seed is the input you
 * @dev want to generate randomness from.
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomness method.
 *
 * @dev The randomness argument to fulfillRandomness is the actual random value
 * @dev generated from your seed.
 *
 * @dev The requestId argument is generated from the keyHash and the seed by
 * @dev makeRequestId(keyHash, seed). If your contract could have concurrent
 * @dev requests open, you can use the requestId to track which seed is
 * @dev associated with which randomness. See VRFRequestIDBase.sol for more
 * @dev details. (See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.)
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ. (Which is critical to making unpredictable randomness! See the
 * @dev next section.)
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
 * @dev Since the ultimate input to the VRF is mixed with the block hash of the
 * @dev block in which the request is made, user-provided seeds have no impact
 * @dev on its economic security properties. They are only included for API
 * @dev compatability with previous versions of this contract.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request.
 */
abstract contract VRFConsumerBase is VRFRequestIDBase {
  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBase expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomness the VRF output
   */
  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal virtual;

  /**
   * @dev In order to keep backwards compatibility we have kept the user
   * seed field around. We remove the use of it because given that the blockhash
   * enters later, it overrides whatever randomness the used seed provides.
   * Given that it adds no security, and can easily lead to misunderstandings,
   * we have removed it from usage and can now provide a simpler API.
   */
  uint256 private constant USER_SEED_PLACEHOLDER = 0;

  /**
   * @notice requestRandomness initiates a request for VRF output given _seed
   *
   * @dev The fulfillRandomness method receives the output, once it's provided
   * @dev by the Oracle, and verified by the vrfCoordinator.
   *
   * @dev The _keyHash must already be registered with the VRFCoordinator, and
   * @dev the _fee must exceed the fee specified during registration of the
   * @dev _keyHash.
   *
   * @dev The _seed parameter is vestigial, and is kept only for API
   * @dev compatibility with older versions. It can't *hurt* to mix in some of
   * @dev your own randomness, here, but it's not necessary because the VRF
   * @dev oracle will mix the hash of the block containing your request into the
   * @dev VRF seed it ultimately uses.
   *
   * @param _keyHash ID of public key against which randomness is generated
   * @param _fee The amount of LINK to send with the request
   *
   * @return requestId unique ID for this request
   *
   * @dev The returned requestId can be used to distinguish responses to
   * @dev concurrent requests. It is passed as the first argument to
   * @dev fulfillRandomness.
   */
  function requestRandomness(bytes32 _keyHash, uint256 _fee) internal returns (bytes32 requestId) {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));
    // This is the seed passed to VRFCoordinator. The oracle will mix this with
    // the hash of the block containing this request to obtain the seed/input
    // which is finally passed to the VRF cryptographic machinery.
    uint256 vRFSeed = makeVRFInputSeed(_keyHash, USER_SEED_PLACEHOLDER, address(this), nonces[_keyHash]);
    // nonces[_keyHash] must stay in sync with
    // VRFCoordinator.nonces[_keyHash][this], which was incremented by the above
    // successful LINK.transferAndCall (in VRFCoordinator.randomnessRequest).
    // This provides protection against the user repeating their input seed,
    // which would result in a predictable/duplicate output, if multiple such
    // requests appeared in the same block.
    nonces[_keyHash] = nonces[_keyHash] + 1;
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface internal immutable LINK;
  address private immutable vrfCoordinator;

  // Nonces for each VRF key from which randomness has been requested.
  //
  // Must stay in sync with VRFCoordinator[_keyHash][this]
  mapping(bytes32 => uint256) /* keyHash */ /* nonce */
    private nonces;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   * @param _link address of LINK token contract
   *
   * @dev https://docs.chain.link/docs/link-token-contracts
   */
  constructor(address _vrfCoordinator, address _link) {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomness(bytes32 requestId, uint256 randomness) external {
    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
    fulfillRandomness(requestId, randomness);
  }
}