import Oscilla from './oscilla.js';
import Scenarist from 'scenarist.dev';
import { createReadStream, createWriteStream } from 'fs';
import Shell from 'shell.scenarist.dev';

let argv = process .argv .slice ( 2 );
let input, output;

switch ( argv .length ) {

case 1: [ output ] = argv; break;
case 2: [ input, output ] = argv; break;

default:

console .error ( '#error Illegal command arguments' );

process .exit ( -1 );

}

input = 'design.oscilla';

const play = Scenarist ( new Oscilla );

Shell .start ( {

play,
lineByLine: true,
input: createReadStream ( input, 'utf8' ),
output: createWriteStream ( output, 'utf8' )

} );
