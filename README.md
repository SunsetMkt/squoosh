# [Squoosh]!

[Squoosh] is an image compression web app that reduces image sizes through numerous formats.

# Privacy

Squoosh does not send your image to a server. All image compression processes locally.

However, Squoosh utilizes Google Analytics to collect the following:

- [Basic visitor data](https://support.google.com/analytics/answer/6004245?ref_topic=2919631).
- The before and after image size value.
- If Squoosh PWA, the type of Squoosh installation.
- If Squoosh PWA, the installation time and date.

# Developing

## Web App

To develop for Squoosh:

1. Clone the repository
1. To install node packages, run:
   ```sh
   npm install
   ```
1. Then build the app by running:
   ```sh
   npm run build
   ```
1. After building, start the development server by running:
   ```sh
   npm run dev
   ```

## Codecs

All build instructions for codecs are written using [Nix]. If you have Nix installed, you can rebuild the WebAssembly binaries by running:

```sh
# Build the codec
cd codec/<codec>
nix run '.#updateRepoBinaries'
```

If you do not have Nix installed, you can use the provided Docker image to create a shell with nix available:

```sh
# Build the image (only needs to be done once).
docker build -t squoosh-nix ./nix
docker run --name squoosh-nix -ti -v $PWD:/app squoosh-nix /bin/sh
# ... continue with the steps above
```

# Contributing

Squoosh is an open-source project that appreciates all community involvement. To contribute to the project, follow the [contribute guide](/CONTRIBUTING.md).

[squoosh]: https://squoosh.app
[nix]: https://nixos.org
