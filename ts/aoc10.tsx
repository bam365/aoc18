import * as _ from 'lodash';
import * as React from 'react';
import * as ReactDOM from 'react-dom';

type Point = {
    x: number, 
    y: number,
};

type PixelAnimation = {
    position: Point,
    velocity: Point,
}

const animationRegex = /position=<\s*(-?\d+),\s*(-?\d+)>\s+velocity=<\s*(-?\d+),\s*(-?\d+)>/

const parsePixelAnimation = (line: string): PixelAnimation | null => {
    const match = animationRegex.exec(line);
    console.log(line)
    if (match) {
        console.log(`point: ${match[1]},${match[2]}  ${match[3]},${match[4]}`);
        return {
            position: { x: parseInt(match[1]), y: parseInt(match[2]) },
            velocity: { x: parseInt(match[3]), y: parseInt(match[4]) },
        };
    } else {
        return null;
    }
}

const projectAnimation = (data: PixelAnimation[], seconds: number): Point[] => (
    _.map(data, p => ({
        x: p.position.x + p.velocity.x * seconds,
        y: p.position.y + p.velocity.y * seconds,
    }))
);

const parsePointText = (data: string): Array<PixelAnimation> | null => {
    const lines =  _.map(_.split(data, '\n'), _.trimEnd);
    let ret = [];
    for (let i = 0; i < lines.length; i++) {
        const point = parsePixelAnimation(lines[i]);
        if (point) {
            ret.push(point);
        }
    }
    return ret;
}

const findMinSeconds = (data: PixelAnimation[], width: number, height: number): number => {
    const xBound = width / 2;
    const yBound = height / 2;
    const timeToBox = (pixel: PixelAnimation): number => {
        const x = (Math.abs(pixel.position.x) - xBound) / Math.abs(pixel.velocity.x);
        const y = (Math.abs(pixel.position.y) - yBound) / Math.abs(pixel.velocity.y);
        return  x > y ? x : y;
    }
    return _.floor(_.max(_.map(data, timeToBox)) || 0);
}


interface AnimationUIProps {
    animationData: Array<PixelAnimation>
}

interface AnimationUIState {
    minSeconds: number,
    maxSeconds: number,
    seconds: number,
}

const CANVAS_WIDTH = 800;
const CANVAS_HEIGHT = 600;

class AnimationUI extends React.Component<AnimationUIProps, AnimationUIState> {

    constructor(props: AnimationUIProps) {
        super(props);
        this.state = this.getInitialState(props)
    }

    getInitialState(props: AnimationUIProps): AnimationUIState {
        const minSeconds = findMinSeconds(props.animationData, CANVAS_WIDTH, CANVAS_HEIGHT);
        return {
            minSeconds,
            maxSeconds: minSeconds + 100,
            seconds: minSeconds,
        }
    }

    setSeconds(seconds: number) {
        this.setState({ seconds });
        this.redrawCanvas();
    }

    onChangeMaxSeconds = (ev: React.FormEvent<HTMLInputElement>) => {
        const maxSeconds = parseInt(ev.currentTarget.value);
        if (this.state.seconds > maxSeconds) {
            this.setSeconds(maxSeconds);
        }
        this.setState({ maxSeconds });
    }

    onChangeSeconds = (ev: React.FormEvent<HTMLInputElement>) => {
        const seconds = parseInt(ev.currentTarget.value);
        this.setSeconds(seconds);
    }

    redrawCanvas() {
        const canvas = this.refs.canvas as HTMLCanvasElement | null;
        if (!canvas) {
            return;
        }

        const pointToImageIndex = (point: Point) => (
            (point.x + (point.y * canvas.width)) * 4
        );
        const points = projectAnimation(this.props.animationData, this.state.seconds);
        const ctx = canvas.getContext("2d") as CanvasRenderingContext2D;
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        const canvasData = ctx.getImageData(0, 0, canvas.width, canvas.height);
        for (var i = 0; i < points.length; i++) {
            let iImg = pointToImageIndex(points[i]); 
            canvasData.data[iImg + 2] = 255;
            canvasData.data[iImg + 3] = 255;
        }
        ctx.putImageData(canvasData, 0, 0);
    }

    renderCanvas() {
        return (
            <canvas 
                ref="canvas"
                width={CANVAS_WIDTH}
                height={CANVAS_HEIGHT}
                style={{border: '1px solid grey'}}
            >
            </canvas>
        )
    }

    renderTimeSelect() {
        return (
            <div>
                <span>{this.state.minSeconds}</span>
                <input
                    type="range"
                    value={this.state.seconds}
                    onChange={this.onChangeSeconds}
                    min={this.state.minSeconds}
                    max={this.state.maxSeconds}
                    step={1}
                />
                <input 
                    type="number"
                    value={this.state.maxSeconds}
                    onChange={this.onChangeMaxSeconds}
                    min={this.state.minSeconds}
                    step={1}
                />
            </div>
        );
    }

    render() {
        return (
            <div>
                <div>
                    {this.renderCanvas()}
                </div>
                <div>
                    {this.renderTimeSelect()}
                </div>
            </div>
        );
    }
}

interface AppState {
    pointText: string,
    errorMsg: string | null,
    animationData: Array<PixelAnimation> | null,
}


class App extends React.Component<{}, AppState> {
    constructor(props: {}) {
        super(props);
        this.state = this.getInitialState();
    }

    getInitialState(): AppState {
        return {
            pointText: '',
            errorMsg: null,
            animationData: null
        }
    }

    handleTextChange = (ev: React.FormEvent<HTMLTextAreaElement>) => {
        this.setState({
            pointText: ev.currentTarget.value,
        })
    }

    handleGraphClick = () => {
        const animationData = parsePointText(this.state.pointText);
        this.setState({ animationData });
        if (!animationData) {
            this.setState({
                errorMsg: 'Could not parse animation data',
            });
        }
    }

    renderPointTextInput() {
        return (
            <div>
                {this.state.errorMsg && (
                    <div>{`ERROR: ${this.state.errorMsg}`}</div>
                )}
                <textarea
                    className="pointText"
                    value={this.state.pointText}
                    onChange={this.handleTextChange}
                >
                </textarea>
                <div>
                    <button 
                        onClick={this.handleGraphClick}
                    >
                       Start Animation
                    </button>
                </div>
            </div>
        );
    }

    renderAnimationUI(data: PixelAnimation[]) {
        return (
            <div>
                <AnimationUI animationData={data} />
            </div>
        );
    }

    render() {
        if (this.state.animationData) {
            return this.renderAnimationUI(this.state.animationData)
        } else {
            return this.renderPointTextInput();
        }
    }
}


ReactDOM.render(<App />, document.getElementById('app'));
