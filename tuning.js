import Mode from './mode.js';

const $ = Symbol .for;

export default class Tuning extends Mode {

$maqam ( play, name, ... scale ) {

if ( scale .length !== 7 )
throw `#error #tuning A Maqam must have 7 pitch levels, found ${ scale .length }.`;

scale = scale .map ( ( detune, index ) => ( 2 ** ( ( parseInt ( detune ) + Tuning .step [ index ] * 2 ) / 24 ) ) );

return `i "maqam" 0 0 "${ name }" ${ scale .join ( ' ' ) }`;

}

$keyboard ( play, ... keys ) {

if ( keys .length !== 7 )
throw `#error #tuning A Keyboard must contain 7 keys, found ${ keys .length }.`;

const { oscilla } = this;

return keys .map ( ( key, index ) => {

let number = Tuning .step [ index ];

oscilla ( $ ( 'keyboard' ), key, number );

return `; Key: ( ${ key } ), Number ( ${ number } )`;

} ) .join ( '\n' );

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
