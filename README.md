NES project template
====================

This repository contains a template for building a simple NES game based on my current understanding of the platform, which is incomplete.

Starting a new project
-----


0. Install a recent release of cc65 (e.g., `brew install cc65 --HEAD`)
1. Clone the repository
2. Initialize submodules to get the FamiStudio engine dependency, if desired
3. Edit `config.inc` to taste.
    * NES_MIRRORING defines the nametable layout and may need editing
    * Mappers other than NROM (0) need additional configuration
4. Select a linker script (currently only `nes_nrom.cfg`). You may need to edit the script in a few places if you're using DPCM samples, a different number of PRG ROM banks, CHR RAM, etc.
5. Edit the `Makefile`:
    * set `PROGRAM` to your project name, no spaces
    * set `EMULATOR` to the path to your NES development emulator
    * set `LDCFG` to your linker script
6. Run `make play` to check that everything works. You should see some graphics and hear music, as well as a sound effect when pressing the A button.
7. Edit `Makefile`. Change the value of `SRC` to `start nes main nmi audio`. (You can omit `audio` if you've set `CFG_AUDIO_ENABLE` to 0 in the config.)

At this point you can start writing game code in `main.s`. Anything that needs to access the PPU goes in `nmi.s`, as well as an IRQ handler if you're into that.

If you want to organize your code into separate files, you can either `.include` them directly or create a new file and add it to the `Makefile` list. Remember to `.export` or `.exportzp` any symbols needed outside of the file.


