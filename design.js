import Mode from './mode.js';

const $ = Symbol .for;

export default class Design extends Mode {

$on () { this .status = 144 }
$off () { this .status = 128 }

[ '$+' ] ( play, type = 'oscillator' ) {

const design = this;
const { oscilla } = design;
const instrument = design .instrument = oscilla ( $ ( 'instrument' ) );

return `i ${ instrument } 0 -1 "${ type }" 0 0 0`;

}

$_director ( play, ... order ) {

if ( ! order .length )
return;

const [ parameter, value ] = order;
const { instrument, status } = this;

if ( parameter === undefined || value === undefined )
throw "#error #design Neither the parameter nor value can be undefined."

return [ ... status ? [ status ] : [ 144, 128 ] ]
.map ( status => `i ${ instrument } 0 -1 176 ${ status } "${ parameter }" ${ value }` )
.join ( '\n' );

}

};
