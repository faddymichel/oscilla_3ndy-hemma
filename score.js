import Mode from './mode.js';

const $ = Symbol .for;

export default class Score extends Mode {

$maqam ( play, name ) {

return this .oscilla ( $ ( 'kit' ) )
. map ( instrument => `i ${ instrument .instance } 0 -1 192 "${ name }"` )
.join ( '\n' );

}

time = 0
velocity = 53
octave = 5

$octave ( play, level ) { this .octave = parseInt ( level ) }

$tempo ( play, bpm ) {

return `; Setting tempo to ${ bpm }bpm
t 0 ${ bpm }`;

}

$_director ( play, ... notation ) {

const score = this;
const { oscilla, octave, velocity } = score;

return [

... notation .map ( note => {

let octave = 0;

if ( [ '-', '+' ] .includes ( note [ 0 ] ) ) {

octave += parseInt ( note .slice ( 0, 2 ) );
note = note .slice ( 2 );

}

console .log ( typeof score .octave, typeof octave );

let [ key, duration ] = note .split ( '/' );
const number = oscilla ( $ ( 'noteNumber' ), key );

return score .note ( 1 / parseInt ( duration || 1 ), number + ( score .octave + octave ) * 12 );

} ),
this .time ? `i "out" 0 ${ this .time }` : undefined

] .join ( '\n' );

}

note ( duration, number ) {

const score = this;
const on = score .time;
const off = score .time = on + duration;

return score .oscilla ( $ ( 'kit' ) )
. map ( instrument => `; MIDI Note Number (${ number }) on for ${ duration } beats with Velocity (${ instrument .velocity || score .velocity })
i ${ instrument .instance } ${ on } -1 144 ${ number } ${ instrument .velocity || score .velocity } 0
i ${ instrument .instance } ${ off } -1 128 ${ number } 0 0` )
.join ( '\n' );

}

$velocity ( play, value, instrument ) {

const score = this;
const { oscilla } = score;
const kit = oscilla ( $ ( 'kit' ) );

( instrument ?.length ? kit .equipment .get ( instrument ) : score ) .velocity = value;

}

$repeat ( play, times, ... notation ) {

times = parseInt ( times );

let score = `; Repeating this part for ${ times } times\n`;

for ( let repeats = 0; repeats < times; repeats++ )
score += `; Repeat #${ repeats + 1 }
${ play ( ... notation ) }
`;

return score += "; Finished repeating";
}

};
