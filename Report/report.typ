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

// Let's get started folks!

#table-of-contents(depth: 1)

= Objectif du laboratoire
L'objectif de ce laboratoire est de comprendre la façon dont les performances d'un ordinateur sont mesurées, les facteurs qui influences les mesures et l'impact du développeur sur ces dernières.

Pour ce faire, nous avons effectué des tests sur notre propre ordinateur, afin d'ensuite comparer nos résultats avec ceux de nos collègues.

= Benchmarks
Nous avons utilisé le logiciel GeekBench 6 de Primatelabs pour réaliser les tests.

Ce logiciel permet de mesurer les performances :
- Du processeur (CPU) :
  - En single thread : on mesure ici la performance d'un seul coeur à la fois, ce qui ne dépend pas du nombre de coeurs dont dispose le processeur.
  - En multi-thread : la capacité du processeur à effectuer des opérations en parallèle est ici mesurée : la performance est ici relative à la performance d'un seul coeur ainsi qu'au nombre de coeurs.
- Du processeur graphique (GPU) :
  - OpenCL : effectue des calculs génériques à l'aide du GPU
  - Vulkan : effectue des calculs de rendu vidéo à l'aide du GPU
Les résultats de ces tests sont comparés à une valeur de base et donnent ensuite une évaluation relative de performances.

== Caractéristiques techniques
Mon ordinateur, coabaye dans ce laboratoire, est un laptop de marque Asus avec les caractéristiques techniques suivantes :


*CPU* : AMD Ryzen 9 5900HS, 8 coeurs/16 threads fréquence de base 3 Ghz, boost 4.6 Ghz

*RAM* : 40 Gb (8 + 32), DDR4-3200

*iGPU* : AMD Radeon Vega C4, 512Mb DDR4

*dGPU* : NVIDIA GeForce RTX 3060 Laptop GPU, 6GB GDDR6

*SSD* : 2TB PCIe 3.0 NVMe M.2 SSD

== Résultats des tests CPU
#let cpu_header = [*CPU*]
#figure(table(
  columns: (1fr, 1fr),
  align: center + horizon,
  table.header(table.cell(colspan: 2, cpu_header)),
  [*Single core*],[*Multi core*],
  [1692], [6261],
), caption: [Performances CPU]) <fig_res_cpu>

== Performances iGPU
#let igpu_header = [*iGPU*]
#figure(table(
  columns: (1fr, 1fr),
  align: center + horizon,
  table.header(table.cell(colspan: 2, igpu_header)),
  [*OpenCL*],[*Vulkan*],
  [14460], [13211],
), caption: [Performances iGPU]) <fig_res_igpu>

== Performances iGPU
#let dgpu_header = [*dGPU*]
#figure(table(
  columns: (1fr, 1fr),
  align: center + horizon,
  table.header(table.cell(colspan: 2, dgpu_header)),
  [*OpenCL*],[*Vulkan*],
  [89831], [12924],
), caption: [Performances dGPU]) <fig_res_dgpu>

== Performances ZIP
#let zip_header = [*ZIP*]
#figure(table(
  columns: (1fr, 1fr),
  align: center + horizon,
  table.header(table.cell(colspan: 2, dgpu_header)),
  [*Unzip*],[*Zip*],
  [2.68], [4.64],
), caption: [Performances ZIP]) <fig_res_zip>

= Comparaison des résultats
== Comparaison CPU
=== A quoi correspond le score ?
Le score est relatif à un modèle de référence de 2500 points, correspondant au score d'un processeur Intel Core i7-12700. L'échelle étant linéaire, elle est facile à interpréter (deux fois plus de point = deux fois plus performant).
Il existe deux scores :
- Single-core : mesure les performances d'un seul coeur, retourne un résultat indépendant du nombre de coeurs
- Multi-core : mesure les performances globales du processeur, en utilisant tous les coeurs.

