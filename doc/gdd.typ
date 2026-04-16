#import "@preview/dragonling:0.2.0": *
#show ref: it => {
  if it.element.func() == heading {
    let loc = it.element.location()
    let page = loc.page()

    link(
    loc,
    [_#it.element.body (str. #page)_]
    )
  } else {
    it
  }
}

#show: dndmodule.with(
    title: "GDD:       \n     FAVem\n s davem",
  subtitle: "Zvládnete ukočírovat dav favíků\n lačnících po vědomostech?",
  author: "studenti FAV",
  cover: image("../assets/img/gameplay_elevator.png", height: 100%,scaling: "pixelated"),
  paper: "a4",
  logo: image("../assets/img/faviik_transparent.png", width: 13%),
  fancy-author: true
)

#outline(title: "Obsah\n")
#colbreak()
#heading(outlined: false, level: 1)[Uznání zaslouženým]

V abecedním pořadí podle příjmení: Ladislav Čákora, Jan Hejdušek, Vít Novotný a Jakub Vokoun.

Vyrobeno v rámci předmětu *Počítačové hry* na Katedře informatiky a výpočetní
techniky Fakulty aplikovaných věd *Západočeské univerzity v Plzni* v roce 2026.

#pagebreak()

= Popis hry

Favíci jdou do školy, akorát neví, kde je která učebna. Pomozte favíkům včas dorazit na správné rozvrhové akce.

Úkolem hráče je v časovém limitu naplnit požadavky místností na studenty.

= Herní design

== Úvod

Se čtením začněte v sekci @sec_main-loop a poté si v libovolném pořadí dočtěte
celou kapitolu @ch_mechanics - tím získáte dobrou představu o fungování celé hry.

Kapitoly @ch_story a @ch_level podrobněji popisují pro gameplay méně podstatné
záležitosti, které však pro hráče budou mít význam.

Výtvarné věci se nacházejí v kapitolách @ch_arts a @ch_ui, kde se časem objeví
i první návrhy vzhledu jak hry, tak okolních scén.

Pro projekt podstatnou kapitolou je @ch_proj-mngmnt, kde jsou popsáni všichni
členi týmu, respektive jejich role a zodpovědnosti - a také důležité termíny.

== Mechaniky <ch_mechanics>
Celá hra je silně založena na `VIM` keybindings & motions.

=== Pohyb

Hráč se pohybuje po mapě pomocí kláves `HJKL`.

=== Manipulace se studenty

- Vybírání studentů pomocí kláves `a`/`A` a následně zkratka pro druh studentů. Například `aM`vybere všechny studenty katedry matematiky.
- Lze na mapu položit _marker_ pomocí zkratky `m[0-9]`. Na marker se lze teleportovat pomocí zkratky `g[0-9]`, anebo na ně poslat studenty pomocí `s[druh studentů][0-9]`.

=== Hlavní herní smyčka <sec_main-loop>

Na začátku hry má hráč čas připravit si na mapě markery, zjistit kde je která třída atd...

V hlavní fázi hry je třeba naplnit dané učebny požadovaným počtem studentů.

Hra skončí a hráč vidí skóre.

=== Studenti

Každý student je z dané katedry a studuje konkrétní obor. Katedra je vyznačená barvou, obor symbolem. Tedy je na první pohled poznat o koho se jedná.

== Příběh <ch_story>

Pomáháme studentům dorazit na rozvrhovou akci a vyučujícím udělat radost, že jim chodí studenti.

== Výtvarné prvky <ch_arts>

TODO: Víťa

== Obsah hry <ch_level>

Hra se odehrává na FAVce, mapou tedy je půdorys budovy. 

== Uživatelské rozhraní <ch_ui>

Jsou použité `VIM` keybindings, takže hlavně se používá `HJKL`. Pokud chcete lépe porozumět, doporujčujeme začít používat PDE#footnote[Personalized Development Environment, pojem stvořil teej_dv: #link("https://youtu.be/QMVIJhC9Veg")[https://youtu.be/QMVIJhC9Veg]] Neovim#footnote[Více info o neovimu zde: #link("https://neovim.io/")[https://neovim.io/]].

= Projektové řízení <ch_proj-mngmnt>

Domluvou.

#figure(
  caption: "Projektové řízení domluvou.",
  image("../assets/img/corporate_like.png")
)


== Role v týmu

#box(block[
#align(center,[_Láďa_])
*Hlavní kódík* - struktura projektu, rozhoduje naming conventions etc.

    #h(100%)
])

#box(block[
#align(center,[_Hejdula_])
*Marketér* - dělá PR (haha), shání beta testery, posílá jim hru.

*Vrchní kritik* - krizuje existující hru a nápady.

    #h(100%)
])

#box(block[
#align(center,[_Vítek_])
*Hlavní umělec* - výtvarná vize projektu, zajišťuje assety.

*Zvukař* - v souladu s assety a příběhem zajistí bg music, sound efx.

    #h(100%)
])

#box(block[
#align(center,[_Voky_])
*Šéfík* - koordinace práce, komunikace v týmu, nastavení a hlídání
dodržování termínů.

*Příběhák* - vymýšlí příběh, sbírá reference a vymýšlí kam do hry je dát.

