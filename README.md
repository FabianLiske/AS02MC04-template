# AS02MC04 Vivado Project Template

## Workflow

Das Template nutzt Vivado Project Mode, aber das Projekt wird vollständig aus Tcl erzeugt. Die GUI ist nur zum Untersuchen und Debuggen gedacht. Änderungen in der GUI sind nicht persistent, solange sie nicht in `rtl/`, `constraints/`, `ip/` oder `scripts/` übernommen werden.

Ein frischer Build muss aus dem Repository-Root reproduzierbar sein:

```bash
rm -rf build
make bit
```

Alle generierten Dateien landen unter `build/`. Vivado-Logs und Journals werden ebenfalls nach `build/.../logs/` geschrieben.

## Make-Targets

- `make help`: zeigt Targets und Variablen
- `make project`: erzeugt/aktualisiert das Vivado-Projekt unter `BUILD`
- `make gui`: öffnet das generierte Projekt in der Vivado-GUI
- `make synth`: startet Synthese, schreibt `build/.../checkpoints/<TOP>_synth.dcp` und Synthese-Reports
- `make impl`: startet Implementation bis Route, schreibt `build/.../checkpoints/<TOP>_impl.dcp` und Reports
- `make bit`: startet Implementation inklusive Bitstream und kopiert den fertigen Bitstream nach `build/.../output/<TOP>.bit`
- `make reports`: schreibt Reports aus vorhandenen Runs neu
- `make probe`: öffnet nur Hardware Manager, verbindet `hw_server`, setzt den JTAG-Takt und listet Devices/Properties
- `make program`: lädt einen vorhandenen Bitstream flüchtig per JTAG, nur mit `CONFIRM=1`
- `make clean`: entfernt `build/` und übliche Vivado-Artefakte im Repository-Root

## Make-Variablen

```make
VIVADO ?= vivado
BUILD ?= build/default
JOBS ?= 32
TOP ?= top
BOARD_PART ?= tiferking.cn:as02mc04:part0:1.0
PART ?= xcku3p-ffvb676-2-e
HW_FREQ ?= 1000000
BOARD_CONSTRAINTS ?= 1
LED_IOSTANDARD ?= BOARD
```

Beispiele:

```bash
make bit PART=xcku3p-ffvb676-1-e JOBS=8
make gui BUILD=build/debug
make probe HW_FREQ=750000
make project BOARD_CONSTRAINTS=0
make bit LED_IOSTANDARD=LVCMOS33
make program CONFIRM=1
```

`JOBS` setzt in den Tcl-Skripten `general.maxThreads`. Vivado 2025.2.1 akzeptiert lokal maximal `32`; höhere Werte wie `JOBS=128` werden mit Hinweis auf `32` gedeckelt.

`BOARD_CONSTRAINTS=1` erzeugt beim Projektaufbau `build/.../generated/as02mc04_board.xdc` aus dem installierten Vivado-Boardfile. `LED_IOSTANDARD=BOARD` übernimmt den Wert aus dem Boardfile, `LED_IOSTANDARD=NONE` laesst den LED-I/O-Standard weg, und ein expliziter Wert wie `LVCMOS33` überschreibt ihn für die LED-Ports.

## Speedgrade `-1-e` vs `-2-e`

Die Quellen sind nicht einheitlich: `TiferKing/as02mc04_hack` beschreibt im Board-File `xcku3p-ffvb676-2-e`, waehrend `dkozel/Alibaba-Cloud-FPGA` `xcku3p-ffvb676-1-e` nennt. Deshalb ist `PART` bewusst als Make-Variable vorgesehen. Der Default ist `xcku3p-ffvb676-2-e`, kann aber pro Karte überschrieben werden.

## Constraints Und Offene Pinout-Punkte

Aktiv verwendet werden nur Clock- und LED-Pins, die im installierten Boardfile eindeutig belegt sind. Die konkrete XDC wird bei `make project` nach `build/.../generated/as02mc04_board.xdc` geschrieben. `constraints/as02mc04.xdc` bleibt für lokale Overrides reserviert.