=== Quels sont les points testés par Geekbench 6 ?
Geekbench teste les catégories suivantes :
- Tâches de productivité : compression de fichiers, navigation GPS, navigation web, génération de PDF
- Tâches de développement : édition de texte, compilation de code
- Machine learnig : détection d'objets sur des images
- Synthèse d'image : traçage de rayons lumineux, génération de géométrie 3D
- Transformations d'image : détection de l'horizon, filtres photo

=== A quoi correspondent les architectures x86, AMD64 (x86_64) et AARCH64 ?
- x86
Il s'agit de l'architecture historique des processeurs Intel, en 32 bits. Sortie en 1978 sur les processeurs 8086, elle est aujourd'hui obsolète.
- AMD64 (x86_64)
Descendante 64 bits de l'architecture x86, elle est utilisée à la fois par Intel et par AMD, qui l'a développée. C'est la plus répandue à l'heure actuelle.
- AARCH64
Également une architecture 64 bits, elle est principalement utilisée dans les smartphones et les tablettes, les derniers processeurs Apple, les Raspberry Pi, en raison de son côté économe en énergie.

=== Une fréquence supérieure d’horloge est-elle gage de performances supérieures d’un CPU à l’autre ?
Les performances d'un CPU dépendent grandement :
- De l'architecture : une instruction ARM peut être équivalente à plusieurs instructions Amd64, et vice versa
- Le nombre de coeurs : une fréquence élevée avec un nombre de coeurs réduit est souvent moins efficace que l'inverse ; les tâches parallélisables sont effectuées beaucoup plus rapidement avec un nombre de coeurs plus élevé
- Le nombre d'instruction par cycle : si un CPU peut effectuer plus d'instruction par cycle qu'un autre, à fréquence et nombre de coeurs égaux, il sera plus performant

== Comparaison GPU
=== Qu’est-ce que CUDA, OpenCL et Metal ?
Il s'agit d'APIs de calcul sur GPU, qui permettent d'utiliser ce dernier pour des calculs autres que des calculs de rendus graphique.
- CUDA : développé par Nvidia, très utilisé dans le domaine de l'IA. Ne fonctionne que sur GPU Nvidia
- OpenCL : équivalent open source à CUDA, peut être utilisé sur n'importe quel GPU
- Metal : équivalent Apple de CUDA

=== Quels sont les points testés par Geekbench 6 ? Donner les 4 grandes catégories.
- Machine learning
- Edition d'image
- Synthèse d'image
- Simulation de physique de particules

=== Comment un GPU diffère-t’il d’un CPU ?
Un CPU peut effectuer un grand nombre d'opérations différentes, soit à la suite, soit en parallèle, soit un mélange des deux. Un GPU est prévu pour effectuer un très grand nombre d'opérations similaire en parallèle.

== Comparaison RAM
=== Quelle(s) différence(s) existe(nt) entre des RAMs de type DDR4, LPDDR4 et DDR5 ?
- DDR4
Double Data Rate 4, très répandue depuis 2014
- LPDDR4
Low Power Double Data Rate 4, très répandue dans les smartphones, tablettes et ultrabooks
- DDR5
Double Data Rate 5, deux fois plus rapide que la DDR4, montée sur laptops et pcs haut de gamme
- LPDDR5
Low Power Double Data Rate 5, le meilleur des deux mondes ;)

=== A quoi correspond le CAS, aussi nommé CL pour CAS Latency ?
Il s'agit du temps de réaction de la mémoire vive ; le CL représente le nombre de cycles d'horloge qui s'écoulent entre le moment où le contrôleur mémoire envoie une demande de lecture d'une donnée et le moment où cette donnée est effectivement disponible en sortie.

=== Je travaille sur un programme accédant à des milliers de données en cache. D’un point de vue purement performance d’accès à une donnée, devrais-je préférer utiliser de la RAM DDR4 4000 MT/s CL18 ou de la RAM DDR5 4000 MHz CL38 ?
Le calcul de la @fig_cl montre que la RAM DDR4 4000MT/s CL18 est très légèrement plus rapide.
#figure(table(
  columns: (1fr, 1fr, 1fr, 1fr, 1fr),
  align: center + horizon,
  table.header([*RAM*],[*MT/s*],[*Fréquence* [Mhz]],[*CL*],[*Latence* [ns]]),
  [DDR4], [4000], [2000], [CL18], [$(18 * 2000) / 4000 = 9"ns"$],
  [DDR5], [8000], [4000], [CL38], [$(38 * 2000) / 8000 = 9.5"ns"$]
), caption: [Calcul de la latence RAM]) <fig_cl>

