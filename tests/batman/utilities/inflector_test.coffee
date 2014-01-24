SingularToPlural =
  "search"      : "searches"
  "switch"      : "switches"
  "fix"         : "fixes"
  "box"         : "boxes"
  "process"     : "processes"
  "address"     : "addresses"
  "case"        : "cases"
  "stack"       : "stacks"
  "wish"        : "wishes"
  "fish"        : "fish"
  "jeans"       : "jeans"
  "funky jeans" : "funky jeans"
  "my money"    : "my money"

  "category"    : "categories"
  "query"       : "queries"
  "ability"     : "abilities"
  "agency"      : "agencies"
  "movie"       : "movies"

  "archive"     : "archives"

  "index"       : "indices"

  "wife"        : "wives"
  "safe"        : "saves"
  "half"        : "halves"

  "move"        : "moves"

  "salesperson" : "salespeople"
  "person"      : "people"

  "spokesman"   : "spokesmen"
  "man"         : "men"
  "woman"       : "women"

  "basis"       : "bases"
  "diagnosis"   : "diagnoses"
  "diagnosis_a" : "diagnosis_as"

  "datum"       : "data"
  "medium"      : "media"
  "stadium"     : "stadia"
  "analysis"    : "analyses"

  "node_child"  : "node_children"
  "child"       : "children"

  "experience"  : "experiences"
  "day"         : "days"

  "comment"     : "comments"
  "foobar"      : "foobars"
  "newsletter"  : "newsletters"

  "old_news"    : "old_news"
  "news"        : "news"

  "series"      : "series"
  "species"     : "species"

  "quiz"        : "quizzes"

  "perspective" : "perspectives"

  "ox"          : "oxen"
  "photo"       : "photos"
  "buffalo"     : "buffaloes"
  "tomato"      : "tomatoes"
  "dwarf"       : "dwarves"
  "elf"         : "elves"
  "information" : "information"
  "equipment"   : "equipment"
  "bus"         : "buses"
  "status"      : "statuses"
  "status_code" : "status_codes"
  "mouse"       : "mice"

  "louse"       : "lice"
  "house"       : "houses"
  "octopus"     : "octopi"
  "virus"       : "viri"
  "alias"       : "aliases"
  "portfolio"   : "portfolios"

  "vertex"      : "vertices"
  "matrix"      : "matrices"
  "matrix_fu"   : "matrix_fus"

  "axis"        : "axes"
  "testis"      : "testes"
  "crisis"      : "crises"

  "rice"        : "rice"
  "shoe"        : "shoes"

  "horse"       : "horses"
  "prize"       : "prizes"
  "edge"        : "edges"

  "cow"         : "kine"
  "database"    : "databases"

OrdinalNumbers =
  "-1" : "-1st"
  "-2" : "-2nd"
  "-3" : "-3rd"
  "-4" : "-4th"
  "-5" : "-5th"
  "-6" : "-6th"
  "-7" : "-7th"
  "-8" : "-8th"
  "-9" : "-9th"
  "-10" : "-10th"
  "-11" : "-11th"
  "-12" : "-12th"
  "-13" : "-13th"
  "-14" : "-14th"
  "-20" : "-20th"
  "-21" : "-21st"
  "-22" : "-22nd"
  "-23" : "-23rd"
  "-24" : "-24th"
  "-100" : "-100th"
  "-101" : "-101st"
  "-102" : "-102nd"
  "-103" : "-103rd"
  "-104" : "-104th"
  "-110" : "-110th"
  "-111" : "-111th"
  "-112" : "-112th"
  "-113" : "-113th"
  "-1000" : "-1000th"
  "-1001" : "-1001st"
  "0" : "0th"
  "1" : "1st"
  "2" : "2nd"
  "3" : "3rd"
  "4" : "4th"
  "5" : "5th"
  "6" : "6th"
  "7" : "7th"
  "8" : "8th"
  "9" : "9th"
  "10" : "10th"
  "11" : "11th"
  "12" : "12th"
  "13" : "13th"
  "14" : "14th"
  "20" : "20th"
  "21" : "21st"
  "22" : "22nd"
  "23" : "23rd"
  "24" : "24th"
  "100" : "100th"
  "101" : "101st"
  "102" : "102nd"
  "103" : "103rd"
  "104" : "104th"
  "110" : "110th"
  "111" : "111th"
  "112" : "112th"
  "113" : "113th"
  "1000" : "1000th"
  "1001" : "1001st"