| Signal | Pin | Aktiver Constraint | Quellen |
| --- | --- | --- | --- |
| `clk_100mhz_p` | E18 | `PACKAGE_PIN`, `IOSTANDARD LVDS`, 10 ns Clock | installierter TiferKing Board-Part `part0_pins.xml`; bestätigt durch Essenceia |
| `clk_100mhz_n` | D18 | `PACKAGE_PIN`, `IOSTANDARD LVDS` | installierter TiferKing Board-Part `part0_pins.xml`; bestätigt durch Essenceia |
| `led[0]` | B11 | `PACKAGE_PIN`, default `IOSTANDARD LVCMOS18`, `DRIVE 8`, `SLEW SLOW` | installierter TiferKing Board-Part `part0_pins.xml`; bestätigt durch Essenceia |
| `led[1]` | C11 | `PACKAGE_PIN`, default `IOSTANDARD LVCMOS18`, `DRIVE 8`, `SLEW SLOW` | installierter TiferKing Board-Part `part0_pins.xml`; bestätigt durch Essenceia |
| `led[2]` | A10 | `PACKAGE_PIN`, default `IOSTANDARD LVCMOS18`, `DRIVE 8`, `SLEW SLOW` | installierter TiferKing Board-Part `part0_pins.xml`; bestätigt durch Essenceia |
| `led[3]` | B10 | `PACKAGE_PIN`, default `IOSTANDARD LVCMOS18`, `DRIVE 8`, `SLEW SLOW` | installierter TiferKing Board-Part `part0_pins.xml`; bestätigt durch Essenceia |

Offene Unsicherheit: Essenceia und TiferKing nennen für die LEDs `LVCMOS18`; Chester Gillon dokumentiert später eine Korrektur auf `LVCMOS33` nach VCCO-Messung mit SYSMON. Der Default folgt dem installierten Boardfile (`LED_IOSTANDARD=BOARD`). Wenn deine Karte tatsächlich `LVCMOS33` für die LED-Bank braucht, baue mit `LED_IOSTANDARD=LVCMOS33` oder lege einen Override in `constraints/as02mc04.xdc` ab.

## Checkpoints In Der GUI Oeffnen

Nach `make synth`:

```bash
vivado build/default/checkpoints/top_synth.dcp
```

Nach `make impl` oder `make bit`:

```bash
vivado build/default/checkpoints/top_impl.dcp
```

Alternativ:

```bash
make gui
```

Dann in Vivado den passenden Run oder Checkpoint untersuchen. Relevante Aenderungenen danach in RTL, XDC oder Tcl übernehmen.

## Neues Projekt Aus Dem Template Starten

1. Repository kopieren oder als Template verwenden.
2. `rtl/top.sv` durch das eigene Top-Level ersetzen oder `TOP=<name>` setzen.
3. Boardfile installieren oder `BOARD_CONSTRAINTS=0` setzen und eigene Constraints pflegen.
4. Eigene XCI-Dateien unter `ip/` ablegen.
5. Mit `rm -rf build && make synth` prüfen.
6. Erst nach geklärten I/O-Standards und DRC mit `make bit` bauen.

## Hardware-Zugriff

`make probe` ist nicht destruktiv. Es öffnet den Hardware Manager, verbindet `hw_server`, öffnet das lokale JTAG-Target, setzt `HW_FREQ` und gibt erkannte Devices plus Properties aus. Es programmiert nichts.

`make program CONFIRM=1` programmiert ausschliesslich die flüchtige FPGA-Konfiguration eines erkannten XCKU3P-Devices mit `build/.../output/<TOP>.bit`.

## Keine Flash-Programmierung

Flash-Programmierung ist absichtlich nicht implementiert. Dieses Template legt keine Configuration-Memory-Objekte an, schreibt keinen QSPI-Flash und enthält kein Target dafür. `program` ist nur für volatile JTAG-Konfiguration gedacht.

## Quellen

- Essenceia: <https://essenceia.github.io/projects/alibaba_cloud_fpga/>
- dkozel: <https://github.com/dkozel/Alibaba-Cloud-FPGA>
- TiferKing: <https://github.com/TiferKing/as02mc04_hack>
- Chester Gillon: <https://gist.github.com/Chester-Gillon/765d6286b1c34c7dc26a7b4c4dd0c48c>