== Comparaison des ordinateurs
Globalement mon ordinateur se trouve dans le bas du tableau dans la partie CPU, probablement que cela est dû à son âge (c'est un modèle de 2021), par contre son GPU surpasse largement les autres, car il s'agit d'un GPU dédié (en supplément d'un GPU intégré), relativement performant (surtout pour un laptop de 14 pouces). Le tableau ci-dessous montre les résultats de cette comparaison :


== Calculs de performance du program Zip
- Quel système est le plus rapide ?
Il s'agit d'un ordinateur fixe avec un GPU dédié

- Quel est le facteur entre le système le plus lent et le plus rapide ?
On observe un facteur 4, même entre des processeur de génération similaire

- Y’a-t’il une corrélation avec le score CPU ? La RAM ?
Il y a une corrélation entre le score CPU, mais surtout avec le type de RAM ; la RAM DDR4 est bien moins rapide, ce qui influe sur les performances générales, même avec une configuration élevée. Les processeurs de dernières génération sont les plus performants, sams pour autant qu'il s'agisse de modèles haut de gamme.

= Optimisation software
Comme on peut le constater dans le tableau , les langages compilés Rust et C sont en moyenne *dix fois* plus rapide que les langages interprétés tels que JavaScript.
On remarque également que l'algorithme optimisé peut prendre plus de temps que l'algorithme non-optimisé. Par contre, lorsque qu'il s'agit d'une liste triée, c'est là que ce dernier brille, parcourant le tableau en un temps quasi instantané. Cela vient du fait que l'algorithme optimisé vérifie à la fin de chaque passage à travers le tableau si un swap a été effectué. Si tel n'est pas le cas, il peut déterminer que toutes les valeurs sont dans l'ordre.


== Bubble sort vs quicksort
J'ai choisi l'algorithme de tri quicksort, qui est largement utilisé dans les librairies standard, et, comme on peut l'observer dans la @, cet algorithme est beaucoup plus rapide dans la majeure partie des cas. Il comporte toutefois le risque de voir son temps d'exécution augmenter, dans certains cas comme les listes déjà triées. On observe également qu'il est relativement stable par rapport à la taille du tableau d'entrée.
// #figure(
//   image("sorting_comp_scala.png", height: 3cm),
//   caption: [Comparaison entre bubble sort et quick sort]
// ) <fig_quick_comparison>

== Langage choisi: Scala
Scala est un langage qui est compilé à la volée, comme Java, sur lequel il est basé. Cela peut impliquer une exécution plus lente que les langages compilés.

Avantages:
- Fonctionnel et orienté objet
- Intègre parfaitement tout l'écosystème Java
- Moins verbeux que Java
- Typage fort

Inconvénients
- Moins répandu
- Courbe d'apprentissage
- Temps de compilation

== Algorithme QuickSort
Cet algorithme est dit "divide & conquer", puisqu'il partitionne le tableau autour d'un pivot récursivement, et réarrange chaque partition avec les éléments les plus petit à gauche du pivot, et les plus grands à droite. La récursion s'arrête lorsqu'il n'y a plus qu'un seul élément dans la partition.

Il a une complexité $O(n log(n))$ dans la plupart des cas, mais peut avoir une complexité $O(n^2)$ lorsque le pivot choisi est le plus grand ou le plus petit élément.

