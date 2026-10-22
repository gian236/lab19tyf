## LAB # 19

- **npub de test:** `npub16f0lqqfy6eh8z76y5urc6gakn82j8u8xt0s86yfnxvh3ly39swsqkgv0rd`
- **ID de la nota 1:** `4d3296a0199d67b193b0089f30ae3647a3f14e6d3ee72d6ed5c3a052940b83bd`

### Tabla de Relays

| Relay | ¿Aceptó la nota 1? | Respuesta literal del relay | ¿La devolvió? (`nak req -i <id>`) | ¿Aceptó la #2 tras el ban? |
|---|---|---|---|---|
| `relay.damus.io` | Sí | `connecting to relay.damus.io... ok. publishing to relay.damus.io... success.` | Sí | Aceptaría (Relay abierto sin ban) |
| `nos.lol` | Sí | `connecting to nos.lol... ok. publishing to nos.lol... success.` | Sí | Aceptaría (Relay abierto sin ban) |
| `nostr.wine` | No | `connecting to nostr.wine... ok. publishing to nostr.wine... failed: msg: restricted: sign up at https://nostr.wine to write events to this relay` | No | Rechaza (Requiere suscripción / pago) |
| `relay.nostr.net` *(Sustituto de clase)* | Sí | `connecting to relay.nostr.net... ok. publishing to relay.nostr.net... success.` | Sí | No es posible demostrar el ban porque no se proporcionó un relay administrado por el instructor |

### Comprobación de Firma (1 línea)

**Original válida** (código 0, sin errores en `nak verify`); **copia alterada inválida** (`invalid .id, expected id::94d63ef80b73..., got id::4d3296a0199d...`) porque al modificar una sola letra en el contenido cambia el hash SHA-256 de la nota (su ID canónico), lo cual rompe la correspondencia con los datos serializados e invalida la firma Schnorr BIP-340.

### Reflexión de 3 Líneas

1. Mi nota quedó en 3 de 4 relays; `nostr.wine` la rechazó con: `"restricted: sign up at https://nostr.wine to write events to this relay"`.
2. El ban en un relay específico me quitaría visibilidad en ese nodo particular, pero no la persistencia ni la consulta de mi nota en los demás relays abiertos de la red global.
3. Si mi venture tuviera una cuenta Nostr, la nsec la guardaría en un firmador de hardware o un signer remoto NIP-46 con permisos mínimos porque jamás debe residir en servidores web expuestos ni en computadoras compartidas.

---

### Diagnóstico Técnico: Causa del Bloqueo en Windows

- **Causa:** `nak` en Go inspecciona `os.Stdin` para permitir canalizar o editar eventos. En terminales y entornos no interactivos de Windows (PowerShell/subprocesses), el descriptor de entrada estándar queda abierto sin emitir una señal `EOF` inmediata, provocando que `nak event` y `nak verify` esperen indefinidamente la llegada de datos.
- **Solución implementada:** Se utilizó el flag `--github` (provisto oficialmente por fiatjaf para tratar un stdin vacío como nulo en entornos no interactivos) y la redirección de entrada nula `stdin=DEVNULL`.

### Limitaciones Encontradas y Justificación

1. **Relay de clase del instructor:** No se proveyó una URL de relay administrado (`strfry`). Dado que los relays públicos globales no implementan bloqueos arbitrarios a pedido durante la clase, se usó `relay.nostr.net` como 4º relay de prueba y se documentó de forma fiel y sin falsificar evidencia: *"No es posible demostrar el ban porque no se proporcionó un relay administrado por el instructor"*.
2. **Cómo hubiera sido con el relay de clase:** En el relay local con ban aplicado, la nota 2 habría sido rechazada con `blocked: your pubkey has been banned`, mientras que en `relay.damus.io` y `nos.lol` la nota 2 habría sido aceptada sin impedimento, demostrando la resistencia a la censura de Nostr.
