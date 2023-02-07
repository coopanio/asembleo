import * as ujs from "@rails/ujs"
import * as activestorage from "@rails/activestorage"
import "chartkick/chart.js"
import chartkick from "chartkick"

ujs.start()
activestorage.start()

globalThis.Chartkick = chartkick