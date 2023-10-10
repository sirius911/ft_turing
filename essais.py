import docker

# Créez un client Docker
client = docker.from_env()

# Nom de votre conteneur Docker
container_name = 'turing'

# Exécutez des commandes Docker sur le conteneur
container = client.containers.get(container_name)
result = container.exec_run('./ft_turing machines/02n.json 000')
print(result.output.decode())
