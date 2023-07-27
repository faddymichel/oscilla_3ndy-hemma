import Mode from './mode.js';

const $ = Symbol .for;

export default class Design extends Mode {

$kit ( play, name ) { this .oscilla ( $ ( 'kit' ), name ) }

$on () { this .status = 144 }
$off () { this .status = 128 }

[ '$+' ] ( play, type = 'oscillator', name ) {

const design = this;
const { oscilla } = design;
const instrument = design .instrument = oscilla ( $ ( 'instrument' ), name );

delete design .status;

return `i ${ instrument .instance } 0 -1 "${ type }" 0 0 0`;

}

$_director ( play, ... order ) {

if ( ! order .length )
return;

const [ parameter, value ] = order;
const { instrument, status } = this;

if ( parameter === undefined || value === undefined )
throw "#error #design Neither the parameter nor value can be undefined."

return [ ... status ? [ status ] : [ 144, 128 ] ]
.map ( status => `i ${ instrument .instance } 0 -1 176 ${ status } "${ parameter }" ${ value }` )
.join ( '\n' );

}

};
