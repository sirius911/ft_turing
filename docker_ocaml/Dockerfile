# Utilisez une image de base (par exemple ocaml/opam)
FROM ocaml/opam

# Copiez le script d'initialisation dans l'image
COPY init.sh /home/opam/init.sh

# Rendez le script exécutable
RUN /home/opam/init.sh

# Exécutez le script d'initialisation lors du démarrage du conteneur
CMD ["/bin/bash"]
