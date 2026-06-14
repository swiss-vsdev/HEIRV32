#import "@preview/isc-hei-report:0.6.0" : *

#let doc_language = "fr" // Valid values are en, fr

#show: project.with(
  title: "CAr - Projet - HEIRV",
  authors: ("Gabriel Zeizer, Gonin Raphael"),  
  date: datetime.today(), // or datetime.today()
  language: doc_language, // Please change the value above if required
  
  course-name: "102.2 Computer Architecture",
  course-supervisor: "Zahno Silvan",
  semester: "Semestre de printemps",
  academic-year: "2025-2026",
  
  cover-image: image("CAr-logo.png"),
  cover-image-height: 8cm,
  cover-image-caption: [Computer Architecture],
  
  logo: image("figs/isc_logo.svg"),
  
  code-theme: "bluloco-light", // See directory themes/ for available themes
)

//// If using acronyms
#import "@preview/acrostiche:0.6.0": *
#include "acronyms.typ"
#show raw.where(lang: "vhdl"): set raw(syntaxes: "VHDL.sublime-syntax")
#show raw.where(lang: "riscv"): set raw(syntaxes: "riscv-asm.sublime-syntax")

// Let's get started folks!

#table-of-contents(depth: 2)

= Introduction

Ce projet s'inscrit dans le cadre du cours d'Architecture des ordinateurs de la filière
Informatique et Systèmes de Communication à la HES-SO Valais/Wallis. L'objectif est de réaliser
un processeur RISC-V 32 bits, simulé sous ModelSim puis
déployé physiquement sur une carte FPGA EBS 3.

Le travail couvre trois points principaux : la conception du chemin de données en VHDL,
l'implémentation de l'unité de contrôle (FSM, décodeur ALU, décodeur d'instruction), et l'écriture
d'un programme en assembleur HEIRV32 exploitant les boutons et les LEDs de la carte d'extension.

= Objectif du laboratoire
L'objectif de ce projet est de développer une architecture de processeur simple, de 
type RISC-V. Nous allons essentiellement nous concentrer sur la conception de l'unité de 
contrôle. Nous allons également implémenter un ensemble d'instructions 
de base pour permettre au processeur d'exécuter des programmes simples.

La partie matérielle, comprenant une carte de développement FPGA ainsi que
plusieurs boutons et LEDs pour interagir avec le processeur, nous est fournie.

La deuxième partie du projet consistera à créer un programme en assembleur qui sera exécuté
sur notre processeur, et qui permettra de tester les différentes fonctionnalités que nous avons implémentées.

= Spécification
Le processeur que nous allons implémenter doit être capable d'exécuter les instructions de base suivantes:
- Type R : *add, sub, and, or, slt, xor, sll, srl*
- Type I : *addi, andi, ori, slti, xori, slli, srli*
- Type mémoire : *lw, sw*
- Type saut: *beq, jal, jalr*
Il doit également pouvoir écouter l'activation d'un bouton pour déclencher l'exécution 
du programme, et afficher le résultat de l'exécution sur les LEDs.

#pagebreak()

= Matériel utilisé

Le système EBS3 repose sur trois platines : une motherboard, une daughterboard portant le FPGA, et une carte boutons/LEDs. 

== Motherboard (EBS3)

La carte mère (@fig_motherboard) expose les interfaces vers le monde extérieur :

- 4 connecteurs *PMod* 
- 2 ports parallèles
- Port *Gigabit Ethernet* (contrôleur VSC8531, 125Mhz)
- Port *USB-C* (contrôleur CP2102N)
- Bouton *Hard Reset* (signal `nRESET_IN`)
- Connecteur JTAG extender

#figure(
  image("../img/Motherboard.png", width: 7cm),
  caption: [Carte Mère],
)<fig_motherboard>
== Daughterboard (LFE5U-25F)

La carte fille (@fig_daughterboard) héberge le FPGA et ses périphériques directs. Elle se connecte à la motherboard via un connecteur *SODIMM-200*.

