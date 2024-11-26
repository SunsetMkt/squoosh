FROM nixos/nix:2.24.5

RUN <<EOF
cat >> /etc/nix/nix.conf << EOL
experimental-features = nix-command flakes 
EOL
EOF

WORKDIR /app
CMD ["nix", "run", ".#updateRepoBinaries"]
