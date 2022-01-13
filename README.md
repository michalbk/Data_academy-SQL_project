## Popis
Předmětem SQL projektu Datové akademie je příprava panelových dat (jedné tabulky) týkajících se pandemie koronaviru.

Cílem je vytřídit a agregovat data o jednotlivých státech tak, aby výsledek umožnil porovnání vztahů mezi denními nárůsty počtu nakažených a demografickými a ekonomickými ukazateli jednotlivých států.

Výstupem je SQL skript generující výslednou tabulku ze všech dostupných dat.

**Seznam proměnných:**
- denní nárůsty nakažených v jednotlivých zemích
- počty provedených testů
- počet obyvatel daného státu
- binární proměnná víkend/pracovní den
- roční období daného dne
- hustota zalidnění
- HDP na obyvatele (ekonomická vyspělost)
- GINI koeficient (majetková nerovnost)
- dětská úmrtnost (kvalita zdravotnictví)
- medián věku obyvatel v roce 2018
- podíly jednotlivých náboženství (kulturní specifika)
- rozdíl mezi očekávanou dobou dožití v roce 1965 a v roce 2015 (míra rozvoje)
- průměrná denní teplota
- počet hodin v daném dni, kdy byly srážky nenulové
- maximální síla větru v nárazech během dne

**Seznam tabulek databáze:**
- countries
- economies
- life_expectancy
- religions
- covid19_basic_differences
- covid19_testing
- weather
- lookup_table

## Komentář k výsledkům

Klíče tabulky představují sloupce country a date, které vycházejí z tabulky covid19_basic_differences (dále jen cbd).

Názvy zemí jsou stejnoceny napříč tabulkami - níže uvedené země jsou oproti tabulce cbd přejmenovány takto:

- Burma -> Myanmar
- Cabo Verde -> Cape Verde
- Congo (Brazzaville) a Congo (Kinshasa) -> Congo
- Cote d'Ivoire -> Ivory Coast
- Czechia -> Czech Republic
- Eswatini -> Swaziland
- Korea, South -> South Korea
- Russia -> Russian Federation
- Taiwan* -> Taiwan
- US -> United States

Pro zemi Congo byla v mnoha tabulkách k dispozici duplicitní data pod názvy 'The Democratic Republic of Congo' a 'Congo'. Porovnáním s údaji na Wikipedia.org byla zvolena ta data, která více odpovídala realitě: <br>
- 'The Democratic Republic of Congo' - sloupce population, GDP_per_inhabitant_[USD], gini, mortality_under5, percent_religion_2020, life_expectancy_diff_2015-1965
- 'Congo' - median_age_2018

## Komentář ke sloupcům tabulky

**confirmed** - denní nárůst nakažených v dané zemi
- vynechány hodnoty záporné a NULL
- pro Congo se jedná o součet Congo (Brazzaville) a Congo (Kinshasa) v daném dni (dvě města, zajímají nás celé země)

**tests performed** - počet provedených testů v dané zemi
- vynechány hodnoty záporné a NULL
- k počtu provedených testů ponechána poznámka o testu ve sloupci entity

**population** - počet obyvatel
- použity údaje pro rok 2020 z tabulky economies
- pro země Eritrea, Holy See, Taiwan, West Bank and Gaza použity údaje z tabulky lookup_table
- položky Diamond Princess a MS Zaandam jsou výletní lodě

**flag_weekend**
- 0 = všední den, 1 = víkend

**season**
- 0 = zima, 1 = jaro, 2 = léto, 3 = podzim
- neuvažuje se každoroční posun astronomických začátků/konců ročních období (+- 1-2 dny)

**population_density/km^2** - hustota zalidnění (počet obyvatel / km^2)

**GDP_per_inhabitant_USD, GDP_year** - HDP na obyvatele v USD
- použita nejaktuálnější dostupná data pro každou zemi z tabulky economies
- ve sloupci GDP_year je uveden rok použitého GDP

**gini, gini_year** - GINI koeficient
- použita nejaktuálnější dostupná data pro každou zemi z tabulky economies
- ve sloupci gini_year je uveden rok použitého gini

**mortality_under5** - dětská úmrtnost (do 5 let věku)
- údaje z roku 2019

**median_age_2018** - medián věku obyvatel v roce 2018

**percent_religion_2020** - podíly jednotlivých náboženství
- data z roku 2020

**life_expectancy_diff_2015-1965** - rozdíl mezi očekávanou dobou dožití v roce 1965 a v roce 2015
- pro zemi Timor-Leste v tabulce covid19_basic_differences použita data země Timor (tabulka life_expectancy)

**data o počasí - obecně**
- data v tabulce weather jsou dostupná pouze pro některá hlavní města (celkem 34)
- data z hlavních měst byla spárována s jejich zeměmi pomocí tabulky cities
- data pro Vídeň a Prahu jsou duplicitní, ošetřeno ve výběru

**avg_daily_temp_degC** - průměrná denní teplota ve °C
- vypočítána jako aritmetický průměr měřených dat v čase 6:00-18:00 včetně

**raining_hours** - počet hodin v daném dni, kdy byly srážky nenulové
- uvažováno jako počet jednotlivých záznamů za celý den, kdy byly srážky nenulové (NOT NULL nebo > 0). Jeden záznam = jedna hodina

**max_gust_km/h**
- maximální hodnota nárazů větru za celý den v km/h
