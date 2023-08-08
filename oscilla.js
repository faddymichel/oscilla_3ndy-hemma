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

[ '$>' ] ( play, mode, page ) {

if ( mode === undefined )
throw "#error No mode is specified to switch to.;";

const oscilla = this;
const { setup } = oscilla;

if ( ! setup [ mode ] )
throw `#error '${ mode }' is not an existing mode.`

oscilla .$_director = setup [ mode ];

return {

page,
script: `s ; #mode ${ mode }`

};

}


studio = new Map

$_kit ( play, name ) {

this .kit = [];
this .kit .equipment = new Map;

if ( name ?.length )
this .studio .set ( name, this .kit );

}

output = new Map

$_output () {

const output = [];

this .output .forEach ( channel => output .push ( `i "channel" 0 -1 ${ channel }` ) );

return output;

}

instance = 0

$_instrument ( play, name, channel ) {

const { output, kit } = this;
const instrument = { instance: 13 + ( ++this .instance ) % 1000000 / 1000000 };

kit .push ( instrument );

if ( name ?.length )
kit .equipment .set ( name, instrument );

if ( channel .length )
instrument .channel = output .get ( channel ) || output .set ( channel, output .size + 1 ) .get ( channel );

return instrument;

}

$_setKit ( play, name ) { 

this .kit = this .studio .get ( name ) }

$_getKit () { return this .kit }

keyboard = new Map

get $_keyboardSize () { return this .keyboard .size }

$_keyboard ( play, key, number ) { this .keyboard .set ( key, number ) }

$_noteNumber ( play, key ) { return this .keyboard .get ( key ) }

$forever () { return 'i "forever" 0 1' }

};
