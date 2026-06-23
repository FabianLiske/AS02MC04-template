# AS02MC04 Vivado Project Template

Wiederverwendbares, terminal-first Vivado-Project-Mode-Template fuer die Alibaba Cloud FPGA-Karte AS02MC04 mit Xilinx Kintex UltraScale+ XCKU3P-FFVB676.

Die Vivado-Projektdateien unter `build/` sind generiert. Source of Truth sind RTL, XDC, Tcl und Makefile.

## Voraussetzungen

- Vivado 2025.2.1
- `vivado` im `PATH`
- Make
- Optional fuer Hardware-Zugriff: lokaler oder erreichbarer `hw_server` und JTAG-Adapter
- AS02MC04 Board-Files von `TiferKing/as02mc04_hack`, wenn `BOARD_PART=tiferking.cn:as02mc04:part0:1.0` in Vivado gesetzt werden soll

## AS02MC04 Board-Files Installieren

Die Board-Files liegen im Repository `TiferKing/as02mc04_hack` im Ordner `as02mc04/1.0`. Kopiere den Ordner `as02mc04` in die Vivado-Board-File-Struktur:

```bash
<Vivado>/data/boards/board_files/as02mc04/1.0
```

Falls `board_files` nicht existiert, lege den Ordner an. Ohne installierte Board-Files erzeugt dieses Template das Projekt weiter ueber `PART`, gibt aber eine Warnung aus und setzt `BOARD_PART` nicht.

## Workflow

Das Template nutzt Vivado Project Mode, aber das Projekt wird vollstaendig aus Tcl erzeugt. Die GUI ist nur zum Untersuchen und Debuggen gedacht. Aenderungen in der GUI sind nicht persistent, solange sie nicht in `rtl/`, `constraints/`, `ip/` oder `scripts/` uebernommen werden.

Ein frischer Build muss aus dem Repository-Root reproduzierbar sein:

```bash
rm -rf build
make bit
```

Alle generierten Dateien landen unter `build/`. Vivado-Logs und Journals werden ebenfalls nach `build/.../logs/` geschrieben.

## Make-Targets

- `make help`: zeigt Targets und Variablen
- `make project`: erzeugt/aktualisiert das Vivado-Projekt unter `BUILD`
- `make gui`: oeffnet das generierte Projekt in der Vivado-GUI
- `make synth`: startet Synthese, schreibt `build/.../checkpoints/<TOP>_synth.dcp` und Synthese-Reports
- `make impl`: startet Implementation bis Route, schreibt `build/.../checkpoints/<TOP>_impl.dcp` und Reports
- `make bit`: startet Implementation inklusive Bitstream und kopiert den fertigen Bitstream nach `build/.../output/<TOP>.bit`
- `make reports`: schreibt Reports aus vorhandenen Runs neu
- `make probe`: oeffnet nur Hardware Manager, verbindet `hw_server`, setzt den JTAG-Takt und listet Devices/Properties
- `make program`: laedt einen vorhandenen Bitstream fluechtig per JTAG, nur mit `CONFIRM=1`
- `make clean`: entfernt `build/` und uebliche Vivado-Artefakte im Repository-Root

## Make-Variablen

```make
VIVADO ?= vivado
BUILD ?= build/default
JOBS ?= 4
TOP ?= top
BOARD_PART ?= tiferking.cn:as02mc04:part0:1.0
PART ?= xcku3p-ffvb676-2-e
HW_FREQ ?= 1000000
```

Beispiele:

```bash
make bit PART=xcku3p-ffvb676-1-e JOBS=8
make gui BUILD=build/debug
make probe HW_FREQ=750000
make program CONFIRM=1
```

## Speedgrade `-1-e` vs `-2-e`

Die Quellen sind nicht einheitlich: `TiferKing/as02mc04_hack` beschreibt im Board-File `xcku3p-ffvb676-2-e`, waehrend `dkozel/Alibaba-Cloud-FPGA` `xcku3p-ffvb676-1-e` nennt. Deshalb ist `PART` bewusst als Make-Variable vorgesehen. Der Default ist `xcku3p-ffvb676-2-e`, kann aber pro Karte ueberschrieben werden.

## Constraints Und Offene Pinout-Punkte

Aktiv verwendet werden nur eindeutig belegte Clock- und LED-Pins:

| Signal | Pin | Aktiver Constraint | Quellen |
| --- | --- | --- | --- |
| `clk_100mhz_p` | E18 | `PACKAGE_PIN`, `IOSTANDARD LVDS`, 10 ns Clock | Essenceia Artikel, TiferKing `part0_pins.xml` |
| `clk_100mhz_n` | D18 | `PACKAGE_PIN`, `IOSTANDARD LVDS` | Essenceia Artikel, TiferKing `part0_pins.xml` |
| `led[0]` | B11 | `PACKAGE_PIN` | Essenceia Artikel, TiferKing `part0_pins.xml` |
| `led[1]` | C11 | `PACKAGE_PIN` | Essenceia Artikel, TiferKing `part0_pins.xml` |
| `led[2]` | A10 | `PACKAGE_PIN` | Essenceia Artikel, TiferKing `part0_pins.xml` |
| `led[3]` | B10 | `PACKAGE_PIN` | Essenceia Artikel, TiferKing `part0_pins.xml` |

Die LED-IOSTANDARD-Constraints sind absichtlich auskommentiert. Essenceia und TiferKing nennen `LVCMOS18`; Chester Gillon dokumentiert spaeter eine Korrektur auf `LVCMOS33` nach VCCO-Messung mit SYSMON. Deshalb muss der passende I/O-Standard auf der eigenen Karte verifiziert und in `constraints/as02mc04.xdc` bewusst aktiviert werden, bevor ein Bitstream sauber durch DRC laufen kann.

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

Dann in Vivado den passenden Run oder Checkpoint untersuchen. Uebernimm relevante Aenderungen danach in RTL, XDC oder Tcl.

## Neues Projekt Aus Dem Template Starten

1. Repository kopieren oder als Template verwenden.
2. `rtl/top.sv` durch das eigene Top-Level ersetzen oder `TOP=<name>` setzen.
3. Nur belegte und verifizierte Pins in `constraints/as02mc04.xdc` aktivieren.
4. Eigene XCI-Dateien unter `ip/` ablegen.
5. Mit `rm -rf build && make synth` pruefen.
6. Erst nach geklaerten I/O-Standards und DRC mit `make bit` bauen.

## Hardware-Zugriff

`make probe` ist nicht destruktiv. Es oeffnet den Hardware Manager, verbindet `hw_server`, oeffnet das lokale JTAG-Target, setzt `HW_FREQ` und gibt erkannte Devices plus Properties aus. Es programmiert nichts.

`make program CONFIRM=1` programmiert ausschliesslich die fluechtige FPGA-Konfiguration eines erkannten XCKU3P-Devices mit `build/.../output/<TOP>.bit`.

## Keine Flash-Programmierung

Flash-Programmierung ist absichtlich nicht implementiert. Dieses Template legt keine Configuration-Memory-Objekte an, schreibt keinen QSPI-Flash und enthaelt kein Target dafuer. `program` ist nur fuer volatile JTAG-Konfiguration gedacht.

## Quellen

- Essenceia: <https://essenceia.github.io/projects/alibaba_cloud_fpga/>
- dkozel: <https://github.com/dkozel/Alibaba-Cloud-FPGA>
- TiferKing: <https://github.com/TiferKing/as02mc04_hack>
- Chester Gillon: <https://gist.github.com/Chester-Gillon/765d6286b1c34c7dc26a7b4c4dd0c48c>