Irregularities =
  'person' : 'people'
  'man'    : 'men'
  'child'  : 'children'
  'sex'    : 'sexes'
  'move'   : 'moves'

UnderscoreToHuman =
  "employee_salary" : "Employee salary"
  "employee_id"     : "Employee"
  "underground"     : "Underground"
  "emails.address"  : "Emails address"

testBothDirections = (singular, plural) ->
  test "#{singular} is pluralized to #{plural} and back again", ->
    equal Batman.helpers.inflector.pluralize(singular), plural
    equal Batman.helpers.inflector.singularize(plural), singular

QUnit.module 'Batman.Inflector pluralization and singularization',
test "singulars are pluralized to plurals", ->
  for singular, plural of SingularToPlural
    equal Batman.helpers.inflector.pluralize(singular), plural

test "irregular singulars are pluralized to plurals", ->
  for singular, plural of Irregularities
    equal Batman.helpers.inflector.pluralize(singular), plural

test "plurals are singularized to singulars", ->
  for singular, plural of SingularToPlural
    equal Batman.helpers.inflector.pluralize(singular), plural

test "irregular plurals are singularized to singulars", ->
  for singular, plural of Irregularities
    equal Batman.helpers.inflector.pluralize(singular), plural

QUnit.module 'Batman.Inflector ordinalization',
test "Inflector ordinalizes", ->
  for number, ordinalized of OrdinalNumbers
    equal Batman.helpers.inflector.ordinalize(number), ordinalized

test "radix is assumed to be base 10", ->
  equal Batman.helpers.inflector.ordinalize('010'), "10th"

test "allows for other radix values", ->
  equal Batman.helpers.inflector.ordinalize('010', 2), "2nd"

QUnit.module 'Batman.helpers humanization',
test "helpers humanize", ->
  for underscored, human of UnderscoreToHuman
    equal Batman.helpers.humanize(underscored), human

UncaptializedToCapitalized =
  "congratulations" : 'Congratulations'
  "you're the big winner" : "You're the big winner"
  "you win one US dollar" : "You win one US dollar"

QUnit.module 'Batman.helpers capitalization',
test 'capitalizes the first letter of the first word', ->
  for lowercased, capitalized of UncaptializedToCapitalized
    equal Batman.helpers.capitalize(lowercased), capitalized

UncapitalizedToTitleized =
  "congratulations" : 'Congratulations'
  "you're the big winner" : "You're The Big Winner"
  "you win one US dollar" : "You Win One US Dollar"

QUnit.module 'Batman.helpers titleization',
test 'capitalizes the first letter of each word', ->
  for lowercased, titleized of UncapitalizedToTitleized
    equal Batman.helpers.titleize(lowercased), titleized

ArrayToSentence = [
  {array: ["Paris"], sentence: "Paris"}
  {array: ["Paris", "New York"], sentence: "Paris and New York"}
  {array: ["Paris", "New York", "Tokyo"], sentence: "Paris, New York, and Tokyo"}
  {array: ["Paris", "New York", "Tokyo", "Abu Dhabi"], sentence: "Paris, New York, Tokyo, and Abu Dhabi"}
]

QUnit.module 'Batman.helpers toSentence',
test 'joins the words with commas/"and"', ->
 for {array, sentence} in ArrayToSentence
  equal Batman.helpers.toSentence(array), sentence