#align(center)[
#table(
  columns: (auto, auto),
  align: center,
  [*Composant*], [*Détail*],
  [FPGA], [Lattice LFE5U-25F (famille ECP5)],
  [Horloge], [100 MHz],
  [Programmes], [QSPI Flash - AT25SF321B],
  [DRAM], [256 Mb synchrone - IS42S16160J],
  [Stockage code], [Slot micro-SD],
  [Flashing], [USB/JTAG],
  [Alimentation], [USB-C +5V ou via motherboard],
  [Tensions internes], [+3.3 V / +2.5 V / +1.1 V],
)
]

Trois LEDs indiquent l'état du système :

- *LED bicolore (bleu/jaune)* : bleu signifie que la board est en train de recevoir des données, jaune que des données sont transmises de la board à l'hôte
- *LED verte (LD2)* : programme en cours de chargement depuis la SD (séquence de démarrage active)
- *LED rouge (LD3)* : FPGA sous tension et prêt à être configuré (programme non encore chargé)

Deux boutons sont disponibles sur la daughterboard :

- *Hard Reset* : reset matériel via le circuit APX811-31U (power-on-reset)
- *Soft Reset* : force le rechargement du programme depuis la flash QSPI

#figure(
  image("../img/Daughter.png", width: 8cm),
  caption: [Carte Fille],
)<fig_daughterboard>

== Carte boutons et LEDs

Cette carte fille secondaire (@fig_buttonledmodule) est connectée à la motherboard. Elle possède *4 boutons* et *8 LEDs*, reliés directement aux registres du processeur RISC-V :

- x30 : registre d'écriture des LEDs (bit 0 = LED 0, bit 1 = LED 1, …)
- x31 : registre de lecture des boutons (lecture seule ; bit 0 = S1, bit 1 = S2, …)

#figure(
  image("../img/LED.png", width: 7cm),
  caption: [Carte boutons et LEDs],
)<fig_buttonledmodule>

== Boards supplémentaires
En plus de la carte de base, plusieurs modules d'extension sont disponibles pour ajouter
des fonctionnalités supplémentaires au projet. Deux modules équipés de 8 LEDs chacun (@fig_ledmodule) étaient
également à notre disposition, mais nous avons choisi de ne pas les utiliser.
#align(center)[
#table(
  columns: (auto, auto),
  align: center,
  [*Type*], [*Modules*],
  [Entrées], [PMod BTN, PMod CON1, PMod CON3],
  [Sorties], [PMod OD1, PMod BB],
  [E/S], [PMod MAXSONAR (capteur à ultrasons)],
  [LEDs], [PMod 8LD (8 LEDs supplémentaires)],
)
]
#figure(
  image("../img/LedMod.png", width: 4cm),
  caption: [Carte supplémentaire LEDs],
)<fig_ledmodule>

= Outils
== HDL Designer
HDL Designer est un outil de conception de circuits numériques. Il s'agit de l'outil que nous avons utilisé tout au long de ce projet afin de concevoir notre implémentation du HEIRV32.

== ModelSim
ModelSim est un simulateur qui permet de voir les détails du fonctionnement d'un circuit fait avec HDL Designer. Il nous permet de contrôler le bon fonctionnement de notre implémentation à l'aide de tests unitaires ainsi que de manière visuelle grâce à la représentation visuelle des signaux.

== Lattice Diamond
Lattice Diamond nous permet de flasher la carte FPGA avec un circuit réalisé dans HDL Designer

= Design

== Blocs fournis
Les différents blocs nécessaires à la construction d’un processeur RISC-V ont été fournis et sont listés ci-dessous.

+ HEIRV32_MC
  - *controlUnit* : bloc pour le décodage des instructions
  - *heirv32_mc* : top-level
  - *instructionDataManager* : mémoire du programme groupant instructions et data, capable de lecture et écriture


