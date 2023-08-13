import Mode from './mode.js';

const $ = Symbol .for;

export default class Score extends Mode {

$maqam ( play, name ) {

return this .oscilla ( $ ( 'getKit' ) )
. map ( instrument => `i ${ instrument .instance } 0 -1 192 "${ name }"` )
.join ( '\n' );

}

$kit ( play, name ) {

this .oscilla ( $ ( 'setKit' ), name );

return `; Kit (${ name }) is currently in use`;

}

time = 0

$time ( play, value ) { this .time = parseInt ( value ) }

velocity = 53
$tempo ( play, bpm ) {

return `; Setting tempo to ${ bpm }bpm
t 0 ${ bpm }`;

}

part = []

$_director ( play, ... phrase ) {

if ( ! phrase .length )
return;

this .part .push ( phrase );

}

$_part ( play ) {

const { part, repeats } = this;
const score = [];

while ( this .repeats-- > 0 )
score .push (

`; Repeat #${ repeats - this .repeats }`,
part .map ( phrase => play ( $ ( 'phrase' ), phrase ) ) .join ( '\n' )

);

return score .join ( '\n' );

}

$_phrase ( play, phrase ) { return phrase .map ( note => play ( $ ( 'note' ), note ) ) .join ( '\n' ) }

$_note ( play, note ) {

const score = this;
const { oscilla, velocity } = score;
let [ key, duration ] = note .split ( '/' );
const number = oscilla ( $ ( 'noteNumber' ), key );

duration = 1 / parseInt ( duration || 1 );

if ( number === -1 ) {

score .time += duration;

return `; Rest for ${ duration } beats`;

}

const on = score .time;
const off = score .time = on + duration;

return score .oscilla ( $ ( 'getKit' ) )
.map ( instrument => `; MIDI Note Number (${ number }) on for ${ duration } beats with Velocity (${ instrument .velocity || score .velocity })
i ${ instrument .instance } ${ on } -1 144 ${ number } ${ instrument .velocity || score .velocity } 0
i ${ instrument .instance } ${ off } -1 128 ${ number } 0 0` )
.join ( '\n' );

}

repeats = 0;

[ '$*' ] ( play, repeats ) {

repeats = parseInt ( repeats )

if ( isNaN ( repeats ) )
throw `#score Invalid number of repeats, found: ${ repeats }.`;

let score = play ( $ ( 'part' ) );

this .part = [];
this .repeats = repeats;

if ( repeats > 0 )
score += `; Repeating this part for ${ this .repeats = parseInt ( repeats ) } times`;

if ( score ?.length )
return score;

}

$velocity ( play, value, instrument ) {

const score = this;
const { oscilla } = score;
const kit = oscilla ( $ ( 'getKit' ) );

( instrument ?.length ? kit .equipment .get ( instrument ) : score ) .velocity = value;

}

$_end ( play ) {

const score = [];
const part = play ( $ ( 'part' ) );

if ( part ?.length )
score .push ( part );

if ( this .time )
score .push (

'; Starting audio channels and final output destination.',
... this .oscilla ( $ ( 'output' ) ),
`i "out" 0 ${ this .time }`,
'; Finished scoring.'

);

return score .join ( '\n' );

}

};
