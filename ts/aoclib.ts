import * as fs from 'fs';
import * as readline from 'readline';

export const getConsoleIntf = () => (
    readline.createInterface({
        input: process.stdin,
        output: process.stdout,
    })
);

export const readStdin = () => {
    return fs.readFileSync(0, 'utf-8');
}


