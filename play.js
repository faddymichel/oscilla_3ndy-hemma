import Oscilla from './oscilla.js';
import Scenarist from 'scenarist.dev';
import { createReadStream, createWriteStream } from 'fs';
import Shell from 'shell.scenarist.dev';

let [ input, output ] = process .argv .slice ( 2 );

input = 'design.oscilla';

const play = Scenarist ( new Oscilla );

Shell .start ( {

play,
lineByLine: true,
input: createReadStream ( input, 'utf8' ),
output: createWriteStream ( output, 'utf8' )

} );
