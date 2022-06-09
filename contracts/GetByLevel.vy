# @version ^0.2.0
# Contrato para adquirir o token de um item por level
# v0.0.1

# Struct de dados do usuário
struct User:
  lvl: uint256 # level
  acquired: bool # variável de controle

# Map de usuários
users: public(HashMap[address, User])

# Endereço dos desenvolvedores
owner: address

# Preço para adquirir sem cumprir os requerimentos
price: public(uint256)

# Level mínimo para obter o item
min_lvl: public(uint256)

# Variável de controle para finalizar o evento
deadline: public(uint256)

# Inicializar contrato
@external
def __init__(min_lvl: uint256, price: uint256):
  # Verifica que a deadline é válida
  assert block.timestamp < deadline

  self.owner = msg.sender
  self.min_lvl = min_lvl
  self.price = price
  self.deadline = deadline

# Função para subir o nível de um usuário
@external
def raise_user_lvl(by: uint256):
  self.users[msg.sender].lvl += by

# Função para que o usuário possa resgatar um item
# Condicionado aos requirements do item ou compra
@external
@payable
def redeem():
  assert block.timestamp < self.deadline
  # Verifica que os requerimentos foram cumpridos
  # Ou que o preço foi pago
  assert (self.users[msg.sender].lvl >= min_lvl) or (msg.value >= price)
  assert not self.users[msg.sender].acquired

  self.users[msg.sender].acquired = True

# Função para que um usuário possa transferir o token
@external
def transfer(destiny: address):
    # Testa se quem está transferindo possui o item
    assert self.users[msg.sender].acquired
    # Testa se quem vai receber não possui o item
    assert not self.users[destiny].valid
    
    # Transfere o token para o destino
    self.users[destiny].acquired = True
    # Remove o token do antigo dono
    self.users[msg.sender].acquired = False

# Função para que o dono do contrato possa pegar o dinheiro
@external
def get_balance():
  # Testa se quem está chamando é o dono
  assert msg.sender == self.owner

  send(self.owner, self.balance)
