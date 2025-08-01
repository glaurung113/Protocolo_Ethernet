# Diseño de un bloque de PCS tipo 1000BASE-X

**Curso:** IE-0523 Sistemas Digitales II  
**Ciclo:** I 2025  
**Profesor:** Enrique Coen Alfaro

---

## Integrantes del Grupo

- **Danny Solórzano Mayorga** - [DANNY.SOLORZANO@ucr.ac.cr](mailto:DANNY.SOLORZANO@ucr.ac.cr)
- **Wilber Hernández** - [WILBER.HERNANDEZ@ucr.ac.cr](WILBER.HERNANDEZ@ucr.ac.cr)

---

## Descripción del Proyecto

Este proyecto consiste en la implementación de un bloque de la subcapa de codificación física (PCS, por sus siglas en inglés) de acuerdo con las especificaciones de la cláusula 36 del estándar IEEE 802.3 para redes Ethernet 1000BASE-X.

---

## Estructura del proyecto

Estructura del directorio de archivos.

```
/1S_2025_G6
# Modulos por separado para hacer los unit tests
├── PCS/                
    ├── Makefile                  # Archivo para automatizar tareas de compilación y simulación.
    ├── pcs_cg_def.vh
    ├── pcs_defs.vh
    ├── pcs_tb.v                  # Archivo del testbench del dut.
    ├── pcs_tester.v              # Archivo de verilog para hacer las pruebas del DUT.
    ├── pcs.gtkw
    ├── pcs.v                     # Archivo de verilog con el diseño conductual del DUT.
├── Receiver/
    ├── tff/ 
    ├── Makefile                  # Archivo para automatizar tareas de compilación y simulación.
    ├── pcs_cg_def.vh
    ├── pcs_defs.vh
    ├── receiver_tb.v             # Archivo del testbench del recibidor.
    ├── receiver_tester.v         # Archivo de verilog para hacer las pruebas del recibidor
    ├── receiver.gtkw
    ├── receiver.v                # Archivo de verilog con el diseño conductual del recibidor.
├── Transmitter/ 
    ├── tff/ 
    ├── Makefile                  # Archivo para automatizar tareas de compilación y simulación.
    ├── pcs_cg_def.vh
    ├── pcs_defs.vh
    ├── transmitter_tb.v          # Archivo del testbench del transmisor.
    ├── transmitter_tester.v      # Archivo de verilog para hacer las pruebas del transmisor.
    ├── transmitter.gtkw
    ├── pcs_tx_o_set.v            # Archivo de verilog con el diseño conductual del transmitter ordered sets.   
    ├── pcs_tx_cg.v               # Archivo de verilog con el diseño conductual del transmitter code-groups.
    ├── transmitter.v             # Archivo de verilog con el diseño conductual del transmisor.
├── Synchronizer
    ├── tff/  
    ├── Makefile                  # Archivo para automatizar tareas de compilación y simulación.
    ├── pcs_cg_def.vh
    ├── pcs_defs.vh
    ├── synchronizer_defs.vh
    ├── synchronizer_tb.v         # Archivo del testbench del sincronizador.
    ├── synchronizer_tester.v     # Archivo de verilog para hacer las pruebas del sincronizdor.
    ├── synchronizer.gtkw
    ├── synchronizer.v            # Archivo de verilog con el diseño conductual del sincronizador.
├── README.md                     # Archivo README la estructura de los directorios.
├── .gitignore                    # Archivos a ignorar en el control de versiones.
```

---

## Instrucciones de utilización

1. Clonar este repositorio:
    ```bash
    git clone https://github.com/ecoenucr/1S_2025_G6.git
    cd 1S_2025_G6/
    ```
2. Ir al directorio que desea visualizar en GTKwave, por ejemplo el Transmitter/
    ```bash
    cd Transmitter/
    ```
3. Compilar y ejecutar las simulaciones:
    ```bash
    make
    ```

4. Para borrar los archivos generados utilice:
    ```bash
    make clean
    ```

---

## Control de versiones

Para cada feature o característica a implementar, a partir de un issue crear un branch para hacer las modificaciones del código.

```
git fetch origin
git checkout <branch-destino>
```

Por ejemplo, para el issue #25 Organizar directiorio del repositorio, crear el branch `25-organizar-directorio-del-repositorio`


```
git fetch origin
git checkout 25-organizar-directorio-del-repositorio
```

Al tener una característica funcional hacer un merge del `branch-fuente` al `branch-destino` (branch `main` u otro branch más jerárgico para el que se este implementado un característica).  

```
git checkout <branch-destino>
git merge <branch-fuente>

```

---

## Referencias

- **IEEE 802.3**: [IEEE 802.3 Standard Documentation](https://standards.ieee.org/ieee/802.3/7071/)

---