=== Code Scala
Le @fig_quicksort_scala_code présente l'implémentation de l'algorithme QuickSort en Scala. Il est composé d'une helper function `swap()` qui permet d'échanger deux éléments dans un tableau, d'une autre helper function `partition()` qui retourne une borne de la partition, qui sera utilisée dans la fonction principale `quicksort()`, qui parcourt récursivement les deux partitions de part et d'autre du pivot.
#figure(code()[
```scala
  def mySortAlgorithm(data: Array[Int]): Array[Int] = {
    def swap(a: Array[Int], pos1: Int, pos2: Int): Unit = {
      val stash = a(pos1)
      a(pos1) = a(pos2)
      a(pos2) = stash
    }
    def partition(subArray: Array[Int], low: Int, hi: Int): Int = {
      val pivot = hi;
      var i = low;
      for (
        j <- low to hi
        if subArray(j) < subArray(pivot)
      ) { swap(subArray, i, j); i += 1 }

      swap(subArray, i, pivot);
      return i
    }

    def quicksort(a: Array[Int], low: Int, hi: Int): Unit = {
      if (low < hi) {
        val p = partition(a, low, hi)
        quicksort(a, low, p - 1)
        quicksort(a, p + 1, hi)
      }
    }

    quicksort(data, 0, data.length-1)
    data
  }
  ```
], caption: "Quick sort en Scala")
<fig_quicksort_scala_code>


= Conclusion
Ces tests de performance sont plutôt indicatifs, car la santé du système, l'âge et le système d'exploitation sont des variables qui peuvent beaucoup peser sur la balance et influencer grandement l'environnement de test. On peut voir de grandes différences de score pour des ordinateurs identiques, ce qui laisse croire que ces tests sont à prendre avec des pincettes.

Pour avoir des résultats plus précis et fiables, il faudrait pouvoir réunir des conditions de laboratoire identiques pour chaque machine testée, et comparer des systèmes équivalents : un ultrabook de moins d'un kilo ne peut pas être comparé avec un ordinateur de jeu, le refroidissement et le prix sont des variables qui donnent de grandes différences.

