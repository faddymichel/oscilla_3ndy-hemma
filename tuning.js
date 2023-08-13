import Mode from './mode.js';

const $ = Symbol .for;

export default class Tuning extends Mode {

$maqam ( play, name, ... scale ) {

if ( scale .length !== 7 )
throw `#error #tuning A Maqam must have 7 pitch levels, found ${ scale .length }.`;

scale = scale .map ( ( detune, index ) => ( 2 ** ( ( parseInt ( detune ) + Tuning .step [ index ] * 2 ) / 24 ) ) );

return `i "maqam" 0 0 "${ name }" ${ scale .join ( ' ' ) }`;

}

$octave ( play, octave, ... keys ) {

if ( isNaN ( parseInt ( octave ) ) )
throw `#tuning The 'octave' must be a number, found: ${ octave }.`;

octave = parseInt ( octave );

if ( keys .length !== 7 )
throw `#error #tuning A Keyboard must contain 7 keys, found ${ keys .length }.`;

const { oscilla } = this;

return `; Octave ( ${ octave } )
${ keys .map ( ( key, index ) => {

let number = Tuning .step [ index ] + octave * 12;

oscilla ( $ ( 'keyboard' ), key, number );

return `; Key: ( ${ key } ) Number ( ${ number } )`;

} ) .join ( '\n' ) }`;

}

$rest ( play, key ) {

this .oscilla ( $ ( 'keyboard' ), key, -1 );

}

static step = {

0: 0,

1: 2,

2: 4,
3: 5,

4: 7,

5: 9,

6: 11

}

};
