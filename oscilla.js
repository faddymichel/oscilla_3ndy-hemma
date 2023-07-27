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

room = new Map

$_kit ( play, name ) {

this .kit = [];
this .kit .equipment = new Map;

if ( name ?.length )
this .room .set ( name, this .kit );

}

instance = 0

$_instrument ( play, name ) {

const { kit } = this;
const instrument = { instance: 13 + ( ++this .instance ) % 1000 / 1000 };

kit .push ( instrument );

if ( name ?.length )
kit .equipment .set ( name, instrument );

return instrument;

}

$_setKit ( play, name ) { 

this .kit = this .room .get ( name ) }

$_getKit () { return this .kit }

keyboard = new Map

get $_keyboardSize () { return this .keyboard .size }

$_keyboard ( play, key, number ) { this .keyboard .set ( key, number ) }

$_noteNumber ( play, key ) { return this .keyboard .get ( key ) }

$forever () { return 'i "forever" 0 1' }

};