/*
#pagebreak()
//
// Modèle ci-dessous :
//

#align(center, block[
#box(image("circuit_full_adder.png"), width: 45%, inset: (x: 3pt))  #box(image("circuit_full_adder.png"), width: 45%, inset: (x: 3pt))
])

= Introduction
Écrire un rapport est un exercice autant *de fond que de forme*. Dans ce contexte, nous proposons dans ce document de quoi simplifier la rédaction de la forme sans avoir -- à priori -- d'avis sur le fond, ceci dans le contexte de la filière ISC#footnote[Voici d'ailleurs comment mettre une note de bas de page https://isc.hevs.ch].

Il convient tout d'abord pour présenter le contenu de se rendre compte que ce système de mise en page permet d'utiliser une forme de _markdown_ comme entrée. Le _markdown_ est une manière de formatter des fichiers textes afin de pouvoir les transformer avec un programme afin de les afficher dans différents formats, comme PDF ou encore sous forme de page web.

Le langage _markdown_ utilise différents types de balises permettant de faire du *gras*, de _l'italique_ ou encore du _*gras et de l'italique*_. Il est également possible de faire des listes, des tableaux, des images, des liens hypertextes, des notes de bas de page, des équations mathématiques comme $x^2 = 3$, des blocs de code comme par exemple `def hello()` et encore bien d'autres choses.

Vous trouverez ici de la documentation sur la manière d'utiliser le langage `markdown` pour écrire des documents ici : https://www.markdownguide.org/basic-syntax/. Vous trouverez également une version spécifique sur l'écriture de documents en Typst ici https://typst.app/docs/reference/syntax/.

En plus des choses simples montrées ci-dessus, le `markdown` simplifie la création de listes avec des nombres comme suit :

+ Un élément
+ Un autre élément de liste
+ Encore d'autres éléments si nécessaire

Des choses plus exotiques, comme mettre du #todo[texte mis en évidence] sont également possibles, tout comme les références à d'autres parties, comme dans le @intro[point].

== Insertion de code

Nous pouvons également avoir du `code brut directement en ligne` mais cela peut également être fait avec du code Scala comme par exemple dans ```scala def foo(x: Int)```. Cela n'empêche pas d'avoir des blocs de code joliment mis en forme également. Ainsi, lorsque l'on souhaite avoir du code inséré dans une figure, on peut également utiliser le package `sourcecode` qui rajoute notamment les numéros de ligne. En complément avec une `figure`, il est possible d'avoir une _légende_, un numéro de figure ainsi que du code centré :

#figure(code()[
```scala
  def foo(val a : Any) : Int = {
    a match :
      case a: Int  => 12
      case _ => 42
  }
  ```
], caption: "Un tout petit listing en Scala")

On peut si on le souhaite également avoir des blocs de code plus long si nécessaire, sur plusieurs pages :

#figure(code()[
```scala
  object ImageProcessingApp_Animation extends App {
    val imageFile = "./res/grace_hopper.jpg"

    val org = new ImageGraphics(imageFile, "Original", -200, 0)
    val dest2 = new ImageGraphics(imageFile, "Threshold", 200, 0)

    var direction: Int = 1
    var i = 1

    while (true) {
      if (i == 255 || i == 0)
        direction *= -1

      i = i + direction
      dest2.setPixelsBW(ImageFilters_Solution.threshold(org.getPixelsBW(), i))
    }
  }
  ```
], caption: "Un autre exemple de code, plus long")

=== Insérer du code à partir d'un fichier
Il est tout à fait possible de mettre du code qui provient d'un fichier comme ci-dessous :

#let code_sample = read("code/sample.scala")
#figure(code()[
  #raw(code_sample, lang: "scala")
], caption: "Code included from the file `sample.scala`")

== Insertion d'images

Une image vaut souvent mieux que mille mots ! Il est possible d'ajouter des images, bien entendu. La syntaxe est relativement simple comme vous pouvez le voir dans l'exemple ci-dessous:

#figure(image("figs/pixelize.png", height: 4cm), caption: [Grace Hopper, informaticienne américaine]) <fig_engineer>

Pour le reste, voici un texte pour voir de quoi il retourne. Vous allez réaliser une fonction appelée _mean_ qui va appliquer un filtre de moyenne à l'image. Ce filtre a pour but de flouter l'image et d'enlever ainsi ses aspérités. Le principe est le suivant : la valeur d'un pixel est remplacée par la moyenne des pixels se trouvant dans une zone carrée de 3 par 3 pixels autour du pixel. Si on veut calculer la nouvelle valeur du pixel situé à la position $(x,y)$ selon la figure @fig_engineer, sa nouvelle valeur sera la moyenne des 9 valeurs affichées.

La dérivée doit se calculer selon les deux axes. Le calcul est très simple : la dérivée selon `x` du pixel situé en $(x,y)$ vaut la valeur du pixel de droite $(x+1, y)$ moins la valeur du pixel de gauche $(x-1,y)$. Dans le cas de la figure, la dérivée selon $x$ vaut $D_x=234-255=-21$.

De même, on peut calculer la dérivée selon $y$. Elle correspond au pixel du dessous $(x,y+1)$ moins le pixel $(x,y-1)$ du dessus. Dans le cas de la @fig_engineer, la dérivée selon $y$ vaut $D_y = 230-127 = 103$.

La norme de la dérivée est calculée selon le théorème de Pythagore :

$ D = sqrt(D_x^ 2 +D_y^2) $

On peut également avoir des notations plus complexes :

$ sum_(n=1)^(infinity) 2^(-n) = 1 "ou encore" integral_(x = 0)^3 x^2 dif x $

#inc.showybox(
  title: "Stokes' theorem",
  frame: (
    border-color: blue,
    title-color: blue.lighten(30%),
    body-color: blue.lighten(95%),
    footer-color: blue.lighten(80%),
  ),
  // footer: "Information extracted from a well-known public encyclopedia"
)[
  Let $Sigma$ be a smooth oriented surface in $RR^3$ with boundary $diff Sigma equiv Gamma$. If a vector field $bold(F)(x,y,z)=(F_x (x,y,z), F_y (x,y,z), F_z (x,y,z))$ is defined and has continuous first order partial derivatives in a region containing $Sigma$, then

  $ integral.double_Sigma (bold(nabla) times bold(F)) dot bold(Sigma) = integral.cont_(diff Sigma) bold(F) dot dif bold(Gamma) $
]

// You can create a new page with a pagebreak
#pagebreak()

== Des tables

Il est possible d'insérer des tables simples :

#figure(table(
  align: left,
  columns: 4,
  stroke: none,
  [*Monday*],
  [11.5],
  [13.0],
  [4.0],
  [*Tuesday*],
  [8.0],
  [14.5],
  [5.0],
  [*Wednesday*],
  [9.0],
  [18.5],
  [13.0],
), caption: "Une table simple")

Des tables plus compliquées sont également possible. La page https://typst.app/docs/guides/table-guide/ donne d'ailleurs de bonnes informations.

#set table(stroke: (x, y) => (left: if x > 0 { 0.8pt }, top: if y > 0 { 1.5pt }))

#figure(table(
  // Table with 3 columns and 3 rows
  // There are 3 columns, the first one is twice as large as the two others
  columns: (2fr, 1fr, 1fr),
  align: center + horizon,
  table.header[*Technique*][*Advantage*][*Drawback*],
  [Diegetic],
  [Immersive],
  [May be contrived],
  [Extradiegetic],
  [Breaks immersion],
  [Obstrusive],
  [Omitted],
  [Fosters engagement],
  [May fracture audience],
), caption: [Une table plus complexe])

== Citer ses sources
Il est important de citer les sources que l'on utilise. Par exemple, les deux travaux @mui_nasa_dod09, @mui_hybrid_06 et @mudry:133438 sont deux papiers très intéressants à lire et dont les références complètes se trouvent dans la bibliographie à la fin de ce document. Il est également d'utiliser des acronymes comme par exemple #acr("USB"). Si on l'utilise une deuxième fois, seul l'acronyme apparaît, ainsi #acr("USB") est suffisant.

Si l'on souhaite citer des références issues d'une page ou d'un site web et que cette référence est importante, on utilisera la syntaxe @WinNT qui cite une référence de la bibliographie. Pour les autres cas, il est possible de référer au site uniquement avec son URL.

== Un exemple de texte : le filtre de Sobel
Une autre méthode pour extraire les contours à l'intérieur d'une image est d'utiliser #link("https://fr.wikipedia.org/wiki/Détection_de_contours")[l'algorithme de Sobel] Cette méthode est très similaire à celle de la dérivée, mais un peu plus compliquée et donne de meilleurs résultats.

Pour l'exemple, la valeur du filtre de Sobel selon _x_ vaudrait :

$ S_x= 100 + 2 dot 234 + 84 -128-2 dot 255-123=-109 $

De même la valeur du filtre de Sobel selon _y_ vaudrait:

$ S_y= 123+2 dot 230+84-128-2 dot 127-100 $

Comme auparavant, la norme du filtre de Sobel se calcule selon Pythagore et vaut pour cet exemple :

$ S = sqrt(S_x^2+S_y^2) = sqrt(109^2+185^2) =214.47 $

== Problématique <intro>
#lorem(20)

== Plan du travail
#lorem(40)

#pagebreak()

= Conclusion
#lorem(500)

#pagebreak()
#the-bibliography(bib-file: "bibliography.bib", full: true, style: "ieee")

//////////////
// Appendices
//////////////
#pagebreak()
#appendix-page()
#pagebreak()

// Table of acronyms, NOT COMPULSORY
#print-index(
  title: heavy-title(i18n(doc_language, "acronym-table-title"), mult:1, top:1em, bottom: 1em),
  sorted: "up",
  delimiter: " : ",
  row-gutter: 0.7em,
  outlined: false,
)

#pagebreak()

// Table of listings
#table-of-figures()

// Code inclusion
#pagebreak()
#code-samples()

#let code_sample = read("code/sample.scala")

#figure(code()[
  #raw(code_sample, lang: "scala")
], caption: "Code included from the file example.scala")

#figure(code()[
  #raw(code_sample, lang: "scala")
], caption: "Code included from the file example.scala")

#figure(code()[
  #raw(read("code/sort.py"), lang: "python")
], caption: "Code included from the file sort.py")

// This is the end !