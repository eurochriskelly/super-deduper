_Super deduper_

Commands are described under package.json/scripts section. 
They can be run using:  `npm run commandName` or by running 
the defined command directly if npm is not available.

Variables for your environment should be updated under 
`config/variables.sh`

# Pre-requisites:

- Ensure java is available in client environment
- Download CoRB jars and place under `vendor/` folder
- VM should have sufficient RAM to process many documents at once (e.g. 16 -> 32GB)
- VM should have sufficient disk space to store URI lists for batched processing (e.g. 30GB)

# Build:

Pre-compile scripts using:

`npm run build`

This will build required artefacts under the `dist/` folder

# Install:

Install `/$BASE_LOCATION/dedupe` folder in your MarkLogic server application.

# Use:

From a linux vm with JAVA installed, run:

`npm run dedupe`


# Notes:

An even faster approach would be to create temporary range index during processing to order the docs