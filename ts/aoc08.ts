import * as _ from 'lodash';
import { readStdin } from './aoclib';

type Node = {
    metadata: Array<number>,
    children: Array<Node>,
};

const parseNode = (stream: Iterator<number>): Node => {
    const childCount = stream.next().value;
    const metadataCount = stream.next().value;
    const children = _.times(childCount, () => parseNode(stream));
    const metadata = _.times(metadataCount, () => stream.next().value);
    return { metadata, children };
};

const sumMetadata = (node: Node): number => {
    const childSums = _.map(node.children, sumMetadata);
    return _.sum(node.metadata) + _.sum(childSums);
};

const main = () => {
    const input = readStdin();
    const stream = _.map(input.split(' '), v => Number(v));
    const node = parseNode(stream[Symbol.iterator]());
    const answer = sumMetadata(node);
    console.log(answer);
};

main();
