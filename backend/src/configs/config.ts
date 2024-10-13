import * as devConfig from './dev.config.json';
import * as prodConfig from './prod.config.json';

let config: any;

if (process.env.NODE_ENV === 'prod') {
  config = prodConfig;
} else if (process.env.NODE_ENV === 'dev') {
  config = devConfig;
} else {
    throw "Unsupported Environment"
}

export {
    config
}