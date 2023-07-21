import Design from './design.js';
import Tuning from './tuning.js';
import Score from './score.js';

const $ = Symbol .for;

export default class Oscilla {

setup = {

design: new Design,
tuning: new Tuning,
score: new Score

}

$_producer ( play, { stamp } ) { this .stamp = stamp }

[ '$>' ] ( play, mode ) {

if ( mode === undefined )
throw "#error No mode is specified to switch to.;";

const oscilla = this;
const { setup } = oscilla;

if ( ! setup [ mode ] )
throw `#error '${ mode }' is not an existing mode.`

oscilla .$_director = setup [ mode ];

return `s ; #mode ${ mode }`;

}

kit = []

$_instrument () { return this .kit [ this .kit .push ( 13 + ( this .kit .length + 1 ) % 1000000 / 1000000 ) - 1 ] }

$_kit () { return this .kit }
keyboard = new Map

get $_keyboardSize () { return this .keyboard .size }

$_keyboard ( play, key, number ) { this .keyboard .set ( key, number ) }

$_noteNumber ( play, key ) { return this .keyboard .get ( key ) }

};
