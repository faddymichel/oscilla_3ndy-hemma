import Design from './design.js';
import Tuning from './tuning.js';
import Score from './score.js';

const $ = Symbol .for;

export default class Oscilla {

constructor () {

this .kit = [];
this .kit .equipment = new Map;

}


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

$_instrument ( play, name ) {

const { kit } = this;
const instrument = { instance: 13 + ( kit .length + 1 ) % 1000 / 1000 };

kit .push ( instrument );

if ( name ?.length )
kit .equipment .set ( name, instrument );

return instrument;

}

$_kit () { return this .kit }

keyboard = new Map

get $_keyboardSize () { return this .keyboard .size }

$_keyboard ( play, key, number ) { this .keyboard .set ( key, number ) }

$_noteNumber ( play, key ) { return this .keyboard .get ( key ) }

};