+ HEIRV32
  - *ALU* : une version de l’ALU capable d’addition, soustraction, AND, OR, et SLT
  - *buffer*(Enable) : buffer clockés (bascules) avec ou sans entrée enable
  - *extend* : bloc d’extension de l’instruction pour les tests, supportant les instructions I, S, B et J
  - *mux3To1ULogVec* : mux 3 vers 1 de std_ulogic_vector
  - *registerFile* : bloc de gestion des 32 registres, remplaçant x31 par le vecteur btns - registre de lecture des boutons - et x30 par le vecteur LEDs - registre d’écriture des LEDs -

= Bases Théoriques
Afin de comprendre le fonctionnement du processeur HEIRV32, il est nécessaire d'analyser les
caractéristiques de chaque instruction supportée. Dans l'architecture multi-cycle choisie, chaque
instruction est décomposée en étapes distinctes, séparées par un coup d'horloge. Le pipeline se
construit comme suit :

#pad(left: 1.5em)[
  + *Fetch* : récupération de l'instruction en mémoire
  + *Decode* : décodage de l'instruction et lecture des registres sources
  + *Execute* : exécution de l'opération dans l'ALU
  + *Memory Access* : accès mémoire (uniquement pour `lw`)
  + *Write Back* : enregistrement du résultat dans le registre de destination (sauf `jal`)
]

Toutes les instructions ne nécessitent pas l'exécution de chaque étape, ces dernières peuvent être
dissociées, séparées par un coup d'horloge. Les instructions les plus
courtes ne nécessitant que 3 à 4 étapes bénéficieront d'un traitement plus rapide. 

=== Fetch

Le *fetch* correspond à la récupération de l'instruction depuis la mémoire. Le bloc responsable
est l'`instructionDataManagerSDCard`. Il accède à la mémoire grâce au *Program Counter* (*PC*),
une variable maintenant la position courante dans la mémoire du programme.

L'instruction récupérée est sous forme binaire sur 32 bits, comme démontré dans la @fig_binarycode :

#figure(
  image("../img/machinecode.png", width: 14cm),
  caption: [Code binaire d'une instruction],
) <fig_binarycode>

En parallèle du chargement de l'instruction, un ALU séparé est utilisé pendant le Fetch pour calculer
l'adresse suivante `PC + 4`.

=== Decode

Le *decode* extrait les champs significatifs de la chaîne binaire et génère les signaux de sélection
pour l'ensemble des blocs du circuit. Cette étape est gérée par l'*unité de contrôle* (`controlUnit`).

Les champs extraits sont :

#pad(left: 1.5em)[
  - *`opcode` bits \[6:0\]* : identifie le type d'instruction (R, I, S, B, J)
  - *`funct3` bits \[14:12\]* : affine le décodage pour les instructions de même type
  - *`funct7` bits \[31:25\]* : distingue par exemple `add` de `sub` (type R uniquement)
  - *`rs1`, `rs2`* : adresses des registres sources (bits \[19:15\] et \[24:20\])
  - *`rd`* : adresse du registre de destination (bits \[11:7\])
  - *`imm`* : valeur immédiate, dont la position varie selon le type d'instruction
]

La répartition de ces champs par type d'instruction est définie dans la @fig_instructionset :

#figure(
  image("../img/InstructionSet.png", width: 14cm),
  caption: [HEIRV32 Instruction Set],
)<fig_instructionset>

Grâce à cette identification, l'unité de contrôle génère les signaux appropriés pour chaque bloc
du circuit, détaillés dans la section suivante.

=== Execute

L'étape *execute* lance l'opération dans l'*ALU* selon les ordres fournis par l'unité de contrôle.
Les sources des opérandes A et B de l'ALU sont sélectionnées par les multiplexeurs contrôlés
par `ALUSrcA` et `ALUSrcB`.

Pour les instructions de type R et I, l'ALU effectue directement l'opération arithmétique ou logique.
Pour `beq`, elle calcule la différence `rs1 − rs2` afin de déterminer si les deux registres sont égaux
via le flag *Zero*. Pour `lw` et `sw`, elle calcule l'adresse mémoire `rs1 + imm`.

