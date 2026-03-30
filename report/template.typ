#let bigit(body) = text(size: 1.25em, weight: "bold", fill: rgb(255, 144, 144))[#body]

#let project_style(body) = {
let background_color = rgb(27, 25, 25)




// 2. Apply the page background

set page(fill: background_color)
show table: set text(size: 10pt) // Shrinks table text only
show table: it => {
// This nested show rule only exists inside the scope of a table
show raw: r => {
if r.block {
r
} else {

show "/": "/\u{200B}"

show "_": "_\u{200B}"

r

}

}

it // This "it" tells Typst to actually show the table now

}







// show raw: set text(font: "Cascadia Code")



// Reset raw blocks to the same size as normal text,

// but keep inline raw at the reduced size.

show raw.where(block: true): set text(1em / 0.8)

set raw(theme: "res/gruvbox.tmTheme")



show table: set par(justify: false)

set table(

inset: 7pt,

stroke: 0.6pt + white,

align: center + horizon, // Centers text horizontally AND vertically

)



// 3. Set the default text color

set text(fill: white)



set page(

paper: "us-letter",

margin: (x: 2cm, y: 2.5cm),

numbering: "1",

)



set text(

// font: "linux libertine",

size: 12pt,

)



// Adjust line spacing (leading) here

set par(

leading: 1em, // Space between lines

justify: true, // Optional: makes text flush on both sides

spacing: 2em // Optional: space between separate paragraphs

)



// Title Page






// --- Settings for Headings ---

set heading(numbering: "1.1")



show heading.where(level: 1): it => {

pagebreak(weak: true)

v(2em)

it

v(1em)

}



show heading.where(level: 2): it => {

v(1em)

it

v(1em)

}
body
}