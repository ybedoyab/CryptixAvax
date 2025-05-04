// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CryptixTicket is ERC721URIStorage, Ownable {
    uint256 public ticketCounter;
    mapping(uint256 => bool) public isResellable;
    mapping(uint256 => uint256) public maxResellPrice;

    event TicketMinted(address indexed to, uint256 indexed ticketId, string eventMetadataURI);
    event TicketTransferred(address indexed from, address indexed to, uint256 indexed ticketId, uint256 price);

    constructor() ERC721("Cryptix Ticket", "CXT") {
        ticketCounter = 0;
    }

    /**
     * @dev Crea un nuevo ticket para un evento con URI de metadatos.
     * @param to Dirección del comprador inicial
     * @param tokenURI URI con información del ticket
     * @param _resellable Indica si puede ser revendido
     * @param _maxPrice Precio máximo autorizado de reventa
     */
    function mintTicket(
        address to,
        string memory tokenURI,
        bool _resellable,
        uint256 _maxPrice
    ) external onlyOwner {
        uint256 ticketId = ticketCounter;
        _mint(to, ticketId);
        _setTokenURI(ticketId, tokenURI);
        isResellable[ticketId] = _resellable;
        maxResellPrice[ticketId] = _maxPrice;
        ticketCounter++;

        emit TicketMinted(to, ticketId, tokenURI);
    }

    /**
     * @dev Transferencia segura bajo condiciones de reventa.
     * @param to Nuevo propietario del ticket
     * @param ticketId ID del ticket
     */
    function transferTicket(
        address to,
        uint256 ticketId
    ) external payable {
        require(ownerOf(ticketId) == msg.sender, "No eres el dueño del ticket");
        require(isResellable[ticketId], "Este ticket no se puede revender");
        require(msg.value <= maxResellPrice[ticketId], "Precio de reventa excedido");

        // Transfiere el pago al vendedor
        payable(msg.sender).transfer(msg.value);

        _transfer(msg.sender, to, ticketId);

        emit TicketTransferred(msg.sender, to, ticketId, msg.value);
    }

    /**
     * @dev Consulta el historial de propiedad usando eventos off-chain (block explorers o dApps).
     */
}