=== Memory Access

L'étape *memory access* ne s'applique, dans cette implémentation, qu'à l'instruction `lw`. Elle
utilise l'adresse calculée à l'étape précédente pour lire la valeur stockée en mémoire.

=== Write Back

L'étape *write back* enregistre la valeur résultante dans le registre de destination `rd`. La source
du résultat est déterminée par le signal `resultSrc` :

#pad(left: 1.5em)[
  - `"00"` : résultat de l'ALU (instructions R, I)
  - `"01"` : donnée lue en mémoire (instruction `lw`)
  - `"10"` : résultat ALU bypassed (calcul `PC + 4`)
]

L'instruction `jal` ne passe pas par cette étape de la même manière : elle enregistre directement
`PC + 4` comme adresse de retour dans `rd`, puis met à jour le PC avec l'adresse de saut calculée
en *Decode*.

= Circuit
== Top Level
La première étape du projet consiste à relier les différents composants du processeur entre eux (@fig_toplevel). 
Les différents signaux de contrôle provenant de l'unité de contrôle doivent être 
correctement acheminés vers les différentes unités fonctionnelles du processeur, telles 
que l'ALU, les registres, la mémoire, etc.

#figure(
  image("../img/TopLevel.PNG", width: 17cm),
  caption: [Vue top-level du système HEIRV32 sur FPGA],
)<fig_toplevel>

== Unité de contrôle
L'unité de contrôle, présentée dans la @fig_controlunit, est le cœur du processeur, elle reçoit les instructions du programme
et produit les signaux controlant l'état de tous les éléments du processeur.

#figure(
  image("../img/ControlUnit.PNG", width: 7cm),
  caption: [Vue top-level du Control Unit],
)<fig_controlunit>

=== AluDecoder <title_aludecoder>
Le bloc  de la @fig_aludecoder est chargé de décoder les instructions découlant du signal *AluOp* et de générer 
les signaux de contrôle de l'ALU. Il prend également en compte les signaux *func3* et *func7*, comme démontré dans le @fig_aludecodercode.
#figure(
  image("../img/AluDecoder.PNG", width: 7cm),
  caption: [AluDecoder, situé dans l'unité de contrôle],
)<fig_aludecoder>

#let code_sample = read("../img/aluDecoder_studentVersion.vhd")
#figure(code()[
  #raw(code_sample, lang: "vhdl")
], caption: "Code VHDL AluDecoder")<fig_aludecodercode>


=== InstrDecoder
Ce bloc, décrit par le @fig_instrdecoder, s'occupe de décoder les instructions provenant du signal *Op* et de produire 
le signal de contrôle pour le bloc *extend*.


#let code_sample = read("../img/InstrDecoder_studentVersion.vhd")
#figure(code()[
  #raw(code_sample, lang: "vhdl")
], caption: "Code VHDL InstrDecoder")<fig_instrdecoder>


=== Main FSM
La *Main FSM* (@fig_fsm) est le cœur de l'unité de contrôle. Elle orchestre les étapes du pipeline multi-cycle en générant les signaux de contrôle adéquats à chaque état.

#figure(
  image("../img/FSM.PNG", width: 16cm),
  caption: [Main FSM],
)<fig_fsm>

== Signaux de contrôle

