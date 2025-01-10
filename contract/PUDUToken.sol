// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/// @title PuduToken - Un token ERC20 con funcionalidades de acuñación, quema y pausa
/// @notice Este contrato implementa un token ERC20 con suministro máximo, sistema de minters y capacidad de pausa
contract PuduToken is ERC20, Ownable, ERC20Burnable, Pausable {
    /// @notice Suministro máximo del token (100 millones con 18 decimales)
    uint256 public constant MAX_SUPPLY = 100_000_000 * 10 ** 18;

    /// @notice Evento emitido cuando se acuñan nuevos tokens
    /// @param to Dirección que recibe los tokens acuñados
    /// @param amount Cantidad de tokens acuñados
    event Mint(address indexed to, uint256 amount);

    /// @notice Evento emitido cuando se queman tokens
    /// @param from Dirección desde la que se queman los tokens
    /// @param amount Cantidad de tokens quemados
    event Burn(address indexed from, uint256 amount);

    /// @notice Mapeo para llevar el registro de las direcciones autorizadas para acuñar
    mapping(address => bool) private minters;

    /// @notice Constructor del contrato
    /// @param initialSupply Suministro inicial de tokens a acuñar
    constructor(
        uint256 initialSupply
    ) ERC20("PuduToken", "PUDU") Ownable(msg.sender) {
        require(
            initialSupply * 10**18 <= MAX_SUPPLY,
            "Initial supply exceeds max supply"
        );

        _mint(msg.sender, initialSupply * 10 ** 18);
        emit Mint(msg.sender, initialSupply * 10 ** 18);
    }

    /// @notice Añade un minter
    /// @param minter Dirección a añadir como minter
    function addMinter(address minter) external onlyOwner {
        minters[minter] = true;
    }

    /// @notice Elimina una dirección de la lista de minters
    /// @param minter Dirección a eliminar como minter
    function removeMinter(address minter) external onlyOwner {
        minters[minter] = false;
    }

    /// @notice Acuña nuevos tokens
    /// @param to Dirección que recibirá los tokens acuñados
    /// @param amount Cantidad de tokens a acuñar
    function mint(address to, uint256 amount) external whenNotPaused {
        require(
            minters[msg.sender] || msg.sender == owner(),
            "Caller is not a minter or owner"
        );
        require(
            totalSupply() + amount <= MAX_SUPPLY,
            "Minting would exceed max supply"
        );
        _mint(to, amount);
        emit Mint(to, amount);
    }

    /// @notice Quema tokens del balance del llamante
    /// @param amount Cantidad de tokens a quemar
    function burn(uint256 amount) public override whenNotPaused {
        super.burn(amount);
        emit Burn(msg.sender, amount);
    }

    /// @notice Quema tokens de una cuenta específica (requiere aprobación)
    /// @param account Dirección de la cuenta de la que se quemarán los tokens
    /// @param amount Cantidad de tokens a quemar
    function burnFrom(
        address account,
        uint256 amount
    ) public override whenNotPaused {
        super.burnFrom(account, amount);
        emit Burn(account, amount);
    }

    /// @notice Pausa todas las operaciones del token
    function pause() public onlyOwner {
        _pause();
    }

    /// @notice Reanuda todas las operaciones del token
    function unpause() public onlyOwner {
        _unpause();
    }
}
