import Mode from './mode.js';

const $ = Symbol .for;

export default class Score extends Mode {

$maqam ( play, name ) {

return this .oscilla ( $ ( 'kit' ) )
. map ( instrument => `i ${ instrument } 0 -1 192 "${ name }"` )
.join ( '\n' );

}

time = 0
velocity = 53
octave = 5

$octave ( play, level ) { this .octave = level }

$tempo ( play, bpm ) {

return `; Setting tempo to ${ bpm }bpm
t 0 ${ bpm }`;

}

$_director ( play, ... notation ) {

if ( ! notation .length )
return [ `i "out" 0 ${ this .time }` ];

const score = this;
const { oscilla, octave, velocity } = score;
const note = notation .shift () .split ( '' );
let key, duration;

switch ( note .length ) {

case 1:

duration = 1;
[ key ] = note;

break;

case 2:

[ duration, key ] = note;

break;

default:

throw '#error Invalid note syntax';

}

const number = oscilla ( $ ( 'noteNumber' ), key );

return [ score .note ( parseInt ( duration ), number + octave * 12, velocity ), ... play ( ... notation ) ];

}

note ( duration, number, velocity ) {

const score = this;
const on = score .time;
const off = score .time = on + duration;

return score .oscilla ( $ ( 'kit' ) )
. map ( instrument => `; MIDI Note Number (${ number }) on for ${ duration } beats with Velocity (${ velocity })
i ${ instrument } ${ on } -1 144 ${ number } ${ velocity } 0
i ${ instrument } ${ off } -1 128 ${ number } 0 0` )
.join ( '\n' );

}

};