La FSM génère les signaux détaillés dans la @fig_fsm_signals (valeur par défaut = `'0'` ou `"00"`) :
#figure(
align(center)[
#table(
  columns: (auto, auto, auto),
  [*Signal*], [*Taille*], [*Rôle*],
  [`IRWrite`],   [`1 bit`],  [Autorise l'écriture du registre instruction],
  [`PCUpdate`],  [`1 bit`],  [Mise à jour inconditionnelle du PC],
  [`branch`],    [`1 bit`],  [Activation du branchement conditionnel (BEQ)],
  [`AdrSrc`],    [`1 bit`],  [Sélection source adresse mémoire (0=PC, 1=ALU)],
  [`MemWrite`],  [`1 bit`],  [Écriture mémoire],
  [`regWrite`],  [`1 bit`],  [Écriture dans le fichier de registres],
  [`ALUSrcA`],   [`2 bits`], [Source A de l'ALU (00=PC, 01=oldPC, 10=RS1)],
  [`ALUSrcB`],   [`2 bits`], [Source B de l'ALU (00=RS2, 01=imm, 10=4)],
  [`ALUOp`],     [`2 bits`], [Mode ALU (00=add, 01=sub, 10=instruction)],
  [`resultSrc`], [`2 bits`], [Source du résultat (00=ALU, 01=mémoire, 10=oldALU)],
)
], caption: [Signaux de contrôle générés par la FSM]
)<fig_fsm_signals>

== Opcodes des types d'instructions
Les transitions depuis `Decode` sont déterminées par `op[6:0]` dans la @fig_opcodes::
#figure(
align(center)[
#table(
  columns: (auto, auto, auto),
  [*Type*], [*`op[6:0]`*], [*Instructions*],
  [R],   [`0110011`], [`add, sub, and, or, slt, xor, sll, srl`],
  [I],   [`0010011`], [`addi, andi, ori, slti, xori, slli, srli`],
  [LW],  [`0000011`], [`lw`],
  [SW],  [`0100011`], [`sw`],
  [BEQ], [`1100011`], [`beq`],
  [JAL], [`1101111`], [`jal`],
  [JALR],[`1100111`], [`jalr`],
)
], caption: [Opcodes des types d'instructions]
)<fig_opcodes>

== Table de vérité de la FSM

Chaque ligne de la @fig_truth_fsm correspond à un état et ses sorties associées.
Les signaux non listés sont à leur valeur par défaut (`'0'`/`"00"`).
#figure(
align(center)[
#table(
  columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto),
  [*État*],
  [`IRW`], [`PCUpd`], [`br`], [`AdrSrc`],
  [`MemW`], [`regW`],
  [`ALUSrcA`], [`ALUSrcB`], [`ALUOp`], [`resultSrc`],

  // Fetch
  [*Fetch*],
  [`1`],[`1`],[`0`],[`0`],
  [`0`],[`0`],
  [`00`],[`10`],[`00`],[`10`],

  // Decode
  [*Decode*],
  [`0`],[`0`],[`0`],[`0`],
  [`0`],[`0`],
  [`01`],[`01`],[`00`],[`--`],

  // ExecuteI
  [*ExecuteI*],
  [`0`],[`0`],[`0`],[`0`],
  [`0`],[`0`],
  [`10`],[`01`],[`10`],[`--`],

  // ExecuteR
  [*ExecuteR*],
  [`0`],[`0`],[`0`],[`0`],
  [`0`],[`0`],
  [`10`],[`00`],[`10`],[`--`],

  // ExecuteLW
  [*ExecuteLW*],
  [`0`],[`0`],[`0`],[`0`],
  [`0`],[`0`],
  [`10`],[`01`],[`00`],[`--`],

  // ExecuteS
  [*ExecuteS*],
  [`0`],[`0`],[`0`],[`0`],
  [`0`],[`0`],
  [`10`],[`01`],[`00`],[`--`],

  // ExecuteB
  [*ExecuteB*],
  [`0`],[`0`],[`1`],[`0`],
  [`0`],[`0`],
  [`10`],[`00`],[`01`],[`--`],

  // ExecuteJ
  [*ExecuteJ*],
  [`0`],[`1`],[`0`],[`0`],
  [`0`],[`0`],
  [`01`],[`10`],[`00`],[`--`],

  // ExecuteJalr
  [*ExecuteJalr*],
  [`0`],[`0`],[`0`],[`0`],
  [`0`],[`0`],
  [`10`],[`01`],[`11`],[`--`],

  // WriteBackI
  [*WriteBackI*],
  [`0`],[`0`],[`0`],[`0`],
  [`0`],[`1`],
  [`--`],[`--`],[`--`],[`00`],

  // WriteBackR
  [*WriteBackR*],
  [`0`],[`0`],[`0`],[`0`],
  [`0`],[`1`],
  [`--`],[`--`],[`--`],[`00`],

  // MemAccess
  [*MemAccess*],
  [`0`],[`0`],[`0`],[`1`],
  [`0`],[`0`],
  [`--`],[`--`],[`--`],[`00`],

  // WriteBackLW
  [*WriteBackLW*],
  [`0`],[`0`],[`0`],[`0`],
  [`0`],[`1`],
  [`--`],[`--`],[`--`],[`01`],

  // WriteBackS
  [*WriteBackS*],
  [`0`],[`0`],[`0`],[`1`],
  [`1`],[`0`],
  [`--`],[`--`],[`--`],[`00`],

  // WriteBackJ
  [*WriteBackJ*],
  [`0`],[`0`],[`0`],[`0`],
  [`0`],[`1`],
  [`--`],[`--`],[`--`],[`00`],
)
], caption: [Table de vérité de la FSM]
)<fig_truth_fsm>
_Légende :_ `IRW`=IRWrite, `PCUpd`=PCUpdate, `br`=branch, `MemW`=MemWrite, `regW`=regWrite.

