import Mode from './mode.js';

const $ = Symbol .for;

export default class Design extends Mode {

$kit ( play, name ) { this .oscilla ( $ ( 'kit' ), name ) }

$on () { this .status = 144 }
$off () { this .status = 128 }

unison = 1

$unison ( play, partials ) { this .unison = parseInt ( partials ) || 1 }

[ '$+' ] ( play, type = 'oscillator', name, channel ) {

const design = this;
const { oscilla, unison } = design;
const instrument = design .instrument = [];

for ( let partial = 0; partial < unison; partial++ )
instrument [ partial ] = oscilla ( $ ( 'instrument' ), name, channel );

delete design .status;

design .unison = 1

return instrument .map ( ( instrument, partial ) => `i ${ instrument .instance } 0 -1 "${ type }" ${ instrument .channel } ${ partial } 0` ) .join ( '\n' );

}

$_director ( play, ... order ) {

if ( ! order .length )
return;

const [ parameter, value ] = order;
const { instrument, status } = this;

if ( parameter === undefined || value === undefined )
throw "#error #design Neither the parameter nor value can be undefined."

return instrument .map ( instrument => [ ... status ? [ status ] : [ 144, 128 ] ]
.map ( status => `i ${ instrument .instance } 0 -1 176 ${ status } "${ parameter }" ${ value }` )
.join ( '\n' ) )
.join ( '\n' );

}

};
