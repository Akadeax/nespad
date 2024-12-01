## NES Template project
A template project (used as a starting point) for NES games, setup for Visual Studio Code.

source files are found under `src/` along with your `.cfg` and `.chr` files. [The sample source file is from Tony Cruise](https://github.com/tony-cruise/ProgrammingGamesForTheNES). Any build output will be in `build/`.

To build, run `build.bat` (`CTRL+SHIFT+B` in VSCode). This will output a `.nes` file in `/build` (your finished rom).

to customize file & project name, change the variables in `build.bat`.

If you wish to use Alchemy65 (an NES debugger), configure `.vscode/launch.json` to contain a correct `romPath`, `dbgPath`, and `program` (path to Mesen-X). For further instructions see [Alchemy65](https://github.com/AlchemicRaker/alchemy65)'s Readme.

### Environment Setup
to setup hooks, use `git config core.hooksPath .hooks`.