/*
== Graphe de transitions

Tous les états retournent à *Fetch* une fois terminés. Les transitions conditionnelles depuis
*Decode* dépendent uniquement de `op[6:0]` :

```
Fetch ──► Decode
Decode ──► ExecuteI    (op = 0010011)
       ──► ExecuteR    (op = 0110011)
       ──► ExecuteLW   (op = 0000011)
       ──► ExecuteS    (op = 0100011)
       ──► ExecuteB    (op = 1100011)
       ──► ExecuteJ    (op = 1101111)
       ──► ExecuteJalr (op = 1100111, via ExecuteJ → ExecuteJalr)

ExecuteI   ──► WriteBackI  ──► Fetch
ExecuteR   ──► WriteBackR  ──► Fetch
ExecuteLW  ──► MemAccess ──► WriteBackLW ──► Fetch
ExecuteS   ──► WriteBackS  ──► Fetch
ExecuteB   ──► Fetch  (PCWrite conditionnel si Zero=1)
ExecuteJ   ──► WriteBackJ  ──► Fetch
ExecuteJalr──► WriteBackJ  ──► Fetch
```
*/

== Table de décodage ALU
La @fig_aludecodertable correspond au code que l'on retrouve au @title_aludecoder :
#figure(
align(center)[
#table(
  columns: (auto, auto, auto, auto, auto),
  [*ALUOp*], [*funct3*], [*Op5·funct7[5]*], [*Instruction*], [*ALUControl*],
  [`00`], [`---`], [`--`], [lw, sw],             [`000` (add)],
  [`01`], [`---`], [`--`], [beq],                [`001` (sub)],
  [`10`], [`000`], [`0x, 10`], [add / addi],     [`000` (add)],
  [`10`], [`000`], [`11`], [sub],                [`001` (sub)],
  [`10`], [`001`], [`--`], [sll / slli],         [`110` (sll)],
  [`10`], [`010`], [`--`], [slt / slti],         [`101` (slt)],
  [`10`], [`100`], [`--`], [xor / xori],         [`100` (xor)],
  [`10`], [`101`], [`x0`], [srl / srli],         [`111` (srl)],
  [`10`], [`110`], [`--`], [or / ori],           [`011` (or)],
  [`10`], [`111`], [`--`], [and / andi],         [`010` (and)],
  [`11`], [`---`], [`--`], [jalr (addr step)],   [`000` (add)],
)
], caption: [Table de décodage de l'ALU]
)<fig_aludecodertable>

