;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.ifndef CONFIG_INC
CONFIG_INC = 1

;; Values for iNes header:
.define NES_MAPPER 0            ; iNes mapper number: 0 for NROM
.define NES_PRG_BANKS 2         ; number of 16K PRG banks 
.define NES_CHR_BANKS 1         ; number of 8K CHR banks
.define NES_MIRRORING 1         ; nametable mirroring:
                                ;   0 for horizontal, 1 for vertical
                                ;   scroll direction is typically the opposite

;; Number of players the game supports, 1 or 2. Reading input will be slightly
;; more efficient if you don't need the second controller.
CFG_PLAYERS = 2

;; Whether to initialize the sound engine at all
CFG_AUDIO_ENABLE = 1

;; Optional: if defined with a symbol, init code will jump there after clearing
;; memory but before the PPU is ready
.define CFG_PREINIT_FN early_init

;; If using FamiStudio engine, set these to the segments defined in the linker script
.define FAMISTUDIO_CA65_ZP_SEGMENT   ZEROPAGE
.define FAMISTUDIO_CA65_RAM_SEGMENT  RAM
.define FAMISTUDIO_CA65_CODE_SEGMENT CODE

;; FamiStudio engine configuration
;; see https://famistudio.org/doc/soundengine/#configuration
FAMISTUDIO_CFG_EXTERNAL         = 1
FAMISTUDIO_CFG_PAL_SUPPORT      = 1
FAMISTUDIO_CFG_NTSC_SUPPORT     = 1
FAMISTUDIO_CFG_SFX_SUPPORT      = 1
FAMISTUDIO_CFG_SFX_STREAMS      = 2
FAMISTUDIO_CFG_DPCM_SUPPORT     = 1
FAMISTUDIO_CFG_SMOOTH_VIBRATO   = 1
FAMISTUDIO_CFG_THREAD           = 1
FAMISTUDIO_USE_DELTA_COUNTER    = 1
FAMISTUDIO_USE_FAMITRACKER_TEMPO = 0
FAMISTUDIO_USE_FAMITRACKER_DELAYED_NOTES_OR_CUTS = 0
FAMISTUDIO_USE_RELEASE_NOTES    = 1
FAMISTUDIO_USE_VOLUME_TRACK     = 1
FAMISTUDIO_USE_VOLUME_SLIDES    = 1
FAMISTUDIO_USE_PITCH_TRACK      = 1
FAMISTUDIO_USE_SLIDE_NOTES      = 1
FAMISTUDIO_USE_NOISE_SLIDE_NOTES = 1
FAMISTUDIO_USE_VIBRATO          = 1
FAMISTUDIO_USE_ARPEGGIO         = 0
FAMISTUDIO_USE_DUTYCYCLE_EFFECT = 0
FAMISTUDIO_USE_PHASE_RESET      = 0
FAMISTUDIO_USE_FDS_AUTOMOD      = 0
FAMISTUDIO_USE_DPCM_BANKSWITCHING = 0
FAMISTUDIO_USE_DPCM_EXTENDED_RANGE = 0
FAMISTUDIO_USE_INSTRUMENT_EXTENDED_RANGE = 0

.endif