*Historik* - hlídá git (commit etiketa), verzuje celou hru, taguje,
    někam to zapíše.

    #h(100%)
])

#pagebreak()
== Členové týmu

#statbox((
  name: "Láďa",
  description: [Používá tři lomítka, když chce napsat komentář.],
  ac: [14 (changeling)],
  hp: [20],
  speed: [20ft],
  // dohromady můžeš rozdělit 60 do statů
  stats: (CHAT: 7, ARTS: 5, PLAY: 15, ENGN: 10, GIT: 10, "NVIM": 13),
  skillblock: (
    Dovednosti: [Refaktorace +7, Code Review +6],
    Smysly: [Code Radar 60ft – dokáže odhalit chyby a merge konflikty dřív,
    než ostatní.],
  ),
  traits: (
    ("Stack Overflow Aura", [Když někdo z týmu napíše chybný kód, Láďa
    ho může zkontrolovat a opravit během jednoho kola.]),
    ("\nMerge Master", [Láďa může provést merge i přes konflikty, ostatní
    členové týmu dostávají -1 ke svým git skillům, dokud není merge dokončen.])
  ),
  Actions: (
    ("Debug Barrage", [Odhalí a opraví až 3 bugy během jednoho kola.]),
  )
))

#statbox((
  name: "Hejdula",
  description: [Vůbec by mu nevadilo pracovat jako skladník.],
  ac: [20 (parcour)],
  hp: [14],
  speed: [10ft, climbing 30ft],
  // dohromady můžeš rozdělit 60 do statů
  stats: (CHAT: 8, ARTS: 9, PLAY: 15, ENGN: 7, GIT: 11, "NVIM": 10),
  skillblock: (
    Dovednosti: [Endless Gaming +7, Chill Mode +6],
    Smysly: [Endless Focus 30ft – dokáže vnímat detaily i při multitaskingu.],
  ),
  traits: (
    ("Infinite Patience", [Hejdula dokáže zůstat ve hře hodiny, což zvyšuje
    morálku týmu o +2 během dlouhých coding session.]),
    ("\nArtistic Insight", [Hejdula může zlepšit vizuální styl hry, ostatní členové dostávají +1 k ARTS checkům.])
  ),
  Actions: (
    ("Climber's Leap", [Přeskakuje překážky v projektech (např. bugy) a ignoruje
    malé problémy, až do AC 18).]),
    ("Endless Grind", [Dokáže dohrát demo bez přestávky, ostatní
    dostávají inspiraci +2 k PLAY skillům.]),
  )
))

#statbox((
  name: "Vítek",
  description: [Když zmíníš název nějaké hry, pravděpodobně ji hrál.],
  ac: [17 (kejklíř)],
  hp: [15],
  speed: [20ft],
  // dohromady můžeš rozdělit 60 do statů
  stats: (CHAT: 8, ARTS: 14, PLAY: 15, ENGN: 5, GIT: 8, "NVIM": 10),
  skillblock: (
    Dovednosti: [Vibe-coding +7, Color Sense +6],
    Smysly: [Art Vision 40ft – dokáže rychle odhalit vizuální nesrovnalosti
    a stylistické bugy ve hře.],
  ),
  traits: (
    ("Artful Dodger", [Vítek dokáže obejít jakýkoliv bug s grácií a stylem,
     ostatní mají +1 k ARTS checkům, když ho sledují.]),
    ("\nMood Setter", [Když nastaví hudbu v týmu, všichni mají +2 k PLAY skillům na další 2 hodiny.])
  ),
  Actions: (
    ("Palette Smash", [Přepíše UI/UX s takovým stylem, že hráči jsou ohromeni,
     všechny ARTS checky +1.]),
    ("Vibe Commit", [Commit obsahuje nečekané, ale stylové změny – odhaluje
     bugy. Všichni +2 k Debug.]),
  )
))

#statbox((
  name: "Voky",
  description: [Hrál AoE2 a CS 1.6. To je asi tak všechno.],
  ac: [10 (běžný člověk)],
  hp: [10],
  speed: [30ft (dlouhé nohy)],
  // dohromady můžeš rozdělit 60 do statů
  stats: (CHAT: 17, ARTS: 4, PLAY: 5, ENGN: 7, GIT: 12, "NVIM": 15),
  skillblock: (
    Dovednosti: [Debug +6, Prokrastinace +5],
    Smysly: [Team Vibe 50ft – cítí náladu týmu a dokáže rozpoznat, kdy někdo
    potřebuje slyšet vtip.],
  ),
  traits: (
    ("Motivátor", [Voky povzbudí tým. Každý, kdo s ním spolupracuje, získává
    +2 k vlastní produktivitě.]),
    ("Tentacle of Tasks", [Voky má šest chapadel, která pomáhají organizovat
    úkoly – každé chapadlo vyžaduje vlastní branch. Všichni +2 ke GIT.])
  ),
  Actions: (
    ("Coding Spree", [Každý Vokyho commit je příležitost učit se a zlepšovat –
    tým získává +1 k NVIM.]),
    ("Renaming Fun", [Přehledně přejmenuje funkce, aby kód byl zábavnější,
    např. malloc → jalloc.]),
  )
))
