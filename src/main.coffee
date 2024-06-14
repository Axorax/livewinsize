{ appWindow, LogicalSize } = window.__TAURI__.window
{ open } = window.__TAURI__.shell

# Selectors

s =
  h1: document.querySelector("main h1")
  h2: document.querySelector("main h2")
  h3: document.querySelector("main h3")
  note: document.querySelector(".note")
  search: document.querySelector(".search")
  btn:
    unit: document.querySelector(".group.unit button")
    donate: document.querySelector(".donate.button")
  input:
    height: document.querySelector(".size .height")
    width: document.querySelector(".size .width")
  dropcoverUnitDiv: document.querySelector(".dropcover.unit .content")

# Conversion Variables

unit = "pixels"
ppi = 96

units =
  pixels: [(m) -> m, (m) -> m]
  inches: [(m) -> m / ppi, (m) -> m * ppi]
  centimeters: [(m) -> m * 0.0264583333, (m) -> m / 0.0264583333]
  kilometers: [(m) -> m * 0.0264583333 * 1e-5, (m) -> m / 1e-5 / 0.0264583333]
  feet: [(m) -> (m / ppi) * 0.0833333, (m) -> (m * ppi) / 0.0833333]
  metres: [(m) -> m * 0.0002645833, (m) -> m / 0.0002645833]
  yards: [(m) -> m * 0.00028935181539808, (m) -> m / 0.00028935181539808]
  miles: [(m) -> m * 1.6440444056709e-7, (m) -> m / 1.6440444056709e-7]
  alens: [(m) -> m * 0.0004455929657212, (m) -> m / 0.0004455929657212]
  angstroms: [(m) -> m * 2645833, (m) -> m / 2645833]
  attometers: [(m) -> m * 2.645833e14, (m) -> m / 2.645833e14]
  bicrons: [(m) -> m * 264583300, (m) -> m / 264583300]
  blocks: [(m) -> m * 3.2880888113418e-6, (m) -> m / 3.2880888113418e-6]
  chains: [(m) -> m * 1.3152355245367e-5, (m) -> m / 1.3152355245367e-5]
  cubits: [(m) -> m * 0.00057870363079615, (m) -> m / 0.00057870363079615]
  decameters: [(m) -> m * 2.645833e-5, (m) -> m / 2.645833e-5]
  decimeters: [(m) -> m * 0.002645833, (m) -> m / 0.002645833]
  ems: [(m) -> m * 0.0627343677238, (m) -> m / 0.0627343677238]
  furlongs: [(m) -> m * 1.3152355245367e-6, (m) -> m / 1.3152355245367e-6]
  hands: [(m) -> m * 0.0026041663385827, (m) -> m / 0.0026041663385827]
  hectometers: [(m) -> m * 2.645833e-6, (m) -> m / 2.645833e-6]
  "light-seconds": [(m) -> m * 8.8253268845897e-13, (m) -> m / 8.8253268845897e-13]
  micromicrons: [(m) -> m * 264583300, (m) -> m / 264583300]
  petameters: [(m) -> m * 2.645833e-19, (m) -> m / 2.645833e-19]
  perch: [(m) -> m * 5.2609420981468e-5, (m) -> m / 5.2609420981468e-5]
  nanometers: [(m) -> m * 264583.3, (m) -> m / 264583.3]
  mils: [(m) -> m * 10.416665354331, (m) -> m / 10.416665354331]
  lines: [(m) -> m * 0.12599204761905, (m) -> m / 0.12599204761905]
  hvats: [(m) -> m * 0.000139512551818, (m) -> m / 0.000139512551818]
  gigameters: [(m) -> m * 2.645833e-13, (m) -> m / 2.645833e-13]
  fermi: [(m) -> m * 264583300000, (m) -> m / 264583300000]
  spans: [(m) -> m * 0.0011574072615923, (m) -> m / 0.0011574072615923]
  thou: [(m) -> m * 10.416665354331, (m) -> m / 10.416665354331]
  zolls: [(m) -> m * 0.010416665354331, (m) -> m / 0.010416665354331]

# Functions

resizeFromInput = ->
  await appWindow.setSize new LogicalSize(
    units[unit][1](Number(s.input.width.value))
    units[unit][1](Number(s.input.height.value))
  )
  setSizeInUI()

resizeFromEvent = (e, t, el) ->
  if e.keyCode == 13
    s.note.style.display = "none"
    el.blur()
    el.innerText = el.innerText.replaceAll(" ", "")
    if t == "w"
      await appWindow.setSize new LogicalSize(
        units[unit][1](Number(el.innerText))
        units[unit][1](Number(s.h1.querySelector(".height").innerText))
      )
    else
      await appWindow.setSize new LogicalSize(
        units[unit][1](Number(s.h1.querySelector(".width").innerText))
        units[unit][1](Number(el.innerText))
      )
  else
    s.note.style.display = "block"

