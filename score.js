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

$_director ( play, ... notation ) {

const score = this;
const { oscilla, velocity } = score;

return notation .map ( note => {

let [ key, duration ] = note .split ( '/' );
const number = oscilla ( $ ( 'noteNumber' ), key );

duration = 1 / parseInt ( duration || 1 );

if ( isNaN ( number ) ) {

score .time += duration;

return `; Rest for ${ duration } beats`;

}

const on = score .time;
const off = score .time = on + duration;

return score .oscilla ( $ ( 'getKit' ) )
. map ( instrument => `; MIDI Note Number (${ number }) on for ${ duration } beats with Velocity (${ instrument .velocity || score .velocity })
i ${ instrument .instance } ${ on } -1 144 ${ number } ${ instrument .velocity || score .velocity } 0
i ${ instrument .instance } ${ off } -1 128 ${ number } 0 0` )
.join ( '\n' );

} ) .join ( '\n' );

}

note ( duration, number ) {

const score = this;
const on = score .time;
const off = score .time = on + duration;

return score .oscilla ( $ ( 'getKit' ) )
. map ( instrument => `; MIDI Note Number (${ number }) on for ${ duration } beats with Velocity (${ instrument .velocity || score .velocity })
i ${ instrument .instance } ${ on } -1 144 ${ number } ${ instrument .velocity || score .velocity } 0
i ${ instrument .instance } ${ off } -1 128 ${ number } 0 0` )
.join ( '\n' );

}

$velocity ( play, value, instrument ) {

const score = this;
const { oscilla } = score;
const kit = oscilla ( $ ( 'getKit' ) );

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

$out () {

return this .time ? [

... this .oscilla ( $ ( 'output' ) ),
`i "out" 0 ${ this .time }`

] .join ( '\n' ) : undefined;

}

};
