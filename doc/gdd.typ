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
  cover: image("../assets/img/gameplay_cover.png", height: 100%,scaling: "pixelated"),
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

Studenti mnoha oborů přicházejí do školy, ale neví kudy kam. Na různých
místech školy stojí učitelé potřebující studenty některých oborů na své hodiny.
Úkolem hráče je chytře si organizovat studenty tak, aby je včas stihl dovést
k učiteli a zároveň, aby nečekali ve škole moc dlouho.

Za splněné úkoly od učitelů hráč dostává body, kterých se snaží získat co
nejvíc, než skončí hra. Hra končí ve chvíli, kdy je ve škole až moc studentů,
anebo jich tam moc čeká už příliš dlouho.

Cílem hráčů je získat co nejvyšší skóre, kterým se pak mohou chlubit před
kamarády. Druhým cílem může být nalezní všech referencí na FAVku, které se ve
hře objevují.

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

=== Pohyb

Hráč se pohybuje po mapě pomocí kláves AWSD.

#linebreak()
TODO:
- dash?

=== Manipulace se studenty

- Vybírání studentů: myší, obdelník
- Okolo hráče jsou tři kružnice, studenti se musí nacházet v obasti
  vyznačené největší kružnicí, aby mohli být vybráni.
- Studenti ve sféře vlivu hráče (největší kružnice) se snaží doběhnout k němu,
  respektive na úroveň nejmenší kružnice. Pokud se nachází mezi střední a
  největší kružnicí, zrychlí, aby hráče dostihli.
- POZOR: Hráč je rychlejší, než studenti - když chce, tak jim uteče.

#linebreak()
TODO:
- lepší vybírání, laso?
- precizní třízení studentů v cílové lokaci, možnost autonomního pohybu?

=== Hlavní herní smyčka <sec_main-loop>

Hráč začíná v prázné škole, kam postupně přicházejí studenti. Na některých
místech stojí učitelé, kteří mají questy. Všechny jsou typu: "Potřebuju X
takových, Y takových a Z takových studentů."

Počet questů je fixní, vždy když je jeden splněn, učitel zmizí a nahradí jej
jiný, potenciálně na jiném místě, s jinými požadavky. Čím delší hra, tím více
studentů je třeba pro plnění úkolů.

Předpokládá se, že hráč bude studenty třídit podle jejich oborů (symbolů), aby
se v nich vyznal a mohl lépe plnit úkoly.

Každý student má pouze omezenou trpělivost, dobu po kterou zvládne být ve škole
klidný (počítanou v reálnén čase). Pokud mu dojde, naštve se (= bude vizuálně
odlišený, třeba blikat) a to je problém. Za naštvané studenty je méně bodů
(TODO: anebo žádné).

Hra končí ve chvíli, kdy je ve škole moc studentů - důvod: hráč se dostatečně
nevěnoval questům. Druhý konec je, když je ve škole moc naštvaných studentů -
důvodem je, že chceme hráče donutit pořádně třídit studenty (chodí mu ve
frontě, ale on by je ideálně potřeboval v zásobníku).

=== Studenti

Každý student studuje nějaký obor, respektive je nějakého typu. To bude
vyznačené pomocí symbolů - tak, aby bylo na první pohled poznat, o koho se
jedná.

Zároveň studenti mají různé barvy. Tohle je TODO, mohli by totiž mít nějaké
vztahy typu: když má vedle sebe červený další červené, trpělivost mu ubývá
pomaleji; když má vedle sebe modrý žluté, trpělivost mu vyprchává rychleji.

=== Vyučující

Každý vyučující je osobnost, jejíž podobnost se skutečnými postavami je čistě
náhodná. Každý vyučující zvládá učit pouze některé typy předmětů (studentů).

TODO je třeba rozhodnout jak přesně: asi budou mít seznam povolených předmětů,
ze kterých se vybere vždy náhodně několik. Počty budou muset také být náhodně
generované, aby se zohlednila i fáze hry (čím pozdější, tím více).