focusLost = ->
  s.note.style.display = "none"
  w = s.h1.querySelector(".width")
  h = s.h1.querySelector(".height")
  if w.innerText.trim() == ""
    w.innerText = units[unit][0](window.innerWidth)
  else if h.innerText.trim() == ""
    h.innerText = units[unit][0](window.innerHeight)

onlyNumbers = (event, input) ->
  val = input.value or input.innerText
  key = event.key
  
  if isNaN(key) and key not in ["Backspace", "Enter", "."]
    event.preventDefault()
    return

  if key == "."
    if val.includes(".")
      event.preventDefault()
      return
    if val.startsWith(".") or val.endsWith(".")
      input.value = val.replace(/\./g, "")
    if input.selectionStart == 0
      input.value = "0" + val
      setTimeout ->
        input.setSelectionRange(2, 2)
      , 0

  if val.startsWith(".") or val.endsWith(".")
    input.value = val.replace(/\./g, "")

formatNumber = (num) ->
  if Number.isInteger(num) then num.toString() else num.toFixed(3)

setPPIFromInput = (e) ->
  ppi = e.value
  setSizeInUI()

toggleDropcover = (t) ->
  e = document.querySelector(".dropcover" + t)
  b = document.querySelector(".button-group")
  if e.style.display == "flex"
    e.style.display = "none"
    b.style.display = "flex"
  else
    e.style.display = "flex"
    b.style.display = "none"

setSizeInUI = ->
  h = units[unit][0](window.innerHeight)
  w = units[unit][0](window.innerWidth)
  s.h1.querySelector(".width").innerText = formatNumber(w)
  s.h1.querySelector(".height").innerText = formatNumber(h)
  s.input.height.value = formatNumber(h)
  s.input.width.value = formatNumber(w)

setUnit = (e, u) ->
  selected = document.querySelector(".selected")
  symbol = " ●"
  toggleDropcover(".unit")
  unit = u
  setSizeInUI()
  selected.innerText = selected.innerText.replace(symbol, "")
  e.innerText = e.innerText + symbol
  s.btn.unit.innerText = e.innerText.replace(symbol, "") + " ▾"
  selected.classList.remove("selected")
  e.classList.add("selected")
  s.h2.innerText = e.innerText.replace(symbol, "")

setSizeInUI()

# Make UI For Unit Selection

for name, i in Object.keys(units)
  button = document.createElement('button')
  button.textContent = "#{name} #{if i == 0 then ' ●' else ''}"
  button.classList.add('selected') if i == 0
  button.addEventListener 'click', ->
    setUnit(@, name)
  s.dropcoverUnitDiv.appendChild(button)

# Event Listeners

searchDone = null

window.onresize = ->
  setSizeInUI()

s.btn.unit.onclick = ->
  toggleDropcover(".unit")

s.btn.donate.onclick = ->
  open("https://patreon.com/axorax")

s.search.oninput = ->
  clearTimeout(searchDone)
  searchDone = setTimeout ->
    exists = false

    if s.dropcoverUnitDiv.querySelector("h2")
      s.dropcoverUnitDiv.querySelector("h2").remove()

    s.dropcoverUnitDiv.querySelectorAll("button").forEach (btn) ->
      if btn.innerText.toLowerCase().includes(s.search.value.toLowerCase())
        btn.style.display = "block"
        exists = true
      else
        btn.style.display = "none"

    if exists == false
      s.dropcoverUnitDiv.innerHTML += "<h2 style='margin-top: 1rem;font-size: 1rem;color: #fff;text-align: center;'>No results found!</h2>"
  , 500

document.querySelectorAll('div[contenteditable="true"]').forEach (element) ->
  element.addEventListener 'keypress', (event) ->
    onlyNumbers event, this

document.querySelectorAll('input:not(.search)').forEach (element) ->
  element.addEventListener 'keypress', (event) ->
    onlyNumbers event, this

document.querySelector('.group.ppi input').addEventListener 'input', (event) ->
  setPPIFromInput this

document.querySelector('button.size.button').addEventListener 'click', (event) ->
  resizeFromInput()

document.querySelectorAll('main .width, main .height').forEach (element) ->
  element.addEventListener 'blur', (event) ->
    focusLost()

document.querySelector('main .width').addEventListener 'keydown', (event) ->
  resizeFromEvent event, 'w', this

document.querySelector('main .height').addEventListener 'keydown', (event) ->
  resizeFromEvent event, 'h', this

document.querySelector('.dropcover .back').addEventListener 'click', (event) ->
  toggleDropcover('.unit')