== Table de décodage immédiat (Instr. Decoder)
L'opcode indique le format de l'immédiat via le signal `immSrc` au bloc d'extension immédiate, afin que ce dernier puisse le reconstituer correctement avant de l'étendre à 32 bits.
#figure(
align(center)[
#table(
  columns: (auto, auto, auto),
  [*`op[6:0]`*], [*`immSrc`*], [*Type*],
  [`0010011` / `0000011` / `1100111`], [`00`], [I],
  [`0100011`],                          [`01`], [S],
  [`1100011`],                          [`10`], [B],
  [`1101111`],                          [`11`], [J],
)
], caption: [Table de décodage du signal envoyé à l'extension immédiate]
)<fig_immdecoder>

== Justification des choix d'implémentation

=== JALR : deux étapes d'exécution

`jalr` saute à `rs1 + imm`, contrairement à `jal` qui saute à `oldPC + imm`.
Pendant le décodage, `rs1` n'est pas encore disponible en sortie du fichier de registres
(la bascule interne le retarde d'un cycle). Il est donc impossible de calculer l'adresse de
saut en *Decode* comme pour `jal`. La solution adoptée est l'ajout d'un état intermédiaire
*ExecuteJalr* qui effectue le calcul `rs1 + imm`, puis *ExecuteJ* qui met à jour le PC
et calcule `oldPC + 4`. `ALUOp = "11"` est utilisé pour forcer l'addition dans cet état
sans passer par le décodage instruction.

=== Signal `branch` vs `PCUpdate`

La mise à jour du PC est séparée en deux chemins :
- `PCUpdate` : mise à jour inconditionnelle (utilisée en Fetch pour PC+4, et en ExecuteJ).
- `branch AND Zero` : mise à jour conditionnelle (BEQ uniquement, si les deux registres sont égaux).

Ces deux signaux sont combinés via un OR : `PCWrite = PCUpdate OR (branch AND Zero)`.
Cela évite d'avoir à gérer le flag `Zero` dans tous les états.

=== `ALUSrcA = "01"` en Decode

Pendant le décodage, l'ALU est utilisé pour pré-calculer l'adresse de saut `oldPC + imm`
(utile pour BEQ et JAL). La source A est donc `oldPC` (valeur du PC avant l'incrément),
maintenu dans une bascule dédiée mise à jour à chaque Fetch.


= Simulation

La simulation avec ModelSim a permis de corriger plusieurs erreurs, notamment sur les valeurs générées par l’unité de contrôle. En observant les états internes et les résultats des tests unitaires, nous avons pu identifier des défauts d’implémentation dans la machine d’états (FSM) : certaines transitions étaient mal conditionnées ou les signaux de sortie n’étaient pas mis à jour au bon moment. Ces anomalies ont pu être localisées puis corrigées.

#figure(
  image("../img/sim.PNG", width: 16cm),
  caption: [Simulation avec ModelSim],
)

= Implémentation
Une fois le fonctionnement validé en simulation, le circuit et le code sont transférés sur la carte de développement FPGA.

== Circuit HEIRV32

À l’aide de l’outil Lattice Diamond, le circuit est compilé, prêt à être chargé sur la FPGA.

Le circuit est d’abord testé avec le code préalablement chargé. Puis, après avoir vérifié le bon fonctionnement du circuit, nous pouvons passer à la création de notre propre code assembleur.

== Code assembleur personnalisé
Le code assembleur (@fig_asmcode) est chargé directement sur la carte micro-SD après avoir été compilé par le programme : HEIRV32-ASM_1.2.5. Ce dernier retourne un fichier `.bin`, prêt à être copié sur la carte, à partir de notre fichier assembleur `.c`

Nous avons décidé de faire un code permettant d'afficher une chenille avec les LEDs. Les fonctions sont les suivantes:
#pad(left: 1.5em)[
- Une pression sur le bouton S1 démarre la chenille
- Chaque pression subséquente sur S1 augmente progressivement la vitesse de la chenille
- Chaque pression sur S2 réduit progressivement la vitesse de la chenille
- Une pression sur S3 arrête la chenille
]