TODO: Vyučující potřebují nějakým způsobem pronášet hlášky, nebo jinak
interagovat s hráčem, aby bylo možno přidávat příběhové vtipnosti.

#breakoutbox("Příklad vyučujícího")[
#align(center,[Profesor Láša])
Učí: libovolné informatiky, ideálně něco s grafikou nebo VR

Učí (symboly):
- klávesnice
- VR brýle
- matice
- ...
]

== Příběh <ch_story>

TODO: asi jsme starší studenti na favce, kteří pomáhají prvákům dostat se na
správné předměty?

Příběh bude něco opravdu takhle jednoduchého, každý _run_, tedy jedno spuštění
hry, bude jeden den ve škole. Cílem je vydržet co nejdéle, pomoci co nejvíce
učitelům nalézt jejich žáky.

V této sekci časem bude seznam všech hlášek, interakcí vyučujících s hráčem -
nebo i jenom věty, které občas sami od sebe řeknou. Také zde možná bude seznam
všech mezistudentských interakcí, hlášek. (Možná včetně vysvětlení pro situace
neznalé.)

== Výtvarné prvky <ch_arts>

TODO: Vítek (hádám, hodí se na to nejvíc)

Je potřeba vymyslet jak přesně budou vypadat: hráč, studenti, vyučující, mapa
(nejen podle půdorysu, ale třeba tam zanést pitnou vodu, sloupy, nebo
srandičky), vytvořit jim assety.

Kromě toho se musí vymyslet sound design, je potřeba navrhnout UI - a to jak
pro hlavní scénu (kde přesně budou např. questy, skóre, apod.), tak i
navrhnout scénu pro hlavní menu + nějakou _Credits_ scénu.

== Obsah hry <ch_level>

Hra se odehrává na FAVce, mapou tedy bude půdorys budovy. TODO: Je třeba ještě
rozhodnout konkrétnosti - například jestli půdorys trochu neupravit, aby to
celé byl víc použitelný prostor.

Kdyby se nám chtělo a bylo by třeba přidat více místa na studenty, šlo by jít
vertikálně = přidávat patra FAVky. Pro to by bylo třeba vymyslet rozumné UI a
přechod mezi patry (výtahy, schody?) - také další místa pro vyučující, aby byli
více rozmístěni + jak by při přechodech mezi patry fungovali studenti?

== Uživatelské rozhraní <ch_ui>
Zobrazení studentů:
- kolečko
- na kolečku symbol=obor
- kolečko má barvu
- okolo kolečka je bar trpělivosti
#linebreak()
TODO:
- zobrazovat questy u učitelů, nebo i někde jinde?

#breakoutbox("Grafický návrh studentů")[
Na obrázku je pracovní návrh toho, jak by mohli studenti vypadat:
#image("../assets/img/students_proposal.png",
  width: 100%,
  scaling: "smooth",
  format: "png")
]

= Projektové řízení <ch_proj-mngmnt>

== Role v týmu
TODO:
- třeba rozdělit role, možná nějaký přidat, ubrat, přejmenovat

#box(block[
#align(center,[_Nerozdělené role_])
    *ticho po pěšině...*

    #h(100%)
])

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
  stats: (CHAT: 7, ARTS: 5, PLAY: 15, ENGN: 10, GIT: 10, ".NET": 13),
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
  stats: (CHAT: 8, ARTS: 9, PLAY: 15, ENGN: 7, GIT: 11, ".NET": 10),
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
  stats: (CHAT: 8, ARTS: 14, PLAY: 15, ENGN: 5, GIT: 8, ".NET": 10),
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
  stats: (CHAT: 17, ARTS: 4, PLAY: 5, ENGN: 7, GIT: 12, ".NET": 15),
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
    tým získává +1 k .NET.]),
    ("Renaming Fun", [Přehledně přejmenuje funkce, aby kód byl zábavnější,
    např. malloc → jalloc.]),
  )
))

== Termíny
