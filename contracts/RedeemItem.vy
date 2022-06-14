# @version ^0.3.3
# Contrato para adquirir o token de um item
# v0.0.1

# Struct de dados do usuário
struct UserData:
  amount: uint256
  acquired: bool # variável de controle

# Map de usuários
users: public(HashMap[address, UserData])

# Endereço dos desenvolvedores
contractOwner: address

# Preço para adquirir sem cumprir os requerimentos
price: public(uint256)

# Level mínimo para obter o item
min_lvl: public(uint256)

# Variável de controle do número de tokens do proprietário 
amount_of_tokens: public(uint256)

# Inicializar contrato
@external
def __init__(min_lvl: uint256, price: uint256, amount_of_tokens: uint256):
  self.contractOwner = msg.sender
  self.min_lvl = min_lvl
  self.price = price
  self.amount_of_tokens = amount_of_tokens

# Função para que o usuário possa resgatar um item
# Condicionado aos requirements do item ou compra
@external
@payable
def redeem(user_lvl: uint256):
  assert self.amount_of_tokens > 0
  # Verifica que os requerimentos foram cumpridos
  # Ou que o preço foi pago
  assert (user_lvl >= self.min_lvl) or (msg.value >= self.price)
  assert not self.users[msg.sender].acquired

  self.users[msg.sender] = UserData({
      amount: 1,
      acquired: True
    })
  self.amount_of_tokens -= 1

# Função para que um usuário possa transferir o token
@external
def transfer(destiny: address):
    # Testa se quem está transferindo possui o item
    assert self.users[msg.sender].acquired
    # Testa se quem vai receber não possui o item
    assert not self.users[destiny].acquired
    
    # Transfere o token para o destino
    self.users[destiny] = self.users[msg.sender]
    self.users[msg.sender].acquired = False

# Função para que o dono do contrato possa pegar o dinheiro
@external
def get_balance():
  # Testa se quem está chamando é o dono
  assert msg.sender == self.contractOwner

  send(self.contractOwner, self.balance)