Quelques points importants de notre code:
#pad(left: 1.5em)[
- Une fonction d'écoute de la pression sur l'un des trois boutons s'exécute à chaque boucle de décalage de la chenille; cette dernière utilise également un filtre anti rebond, empêchant un appui long d'incrémenter la vitesse plusieurs fois.
- Le facteur de vitesse est déterminé par l'élévation à la puissance `v` d'une valeur fixe (`0xff = 2047`). Cette opération est effectuée au moyen d'un décalage de cette constante vers la gauche de `v` fois.
]

#let code_sample = read("../Programme Asm/codeFreq.s")
#figure(code()[
  #raw(code_sample, lang: "riscv")
], caption: "Code Assembleur Chenille ")<fig_asmcode>


//== Fonctions supplémentaires
#pagebreak()
= Conclusion
Ce projet avait pour objectif de concevoir et déployer un processeur RISC-V 32-bits réduit,
l'*HEIRV32*, sur une carte FPGA, en implémentant une architecture multi-cycle.

Dans un premier temps, les spécifications ont été définies :

#pad(left: 1.5em)[
  - *Matériel* : carte de développement FPGA EBS3 (Lattice LFE5U-25F), carte boutons/LEDs,
    modules PMod d'extension
  - *Outils logiciels* : HDL Designer pour la conception du circuit, ModelSim pour la simulation,
    Lattice Diamond pour le déploiement sur FPGA
  - *Fonctionnalités* : instructions minimales (R, I, `lw`, `sw`, `beq`, `jal`, `jalr`) et
    fonctions supplémentaires (gestion des boutons, code personnalisé)
]

La conception du processeur s'est articulée autour de deux axes. D'une part, la théorie du
pipeline multi-cycle a guidé l'assemblage des blocs fournis : gestionnaire mémoire, fichier de
registres, bloc d'extension, ALU et unité de contrôle. D'autre part, la *Main FSM* a été
entièrement conçue et programmée pour orchestrer les signaux de contrôle à chaque étape du
pipeline (Fetch → Decode → Execute → Memory Access → Write Back).

La phase de simulation ModelSim a permis de valider le comportement du circuit instruction
par instruction, en corrigeant les valeurs de l'unité de contrôle au fur et à mesure. Le code
assembleur a quant à lui été développé et testé via l'interpréteur RISC-V en ligne et Ripes
avant intégration.

L'intégration sur FPGA a confirmé le bon fonctionnement global du système. Les points
clés du bilan sont les suivants :

#pad(left: 1.5em)[
  - *Circuit* : le processeur HEIRV32 multi-cycle répond aux spécifications minimales et
    s'exécute correctement sur la puce physique
  - *Code assembleur* : les fonctions minimales et supplémentaires sont opérationnelles
  - *Débogage* : la gestion des rebonds de boutons reste un point d'amélioration identifié ;
    le filtrage logiciel représente une piste de résolution directe
]

L'objectif principal est atteint : un processeur RISC-V réduit, capable de charger
et d'exécuter un programme assembleur personnalisé depuis une carte SD, a été conçu, simulé
et déployé. Ce projet illustre concrètement le lien entre les concepts théoriques de l'architecture
des ordinateurs et leur réalisation physique
sur un circuit programmable.

== Difficultés rencontrées
Le passage entre l'architecture single-cycle et multi-cycle a initialement posé quelques problèmes de compréhension, notamment dans la découpe des cycles en fonction des différentes opérations, ainsi que pour le calcul de `PCnext`.
L'établissement de la table de vérité de l'unité de contrôle s'est également avéré être une tâche complexe.

== Etapes suivantes
Si le temps l'avait permis, un développement du support de plus d'instructions assembleur aurait été intéressant, certaines instructions s'avérant très utile pour créer des programmes plus complexes (par exemple BNE, LUI, etc).

Nous aurions pu développer d'autres programmes a exécuter sur notre processeur, tel qu'une implémentation très basique du jeu pong ;)