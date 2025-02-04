# Use official Nix base image
FROM nixos/nix

# Install required packages:
# - git: Required for flakes
# - busybox: Basic Unix utilities
# - zstd: Compression/decompression
# - dotenvx: Environment variable management
# - nixos-rebuild: System configuration tool
RUN nix-channel --update
RUN nix-env -iA nixpkgs.git nixpkgs.busybox nixpkgs.zstd nixpkgs.dotenvx nixpkgs.nixos-rebuild

# Configure Nix to use flakes
RUN mkdir -p ~/.config/nix
RUN echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# Configure Git to be more permissive with repository ownership
RUN git config --system safe.directory '*'

# Set build directory
WORKDIR /build

# Note: Files are mounted at runtime via docker run -v
